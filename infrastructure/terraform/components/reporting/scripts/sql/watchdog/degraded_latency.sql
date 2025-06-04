WITH latency_stats AS (
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    approx_percentile(to_unixtime(endtime) - to_unixtime(starttime), 0.95)
      FILTER (WHERE endtime >= DATE_ADD('month', -1, CURRENT_DATE) AND endtime < CURRENT_DATE) AS monthp95latency,
    approx_percentile(to_unixtime(endtime) - to_unixtime(starttime), 0.5)
      FILTER (WHERE endtime >= CURRENT_DATE) AS todayp50latency
  FROM raw_latency_3m
  WHERE endtime >= DATE_ADD('month', -1, CURRENT_DATE)
  GROUP BY 1, 2, 3, 4
)
SELECT
  clientid,
  COALESCE(campaignid, 'N/A') AS campaignid,
  --Trigger alarm if today's median latency is more than double the 95th percentile for the last month
  COUNT_IF(todayp50latency > 2 * monthp95latency)
FROM latency_stats
GROUP BY 1, 2;
