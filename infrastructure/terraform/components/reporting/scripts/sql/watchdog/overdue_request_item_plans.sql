SELECT
  clientid,
  COUNT(*) - SUM(CASE WHEN status IN ('FAILED', 'DELIVERED', 'SKIPPED') THEN 1 ELSE 0 END)
FROM request_item_plan_status
WHERE
createdtime < DATE_ADD('week', -2, CURRENT_DATE) AND
createdtime >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid
