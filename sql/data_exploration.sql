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
