CREATE OR REPLACE VIEW ${view_name} AS
WITH email_only_sending_groups AS (
  SELECT clientid, sendinggroupid FROM request_item_plan_completed_summary_all
  WHERE sendinggroupid IS NOT NULL
  GROUP BY clientid, sendinggroupid
  HAVING
    COUNT_IF(communicationtype = 'EMAIL') > 0
    AND COUNT_IF(communicationtype <> 'EMAIL') = 0
)
SELECT * FROM request_item_status_summary_all
WHERE NOT (
  clientid = '688040bc-92ea-4037-89f4-d105c9ae59a4'
  AND EXISTS (
    SELECT 1
    FROM email_only_sending_groups
    WHERE
      email_only_sending_groups.clientid = request_item_status_summary_all.clientid
      AND email_only_sending_groups.sendinggroupid = request_item_status_summary_all.sendinggroupid
  )
)
