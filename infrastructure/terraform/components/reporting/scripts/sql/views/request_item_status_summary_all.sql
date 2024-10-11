CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  NULL AS requestrefid,
  NULL AS requestid,
  createddate,
  requestedcount,
  deliveredcount,
  failedcount,
  completedcount,
  outstandingcount,
  nhsappdeliveredcount,
  emaildeliveredcount,
  smsdeliveredcount,
  letterdeliveredcount,
  nhsappfailedcount,
  emailfailedcount,
  smsfailedcount,
  letterfailedcount
FROM request_item_status_summary
WHERE clientid NOT IN (SELECT DISTINCT clientid FROM request_item_status_summary_batch)
UNION ALL
SELECT
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  requestrefid,
  requestid,
  createddate,
  requestedcount,
  deliveredcount,
  failedcount,
  completedcount,
  outstandingcount,
  nhsappdeliveredcount,
  emaildeliveredcount,
  smsdeliveredcount,
  letterdeliveredcount,
  nhsappfailedcount,
  emailfailedcount,
  smsfailedcount,
  letterfailedcount
FROM request_item_status_summary_batch
