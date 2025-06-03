CREATE OR REPLACE VIEW ${view_name} AS
SELECT * FROM (
  --Receipt to first channel send
  SELECT
    rip.clientid, rip.campaignid, rip.communicationtype, rq.rqcreatedtime AS starttime, rip.sendtime AS endtime FROM
      (
        SELECT clientid, requestid, MIN(createdtime) AS rqcreatedtime FROM request_item_status
        WHERE createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
        GROUP BY 1, 2
      ) AS rq
    INNER JOIN request_item_plan_status rip
    ON rq.clientid = rip.clientid AND rq.requestid = rip.requestid
    WHERE rip.ordernumber = 1
    AND rip.channeltype = 'primary'
    AND rip.createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
  UNION ALL
  --Failure to fallback channel send
    SELECT
      clientid,
      campaignid,
      communicationtype,
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
      WHERE channeltype = 'primary'
      AND createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
    )
    WHERE ordernumber > 1
)
WHERE starttime IS NOT NULL
AND endtime IS NOT NULL
AND starttime > DATE('2000-01-01')
AND DAY_OF_WEEK(starttime) <= 5
AND HOUR(AT_TIMEZONE(DATE_ADD('minute', 2, starttime), 'Europe/London')) BETWEEN 8 AND 17
AND HOUR(AT_TIMEZONE(DATE_ADD('minute', -2, starttime), 'Europe/London')) BETWEEN 8 AND 17
