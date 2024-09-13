OPTIMIZE request_item_status
REWRITE DATA USING BIN_PACK
WHERE createdtime >= DATE_ADD('month', -3, CURRENT_DATE)
