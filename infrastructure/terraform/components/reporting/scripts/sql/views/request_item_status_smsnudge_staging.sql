CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  ris.*,
  NULLIF(split_part(ris.billingref, '|', 1), '') AS originatingclientid,
  NULLIF(split_part(ris.billingref, '|', 2), '') AS originatingcampaignid,
  NULLIF(split_part(ris.billingref, '|', 3), '') AS originatingbillingref,
  NULLIF(split_part(ris.requestitemrefid, '_', 1), '') AS originatingrequestitemid,
  NULLIF(split_part(ris.requestitemrefid, '_', 2), '') AS originatingrequestitemplanid
FROM request_item_status ris
WHERE ris.clientid = ${sms_nudge_client_id}
