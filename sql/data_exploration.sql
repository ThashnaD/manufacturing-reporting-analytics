--explore production orders
SELECT *
FROM raw_data.production_orders
LIMIT 20;

--production totals by machine
SELECT machine_id,
SUM(actual_quantity_tons) AS total_production
FROM raw_data.production_orders
GROUP BY machine_id
ORDER BY total_production DESC;
