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
    rip.completedtime IS NOT NULL AND
    (
        (
            --Bill for all text messages forwarded to the supplier
            (rip.communicationtype ='SMS') AND (rip.status IN ('DELIVERED', 'FAILED')) AND (sendtime IS NOT NULL)
        ) OR (
            --Bill for all letters accepted by the supplier
            (rip.communicationtype ='LETTER') AND (rip.status='DELIVERED')
        )
    )
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
