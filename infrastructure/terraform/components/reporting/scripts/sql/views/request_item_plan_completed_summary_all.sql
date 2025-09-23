CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  NULL AS requestrefid,
  NULL AS requestid,
  communicationtype,
  supplier,
  createddate,
  completeddate,
  status,
  failedreason,
  contactdetailsource,
  channeltype,
  templateid,
  requestitemcount
FROM request_item_plan_completed_summary
WHERE clientid NOT IN (SELECT DISTINCT clientid FROM request_item_plan_completed_summary_batch)
UNION ALL
SELECT
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  requestrefid,
  requestid,
  communicationtype,
  supplier,
  createddate,
  completeddate,
  status,
  failedreason,
  contactdetailsource,
  channeltype,
  templateid,
  requestitemcount
FROM request_item_plan_completed_summary_batch
