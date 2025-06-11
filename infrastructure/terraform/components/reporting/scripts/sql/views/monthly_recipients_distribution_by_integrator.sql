CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    clientid,
    messagedeliveredcount,
    COUNT(DISTINCT nhsnumberhash) AS recipientcount
FROM (
    SELECT
        createdmonth,
        clientid,
        nhsnumberhash,
        COUNT(*) AS messagedeliveredcount
    FROM delivered_messages
    GROUP BY 1, 2, 3
)
GROUP BY 1, 2, 3
