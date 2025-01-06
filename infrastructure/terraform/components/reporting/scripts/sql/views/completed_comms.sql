CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    ri.clientid as clientid,
    ri.requestid as requestid,
    ri.requestrefid as requestrefid,
    ri.requestitemid AS requestitemid,
    ri.requestitemrefid as requestitemrefid,
    to_iso8601(ri.completedtime) AS requestitemcompletedtime,
    ri.failedreason as requestitemfailedreason,
    ri.sendinggroupid as sendinggroupid,
    ri.sendinggroupidversion as sendinggroupidversion,
    ri.sendinggroupname as sendinggroupname,
    to_iso8601(ri.sendinggroupcreatedtime) as sendinggroupcreatedtime,
    ri.status AS requestitemstatus,
    rip.requestitemplanid AS requestitemplanid,
    to_iso8601(rip.completedtime) AS requestitemplancompletedtime,
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
