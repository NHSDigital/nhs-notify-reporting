CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    monthlytotalmessages,
    nhsnumberhash,
    clientid,
    SUM(CASE WHEN communicationtype = 'NHSAPP' THEN messagesdelivered ELSE 0 END) AS appdelivered,
    SUM(CASE WHEN communicationtype = 'EMAIL' THEN messagesdelivered ELSE 0 END) AS emaildelivered,
    SUM(CASE WHEN communicationtype = 'SMS' THEN messagesdelivered ELSE 0 END) AS smsdelivered,
    SUM(CASE WHEN communicationtype = 'LETTER' THEN messagesdelivered ELSE 0 END) AS letterdelivered
FROM (
    SELECT
        createdmonth,
        nhsnumberhash,
        communicationtype,
        clientid,
        COUNT(*) AS messagesdelivered,
        SUM(COUNT(*)) OVER (PARTITION BY createdmonth, nhsnumberhash) AS monthlytotalmessages
    FROM delivered_messages
    GROUP BY 1, 2, 3, 4
)
WHERE monthlytotalmessages >= 5
GROUP BY 1, 2, 3, 4

