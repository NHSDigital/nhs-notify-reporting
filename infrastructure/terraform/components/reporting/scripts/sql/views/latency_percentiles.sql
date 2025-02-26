SELECT
  clientid,
  campaignid,
  communicationtype,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.01) AS p010,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.1) AS p100,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.2) AS p200,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.3) AS p300,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.4) AS p400,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.5) AS p500,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.6) AS p600,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.7) AS p700,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.8) AS p800,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.9) AS p900,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.95) AS p950,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.96) AS p960,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.97) AS p970,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.98) AS p980,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.99) AS p990,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.999) AS p999
FROM (
  SELECT rip.clientid, rip.campaignid, rip.communicationtype, rq.rqcreatedtime AS starttime, rip.sendtime AS endtime FROM
		(
			SELECT requestid, MIN(createdtime) AS rqcreatedtime FROM request_item_status
			GROUP BY requestid
		) AS rq
		INNER JOIN request_item_plan_status rip ON rq.requestid = rip.requestid
		WHERE rip.createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
		AND rq.rqcreatedtime >= DATE_ADD('month', -3, CURRENT_DATE)
		AND rip.ordernumber = 1
	UNION ALL
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
    WHERE createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
	)
	WHERE ordernumber > 1
)
WHERE starttime IS NOT NULL
AND endtime IS NOT NULL
AND starttime > DATE('2000-01-01')
AND DAY_OF_WEEK(starttime) <= 5
AND HOUR(starttime) < 16
AND HOUR(starttime) >= 9
GROUP BY clientid, campaignid, communicationtype
ORDER BY clientid, campaignid, communicationtype
