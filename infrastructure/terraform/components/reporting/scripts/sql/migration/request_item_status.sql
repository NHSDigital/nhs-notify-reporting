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
        NULL AS campaignid,
        sendinggroupid,
        sendinggroupidversion,
        requestitemrefid,
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
        NULL AS patientodscode,
        CAST("$classification".timestamp AS BIGINT) * 1000 AS timestamp --transaction_history_old has second granularity timestamps
      FROM transaction_history_old
      WHERE (sk LIKE 'REQUEST_ITEM#%')
      UNION ALL
      SELECT
        clientid,
        campaignid,
        sendinggroupid,
        sendinggroupidversion,
        requestitemrefid,
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
        patientodscode,
        CAST("$classification".timestamp AS BIGINT) AS timestamp
      FROM transaction_history
      WHERE (sk LIKE 'REQUEST_ITEM#%') AND ((completeddate IS NULL) OR (SUBSTRING(completeddate, 11, 1) = 'T'))
      UNION ALL
      --data quality issue from invalid manual correction of source data
      SELECT
        clientid,
        campaignid,
        sendinggroupid,
        sendinggroupidversion,
        requestitemrefid,
        requestitemid,
        requestrefid,
        requestid,
        to_base64(sha256(cast((? || '.' || nhsnumber) AS varbinary))) AS nhsnumberhash,
        from_iso8601_timestamp(createddate) AS createdtime,
        cast(completeddate AS timestamp) AS completedtime,
        completedcommunicationtypes,
        failedcommunicationtypes,
        status,
        failedreason,
        patientodscode,
        CAST("$classification".timestamp AS BIGINT) AS timestamp
      FROM transaction_history
      WHERE (sk LIKE 'REQUEST_ITEM#%') AND ((completeddate IS NOT NULL) AND (SUBSTRING(completeddate, 11, 1) != 'T'))
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
  sendinggroupidversion = source.sendinggroupidversion,
  requestitemrefid = source.requestitemrefid,
  requestrefid = source.requestrefid,
  requestid = source.requestid,
  nhsnumberhash = source.nhsnumberhash,
  createdtime = source.createdtime,
  completedtime = source.completedtime,
  completedcommunicationtypes = source.completedcommunicationtypes,
  failedcommunicationtypes = source.failedcommunicationtypes,
  status = source.status,
  failedreason = source.failedreason,
  patientodscode = source.patientodscode,
  timestamp = source.timestamp
WHEN NOT MATCHED THEN INSERT (
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  requestitemrefid,
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
  patientodscode,
  timestamp
)
VALUES (
  source.clientid,
  source.campaignid,
  source.sendinggroupid,
  source.sendinggroupidversion,
  source.requestitemrefid,
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
  source.patientodscode,
  source.timestamp
)
