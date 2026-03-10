CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  rip.*,
  ris.originatingclientid,
  ris.originatingcampaignid,
  ris.originatingbillingref,
  ris.originatingrequestitemid,
  ris.originatingrequestitemplanid,
  original_ri.sendinggroupid AS originatingsendinggroupid
FROM request_item_plan_status rip
LEFT JOIN request_item_status_smsnudge_staging ris
  ON rip.requestitemid = ris.requestitemid
LEFT JOIN request_item_status original_ri
  ON original_ri.requestitemid = ris.originatingrequestitemid
  AND original_ri.clientid = ris.originatingclientid
WHERE rip.clientid = ${sms_nudge_client_id}
