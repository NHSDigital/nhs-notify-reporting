SELECT rip_success.requestitemid, rip_success.completedtime, rip_success.communicationtype, rip_success.recipientcontactid
FROM (
    SELECT ri.nhsnumberhash, rip.communicationtype, ri.requestitemid AS secondrequestitemid,
      LAG(ri.requestitemid,1) OVER (PARTITION BY ri.nhsnumberhash, rip.communicationtype ORDER BY ri.createdtime) AS firstrequestitemid
    FROM request_item_status ri
    INNER JOIN request_item_plan_status rip ON
      rip.requestitemid = ri.requestitemid
    WHERE (rip.communicationtype = 'EMAIL' OR rip.communicationtype = 'SMS')
) AS tx
INNER JOIN request_item_plan_status rip_success ON
  rip_success.requestitemid = tx.secondrequestitemid AND
  rip_success.communicationtype = tx.communicationtype
INNER JOIN request_item_plan_status rip_failed ON
  rip_failed.requestitemid = firstrequestitemid AND
  rip_failed.communicationtype = tx.communicationtype
WHERE
  rip_success.communicationtype IN ('SMS', 'EMAIL') AND
  rip_success.communicationtype = rip_failed.communicationtype AND
  rip_success.status = 'DELIVERED' AND
  rip_failed.status = 'FAILED' AND
  (rip_failed.failedreason LIKE '%TEMPORARY%' OR rip_failed.failedreason LIKE '%PERMANENT%')
ORDER BY rip_success.completedtime
