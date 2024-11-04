SELECT
    ri.requestitemid AS requestitemid,
    ri.clientid AS clientid,
    DATE(ri.createdtime) AS requestitemcreateddate,
    ri.status AS requestitemstatus,
    rip.requestitemplanid AS requestitemplanid,
    DATE(rip.completedtime) AS requestitemplancompleteddate,
    rip.status AS requestitemplanstatus,
    rip.communicationtype AS communicationtype,
    rip.channeltype AS channeltype
FROM request_item_status ri
LEFT OUTER JOIN request_item_plan_status rip ON
    ri.requestitemid = rip.requestitemid AND
    ri.clientid = rip.clientid
WHERE
    ri.clientid = ? AND
    ri.status IN ('FAILED', 'DELIVERED') AND
    (
        rip.status is null OR
        rip.status IN ('FAILED', 'DELIVERED', 'SKIPPED')
    ) AND
    (
        DATE(ri.completedtime) = DATE(?) OR DATE(rip.completedtime) = DATE(?)
    )
