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
        (DATE(from_iso8601_timestamp(requestitemplancompletedtime)) = DATE(?)) OR
        (requestitemplanid IS NULL AND DATE(from_iso8601_timestamp(requestitemcompletedtime)) = DATE(?))
    )
