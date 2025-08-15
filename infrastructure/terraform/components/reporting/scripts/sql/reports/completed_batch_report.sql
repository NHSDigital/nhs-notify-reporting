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
    requestitemplanfailedreason,
    templatename
FROM completed_comms
WHERE clientid = ? AND requestid = ?
