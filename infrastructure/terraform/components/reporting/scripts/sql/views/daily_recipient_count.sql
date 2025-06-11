CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  createddate,
  clientid,
  communicationtype,
  COUNT(DISTINCT nhsnumberhash) AS recipientcount
FROM delivered_messages
GROUP BY 1, 2, 3
