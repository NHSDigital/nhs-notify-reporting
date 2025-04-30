MERGE INTO client_latest_name as target
USING (
  SELECT clientid, clientname, CAST("$classification".timestamp AS BIGINT) AS timestamp
  FROM ${source_table}
  WHERE (sk LIKE 'REQUEST#%' OR sk LIKE 'REQUEST_ITEM#%' OR sk LIKE 'REQUEST_ITEM_PLAN#%') 
    AND (
      -- Moving 1-week ingestion window
      DATE(CAST(__year AS VARCHAR) || '-' || CAST(__month AS VARCHAR) || '-' || CAST(__day  AS VARCHAR)) >= DATE_ADD('week', -1, CURRENT_DATE)
    )
) as source
ON
  source.clientid = target.clientid 
WHEN MATCHED AND (source.timestamp > target.timestamp) THEN UPDATE SET 
  target.clientname = source.clientname
  target.timestamp = source.timestamp
WHEN NOT MATCHED THEN INSERT (
  clientid,
  clientname,
  timestamp
)
VALUES (
  source.clientid,
  source.clientname,
  source.timestamp
)
