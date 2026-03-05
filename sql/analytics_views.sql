-- =========================================
-- ANALYTICS VIEWS
-- These views build on the raw production data.
-- During EDA I noticed that some aggregates like
-- total production and runtime were being repeated
-- in multiple queries.
--
-- Instead of recalculating them every time, I am
-- creating views so these aggregates can be reused
-- for further analysis and later for Power BI.
--Earlier I created test views hence create or replace is used.
-- =========================================



-- =========================================
-- VIEW: MACHINE PRODUCTION
-- Total production per machine.
-- =========================================
CREATE OR REPLACE VIEW analytics.vw_machine_production AS
SELECT
machine_id,
SUM(actual_quantity_tons) AS total_production_tons
FROM raw_data.production_orders
GROUP BY machine_id;



-- =========================================
-- VIEW: PRODUCTION PERFORMANCE
-- Comparing planned production vs actual
-- production to see if machines are meeting
-- targets or underperforming.
-- =========================================
CREATE OR REPLACE VIEW analytics.vw_production_performance AS
SELECT
machine_id,
SUM(planned_quantity_tons) AS planned_production,
SUM(actual_quantity_tons) AS actual_production,
SUM(actual_quantity_tons - planned_quantity_tons) AS production_variance
FROM raw_data.production_orders
GROUP BY machine_id;



-- =========================================
-- VIEW: MACHINE PRODUCT TOTALS
-- Machines can produce different products,
-- so looking at totals per machine alone
-- might hide some patterns.
--
-- This view calculates production and runtime
-- for each machine-product combination.
-- =========================================
CREATE OR REPLACE VIEW analytics.vw_machine_product_totals AS
SELECT
machine_id,
product,
SUM(actual_quantity_tons) AS total_production_tons,
SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS total_runtime_days
FROM raw_data.production_orders
GROUP BY machine_id, product;



-- =========================================
-- VIEW: MACHINE PRODUCT THROUGHPUT
-- Using the totals from the previous view to
-- calculate throughput in tons per runtime day.
-- =========================================
CREATE OR REPLACE VIEW analytics.vw_machine_product_throughput AS
SELECT
machine_id,
product,
total_production_tons,
total_runtime_days,
total_production_tons /
NULLIF(total_runtime_days,0) AS tons_per_day
FROM analytics.vw_machine_product_totals;
