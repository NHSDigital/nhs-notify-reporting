SELECT requestid, requestrefid FROM (
  SELECT
    requestid,
    requestrefid,
    COUNT(*) AS totalitems,
    SUM(CASE WHEN status IN ('FAILED', 'DELIVERED') THEN 1 ELSE 0 END) AS completeditems,
    MAX(completedtime) AS completedtime
  FROM request_item_status
  WHERE clientid = ?
  GROUP BY requestid, requestrefid
)
WHERE totalitems=completeditems AND DATE(completedtime) >= DATE(DATE_ADD('week', -1, CURRENT_DATE))
