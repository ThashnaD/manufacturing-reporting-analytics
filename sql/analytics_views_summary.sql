-- =========================================
-- VIEW: MACHINE SUMMARY
-- A combined view of machine production,
-- performance and throughput.
-- =========================================

CREATE VIEW analytics.vw_machine_summary AS
SELECT
p.machine_id,
p.planned_production,
p.actual_production,
p.production_variance,
m.total_production_tons,
t.tons_per_day
FROM analytics.vw_production_performance_cleaned p
LEFT JOIN analytics.vw_machine_production_cleaned m
ON p.machine_id = m.machine_id
LEFT JOIN (
    SELECT
    machine_id,
    AVG(tons_per_day) AS tons_per_day
    FROM analytics.vw_machine_product_throughput_cleaned
    GROUP BY machine_id
) t
ON p.machine_id = t.machine_id;

-- =========================================
-- VIEW: PRODUCTION SUMMARY
-- Aggregates production by product.
-- =========================================

CREATE VIEW analytics.vw_production_summary AS
SELECT
product,
SUM(total_production_tons) AS total_production_tons,
AVG(tons_per_day) AS avg_throughput_tons_per_day
FROM analytics.vw_machine_product_throughput_cleaned
GROUP BY product;

-- =========================================
-- VIEW: MACHINE DOWNTIME SUMMARY
-- Looking at downtime per machine to see
-- which machines experience more downtime
-- during production runs.
--
-- This can help highlight machines that may
-- be less reliable or may need maintenance.
-- =========================================

CREATE VIEW analytics.vw_machine_downtime_analysis AS
SELECT
machine_id,
COUNT(*) AS number_of_orders,
SUM(downtime_minutes) AS total_downtime_minutes,
AVG(downtime_minutes) AS avg_downtime_minutes,
MAX(downtime_minutes) AS max_downtime_minutes
FROM raw_data.production_orders
WHERE
machine_id IS NOT NULL
AND downtime_minutes >= 0
GROUP BY machine_id;

-- =========================================
-- SUMMARY VIEW: MACHINE PERFORMANCE
-- Combining throughput and downtime
-- so I can see overall machine performance
-- in one place.
-- =========================================

CREATE VIEW analytics.vw_machine_performance AS
SELECT
t.machine_id,
AVG(t.tons_per_day) AS avg_throughput_tons_per_day,
d.total_downtime_minutes,
d.avg_downtime_minutes
FROM analytics.vw_machine_product_throughput_cleaned t
LEFT JOIN analytics.vw_machine_downtime_analysis d
ON t.machine_id = d.machine_id
GROUP BY
t.machine_id,
d.total_downtime_minutes,
d.avg_downtime_minutes
ORDER BY avg_throughput_tons_per_day DESC;
