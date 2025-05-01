CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  DATE(createdTime) AS createddate,
  clientid,
  communicationtype,
  COUNT(DISTINCT nhsnumberhash) recipientcount
FROM request_item_status CROSS JOIN UNNEST(completedcommunicationtypes) AS t(communicationtype)
WHERE status='DELIVERED'
GROUP BY 1, 2, 3
