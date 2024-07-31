MERGE INTO completed_request_item_plan_summary as target
USING (
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    supplier,
    DATE(SUBSTRING(createddate,1,10)) as createddate,
    DATE(SUBSTRING(completeddate,1,10)) as completeddate,
    status,
    failedreason,
    count(distinct requestitemid) AS requestitemcount
  FROM ${source_table}
  WHERE (status = 'DELIVERED' OR status = 'FAILED') AND (sk LIKE 'REQUEST_ITEM_PLAN#%') AND
    (
      -- Moving 1-month ingestion window
      (__month=MONTH(CURRENT_DATE) AND __year=YEAR(CURRENT_DATE)) OR
      (__month=MONTH(DATE_ADD('month', -1, CURRENT_DATE)) AND __year=YEAR(DATE_ADD('month', -1, CURRENT_DATE)) AND __day >= DAY(CURRENT_DATE))
    )
  GROUP BY
    clientid,
    campaignid,
    sendinggroupid,
    communicationtype,
    supplier,
    DATE(SUBSTRING(createddate,1,10)),
    DATE(SUBSTRING(completeddate,1,10)),
    status,
    failedreason
) as source
ON
  -- Allow aggregation of null dimensions
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
