-- =========================================
-- ANALYTICS VIEWS
-- These views build on the raw production data.
-- During EDA I noticed some aggregates like
-- production totals and runtime were repeating
-- in different queries.
--
-- Instead of recalculating them each time,
-- I created views so the results can be reused
-- for further analysis and later connected to
-- Power BI dashboards.
-- =========================================



-- =========================================
-- VIEW: MACHINE PRODUCTION
-- Aggregates total production per machine
-- =========================================
DROP VIEW IF EXISTS analytics.vw_machine_production;

CREATE VIEW analytics.vw_machine_production AS
SELECT
machine_id,
SUM(actual_quantity_tons) AS total_production_tons
FROM raw_data.production_orders
GROUP BY machine_id;



-- =========================================
-- VIEW: PRODUCTION PERFORMANCE
-- Compares planned vs actual production
-- =========================================
DROP VIEW IF EXISTS analytics.vw_production_performance;

CREATE VIEW analytics.vw_production_performance AS
SELECT
machine_id,
SUM(planned_quantity_tons) AS planned_production,
SUM(actual_quantity_tons) AS actual_production,
SUM(actual_quantity_tons - planned_quantity_tons) AS production_variance
FROM raw_data.production_orders
GROUP BY machine_id;



-- =========================================
-- VIEW: MACHINE PRODUCT TOTALS
-- Aggregates production and runtime for each
-- machine-product combination
-- =========================================
CREATE VIEW analytics.vw_machine_product_totals AS
SELECT
machine_id,
product,
SUM(actual_quantity_tons) AS total_production_tons,
SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS total_runtime_days
FROM raw_data.production_orders
GROUP BY machine_id, product;



-- =========================================
-- VIEW: MACHINE PRODUCT THROUGHPUT
-- Calculates throughput in tons per runtime day
-- =========================================
CREATE VIEW analytics.vw_machine_product_throughput AS
SELECT
machine_id,
product,
total_production_tons,
total_runtime_days,
total_production_tons /
NULLIF(total_runtime_days,0) AS tons_per_day
FROM analytics.vw_machine_product_totals;
