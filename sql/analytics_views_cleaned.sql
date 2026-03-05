-- =========================================
-- CLEANED ANALYTICS VIEWS
-- After creating the first views I noticed
-- a few things that could cause problems
-- like missing machine ids or invalid
-- runtimes.
--
-- Instead of changing the raw tables I made
-- cleaned versions of the views. This keeps
-- the original data as it is but lets the
-- analysis use cleaner records.
-- =========================================



-- =========================================
-- CLEANED VIEW: MACHINE PRODUCTION
-- Removes rows with missing machines or
-- negative production values
-- =========================================
CREATE VIEW analytics.vw_machine_production_cleaned AS
SELECT
machine_id,
SUM(actual_quantity_tons) AS total_production_tons
FROM raw_data.production_orders
WHERE
machine_id IS NOT NULL
AND actual_quantity_tons >= 0
GROUP BY machine_id;



-- =========================================
-- CLEANED VIEW: PRODUCTION PERFORMANCE
-- Ensures production values are valid
-- =========================================
CREATE VIEW analytics.vw_production_performance_cleaned AS
SELECT
machine_id,
SUM(planned_quantity_tons) AS planned_production,
SUM(actual_quantity_tons) AS actual_production,
SUM(actual_quantity_tons - planned_quantity_tons) AS production_variance
FROM raw_data.production_orders
WHERE
machine_id IS NOT NULL
AND planned_quantity_tons >= 0
AND actual_quantity_tons >= 0
GROUP BY machine_id;



-- =========================================
-- CLEANED VIEW: MACHINE PRODUCT TOTALS
-- Removes invalid runtimes and missing machines
-- =========================================
CREATE VIEW analytics.vw_machine_product_totals_cleaned AS
SELECT
machine_id,
product,
SUM(actual_quantity_tons) AS total_production_tons,
SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS total_runtime_days
FROM raw_data.production_orders
WHERE
machine_id IS NOT NULL
AND end_time > start_time
AND actual_quantity_tons >= 0
GROUP BY machine_id, product;



-- =========================================
-- CLEANED VIEW: MACHINE PRODUCT THROUGHPUT
-- Calculates throughput using cleaned totals
-- =========================================
CREATE VIEW analytics.vw_machine_product_throughput_cleaned AS
SELECT
machine_id,
product,
total_production_tons,
total_runtime_days,
total_production_tons /
NULLIF(total_runtime_days,0) AS tons_per_day
FROM analytics.vw_machine_product_totals_cleaned;
