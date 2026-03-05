--explore production orders
SELECT *
FROM raw_data.production_orders
LIMIT 20;

-- check how many production orders exist
SELECT COUNT(*)
FROM raw_data.production_orders;

--production totals by machine
SELECT machine_id,
SUM(actual_quantity_tons) AS total_production
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY total_production DESC;

-- compare planned vs actual production
SELECT
machine_id,
SUM(planned_quantity_tons) AS planned,
SUM(actual_quantity_tons) AS actual,
SUM(actual_quantity_tons - planned_quantity_tons) AS variance
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY variance DESC;

-- average downtime per machine
SELECT
machine_id,
AVG(downtime_minutes) AS avg_downtime
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY avg_downtime DESC;

-- revenue by product
SELECT
product,
SUM(order_qty_tons * price_per_ton) AS revenue
FROM raw_data.sales_orders
GROUP BY product
ORDER BY revenue DESC;

-- sales volume by delivery plant
SELECT
delivery_plant,
SUM(order_qty_tons) AS total_sales
FROM raw_data.sales_orders
GROUP BY delivery_plant
ORDER BY total_sales DESC;

SELECT
MIN(temperature_c),
MAX(temperature_c),
AVG(temperature_c)
FROM raw_data.process_sensors;

-- check pressure statistics
SELECT
MIN(pressure_bar),
MAX(pressure_bar),
AVG(pressure_bar)
FROM raw_data.process_sensors;

-- average process conditions per machine
SELECT
machine_id,
AVG(temperature_c) AS avg_temp,
AVG(pressure_bar) AS avg_pressure,
AVG(flow_rate_m3h) AS avg_flow
FROM raw_data.process_sensors
GROUP BY machine_id
ORDER BY avg_temp DESC;

-- current inventory levels by material
SELECT
material,
SUM(stock_qty) AS total_stock
FROM raw_data.inventory_levels
GROUP BY material
ORDER BY total_stock DESC;

-- supplier spend analysis
SELECT
supplier,
SUM(ordered_qty * unit_cost) AS total_spend
FROM raw_data.purchase_orders
GROUP BY supplier
ORDER BY total_spend DESC;

-- =========================================
-- MACHINE RUNTIME
-- Looking at how long production runs per machine
-- checking how long machines typically run during production
-- =========================================

SELECT
machine_id,
AVG(end_time - start_time) AS avg_runtime,
MAX(end_time - start_time) AS max_runtime
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY avg_runtime DESC;
-- runtime intervals appear very large in the synthetic dataset,
-- likely due to how timestamps were generated

-- =========================================
-- MACHINE RUNTIME IN DAYS
-- Converting runtime to days to make large intervals easier to read
-- =========================================

SELECT
machine_id,
AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS avg_runtime_days,
MAX(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS max_runtime_days
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY avg_runtime_days DESC;

-- =========================================
-- PRODUCTION EFFICIENCY
-- Checking how efficiently machines meet production targets
-- =========================================

SELECT
machine_id,
SUM(actual_quantity_tons) / NULLIF(SUM(planned_quantity_tons),0) * 100 AS efficiency_pct
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY efficiency_pct DESC;

-- =========================================
-- MACHINE THROUGHPUT
-- Comparing production per runtime day
-- This is an important comparison because
-- machine are built differently and just
-- comparing total_tons to runtime isn't useful enough
-- what is useful is throughput for investments and capacity planning.
-- =========================================

SELECT
machine_id,
SUM(actual_quantity_tons) AS total_production_tons,
SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS total_runtime_days,
SUM(actual_quantity_tons) /
NULLIF(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400),0) AS tons_per_day
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY tons_per_day DESC;

-- =========================================
-- MACHINE + PRODUCT THROUGHPUT
-- Machines produce different products so comparing machines alone
-- might not be fair. Some machines could run longer or handle
-- different product grades.
--
-- Here I first calculate total production and total runtime for each
-- machine-product combination. I do this in a subquery so the totals
-- are calculated once and then reused.
--
-- Then in the outer query I calculate throughput as tons per day.
-- This helps compare how efficiently each machine produces each
-- product type.
-- =========================================

SELECT
t.machine_id,
t.product,
t.total_production_tons,
t.total_runtime_days,
t.total_production_tons / NULLIF(t.total_runtime_days,0) AS tons_per_day
FROM (
    SELECT
    machine_id,
    product,
    SUM(actual_quantity_tons) AS total_production_tons,
    SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 86400) AS total_runtime_days
    FROM raw_data.production_orders
    GROUP BY machine_id, product
) t;

-- =========================================

-- While writing these queries I noticed that the same aggregates
-- (total production and total runtime) keep appearing in multiple
-- calculations.
--
-- This suggests that these aggregates should probably exist as a
-- reusable dataset instead of being recalculated each time.
--
-- A good approach is to create a view that holds machine totals
-- and runtime totals so other queries can reference it.
--
-- Next step: create analytics views for machine production totals
-- and use those views for further analysis and reporting.
-- =========================================
