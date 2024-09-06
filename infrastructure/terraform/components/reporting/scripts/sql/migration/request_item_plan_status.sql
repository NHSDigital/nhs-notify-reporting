MERGE INTO request_item_plan_status as target
USING (
  SELECT * FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (
        partition BY requestitemplanid ORDER BY
        timestamp DESC,
        length(coalesce(cast(completedtime AS varchar), '')) DESC
      ) AS rownumber
    FROM (
      SELECT
        clientid,
        campaignid,
        sendinggroupid,
        sendinggroupidversion,
        requestitemrefid,
        requestitemid,
        requestrefid,
        requestid,
        requestitemplanid,
        communicationtype,
        supplier,
        from_iso8601_timestamp(createddate) AS createdtime,
        from_iso8601_timestamp(completeddate) AS completedtime,
        status,
        failedreason,
        contactdetailsource,
        channeltype,
        CAST("$classification".timestamp AS BIGINT) AS timestamp
      FROM transaction_history
      WHERE (sk LIKE 'REQUEST_ITEM_PLAN#%')
      UNION
            SELECT
        clientid,
        NULL as campaignid,
        sendinggroupid,
        sendinggroupidversion,
        requestitemrefid,
        requestitemid,
        requestrefid,
        requestid,
        requestitemplanid,
        communicationtype,
        supplier,
        from_iso8601_timestamp(createddate) AS createdtime,
        from_iso8601_timestamp(completeddate) AS completedtime,
        status,
        failedreason,
        NULL as contactdetailsource,
        NULL as channeltype,
        CAST("$classification".timestamp AS BIGINT) * 1000 AS timestamp --transaction_history_old has second granularity timestamps
      FROM transaction_history_old
      WHERE (sk LIKE 'REQUEST_ITEM_PLAN#%')
    )
  )
  WHERE rownumber = 1
) as source
ON
  source.requestitemplanid = target.requestitemplanid
WHEN MATCHED AND (source.timestamp > target.timestamp) THEN UPDATE SET
  clientid = source.clientid,
  campaignid = source.campaignid,
  sendinggroupid = source.sendinggroupid,
  sendinggroupidversion = source.sendinggroupidversion,
  requestitemrefid = source.requestitemrefid,
  requestitemid = source.requestitemid,
  requestrefid = source.requestrefid,
  requestid = source.requestid,
  communicationtype = source.communicationtype,
  supplier = source.supplier,
  createdtime = source.createdtime,
  completedtime = source.completedtime,
  status = source.status,
  failedreason = source.failedreason,
  contactdetailsource = source.contactdetailsource,
  channeltype = source.channeltype,
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
  requestitemplanid,
  communicationtype,
  supplier,
  createdtime,
  completedtime,
  status,
  failedreason,
  contactdetailsource,
  channeltype,
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
  source.requestitemplanid,
  source.communicationtype,
  source.supplier,
  source.createdtime,
  source.completedtime,
  source.status,
  source.failedreason,
  source.contactdetailsource,
  source.channeltype,
  source.timestamp
)
