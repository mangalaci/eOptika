

ALTER TABLE BASE_03_TABLE ADD INDEX (`created`) USING BTREE;


DROP TABLE IF EXISTS inventory_service_level;
CREATE TABLE IF NOT EXISTS inventory_service_level
SELECT 

	b.order_year, 
	b.order_month, 
	b.order_day_in_month, 
	b.CT1_SKU, 
	b.CT1_SKU_name,
	b.CT2_pack,
	b.CT3_product,
	b.CT4_product_brand,
	b.CT5_manufacturer,
	NULL AS supplier,
	b.product_group,
	b.lens_type,
	b.wear_duration,
	b.is_color,
	b.related_warehouse,
	SUM(b.item_quantity) AS Ordered,
	CASE WHEN t.actual_quantity >= SUM(b.item_quantity) THEN SUM(b.item_quantity) ELSE t.actual_quantity END AS Reserved,
	CASE WHEN t.actual_quantity >= SUM(b.item_quantity) THEN 1 ELSE t.actual_quantity/SUM(b.item_quantity) END AS service_level,
	COUNT(DISTINCT b.user_id) AS Users,
	COUNT(DISTINCT b.erp_invoice_id) AS Transactions
FROM BASE_03_TABLE b
LEFT JOIN
(
SELECT m.item_sku, s.order_date, m.actual_quantity
FROM
(
SELECT i.item_sku, STR_TO_DATE(CONCAT(a.order_year, '-',LPAD(a.order_month,2,'0'), '-',a.order_day_in_month),'%Y-%m-%d') AS order_date, MAX(i.processed) AS max_processed
FROM inventory_report i
LEFT JOIN BASE_03_TABLE a
ON (a.CT1_SKU = i.item_sku AND i.processed <= STR_TO_DATE(CONCAT(a.order_year, '-',LPAD(a.order_month,2,'0'), '-',a.order_day_in_month),'%Y-%m-%d'))
GROUP BY i.item_sku, STR_TO_DATE(CONCAT(a.order_year, '-',LPAD(a.order_month,2,'0'), '-',a.order_day_in_month),'%Y-%m-%d')
) s,
inventory_report m
WHERE (m.item_sku = s.item_sku AND m.processed = s.max_processed)
) t
ON (b.CT1_SKU = t.item_sku AND t.order_date = STR_TO_DATE(CONCAT(b.order_year, '-',LPAD(b.order_month,2,'0'), '-',b.order_day_in_month),'%Y-%m-%d'))
WHERE b.origin = 'invoices'
AND b.is_canceled = 'no'
AND b.item_quantity > 0
AND b.order_year = 2018
AND b.order_month >= 5
GROUP BY b.order_year, b.order_month, b.order_day_in_month, b.CT1_SKU, b.CT1_SKU_name
;



ALTER TABLE inventory_service_level ADD INDEX (`CT1_SKU`) USING BTREE;

