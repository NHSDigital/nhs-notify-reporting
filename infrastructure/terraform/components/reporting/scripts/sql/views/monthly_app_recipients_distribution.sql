CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    appmessagecount,
    COUNT(*) AS recipientcount
FROM (
    SELECT
        createdmonth,
        nhsnumberhash,
        COUNT(*) AS appmessagecount
    FROM delivered_messages
    WHERE communicationtype = 'NHSAPP'
    GROUP BY 1, 2
)
GROUP BY 1, 2
