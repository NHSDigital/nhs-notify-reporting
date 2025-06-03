CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  clientid,
  campaignid,
  communicationtype,
  percentile * 100 AS percentile,
  approx_percentile(to_unixtime(endtime)-to_unixtime(starttime), percentile) AS latency
FROM raw_latency
CROSS JOIN UNNEST (ARRAY[0.001, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.96, 0.97, 0.98, 0.99, 0.999]) AS t(percentile)
WHERE endtime >= DATE_ADD('month', -2, CURRENT_DATE)
GROUP BY clientid, campaignid, communicationtype, percentile
ORDER BY clientid, campaignid, communicationtype, percentile
