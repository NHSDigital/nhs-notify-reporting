CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    monthlytotalmessages,
    COUNT(*) AS recipientcount
FROM (
    SELECT
        createdmonth,
        nhsnumberhash,
        COUNT(*) AS monthlytotalmessages
    FROM delivered_messages
    GROUP BY 1, 2
)
GROUP BY 1, 2
