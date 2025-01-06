CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    ri.clientid as clientid,
    ri.requestid as requestid,
    ri.requestrefid as requestrefid,
    ri.requestitemid AS requestitemid,
    ri.requestitemrefid as requestitemrefid,
    DATE(ri.completedtime) AS requestitemcompleteddate,
    ri.failedreason as requestitemfailedreason,
    ri.sendinggroupid as sendinggroupid,
    ri.sendinggroupidversion as sendinggroupidversion,
    ri.sendinggroupname as sendinggroupname,
    ri.sendinggroupcreateddate as sendinggroupcreateddate,
    ri.status AS requestitemstatus,
    rip.requestitemplanid AS requestitemplanid,
    DATE(rip.completedtime) AS requestitemplancompleteddate,
    rip.status AS requestitemplanstatus,
    rip.communicationtype AS communicationtype,
    rip.channeltype AS channeltype,
    rip.failedreason as requestitemplanfailedreason
FROM request_item_status ri
LEFT OUTER JOIN request_item_plan_status rip ON
    ri.requestitemid = rip.requestitemid AND
    ri.clientid = rip.clientid
WHERE
    rip.status IN ('FAILED', 'DELIVERED', 'SKIPPED') OR
    (ri.status IN ('FAILED') AND rip.requestitemplanid IS NULL)
ORDER BY clientid, requestid, requestitemid, requestitemplanid
