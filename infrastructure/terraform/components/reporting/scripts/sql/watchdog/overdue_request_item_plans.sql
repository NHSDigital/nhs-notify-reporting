SELECT
  clientid,
  COALESCE(campaignid, 'N/A'),
  COUNT(*) - SUM(CASE WHEN status IN ('FAILED', 'DELIVERED', 'SKIPPED') THEN 1 ELSE 0 END)
FROM request_item_plan_status
WHERE
  (
      (ordernumber = 1 AND createdtime < DATE_ADD('day', -4, CURRENT_DATE) AND communicationtype = 'NHSAPP') OR
      (ordernumber = 1 AND createdtime < DATE_ADD('day', -4, CURRENT_DATE) AND communicationtype = 'SMS') OR
      (ordernumber = 1 AND createdtime < DATE_ADD('day', -4, CURRENT_DATE) AND communicationtype = 'EMAIL') OR
      (ordernumber = 1 AND createdtime < DATE_ADD('day', -7, CURRENT_DATE) AND communicationtype = 'LETTER') OR
      (ordernumber = 2 AND createdtime < DATE_ADD('day', -10, CURRENT_DATE)) OR
      createdtime < DATE_ADD('week', -2, CURRENT_DATE)
  ) AND
  createdtime >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid, campaignid
