CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  DATE(nudge.createdtime) createddate,
  nudge.clientid,
  nudge.requestitemplanid,
  originatingclientid,
  originatingcampaignid,
  originatingbillingref,
  originatingsendinggroupid,
  originatingrequestitemplanid,
  app.status AS originalStatus,
  CASE
    WHEN nudge.status = 'DELIVERED'
    AND app.status = 'DELIVERED' THEN DATE_DIFF('second', nudge.createdtime, app.completedtime) / 3600.0 ELSE NULL
  END hrsToRead
FROM
  request_item_plan_status_smsnudge nudge
LEFT JOIN
  request_item_plan_status app
ON (
  nudge.originatingrequestitemplanid = app.requestitemplanid
  AND nudge.originatingclientid = app.clientid
  AND app.communicationtype = 'NHSAPP'
)
