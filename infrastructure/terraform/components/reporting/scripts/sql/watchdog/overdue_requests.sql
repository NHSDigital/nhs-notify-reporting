SELECT clientid, campaignid, SUM(CASE WHEN totalitems > completeditems THEN 1 ELSE 0 END) FROM (
  SELECT
    clientid,
    COALESCE(campaignid, 'Unspecified') AS campaignid,
    requestid,
    COUNT(*) AS totalitems,
    SUM(CASE WHEN status IN ('FAILED', 'DELIVERED') THEN 1 ELSE 0 END) AS completeditems,
    DATE(MIN(createdtime)) AS createddate
  FROM request_item_status
  GROUP BY clientid, campaignid, requestid
)
WHERE
createddate < DATE_ADD('week', -2, CURRENT_DATE) AND
createddate >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid, campaignid
