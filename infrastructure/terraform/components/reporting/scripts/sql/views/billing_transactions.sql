CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    DATE(rip.completedtime) AS billingdate,
    rip.clientid,
    rip.campaignid,
    ri.billingref,
    rip.senderodscode,
    rip.communicationtype,
    rip.specificationid,
    rip.specificationbillingid,
    rip.messagelength,
    rip.messagelengthunits,
    COUNT(*) AS messagecount
FROM request_item_plan_status rip
INNER JOIN request_item_status ri
ON
    rip.clientid = ri.clientid AND
    rip.requestitemid = ri.requestitemid
WHERE
    rip.status='DELIVERED' AND
    rip.communicationtype IN ('SMS', 'LETTER') AND
    rip.completedtime IS NOT NULL
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
