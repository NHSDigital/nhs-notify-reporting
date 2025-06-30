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
  WHERE ri.clientid = ? AND
    --Prevent scanning of all possible created dates
    (ri.createdtime IS NULL OR ri.createdtime >= DATE(DATE_ADD('day', -90, CURRENT_DATE))) AND
    (rip.createdtime IS NULL OR rip.createdtime >= DATE(DATE_ADD('day', -90, CURRENT_DATE)))
  GROUP BY ri.requestid, ri.requestrefid
)
WHERE
  totalitems=completeditems AND
  totalplans=completedplans AND
  (
    DATE(itemscompletedtime) >= DATE(DATE_ADD('day', -2, CURRENT_DATE)) OR
    DATE(planscompletedtime) >= DATE(DATE_ADD('day', -2, CURRENT_DATE))
  )
