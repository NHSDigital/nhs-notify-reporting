CREATE OR REPLACE VIEW ${view_name} AS
WITH request_created_time AS (
  SELECT
    clientid,
    requestid,
    MIN(createdtime) AS createdtime
  FROM request_item_status
  WHERE createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
  GROUP BY clientid, requestid
),
first_channel_send AS (
  --Time from batch receipt to first message send
  SELECT
    rip.clientid,
    rip.campaignid,
    rip.sendinggroupid,
    rip.communicationtype,
    rct.createdtime AS starttime,
    rip.sendtime AS endtime
  FROM request_created_time rct
  INNER JOIN request_item_plan_status rip
    ON rct.clientid = rip.clientid
    AND rct.requestid = rip.requestid
  WHERE rip.ordernumber = 1
    AND rip.channeltype = 'primary'
    AND rip.createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
),
fallback_candidates AS (
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    ordernumber,
    sendtime,
    communicationtype,
    LAG(completedtime, 1) OVER win AS prevfailedtime1,
    LAG(completedtime, 2) OVER win AS prevfailedtime2,
    LAG(completedtime, 3) OVER win AS prevfailedtime3
  FROM request_item_plan_status
  WHERE channeltype = 'primary'
    AND createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
  WINDOW win AS (PARTITION BY requestitemid ORDER BY ordernumber ASC)
),
fallback_channel_send AS (
  --Time from failover trigger to subsequent send
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    GREATEST(
      COALESCE(prevfailedtime1, DATE('2000-01-01')),
      COALESCE(prevfailedtime2, DATE('2000-01-01')),
      COALESCE(prevfailedtime3, DATE('2000-01-01'))
    ) AS starttime,
    sendtime AS endtime
  FROM fallback_candidates
  WHERE ordernumber > 1
),
combined_events AS (
  SELECT * FROM first_channel_send
  UNION ALL
  SELECT * FROM fallback_channel_send
)
SELECT *
FROM combined_events
WHERE starttime IS NOT NULL
  AND endtime IS NOT NULL
  AND starttime > DATE('2000-01-01')
  --Exclude unsociable hours, use 2 minute tolerance to eliminate spurious values due to race conditions
  AND DAY_OF_WEEK(starttime) <= 5
  AND HOUR(AT_TIMEZONE(DATE_ADD('minute', 2, starttime), 'Europe/London')) BETWEEN 8 AND 17
  AND HOUR(AT_TIMEZONE(DATE_ADD('minute', -2, starttime), 'Europe/London')) BETWEEN 8 AND 17;
