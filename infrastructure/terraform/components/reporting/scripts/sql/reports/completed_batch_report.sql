SELECT
    requestid,
    requestrefid,
    requestitemid,
    requestitemrefid,
    requestitemcompleteddate,
    requestitemfailedreason,
    sendinggroupid,
    sendinggroupidversion,
    sendinggroupname,
    sendinggroupcreateddate,
    requestitemstatus,
    requestitemplanid,
    requestitemplancompleteddate,
    requestitemplanstatus,
    communicationtype,
    channeltype,
    requestitemplanfailedreason
FROM completed_comms
WHERE clientid = ? AND requestid = ?