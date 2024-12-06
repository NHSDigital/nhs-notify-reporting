CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    ri.clientid as clientid
    ri.requestId as requestid,
    ri.requestRefId as requestrefid,
    ri.requestitemid AS requestitemid,
    ri.requestItemRefId as requestitemrefid,
    DATE(ri.completedtime) AS requestitemcompleteddate,
    ri.failedReason as requestitemfailedreason,
    ri.sendingGroupId as sendinggroupid,
    ri.sendingGroupIdVersion as sendinggroupidversion,
    ri.sendingGroupName as sendinggroupname,
    ri.sendingGroupCreatedDate as sendinggroupcreateddate,
    ri.status AS requestitemstatus,
    rip.requestitemplanid AS requestitemplanid,
    DATE(rip.completedtime) AS requestitemplancompleteddate,
    rip.status AS requestitemplanstatus,
    rip.communicationtype AS communicationtype,
    rip.channeltype AS channeltype,
    rip.failedReason as requestitemplanfailedreason
FROM request_item_status ri
LEFT OUTER JOIN request_item_plan_status rip ON
    ri.requestitemid = rip.requestitemid AND
    ri.clientid = rip.clientid
WHERE
    rip.status IN ('FAILED', 'DELIVERED') OR
    (ri.status IN ('FAILED') AND rip.requestitemplanid IS NULL)
