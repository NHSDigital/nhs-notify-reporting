WITH joined_request_item_plans AS (
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
    rip.status,
    rip.sendtime
  FROM request_item_plan_status rip
  INNER JOIN request_item_status ri
    ON rip.clientid = ri.clientid
    AND rip.requestitemid = ri.requestitemid
  WHERE ri.clientid != ${sms_nudge_client_id}
  UNION ALL
  SELECT
    DATE(completedtime) AS billingdate,
    originatingclientid AS clientid,
    originatingcampaignid AS campaignid,
    originatingbillingrefid AS billingref,
    NULL AS senderodscode,
    communicationtype,
    specificationid,
    specificationbillingid,
    messagelength,
    messagelengthunits,
    status,
    sendtime
  FROM request_item_plan_status_smsnudge
)

SELECT
  billingdate,
  clientid,
  campaignid,
  billingref,
  senderodscode,
  communicationtype,
  specificationid,
  specificationbillingid,
  messagelength,
  messagelengthunits,
  COUNT(*) AS messagecount
FROM joined_request_item_plans
WHERE
  billingdate IS NOT NULL
  AND (
    (
      -- Bill for all text messages forwarded to the supplier
      (communicationtype = 'SMS') AND (status IN ('DELIVERED', 'FAILED')) AND (sendtime IS NOT NULL)
    )
    OR (
      -- Bill for all letters accepted by the supplier
      (communicationtype = 'LETTER') AND (status = 'DELIVERED')
    )
  )
GROUP BY
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10
ORDER BY
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
