CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  createddate,
  communicationtype,
  messagecount,
  COUNT(*) AS recipientcount
FROM (
  SELECT
    createddate,
    nhsnumberhash,
    communicationtype,
    COUNT(*) AS messagecount
  FROM delivered_messages
  GROUP BY 1, 2, 3
)
GROUP BY 1, 2, 3
