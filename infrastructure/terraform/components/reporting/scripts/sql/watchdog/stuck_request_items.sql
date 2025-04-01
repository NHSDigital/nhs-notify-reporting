SELECT
  clientid,
  COALESCE(campaignid, 'N/A'),
  SUM(
    CASE
      WHEN status='ENRICHED' AND createdtime < DATE_ADD('day', -6, CURRENT_DATE) THEN 1
      WHEN status='PENDING_ENRICHMENT' AND createdtime < DATE_ADD('day', -2, CURRENT_DATE) THEN 1
      ELSE 0
    END
  )
FROM request_item_status
WHERE createdtime >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid, campaignid
