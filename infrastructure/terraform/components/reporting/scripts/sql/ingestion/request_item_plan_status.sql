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
        from_iso8601_timestamp(datesent) AS sendtime,
        status,
        failedreason,
        contactdetailsource,
        channeltype,
        ordernumber,
        recipientcontactid,
        CAST(CAST(th.templates.suppliers AS json) AS map<varchar, varchar>)[LOWER(supplier)] AS templateid,
        CAST("$classification".timestamp AS BIGINT) AS timestamp
      FROM ${source_table}
      WHERE (sk LIKE 'REQUEST_ITEM_PLAN#%') AND
      (
        -- Moving 1-week ingestion window
        DATE(CAST(__year AS VARCHAR) || '-' || CAST(__month AS VARCHAR) || '-' || CAST(__day  AS VARCHAR)) >= DATE_ADD('week', -1, CURRENT_DATE)
      )
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
  sendtime = source.sendtime,
  status = source.status,
  failedreason = source.failedreason,
  contactdetailsource = source.contactdetailsource,
  channeltype = source.channeltype,
  ordernumber = source.ordernumber,
  recipientcontactid =  source.recipientcontactid,
  templateid = source.templateid,
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
  sendtime,
  status,
  failedreason,
  contactdetailsource,
  channeltype,
  ordernumber,
  recipientcontactid,
  templateid,
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
  source.sendtime,
  source.status,
  source.failedreason,
  source.contactdetailsource,
  source.channeltype,
  source.ordernumber,
  source.recipientcontactid,
  source.templateid,
  source.timestamp
)
