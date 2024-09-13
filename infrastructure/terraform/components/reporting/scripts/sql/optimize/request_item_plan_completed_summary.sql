OPTIMIZE request_item_plan_completed_summary
REWRITE DATA USING BIN_PACK
WHERE createddate >= DATE_ADD('month', -3, CURRENT_DATE)
