DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_01;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_01
SELECT  
		i.item_sku AS stock_sku,
		i.item_name_hun AS stock_name_hun,
		i.warehouse_id AS stock_warehouse_id,
		i.warehouse AS stock_warehouse,
		ROUND(i.actual_quantity) AS stock_actual_quantity,
		b.CT2_sku,
		b.CT2_pack,
		b.CT3_product,
		b.CT3_product_short,
		b.CT4_product_brand,
		b.CT5_manufacturer,
		b.product_group,
		b.lens_type,
		b.is_color,
		b.wear_duration,
		b.quantity_in_a_pack,
		b.qty_per_storage_unit,
		b.pack_size,
		b.package_unit,
		b.box_width,
		b.box_height,
		b.box_depth,
		b.LVCR_item_flg,
		NULL AS supplier,
		b.items_sold_30days AS invoice_items_sold_30days,
		b.items_sold_60days AS invoice_items_sold_60days,
		b.items_sold_90days AS invoice_items_sold_90days,
		b.items_sold_120days AS invoice_items_sold_120days,

		ROUND(COALESCE(b.items_sold_30days,0)/i.actual_quantity,2) AS inventory_turns_in_30days,
		ROUND(COALESCE(b.items_sold_60days,0)/i.actual_quantity,2) AS inventory_turns_in_60days,
		ROUND(COALESCE(b.items_sold_90days,0)/i.actual_quantity,2) AS inventory_turns_in_90days,
		ROUND(COALESCE(b.items_sold_120days,0)/i.actual_quantity,2) AS inventory_turns_in_120days,
		
		ROUND(revenues_wdisc_in_base_currency_30days) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(revenues_wdisc_in_base_currency_60days) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(revenues_wdisc_in_base_currency_90days) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(revenues_wdisc_in_base_currency_120days) as invoice_revenues_wdisc_in_base_currency_120days,
		b.num_of_transactions_30days AS invoice_num_of_transactions_30days,
		b.num_of_transactions_60days AS invoice_num_of_transactions_60days,
		b.num_of_transactions_90days AS invoice_num_of_transactions_90days,
		b.num_of_transactions_120days AS invoice_num_of_transactions_120days,
		b.num_of_users_30days AS invoice_num_of_users_30days,
		b.num_of_users_60days AS invoice_num_of_users_60days,
		b.num_of_users_90days AS invoice_num_of_users_90days,
		b.num_of_users_120days AS invoice_num_of_users_120days
		
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		related_warehouse,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN item_quantity ELSE 0 END) AS items_sold_120days,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 30 THEN item_quantity ELSE 0 END) AS items_sold_30,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 29 THEN item_quantity ELSE 0 END) AS items_sold_29,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 28 THEN item_quantity ELSE 0 END) AS items_sold_28,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_120days,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN user_id ELSE 0 END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN user_id ELSE 0 END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN user_id ELSE 0 END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN user_id ELSE 0 END) AS num_of_users_120days
		
FROM BASE_03_TABLE
WHERE (origin = 'invoices' OR (origin = 'orders' AND is_canceled = 'no'))
AND item_quantity > 0
GROUP BY 
		related_warehouse,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse
WHERE i.warehouse_id <> 16
;


ALTER TABLE BASE_TABLE_INVENTORY_01 ADD INDEX (`stock_sku`) USING BTREE;



ALTER TABLE BASE_03_TABLE ADD INDEX (`related_warehouse`) USING BTREE;



INSERT INTO calendar_table
SELECT CURRENT_DATE FROM DUAL
;



DROP TABLE IF EXISTS t30;
CREATE TABLE IF NOT EXISTS t30
SELECT 
		created,
		related_warehouse,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) <= 30 THEN item_quantity ELSE 0 END) AS items_sold_30days		
FROM BASE_03_TABLE
WHERE (origin = 'invoices' OR (origin = 'orders' AND is_canceled = 'no'))
AND item_quantity > 0
AND DATEDIFF(CURDATE(), created) <= 30
GROUP BY 	created,
		related_warehouse,
		CT1_sku
;



