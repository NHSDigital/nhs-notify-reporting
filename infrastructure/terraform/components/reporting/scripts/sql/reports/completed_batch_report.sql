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
    requestitemplanfailedreasoncode,
    requestitemfailedreasoncode
FROM completed_comms
WHERE clientid = ? AND requestid = ?
