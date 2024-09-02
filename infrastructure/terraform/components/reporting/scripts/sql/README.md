# NHS Notify Reporting Tables

## Ingestion Tables

### request_item_status

A projection containing one row per request item.

Each row corresponds to the latest state of each request item in the system, with the following fields available:

    clientid
    campaignid
    sendinggroupid
    requestitemid
    requestrefid
    requestid
    nhsnumberhash
    createdtime
    completedtime
    completedcommunicationtypes
    failedcommunicationtypes
    status
    failedreason
    timestamp

### request_item_plan_completed_summary

An aggregated view of request item plans that have reached `DELIVERED` or `FAILED` status.

Dimensions:

    clientid
    campaignid
    sendinggroupid
    communicationtype
    supplier
    createddate
    completeddate
    status
    failedreason

Facts:

    Number of distinct request items

## Anatomy of an Ingestion Query

Ingestion queries follow a similar format in order to take account of the characteristics of the underlying transaction_history table.

These are simplified examples of the actual ingestion queries.

### Projection Queries

This query finds the latest update  of each object in the ingestion window. It then inserts a subset of columns into the reporting table if the primary key is not already present, or updates the row if already present but a later version is available.

    MERGE INTO <reporting_table> as target
    USING (
        SELECT * FROM (
            SELECT
            *,
            ROW_NUMBER() OVER (
                --Only select last update from sample window
                --Use completeddate as indicator of terminal state as a tie-breaker on identical timestamps
                partition BY requestitemid ORDER BY
                timestamp DESC,
                length(coalesce(completeddate, '')) DESC
            ) AS rownumber
            FROM (
                SELECT
                    --Primary key for matching
                    requestitemid,

                    --Data column(s)
                    status,

                    --Timestamp partitioning/ordering columns
                    completeddate,
                    CAST("$classification".timestamp AS BIGINT) AS timestamp
                FROM ${source_table}
                WHERE (sk LIKE 'REQUEST_ITEM#%') AND
                (
                    -- Moving 1-month ingestion window
                    (__month=MONTH(CURRENT_DATE) AND __year=YEAR(CURRENT_DATE)) OR
                    (__month=MONTH(DATE_ADD('month', -1, CURRENT_DATE)) AND __year=YEAR(DATE_ADD('month', -1, CURRENT_DATE)) AND __day >= DAY(CURRENT_DATE))
                )
            )
        )
        WHERE rownumber = 1
    ) as source
    ON
        --Match on primary key
        source.requestitemid = target.requestitemid

    --Update if match exists and source has later timestamp
    WHEN MATCHED AND (source.timestamp > target.timestamp) THEN UPDATE SET
        status = source.status

    --Insert if no match exists
    WHEN NOT MATCHED THEN INSERT (
        requestitemid,
        status,
        timestamp
    )
    VALUES (
        source.requestitemid,
        source.status,
        source.timestamp
    )

### Aggregation Queries

Aggregation queries produce much smaller result sets than the corresponding projection queries by grouping related items together.

This query finds the latest update of each object in the ingestion window, then groups them together according to the specified dimensions.

If a new combination of dimensions are found an insert is performed.

If an existing combination of dimensions are found an update is performed only if the total would be increased (this is to prevent totals being reduced as events expire from the sliding ingestion window)

For correct results, the ingestion window must be large enough to encompass all events that correspond to a given combination of dimensions.

    MERGE INTO <reporting_table> as target
    USING (
    SELECT
        --Dimensions
        clientid,
        sendinggroupid,

        --Facts
        count(distinct requestitemid) AS requestitemcount
    FROM (
        SELECT
        *,
        ROW_NUMBER() OVER (
            --Only select last update from sample window
            --Use completeddate as indicator of terminal state as a tie-breaker on identical timestamps
            partition BY sk ORDER BY
            timestamp DESC,
            length(coalesce(completeddate, '')) DESC
        ) AS rownumber
        FROM (
            SELECT
                --Dimensions
                clientid,
                sendinggroupid,

                --Facts
                requestitemid,

                --Timestamp partitioning/ordering columns
                sk,
                completeddate,
                CAST("$classification".timestamp AS BIGINT) AS timestamp
            FROM ${source_table}
            WHERE (status = 'DELIVERED' OR status = 'FAILED') AND (sk LIKE 'REQUEST_ITEM_PLAN#%') AND
            (
                -- Moving 1-month ingestion window
                (__month=MONTH(CURRENT_DATE) AND __year=YEAR(CURRENT_DATE)) OR
                (__month=MONTH(DATE_ADD('month', -1, CURRENT_DATE)) AND __year=YEAR(DATE_ADD('month', -1, CURRENT_DATE)) AND __day >= DAY(CURRENT_DATE))
            )
        )
    )
    WHERE rownumber = 1

    -- Group by dimension columns
    GROUP BY
        clientid,
        sendinggroupid
    ) as source
    ON
        -- Match on dimensions, using COALESCE to match on null values correctly
        COALESCE(source.clientid, '') = COALESCE(target.clientid, '') AND
        COALESCE(source.sendinggroupid, '') = COALESCE(target.sendinggroupid, '') AND

    --If matched, update the fact(s) with a one-way check
    WHEN MATCHED AND (source.requestitemcount > target.requestitemcount) THEN UPDATE
        SET requestitemcount = source.requestitemcount

    --If not matched, insert dimensions and facts
    WHEN NOT MATCHED THEN INSERT (
        clientid,
        sendinggroupid,
        requestitemcount
    )
    VALUES (
        source.clientid,
        source.sendinggroupid,
        source.requestitemcount
    )

### Handling NHS Numbers

Raw NHS numbers are not to be exposed in reporting tables. Instead, the following conversion is used:

    to_base64(sha256(cast((? || '.' || nhsnumber) AS varbinary))) AS nhsnumberhash

An environment-specific secret key is injected as an execution parameter to prevent precomputation attacks.

The same format should be used in all queries to ensure that the same hash value is always generated for the same NHS number in any given enviroment.

## Data Migration Queries

Data migration queries are executed manually and are held in this repository solely for traceability.

A data migration query is usually very similar to the corresponding ingestion query, and operates in exactly the same way.

Key differences include:

- The sliding time window is omitted so that all available rows in the source table are available
- The migration queries use a UNION operator to pull from both `transaction_history_old` and `transaction_history` tables
- Historic indiosyncrasies are accounted for (such as the change from second-precision to millisecond-precision timestamps between `transaction_history_old` and `transaction_history` tables)
- Migration queries may include specific amendments to rectify  historic data quality issues
