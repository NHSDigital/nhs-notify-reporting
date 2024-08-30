MERGE INTO request_item_plan_completed_summary as target
USING (
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    supplier,
    createddate,
    completeddate,
    status,
    failedreason,
    count(distinct requestitemid) AS requestitemcount
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (
        partition BY sk ORDER BY
        timestamp DESC,
        length(coalesce(completeddate, '')) DESC
      ) AS rownumber
    FROM (
      SELECT
        requestitemid,
        sk,
        clientid,
        NULL AS campaignid,
        sendinggroupid,
        communicationtype,
        supplier,
        DATE(SUBSTRING(createddate,1,10)) as createddate,
        DATE(SUBSTRING(completeddate,1,10)) as completeddate,
        status,
        failedreason,
        CAST("$classification".timestamp AS BIGINT) * 1000 AS timestamp --transaction_history_old has second granularity timestamps
      FROM transaction_history_old
      WHERE (status = 'DELIVERED' OR status = 'FAILED') AND (sk LIKE 'REQUEST_ITEM_PLAN#%')
      UNION
      SELECT
        requestitemid,
        sk,
        clientid,
        campaignid,
        sendinggroupid,
        communicationtype,
        supplier,
        DATE(SUBSTRING(createddate,1,10)) as createddate,
        DATE(SUBSTRING(completeddate,1,10)) as completeddate,
        status,
        failedreason,
        CAST("$classification".timestamp AS BIGINT) AS timestamp
      FROM transaction_history
      WHERE (status = 'DELIVERED' OR status = 'FAILED') AND (sk LIKE 'REQUEST_ITEM_PLAN#%')
    )
  )
  WHERE rownumber = 1
  GROUP BY
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    supplier,
    createddate,
    completeddate,
    status,
    failedreason
) as source
ON
  -- Allow match on null dimensions
  COALESCE(source.clientid, '') = COALESCE(target.clientid, '') AND
  COALESCE(source.campaignid, '') = COALESCE(target.campaignid, '') AND
  COALESCE(source.sendinggroupid, '') = COALESCE(target.sendinggroupid, '') AND
  COALESCE(source.communicationtype, '') = COALESCE(target.communicationtype, '') AND
  COALESCE(source.supplier, '') = COALESCE(target.supplier, '') AND
  COALESCE(CAST(source.createddate AS varchar), '') = COALESCE(CAST(target.createddate AS varchar), '') AND
  COALESCE(CAST(source.completeddate AS varchar), '') = COALESCE(CAST(target.completeddate AS varchar), '') AND
  COALESCE(source.status, '') = COALESCE(target.status, '') AND
  COALESCE(source.failedreason, '') = COALESCE(target.failedreason, '')
WHEN MATCHED AND (source.requestitemcount > target.requestitemcount) THEN UPDATE SET requestitemcount = source.requestitemcount
WHEN NOT MATCHED THEN INSERT (
  clientid,
  campaignid,
  sendinggroupid,
  communicationtype,
  supplier,
  createddate,
  completeddate,
  status,
  failedreason,
  requestitemcount
)
VALUES (
  source.clientid,
  source.campaignid,
  source.sendinggroupid,
  source.communicationtype,
  source.supplier,
  source.createddate,
  source.completeddate,
  source.status,
  source.failedreason,
  source.requestitemcount
)
