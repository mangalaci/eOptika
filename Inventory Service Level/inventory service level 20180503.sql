DROP TABLE IF EXISTS service_level;
CREATE TABLE IF NOT EXISTS service_level
SELECT 
	b.order_year, 
	b.order_month, 
	b.order_day_in_month, 
	b.CT1_SKU, 
	b.CT1_SKU_name, 
	SUM(b.item_quantity) AS Ordered,
	CASE WHEN t.actual_quantity >= SUM(b.item_quantity) THEN SUM(b.item_quantity) ELSE t.actual_quantity END AS Reserved,
	CASE WHEN t.actual_quantity >= SUM(b.item_quantity) THEN 1 ELSE t.actual_quantity/SUM(b.item_quantity) END AS service_level
FROM BASE_09_TABLE b
LEFT JOIN
(
SELECT m.item_sku, m.actual_quantity
FROM
(
SELECT item_sku, MAX(processed) AS max_processed
FROM inventory_report
GROUP BY item_sku
) s,
inventory_report m
WHERE (m.item_sku = s.item_sku AND m.processed = s.max_processed)
) t
ON b.CT1_SKU = t.item_sku
WHERE b.origin = 'orders'
AND b.is_canceled = 'no'
AND b.item_quantity > 0
AND b.order_year = 2018
AND b.order_month >= 4
GROUP BY b.order_year, b.order_month, b.order_day_in_month, b.CT1_SKU, b.CT1_SKU_name
;



ALTER TABLE service_level ADD INDEX (`CT1_SKU`) USING BTREE;

