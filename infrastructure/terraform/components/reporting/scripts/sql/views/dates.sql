CREATE OR REPLACE VIEW ${view_name} AS
SELECT
  CAST(t.date AS DATE) datevalue,
  year(t.date) year,
  month(t.date) month,
  day(t.date) day
FROM (
  SELECT sequence(DATE('2023-01-01'), DATE(concat(cast(YEAR(current_date) as varchar), '-12-31')), INTERVAL '1' DAY) dates
),
UNNEST(dates) t (date)
