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
			GROUP BY requestid
		) AS rq
		INNER JOIN request_item_plan_status rip ON rq.requestid = rip.requestid
		WHERE rip.createdtime >= DATE_ADD('month', -2, CURRENT_DATE)
		AND rq.rqcreatedtime >= DATE_ADD('month', -2, CURRENT_DATE)
		AND rip.ordernumber = 1
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
	)
	WHERE ordernumber > 1
)
CROSS JOIN UNNEST (ARRAY[0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99, 0.999]) AS t(percentile)
WHERE starttime IS NOT NULL
AND endtime IS NOT NULL
AND starttime > DATE('2000-01-01')
AND DAY_OF_month(starttime) <= 5
AND HOUR(starttime) < 16
AND HOUR(starttime) >= 9
GROUP BY clientid, campaignid, communicationtype, percentile
ORDER BY clientid, campaignid, communicationtype, percentile
