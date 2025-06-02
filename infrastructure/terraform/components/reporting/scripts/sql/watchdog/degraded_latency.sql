SELECT
  recent.clientid,
  recent.campaignid,
  SUM(
    CASE
      WHEN recent.p50latency > historic.p99latency THEN 1
      ELSE 0
    END
  )
FROM (
    SELECT
      clientid,
      COALESCE(campaignid, 'N/A') AS campaignid,
      sendinggroupid,
      communicationtype,
      approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.99) AS p99latency
    FROM (
      --Receipt to first channel send
      SELECT rip.clientid, rip.campaignid, rip.communicationtype, rip.sendinggroupid, rq.rqcreatedtime AS starttime, rip.sendtime AS endtime FROM
        (
          SELECT requestid, MIN(createdtime) AS rqcreatedtime FROM request_item_status
          --Query optimisation to prevent full table scan on request_item_status createdtime
          WHERE createdtime >= DATE_ADD('week', -1, DATE_ADD('month', -1, CURRENT_DATE))
          GROUP BY requestid
        ) AS rq
        INNER JOIN request_item_plan_status rip ON rq.requestid = rip.requestid
        WHERE rip.createdtime >= DATE_ADD('month', -1, CURRENT_DATE)
        AND rip.ordernumber = 1
        AND rip.channeltype = 'primary'
      UNION ALL
      --Failure to fallback channel send
      SELECT clientid, campaignid, communicationtype, sendinggroupid,
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
          sendinggroupid,
          LAG(completedtime,1) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime1,
          LAG(completedtime,2) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime2,
          LAG(completedtime,3) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime3
        FROM request_item_plan_status
        WHERE createdtime >= DATE_ADD('month', -1, CURRENT_DATE)
        AND channeltype = 'primary'
      )
      WHERE ordernumber > 1
    )
    WHERE starttime IS NOT NULL
    AND endtime IS NOT NULL
    AND starttime > DATE('2000-01-01')
    AND DAY_OF_WEEK(starttime) <= 5
    AND HOUR(AT_TIMEZONE(DATE_ADD('minute', 2, starttime), 'Europe/London')) BETWEEN 8 AND 17
    AND HOUR(AT_TIMEZONE(DATE_ADD('minute', -2, starttime), 'Europe/London')) BETWEEN 8 AND 17
    GROUP BY clientid, campaignid, communicationtype, sendinggroupid
) historic
INNER JOIN (
    SELECT
      clientid,
      COALESCE(campaignid, 'N/A') AS campaignid,
      sendinggroupid,
      communicationtype,
      approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), 0.5) AS p50latency
    FROM (
      --Receipt to first channel send
      SELECT rip.clientid, rip.campaignid, rip.communicationtype, rip.sendinggroupid, rq.rqcreatedtime AS starttime, rip.sendtime AS endtime FROM
        (
          SELECT requestid, MIN(createdtime) AS rqcreatedtime FROM request_item_status
          --Query optimisation to prevent full table scan on request_item_status createdtime
          WHERE createdtime >= DATE_ADD('week', -1, DATE_ADD('month', -1, CURRENT_DATE))
          GROUP BY requestid
        ) AS rq
        INNER JOIN request_item_plan_status rip ON rq.requestid = rip.requestid
        WHERE rip.createdtime >= DATE_ADD('month', -1, CURRENT_DATE)
        AND rip.ordernumber = 1
        AND rip.channeltype = 'primary'
      UNION ALL
      --Failure to fallback channel send
      SELECT clientid, campaignid, communicationtype, sendinggroupid,
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
          sendinggroupid,
          LAG(completedtime,1) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime1,
          LAG(completedtime,2) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime2,
          LAG(completedtime,3) OVER (PARTITION BY requestitemid ORDER BY ordernumber ASC) as prevfailedtime3
        FROM request_item_plan_status
        WHERE createdtime >= DATE_ADD('month', -1, CURRENT_DATE)
        AND channeltype = 'primary'
      )
      WHERE ordernumber > 1
    )
    WHERE starttime IS NOT NULL
    AND endtime IS NOT NULL
    AND starttime > DATE('2000-01-01')
    AND DAY_OF_WEEK(starttime) <= 5
    AND HOUR(AT_TIMEZONE(DATE_ADD('minute', 2, starttime), 'Europe/London')) BETWEEN 8 AND 17
    AND HOUR(AT_TIMEZONE(DATE_ADD('minute', -2, starttime), 'Europe/London')) BETWEEN 8 AND 17
    AND endtime >= CURRENT_DATE
    GROUP BY clientid, campaignid, communicationtype, sendinggroupid
) recent
ON
historic.clientid = recent.clientid AND
historic.campaignid = recent.campaignid AND
historic.sendinggroupid = recent.sendinggroupid AND
historic.communicationtype = recent.communicationtype
GROUP BY 1, 2
