CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  clientid,
  campaignid,
  communicationtype,
  percentile * 100 AS percentile,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), percentile) AS latency
FROM (
  --Receipt to first channel send
  SELECT rip.clientid, rip.campaignid, rip.communicationtype, rq.rqcreatedtime AS starttime, rip.sendtime AS endtime FROM
    (
      SELECT requestid, MIN(createdtime) AS rqcreatedtime FROM request_item_status
      --Query optimisation to prevent full table scan on request_item_status createdtime
      WHERE createdtime >= DATE_ADD('week', -1, DATE_ADD('month', -2, CURRENT_DATE))
      GROUP BY requestid
    ) AS rq
    INNER JOIN request_item_plan_status rip ON rq.requestid = rip.requestid
    WHERE rip.createdtime >= DATE_ADD('month', -2, CURRENT_DATE)
    AND rip.ordernumber = 1
    AND rip.channeltype = 'primary'
  UNION ALL
  --Failure to fallback channel send
  SELECT clientid, campaignid, communicationtype,
    GREATEST(
      COALESCE(prevfailedtime1, DATE('2000-01-01')),
      COALESCE(prevfailedtime2, DATE('2000-01-01')),
      COALESCE(prevfailedtime3, DATE('2000-01-01'))
    ) AS starttime,
    sendtime AS endtime
  FROM (
    SELECT
      clientid,
      campaignid,
      ordernumber,
      sendtime,
      communicationtype,
      LAG(completedtime,1) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime1,
      LAG(completedtime,2) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime2,
      LAG(completedtime,3) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime3
    FROM request_item_plan_status
    WHERE createdtime >= DATE_ADD('month', -2, CURRENT_DATE)
    AND channeltype = 'primary'
  )
  WHERE ordernumber > 1
)
CROSS JOIN UNNEST (ARRAY[0.001, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.96, 0.97, 0.98, 0.99, 0.999]) AS t(percentile)
WHERE starttime IS NOT NULL
AND endtime IS NOT NULL
AND starttime > DATE('2000-01-01')
AND DAY_OF_WEEK(starttime) <= 5
AND HOUR(AT_TIMEZONE(DATE_ADD('minute', 2, starttime), 'Europe/London')) BETWEEN 8 AND 17
AND HOUR(AT_TIMEZONE(DATE_ADD('minute', -2, starttime), 'Europe/London')) BETWEEN 8 AND 17
GROUP BY clientid, campaignid, communicationtype, percentile
ORDER BY clientid, campaignid, communicationtype, percentile
