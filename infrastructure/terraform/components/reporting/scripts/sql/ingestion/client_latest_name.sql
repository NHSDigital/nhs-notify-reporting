MERGE INTO client_latest_name as target
USING (
  SELECT
    clientid,
    MAX_BY(clientname, createddate) AS clientname,
    from_iso8601_timestamp(MAX(createddate)) AS createdtime
  FROM ${source_table}
  WHERE (sk LIKE 'REQUEST_ITEM#%')
    AND (
      -- Moving 1-week ingestion window
      DATE(CAST(__year AS VARCHAR) || '-' || CAST(__month AS VARCHAR) || '-' || CAST(__day  AS VARCHAR)) >= DATE_ADD('week', -1, CURRENT_DATE)
    )
  GROUP BY clientid
) as source
ON
  source.clientid = target.clientid
WHEN MATCHED AND (source.createdtime > target.createdtime) THEN UPDATE SET
  clientname = source.clientname,
  createdtime = source.createdtime
WHEN NOT MATCHED THEN INSERT (
  clientid,
  clientname,
  createdtime
)
VALUES (
  source.clientid,
  source.clientname,
  source.createdtime
)
