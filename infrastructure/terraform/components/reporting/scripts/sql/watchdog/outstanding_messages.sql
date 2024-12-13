SELECT clientid, SUM(outstandingcount) FROM request_item_status_summary WHERE
createddate <= DATE_ADD('week', -2, CURRENT_DATE) AND
createddate >= DATE_ADD('day', -90, CURRENT_DATE)
GROUP BY clientid
