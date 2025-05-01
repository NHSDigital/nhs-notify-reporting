CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  createddate,
  communicationtype,
  messagecount,
  COUNT(nhsnumberhash) AS recipientcount
FROM (
  SELECT
    DATE(createdtime) AS createddate,
    nhsnumberhash,
    communicationtype,
    COUNT(requestitemid) AS messagecount
  FROM request_item_status CROSS JOIN UNNEST(completedcommunicationtypes) AS t(communicationtype)
  WHERE status='DELIVERED'
  GROUP BY 1, 2, 3
)
GROUP BY 1, 2, 3