ALTER TABLE t30 ADD INDEX (`created`) USING BTREE;
ALTER TABLE t30 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t30 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS t30_descartes;
CREATE TABLE IF NOT EXISTS t30_descartes
SELECT DISTINCT c.date, t30.related_warehouse, t30.CT1_sku
FROM calendar_table c, t30
WHERE DATEDIFF(CURDATE(), c.date) <= 30
;


ALTER TABLE t30_descartes ADD INDEX (`date`) USING BTREE;
ALTER TABLE t30_descartes ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t30_descartes ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t30_ext;
CREATE TABLE IF NOT EXISTS t30_ext
SELECT d.date, d.related_warehouse, d.CT1_sku, COALESCE(t30.items_sold_30days,0) AS items_sold_30days
FROM t30_descartes d
LEFT JOIN t30
ON d.date = t30.created
AND d.related_warehouse = t30.related_warehouse
AND d.CT1_sku = t30.CT1_sku
;


ALTER TABLE t30_ext ADD INDEX (`date`) USING BTREE;
ALTER TABLE t30_ext ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t30_ext ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS t60;
CREATE TABLE IF NOT EXISTS t60
SELECT 
		created,
		related_warehouse,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) <= 60 THEN item_quantity ELSE 0 END) AS items_sold_60days
FROM BASE_03_TABLE
WHERE (origin = 'invoices' OR (origin = 'orders' AND is_canceled = 'no'))
AND item_quantity > 0
AND DATEDIFF(CURDATE(), created) <= 60
GROUP BY 	created,
		related_warehouse,
		CT1_sku
;



ALTER TABLE t60 ADD INDEX (`created`) USING BTREE;
ALTER TABLE t60 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t60 ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t60_descartes;
CREATE TABLE IF NOT EXISTS t60_descartes
SELECT DISTINCT c.date, t60.related_warehouse, t60.CT1_sku
FROM calendar_table c, t60
WHERE DATEDIFF(CURDATE(), c.date) <= 60
;


ALTER TABLE t60_descartes ADD INDEX (`date`) USING BTREE;
ALTER TABLE t60_descartes ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t60_descartes ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t60_ext;
CREATE TABLE IF NOT EXISTS t60_ext
SELECT d.date, d.related_warehouse, d.CT1_sku, COALESCE(t60.items_sold_60days,0) AS items_sold_60days
FROM t60_descartes d
LEFT JOIN t60
ON d.date = t60.created
AND d.related_warehouse = t60.related_warehouse
AND d.CT1_sku = t60.CT1_sku
;


ALTER TABLE t60_ext ADD INDEX (`date`) USING BTREE;
ALTER TABLE t60_ext ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t60_ext ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t90;
CREATE TABLE IF NOT EXISTS t90
SELECT 
		created,
		related_warehouse,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) <= 90 THEN item_quantity ELSE 0 END) AS items_sold_90days
FROM BASE_03_TABLE
WHERE (origin = 'invoices' OR (origin = 'orders' AND is_canceled = 'no'))
AND item_quantity > 0
AND DATEDIFF(CURDATE(), created) <= 90
GROUP BY 	created,
		related_warehouse,
		CT1_sku
;



ALTER TABLE t90 ADD INDEX (`created`) USING BTREE;
ALTER TABLE t90 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t90 ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t90_descartes;
CREATE TABLE IF NOT EXISTS t90_descartes
SELECT DISTINCT c.date, t90.related_warehouse, t90.CT1_sku
FROM calendar_table c, t90
WHERE DATEDIFF(CURDATE(), c.date) <= 90
;


ALTER TABLE t90_descartes ADD INDEX (`date`) USING BTREE;
ALTER TABLE t90_descartes ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t90_descartes ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t90_ext;
CREATE TABLE IF NOT EXISTS t90_ext
SELECT d.date, d.related_warehouse, d.CT1_sku, COALESCE(t90.items_sold_90days,0) AS items_sold_90days
FROM t90_descartes d
LEFT JOIN t90
ON d.date = t90.created
AND d.related_warehouse = t90.related_warehouse
AND d.CT1_sku = t90.CT1_sku
;


ALTER TABLE t90_ext ADD INDEX (`date`) USING BTREE;
ALTER TABLE t90_ext ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t90_ext ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS t120;
CREATE TABLE IF NOT EXISTS t120
SELECT 
		created,
		related_warehouse,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) <= 120 THEN item_quantity ELSE 0 END) AS items_sold_120days
