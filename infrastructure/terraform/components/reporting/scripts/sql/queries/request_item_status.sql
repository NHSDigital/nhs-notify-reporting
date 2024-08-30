MERGE INTO request_item_status as target
USING (
  SELECT * FROM (
    SELECT 
      *,
      ROW_NUMBER() OVER (
        partition BY requestitemid ORDER BY
        timestamp DESC,
        length(coalesce(cast(completedtime AS varchar), '')) DESC
      ) AS rownumber
    FROM (
      SELECT
        clientid,
        campaignid,
        sendinggroupid,
        requestitemid,
        requestrefid,
        requestid,
        to_base64(sha256(cast((? || '.' || nhsnumber) AS varbinary))) AS nhsnumberhash,
        from_iso8601_timestamp(createddate) AS createdtime,
        from_iso8601_timestamp(completeddate) AS completedtime,
        completedcommunicationtypes,
        failedcommunicationtypes,
        status,
        failedreason,
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
  source.requestitemid = target.requestitemid
WHEN MATCHED AND (source.timestamp > target.timestamp) THEN UPDATE SET
  clientid = source.clientid,
  campaignid = source.campaignid,
  sendinggroupid = source.sendinggroupid,
  requestrefid = source.requestrefid,
  requestid = source.requestid,
  nhsnumberhash = source.nhsnumberhash,
  createdtime = source.createdtime,
  completedtime = source.completedtime,
  completedcommunicationtypes = source.completedcommunicationtypes,
  failedcommunicationtypes = source.failedcommunicationtypes,
  status = source.status,
  failedreason = source.failedreason,
  timestamp = source.timestamp
WHEN NOT MATCHED THEN INSERT (
  clientid,
  campaignid,
  sendinggroupid,
  requestitemid,
  requestrefid,
  requestid,
  nhsnumberhash,
  createdtime,
  completedtime,
  completedcommunicationtypes,
  failedcommunicationtypes,
  status,
  failedreason,
  timestamp
)
VALUES (
  source.clientid,
  source.campaignid,
  source.sendinggroupid,
  source.requestitemid,
  source.requestrefid,
  source.requestid,
  source.nhsnumberhash,
  source.createdtime,
  source.completedtime,
  source.completedcommunicationtypes,
  source.failedcommunicationtypes,
  source.status,
  source.failedreason,
  source.timestamp
)
