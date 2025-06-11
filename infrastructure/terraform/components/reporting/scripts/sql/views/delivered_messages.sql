CREATE OR REPLACE VIEW ${view_name} AS
SELECT
    DATE(createdtime) AS createddate,
    DATE(DATE_TRUNC('month', createdtime)) AS createdmonth,
    nhsnumberhash,
    clientid,
    t.communicationtype,
    requestitemid
FROM request_item_status
CROSS JOIN UNNEST(completedcommunicationtypes) AS t(communicationtype)
WHERE status = 'DELIVERED'
