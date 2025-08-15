CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    ri.clientid as clientid,
    ri.requestid as requestid,
    ri.requestrefid as requestrefid,
    ri.requestitemid as requestitemid,
    ri.requestitemrefid as requestitemrefid,
    substring(cast(to_iso8601(ri.completedtime) as varchar), 1, 23) || 'Z' as requestitemcompletedtime,
    ri.failedreason as requestitemfailedreason,
    ri.sendinggroupid as sendinggroupid,
    ri.sendinggroupidversion as sendinggroupidversion,
    ri.sendinggroupname as sendinggroupname,
    substring(cast(to_iso8601(ri.sendinggroupcreatedtime) as varchar), 1, 23) || 'Z' as sendinggroupcreatedtime,
    ri.status as requestitemstatus,
    rip.requestitemplanid as requestitemplanid,
    substring(cast(to_iso8601(rip.completedtime) as varchar), 1, 23) || 'Z' as requestitemplancompletedtime,
    rip.status as requestitemplanstatus,
    rip.communicationtype as communicationtype,
    rip.channeltype as channeltype,
    rip.failedreason as requestitemplanfailedreason,
    rip.templatename as templatename
FROM request_item_status ri
LEFT OUTER JOIN request_item_plan_status rip ON
    ri.requestitemid = rip.requestitemid AND
    ri.clientid = rip.clientid
WHERE
    (rip.status IN ('FAILED', 'DELIVERED', 'SKIPPED') OR (ri.status IN ('FAILED') AND rip.requestitemplanid IS NULL)) AND
    --Prevent scanning of all possible created dates
    (ri.createdtime IS NULL OR ri.createdtime >= DATE(DATE_ADD('day', -90, CURRENT_DATE))) AND
    (rip.createdtime IS NULL OR rip.createdtime >= DATE(DATE_ADD('day', -90, CURRENT_DATE)))
ORDER BY clientid, requestid, requestitemid, requestitemplanid
