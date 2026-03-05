-- =========================================
-- DATABASE SETUP
-- Manufacturing Reporting Analytics Project
--
-- ChatGPT generated the dataset based on my past work experience
-- in manufacturing, production systems, instrumentation and
-- some chemical engineering concepts.
--
-- The tables were created in CSV format. I looked through the
-- data in Excel first to understand the structure and then
-- exported/imported the files into my PostgreSQL server.
--
-- After checking the data in Excel it looked cleaner than I
-- expected, which made the first round of exploration easier.
-- =========================================

-- create schemas
CREATE SCHEMA raw_data;
CREATE SCHEMA analytics;

-- =========================================
-- RAW DATA TABLES
--
-- I created these tables using the pgAdmin interface and the SQL
-- code below. Doing this helped me understand better how schemas
-- and tables work in PostgreSQL.
--
-- I looked at the data in Excel first to get a sense of the columns
-- and used that to decide the formats like TEXT and NUMERIC before
-- importing the CSV files.
-- =========================================


-- machines table
CREATE TABLE raw_data.machines (
    machine_id TEXT,
    plant TEXT,
    machine_type TEXT,
    commission_year INT
);

-- production orders
CREATE TABLE raw_data.production_orders (
    production_order_id TEXT,
    machine_id TEXT,
    product TEXT,
    planned_quantity_tons NUMERIC,
    actual_quantity_tons NUMERIC,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    downtime_minutes INT,
    operator_id TEXT
);

-- sales orders
CREATE TABLE raw_data.sales_orders (
    sales_order_id TEXT,
    customer TEXT,
    product TEXT,
    order_qty_tons NUMERIC,
    price_per_ton NUMERIC,
    order_date DATE,
    delivery_plant TEXT,
    sales_rep TEXT
);

-- inventory levels
CREATE TABLE raw_data.inventory_levels (
    material TEXT,
    plant TEXT,
    stock_qty NUMERIC,
    reorder_level NUMERIC,
    last_updated DATE
);

-- bill of materials
CREATE TABLE raw_data.bill_of_materials (
    product TEXT,
    material TEXT,
    qty_required_per_ton NUMERIC
);


-- purchase orders
CREATE TABLE raw_data.purchase_orders (
    purchase_order_id TEXT,
    supplier TEXT,
    material TEXT,
    ordered_qty NUMERIC,
    unit_cost NUMERIC,
    order_date DATE,
    plant TEXT,
    status TEXT
);

-- process sensor data
CREATE TABLE raw_data.process_sensors (
    timestamp TIMESTAMP,
    machine_id TEXT,
    temperature_c NUMERIC,
    pressure_bar NUMERIC,
    flow_rate_m3h NUMERIC,
    consistency_pct NUMERIC
);
