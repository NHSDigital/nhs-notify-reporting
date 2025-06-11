SELECT
  createddate,
  communicationType,
  messagecount,
  COUNT(*) AS recipientcount
FROM (
  SELECT
    createddate,
    nhsnumberhash,
    communicationType,
    COUNT(*) AS messagecount
  FROM vw_delivered_messages_flat
  GROUP BY 1, 2, 3
)
GROUP BY 1, 2, 3