FROM BASE_03_TABLE
WHERE (origin = 'invoices' OR (origin = 'orders' AND is_canceled = 'no'))
AND item_quantity > 0
AND DATEDIFF(CURDATE(), created) <= 120
GROUP BY 	created,
		related_warehouse,
		CT1_sku
;



ALTER TABLE t120 ADD INDEX (`created`) USING BTREE;
ALTER TABLE t120 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t120 ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t120_descartes;
CREATE TABLE IF NOT EXISTS t120_descartes
SELECT DISTINCT c.date, t120.related_warehouse, t120.CT1_sku
FROM calendar_table c, t120
WHERE DATEDIFF(CURDATE(), c.date) <= 120
;


ALTER TABLE t120_descartes ADD INDEX (`date`) USING BTREE;
ALTER TABLE t120_descartes ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t120_descartes ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS t120_ext;
CREATE TABLE IF NOT EXISTS t120_ext
SELECT d.date, d.related_warehouse, d.CT1_sku, COALESCE(t120.items_sold_120days,0) AS items_sold_120days
FROM t120_descartes d
LEFT JOIN t120
ON d.date = t120.created
AND d.related_warehouse = t120.related_warehouse
AND d.CT1_sku = t120.CT1_sku
;


ALTER TABLE t120_ext ADD INDEX (`date`) USING BTREE;
ALTER TABLE t120_ext ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE t120_ext ADD INDEX (`CT1_sku`) USING BTREE;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_02;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_02
SELECT DISTINCT
		t30_ext.related_warehouse,
		t30_ext.CT1_sku,
		ROUND(STDDEV_SAMP(t30_ext.items_sold_30days),2) AS items_sold_30days_std,
		ROUND(STDDEV_SAMP(t60_ext.items_sold_60days),2) AS items_sold_60days_std
FROM t30_ext
LEFT JOIN t60_ext
ON 	(t30_ext.related_warehouse = t60_ext.related_warehouse AND t30_ext.CT1_sku = t60_ext.CT1_sku)
GROUP BY 
		related_warehouse,
		CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_02 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_02 ADD INDEX (`related_warehouse`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_03;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_03
SELECT DISTINCT
		t02.*,
		ROUND(STDDEV_SAMP(t90_ext.items_sold_90days),2) AS items_sold_90days_std
FROM BASE_TABLE_INVENTORY_02 t02
LEFT JOIN t90_ext
ON 	(t02.related_warehouse = t90_ext.related_warehouse AND t02.CT1_sku = t90_ext.CT1_sku)
GROUP BY 
		t02.related_warehouse,
		t02.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_03 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_03 ADD INDEX (`related_warehouse`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_04;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_04
SELECT DISTINCT
		t03.*,
		ROUND(STDDEV_SAMP(t120_ext.items_sold_120days),2) AS items_sold_120days_std
FROM BASE_TABLE_INVENTORY_03 t03
LEFT JOIN t120_ext
ON	(t03.related_warehouse = t120_ext.related_warehouse AND t03.CT1_sku = t120_ext.CT1_sku)
GROUP BY 
		t03.related_warehouse,
		t03.CT1_sku
;



ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`related_warehouse`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY
SELECT DISTINCT m.*,
s.items_sold_30days_std AS invoice_items_sold_30days_std,
s.items_sold_60days_std AS invoice_items_sold_60days_std,
s.items_sold_90days_std AS invoice_items_sold_90days_std,
s.items_sold_120days_std AS invoice_items_sold_120days_std,
CASE 	WHEN m.stock_warehouse_id = 1 THEN i.terez_korut_41
		WHEN m.stock_warehouse_id = 10 THEN i.terez_korut_50
END  AS buffer_level
FROM BASE_TABLE_INVENTORY_01 m
LEFT JOIN BASE_TABLE_INVENTORY_04 s
ON (m.stock_sku = s.CT1_sku
AND m.stock_warehouse = s.related_warehouse)
LEFT JOIN inventory_minimum_stock i
ON m.stock_sku = i.sku
;


ALTER TABLE BASE_TABLE_INVENTORY ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_warehouse`) USING BTREE;



