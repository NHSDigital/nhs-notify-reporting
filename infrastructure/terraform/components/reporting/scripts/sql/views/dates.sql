CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  CAST(t.date AS DATE) datevalue,
  year(t.date) year,
  month(t.date) month,
  day(t.date) day
FROM (
  SELECT sequence(DATE('2023-06-01'), DATE(CURRENT_DATE), INTERVAL '1' DAY) dates
),
UNNEST(dates) t (date)
