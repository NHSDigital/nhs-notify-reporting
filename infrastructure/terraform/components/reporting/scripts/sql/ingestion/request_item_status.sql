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
        sendinggroupidversion,
        sendinggroupname,
        from_iso8601_timestamp(sendinggroupcreateddate) AS sendinggroupcreatedtime,
        requestitemrefid,
        requestitembillingrefid,
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
      FROM ${source_table}
      WHERE (sk LIKE 'REQUEST_ITEM#%') AND
      (
        -- Moving 1-week ingestion window
        DATE(CAST(__year AS VARCHAR) || '-' || CAST(__month AS VARCHAR) || '-' || CAST(__day  AS VARCHAR)) >= DATE_ADD('week', -1, CURRENT_DATE)
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
  sendinggroupidversion = source.sendinggroupidversion,
  sendinggroupname = source.sendinggroupname,
  sendinggroupcreatedtime = source.sendinggroupcreatedtime,
  requestitemrefid = source.requestitemrefid,
  requestitembillingrefid = source.requestitembillingrefid,
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
  sendinggroupname,
  sendinggroupcreatedtime,
  requestitemrefid,
  requestitembillingrefid,
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
  source.sendinggroupname,
  source.sendinggroupcreatedtime,
  source.requestitemrefid,
  source.requestitembillingrefid,
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
