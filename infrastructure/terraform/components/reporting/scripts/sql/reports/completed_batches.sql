SELECT requestid, requestrefid FROM (
  SELECT
    ri.requestid,
    ri.requestrefid,
    COUNT(DISTINCT ri.requestitemid) AS totalitems,
    COUNT(DISTINCT CASE WHEN ri.status IN ('FAILED', 'DELIVERED') THEN ri.requestitemid END) AS completeditems,
    COUNT(DISTINCT rip.requestitemplanid) AS totalplans,
    COUNT(DISTINCT CASE WHEN rip.status IN ('FAILED', 'DELIVERED', 'SKIPPED') THEN rip.requestitemplanid END) AS completedplans,
    MAX(ri.completedtime) AS itemscompletedtime,
    MAX(rip.completedtime) AS planscompletedtime
  FROM request_item_status ri
  LEFT OUTER JOIN request_item_plan_status rip ON
    ri.requestitemid = rip.requestitemid AND
    ri.clientid = rip.clientid
  WHERE ri.clientid = ?
  GROUP BY ri.requestid, ri.requestrefid
)
WHERE
  totalitems=completeditems AND
  totalplans=completedplans AND
  (
    DATE(itemscompletedtime) >= DATE(DATE_ADD('week', -1, CURRENT_DATE)) OR
    DATE(planscompletedtime) >= DATE(DATE_ADD('week', -1, CURRENT_DATE))
  )
