CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    clientcount,
    COUNT(*) AS recipientcount
FROM (
    SELECT
        createdmonth,
        nhsnumberhash,
        COUNT(DISTINCT clientid) AS clientcount
    FROM delivered_messages
    WHERE communicationtype = 'NHSAPP'
    GROUP BY 1, 2
    HAVING COUNT(DISTINCT clientid) > 1
)
GROUP BY 1, 2
