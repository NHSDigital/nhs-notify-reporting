MERGE INTO request_item_status as target
USING (
	SELECT
    clientid,
    campaignid,
    sendinggroupid,
    requestitemid,
    requestrefid,
    requestid,
    any_value(to_base64(sha256(cast(? || '.' || nhsnumber AS varbinary)))) AS nhsnumberhash,
    any_value(DATE(SUBSTRING(createddate,1,10))) AS createddate,
    any_value(DATE(SUBSTRING(completeddate,1,10))) AS completeddate,
    array_distinct(flatten(array_agg(completedcommunicationtypes))) AS completedcommunicationtypes,
    array_distinct(flatten(array_agg(failedcommunicationtypes))) AS failedcommunicationtypes,
    bool_or(case status when 'DELIVERED' then true else false end) AS delivered,
    bool_or(case status when 'FAILED' then true else false end) AS failed
  FROM ${source_table}
  WHERE (sk LIKE 'REQUEST_ITEM#%') AND
    (
      -- Moving 1-month ingestion window
      (__month=MONTH(CURRENT_DATE) AND __year=YEAR(CURRENT_DATE)) OR
      (__month=MONTH(DATE_ADD('month', -1, CURRENT_DATE)) AND __year=YEAR(DATE_ADD('month', -1, CURRENT_DATE)) AND __day >= DAY(CURRENT_DATE))
    )
  GROUP BY
    clientid,
    campaignid,
    sendinggroupid,
    requestitemid,
    requestrefid,
    requestid
) as source
ON
  -- Allow match on null dimensions
  COALESCE(source.clientid, '') = COALESCE(target.clientid, '') AND
  COALESCE(source.campaignid, '') = COALESCE(target.campaignid, '') AND
  COALESCE(source.sendinggroupid, '') = COALESCE(target.sendinggroupid, '') AND
  COALESCE(source.requestitemid, '') = COALESCE(target.requestitemid, '') AND
  COALESCE(source.requestrefid, '') = COALESCE(target.requestrefid, '') AND
  COALESCE(source.requestid, '') = COALESCE(target.requestid, '')
WHEN MATCHED THEN UPDATE SET 
  nhsnumberhash = COALESCE(source.nhsnumberhash, target.nhsnumberhash),
  createddate = COALESCE(source.createddate, target.createddate),
  completeddate = COALESCE(source.completeddate, target.completeddate),
  completedcommunicationtypes = array_union(source.completedcommunicationtypes, target.completedcommunicationtypes),
  failedcommunicationtypes = array_union(source.failedcommunicationtypes, target.failedcommunicationtypes),
  delivered = source.delivered OR target.delivered,
  failed = source.failed OR target.failed
WHEN NOT MATCHED THEN INSERT (
  clientid,
  campaignid,
  sendinggroupid,
  requestitemid,
  requestrefid,
  requestid,
  nhsnumberhash,
  createddate,
  completeddate,
  completedcommunicationtypes,
  failedcommunicationtypes,
  delivered,
  failed
)
VALUES (
  source.clientid,
  source.campaignid,
  source.sendinggroupid,
  source.requestitemid,
  source.requestrefid,
  source.requestid,
  source.nhsnumberhash,
  source.createddate,
  source.completeddate,
  source.completedcommunicationtypes,
  source.failedcommunicationtypes,
  source.delivered,
  source.failed
)
