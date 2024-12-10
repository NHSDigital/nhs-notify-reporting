SELECT clientid, COUNT(DISTINCT requestid) FROM (
  SELECT
    clientid, requestid,
    COUNT(*) AS totalitems,
    SUM(CASE WHEN status IN ('FAILED', 'DELIVERED') THEN 1 ELSE 0 END) AS completeditems,
    DATE(MIN(createdtime)) AS createddate
  FROM request_item_status
  GROUP BY clientid, requestid
)
WHERE totalitems > completeditems AND
createddate <= DATE_ADD('week', -2, CURRENT_DATE) AND
createddate >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid
