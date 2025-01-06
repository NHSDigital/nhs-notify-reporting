SELECT
    requestid,
    requestrefid,
    requestitemid,
    requestitemrefid,
    requestitemcompletedtime,
    requestitemfailedreason,
    sendinggroupid,
    sendinggroupidversion,
    sendinggroupname,
    sendinggroupcreatedtime,
    requestitemstatus,
    requestitemplanid,
    requestitemplancompletedtime,
    requestitemplanstatus,
    communicationtype,
    channeltype,
    requestitemplanfailedreason
FROM completed_comms
WHERE
    clientid = ? AND
    (
        (DATE(requestitemplancompletedtime) = DATE(?)) OR
        (requestitemplanid IS NULL AND DATE(requestitemcompletedtime) = DATE(?))
    )
