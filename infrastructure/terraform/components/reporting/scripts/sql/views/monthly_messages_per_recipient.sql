CREATE OR REPLACE VIEW ${view_name} AS
WITH message_counts AS (
    SELECT
        createdmonth,
        communicationtype,
        COUNT(*) AS messagedeliveredcount
    FROM delivered_messages
    GROUP BY 1, 2
),
monthly_recipient_counts AS (
    SELECT
        createdmonth,
        COUNT(DISTINCT nhsnumberhash) AS totalmonthlyrecipients
    FROM delivered_messages
    GROUP BY 1
)

SELECT
    m.createdmonth,
    m.communicationtype,
    r.totalmonthlyrecipients,
    m.messagedeliveredcount,
    (m.messagedeliveredcount * 1.0) / (r.totalmonthlyrecipients * 1.0) AS averagemessagesperecipient
FROM message_counts m
JOIN monthly_recipient_counts r
    ON m.createdmonth = r.createdmonth
