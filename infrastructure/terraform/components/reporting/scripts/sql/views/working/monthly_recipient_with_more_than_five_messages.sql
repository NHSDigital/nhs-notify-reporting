CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    createdmonth,
    monthlytotalmessages,
    nhsnumberhash,
    clientid,
    SUM(CASE WHEN communicationtype = 'NHSAPP' THEN messagedeliveredcount ELSE 0 END) AS AppDelivered,
    SUM(CASE WHEN communicationtype = 'EMAIL' THEN messagedeliveredcount ELSE 0 END) AS EmailDelivered,
    SUM(CASE WHEN communicationtype = 'SMS' THEN messagedeliveredcount ELSE 0 END) AS SMSDelivered,
    SUM(CASE WHEN communicationtype = 'LETTER' THEN messagedeliveredcount ELSE 0 END) AS LetterDelivered
FROM (
    SELECT
        DATE(DATE_TRUNC('month', createdtime)) AS createdmonth,
        nhsnumberhash,
        communicationtype,
        clientid,
        COUNT(*) AS messagedeliveredcount,
        SUM(COUNT(*)) OVER (
            PARTITION BY DATE(DATE_TRUNC('month', createdtime)), nhsnumberhash
        ) AS monthlytotalmessages
    FROM request_item_status
    CROSS JOIN UNNEST(completedcommunicationtypes) AS t(communicationtype)
    WHERE status = 'DELIVERED'
    GROUP BY 1, 2, 3, 4
)
WHERE monthlytotalmessages >= 5
GROUP BY 1, 2, 3, 4
