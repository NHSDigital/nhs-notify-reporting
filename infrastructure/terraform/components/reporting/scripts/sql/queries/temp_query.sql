SELECT
  requestitemid,
  TO_BASE64(SHA256(CAST(? || '.' || requestitemid AS varbinary))) as requestitemhash
FROM ${source_table}
WHERE (sk LIKE 'REQUEST_ITEM#%')
LIMIT 1;
