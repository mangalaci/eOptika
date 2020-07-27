/* ezt csak először kell futtatni:

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
	CASE WHEN i.actual_quantity >= SUM(b.item_quantity) THEN SUM(b.item_quantity) ELSE i.actual_quantity END AS Reserved,
	CASE WHEN i.actual_quantity >= SUM(b.item_quantity) THEN 1 ELSE i.actual_quantity/SUM(b.item_quantity) END AS service_level,	
	COUNT(DISTINCT b.user_id) AS Users,
	COUNT(DISTINCT b.erp_invoice_id) AS Transactions
FROM BASE_03_TABLE b
LEFT JOIN inventory_report i
ON (b.CT1_SKU = i.item_sku AND b.related_warehouse = i.warehouse)
WHERE STR_TO_DATE(CONCAT(b.order_year, '-',LPAD(b.order_month,2,'0'), '-',b.order_day_in_month),'%Y-%m-%d') =  
(
SELECT MAX(STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-',order_day_in_month),'%Y-%m-%d'))
FROM BASE_03_TABLE
)
AND b.is_canceled = 'no'
AND b.item_quantity > 0
GROUP BY b.order_year, b.order_month, b.order_day_in_month, b.CT1_SKU, b.CT1_SKU_name
;


ALTER TABLE inventory_service_level ADD INDEX (`CT1_SKU`) USING BTREE;

*/


INSERT INTO inventory_service_level
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
	CASE WHEN i.actual_quantity >= SUM(b.item_quantity) THEN SUM(b.item_quantity) ELSE i.actual_quantity END AS Reserved,
	CASE WHEN i.actual_quantity >= SUM(b.item_quantity) THEN 1 ELSE i.actual_quantity/SUM(b.item_quantity) END AS service_level,	
	COUNT(DISTINCT b.user_id) AS Users,
	COUNT(DISTINCT b.erp_invoice_id) AS Transactions
FROM BASE_03_TABLE b
LEFT JOIN inventory_report i
ON (b.CT1_SKU = i.item_sku AND b.related_warehouse = i.warehouse)
WHERE STR_TO_DATE(CONCAT(b.order_year, '-',LPAD(b.order_month,2,'0'), '-',b.order_day_in_month),'%Y-%m-%d') =  
(
SELECT MAX(STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-',order_day_in_month),'%Y-%m-%d'))
FROM BASE_03_TABLE
)
AND b.is_canceled = 'no'
AND b.item_quantity > 0
GROUP BY b.order_year, b.order_month, b.order_day_in_month, b.CT1_SKU, b.CT1_SKU_name
;

