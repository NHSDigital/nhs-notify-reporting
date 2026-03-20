CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  date(nudge.createdtime) createddate,
  nudge.clientid,
  nudge.requestitemplanid,
  originatingclientid,
  originatingcampaignid,
  originatingbillingref,
  originatingsendinggroupid,
  originatingrequestitemplanid,
  app.status as originalStatus,
  case
    when nudge.status = 'DELIVERED'
    and app.status = 'DELIVERED' then date_diff('second', nudge.createdtime, app.completedtime) / 3600.0 else null
  end hrsToRead
FROM
  request_item_plan_status_smsnudge nudge
left join
  request_item_plan_status app
on (
  nudge.originatingrequestitemplanid = app.requestitemplanid
  and nudge.originatingclientid = app.clientid
  and app.communicationtype = 'NHSAPP'
)
