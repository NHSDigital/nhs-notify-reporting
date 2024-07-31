SELECT
  requestitemid,
  TO_BASE64(SHA256(CAST('env_secret' || '.' || requestitemid AS varbinary))) as requestitemhash
FROM ${source_table}
WHERE (sk LIKE 'REQUEST_ITEM#%')
LIMIT 10;