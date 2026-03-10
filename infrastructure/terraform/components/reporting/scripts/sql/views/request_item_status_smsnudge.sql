CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  ris.*,
  rips.originatingsendinggroupid
FROM request_item_status_smsnudge_staging ris
LEFT JOIN request_item_plan_status_smsnudge rips
  ON ris.requestitemid = rips.requestitemid
