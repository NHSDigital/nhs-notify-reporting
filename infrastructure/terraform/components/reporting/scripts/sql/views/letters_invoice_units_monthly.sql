CREATE OR REPLACE VIEW ${view_name} AS
SELECT clientid, campaignid, supplier, YEAR(invoicetime) AS invoiceyear, MONTH(invoicetime) AS invoicemonth, COUNT(*) AS unitcount
FROM (
    SELECT clientid, campaignid, supplier,
        CASE
            WHEN supplier='MBA' THEN
                CASE
                    WHEN DAY_OF_WEEK(sendtime)=4 THEN DATE_ADD('day', 4, sendtime)
                    WHEN DAY_OF_WEEK(sendtime)=5 THEN DATE_ADD('day', 4, sendtime)
                    WHEN DAY_OF_WEEK(sendtime)=6 THEN DATE_ADD('day', 4, sendtime)
                    WHEN DAY_OF_WEEK(sendtime)=7 THEN DATE_ADD('day', 3, sendtime)
                    ELSE DATE_ADD('day', 2, sendtime)
                END
            ELSE sendtime
        END AS invoicetime
    FROM request_item_plan_status
    WHERE communicationtype='LETTER'
    AND sendtime IS NOT NULL
    AND status='DELIVERED'
)
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3, 4, 5
