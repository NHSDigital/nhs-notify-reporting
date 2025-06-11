CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  createddate,
  clientid,
  communicationType,
  COUNT(DISTINCT nhsnumberhash) AS recipientcount
FROM vw_delivered_messages_flat
GROUP BY 1, 2, 3
