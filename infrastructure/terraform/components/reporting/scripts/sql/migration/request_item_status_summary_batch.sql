MERGE INTO request_item_status_summary_batch as target
USING (
  SELECT
    clientid,
    campaignid,
    sendinggroupid,
    sendinggroupidversion,
    requestrefid,
    requestid,
    DATE(createdtime) AS createddate,
    COUNT(DISTINCT requestitemid) AS requestedcount,
    SUM(CASE WHEN status='DELIVERED' THEN 1 ELSE 0 END ) as deliveredcount,
    SUM(CASE WHEN status='FAILED' THEN 1 ELSE 0 END ) as failedcount,
    SUM(CASE WHEN status IN ('DELIVERED', 'FAILED') THEN 1 ELSE 0 END ) as completedcount,
    SUM(CASE WHEN status NOT IN ('DELIVERED', 'FAILED') THEN 1 ELSE 0 END ) as outstandingcount,
    SUM(CASE WHEN CONTAINS(completedcommunicationtypes, 'NHSAPP') THEN 1 ELSE 0 END ) as nhsappdeliveredcount,
    SUM(CASE WHEN CONTAINS(completedcommunicationtypes, 'EMAIL') THEN 1 ELSE 0 END ) as emaildeliveredcount,
    SUM(CASE WHEN CONTAINS(completedcommunicationtypes, 'SMS') THEN 1 ELSE 0 END ) as smsdeliveredcount,
    SUM(CASE WHEN CONTAINS(completedcommunicationtypes, 'LETTER') THEN 1 ELSE 0 END ) as letterdeliveredcount,
    SUM(CASE WHEN CONTAINS(failedcommunicationtypes, 'NHSAPP') THEN 1 ELSE 0 END ) as nhsappfailedcount,
    SUM(CASE WHEN CONTAINS(failedcommunicationtypes, 'EMAIL') THEN 1 ELSE 0 END ) as emailfailedcount,
    SUM(CASE WHEN CONTAINS(failedcommunicationtypes, 'SMS') THEN 1 ELSE 0 END ) as smsfailedcount,
    SUM(CASE WHEN CONTAINS(failedcommunicationtypes, 'LETTER') THEN 1 ELSE 0 END ) as letterfailedcount
  FROM request_item_status
  WHERE clientid IN (${batch_client_ids})
  GROUP BY
      clientid,
      campaignid,
      sendinggroupid,
      sendinggroupidversion,
      requestrefid,
      requestid,
      DATE(createdtime)
) as source
ON
  -- Allow match on null dimensions
  COALESCE(source.clientid, '') = COALESCE(target.clientid, '') AND
  COALESCE(source.campaignid, '') = COALESCE(target.campaignid, '') AND
  COALESCE(source.sendinggroupid, '') = COALESCE(target.sendinggroupid, '') AND
  COALESCE(source.sendinggroupidversion, '') = COALESCE(target.sendinggroupidversion, '') AND
  COALESCE(source.requestrefid, '') = COALESCE(target.requestrefid, '') AND
  COALESCE(source.requestid, '') = COALESCE(target.requestid, '') AND
  COALESCE(CAST(source.createddate AS varchar), '') = COALESCE(CAST(target.createddate AS varchar), '') AND
WHEN MATCHED AND
(
  source.requestedcount > target.requestedcount OR
  source.deliveredcount > target.deliveredcount OR
  source.failedcount > target.failedcount OR
  source.completedcount > target.completedcount OR
  --outstandingcount does not monotonically increase
  source.nhsappdeliveredcount > target.nhsappdeliveredcount OR
  source.emaildeliveredcount > target.emaildeliveredcount OR
  source.smsdeliveredcount > target.smsdeliveredcount OR
  source.letterdeliveredcount > target.letterdeliveredcount OR
  source.nhsappfailedcount > target.nhsappfailedcount OR
  source.emailfailedcount > target.emailfailedcount OR
  source.smsfailedcount > target.smsfailedcount OR
  source.letterfailedcount > target.letterfailedcount
)
THEN UPDATE SET
  requestedcount = source.requestedcount,
  deliveredcount = source.deliveredcount,
  failedcount = source.failedcount,
  completedcount = source.completedcount,
  outstandingcount = source.outstandingcount,
  nhsappdeliveredcount = source.nhsappdeliveredcount,
  emaildeliveredcount = source.emaildeliveredcount,
  smsdeliveredcount = source.smsdeliveredcount,
  letterdeliveredcount = source.letterdeliveredcount,
  nhsappfailedcount = source.nhsappfailedcount,
  emailfailedcount = source.emailfailedcount,
  smsfailedcount = source.smsfailedcount,
  letterfailedcount = source.letterfailedcount
WHEN NOT MATCHED THEN INSERT (
  clientid,
  campaignid,
  sendinggroupid,
  sendinggroupidversion,
  requestrefid,
  requestid,
  createddate,
  requestedcount,
  deliveredcount,
  failedcount,
  completedcount,
  outstandingcount,
  nhsappdeliveredcount,
  emaildeliveredcount,
  smsdeliveredcount,
  letterdeliveredcount,
  nhsappfailedcount,
  emailfailedcount,
  smsfailedcount,
  letterfailedcount
)
VALUES (
  source.clientid,
  source.campaignid,
  source.sendinggroupid,
  source.sendinggroupidversion,
  source.requestrefid,
  source.requestid,
  source.createddate,
  source.requestedcount,
  source.deliveredcount,
  source.failedcount,
  source.completedcount,
  source.outstandingcount,
  source.nhsappdeliveredcount,
  source.emaildeliveredcount,
  source.smsdeliveredcount,
  source.letterdeliveredcount,
  source.nhsappfailedcount,
  source.emailfailedcount,
  source.smsfailedcount,
  source.letterfailedcount
)
