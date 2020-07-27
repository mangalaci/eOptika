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
		b.items_sold_180days AS invoice_items_sold_180days,
		b.items_sold_365days AS invoice_items_sold_365days,
		b.items_sold_all_time AS invoice_items_sold_all_time,

		ROUND(COALESCE(b.items_sold_30days,0)/i.actual_quantity,2) AS inventory_turns_in_30days,
		ROUND(COALESCE(b.items_sold_60days,0)/i.actual_quantity,2) AS inventory_turns_in_60days,
		ROUND(COALESCE(b.items_sold_90days,0)/i.actual_quantity,2) AS inventory_turns_in_90days,
		ROUND(COALESCE(b.items_sold_120days,0)/i.actual_quantity,2) AS inventory_turns_in_120days,
		ROUND(COALESCE(b.items_sold_180days,0)/i.actual_quantity,2) AS inventory_turns_in_180days,
		ROUND(COALESCE(b.items_sold_365days,0)/i.actual_quantity,2) AS inventory_turns_in_365days,
		ROUND(COALESCE(b.items_sold_all_time,0)/i.actual_quantity,2) AS inventory_turns_in_all_time,
		
		ROUND(revenues_wdisc_in_base_currency_30days) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(revenues_wdisc_in_base_currency_60days) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(revenues_wdisc_in_base_currency_90days) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(revenues_wdisc_in_base_currency_120days) as invoice_revenues_wdisc_in_base_currency_120days,
		ROUND(revenues_wdisc_in_base_currency_180days) as invoice_revenues_wdisc_in_base_currency_180days,
		ROUND(revenues_wdisc_in_base_currency_365days) as invoice_revenues_wdisc_in_base_currency_365days,
		ROUND(revenues_wdisc_in_base_currency_all_time) as invoice_revenues_wdisc_in_base_currency_all_time,

		b.num_of_transactions_30days AS invoice_num_of_transactions_30days,
		b.num_of_transactions_60days AS invoice_num_of_transactions_60days,
		b.num_of_transactions_90days AS invoice_num_of_transactions_90days,
		b.num_of_transactions_120days AS invoice_num_of_transactions_120days,
		b.num_of_transactions_180days AS invoice_num_of_transactions_180days,
		b.num_of_transactions_365days AS invoice_num_of_transactions_365days,
		b.num_of_transactions_all_time AS invoice_num_of_transactions_all_time,
		
		b.num_of_users_30days AS invoice_num_of_users_30days,
		b.num_of_users_60days AS invoice_num_of_users_60days,
		b.num_of_users_90days AS invoice_num_of_users_90days,
		b.num_of_users_120days AS invoice_num_of_users_120days,
		b.num_of_users_180days AS invoice_num_of_users_180days,
		b.num_of_users_365days AS invoice_num_of_users_365days,
		b.num_of_users_all_time AS invoice_num_of_users_all_time,
		
		s.service_level
		
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		t.related_warehouse,
		t.CT1_sku,
		t.CT1_sku_name,
		t.CT2_sku,
		t.CT2_pack,
		t.CT3_product,
		t.CT3_product_short,
		t.CT4_product_brand,
		t.CT5_manufacturer,
		t.product_group,
		t.lens_type,
		t.is_color,
		t.wear_duration,
		t.quantity_in_a_pack,
		t.qty_per_storage_unit,
		t.pack_size,
		t.package_unit,
		t.box_width,
		t.box_height,
		t.box_depth,
		t.LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days,
		SUM(t.item_quantity) AS items_sold_all_time,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 30 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 60 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 90 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 120 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 180 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 365 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_365days,
		SUM(t.revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 30 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 60 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 90 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 120 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 180 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 365 THEN t.erp_invoice_id ELSE 0 END) AS num_of_transactions_365days,
		COUNT(DISTINCT t.erp_invoice_id) AS num_of_transactions_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 30 THEN t.user_id ELSE 0 END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 60 THEN t.user_id ELSE 0 END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 90 THEN t.user_id ELSE 0 END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 120 THEN t.user_id ELSE 0 END) AS num_of_users_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 180 THEN t.user_id ELSE 0 END) AS num_of_users_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) < 365 THEN t.user_id ELSE 0 END) AS num_of_users_365days,
		COUNT(DISTINCT t.user_id) AS num_of_users_all_time

FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
GROUP BY 
		t.related_warehouse,
		t.CT1_sku,
		t.CT1_sku_name,
		t.CT2_sku,
		t.CT2_pack,
		t.CT3_product,
		t.CT3_product_short,
		t.CT4_product_brand,
		t.CT5_manufacturer,
		t.product_group,
		t.lens_type,
		t.is_color,
		t.wear_duration,
		t.quantity_in_a_pack,
		t.qty_per_storage_unit,
		t.pack_size,
		t.package_unit,
		t.box_width,
		t.box_height,
		t.box_depth,
		t.LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse
LEFT JOIN inventory_service_level s
ON i.item_sku = s.CT1_sku AND i.warehouse = s.related_warehouse
WHERE i.warehouse_id <> 16
;


ALTER TABLE BASE_TABLE_INVENTORY_01 ADD INDEX (`stock_sku`) USING BTREE;



ALTER TABLE BASE_03_TABLE ADD INDEX (`related_warehouse`) USING BTREE;



INSERT INTO calendar_table
SELECT CURRENT_DATE FROM DUAL
;

/* teszt eleje */



DROP TABLE IF EXISTS x_bar_30;
CREATE TABLE IF NOT EXISTS x_bar_30
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/30,2) AS avg_items_sold_30days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_30 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_30 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_30 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_30;
CREATE TABLE IF NOT EXISTS x_i_30
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_30 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_30 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_30 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_30
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_30
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_30;

DELIMITER //

CREATE PROCEDURE STD_30()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_30 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_30 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 30-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_30);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_30 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_30 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_30 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_30 (order_date, related_warehouse, CT1_sku, items_sold_30days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_30();



/* 60 days */

DROP TABLE IF EXISTS x_bar_60;
CREATE TABLE IF NOT EXISTS x_bar_60
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/60,2) AS avg_items_sold_60days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_60 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_60 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_60 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_60;
CREATE TABLE IF NOT EXISTS x_i_60
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_60 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_60 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_60 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_60
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_60
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_60;

DELIMITER //

CREATE PROCEDURE STD_60()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_60 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_60 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 60-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_60);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_60 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_60 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_60 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_60 (order_date, related_warehouse, CT1_sku, items_sold_60days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_60();




/* 90 days */

DROP TABLE IF EXISTS x_bar_90;
CREATE TABLE IF NOT EXISTS x_bar_90
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/90,2) AS avg_items_sold_90days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_90 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_90 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_90 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_90;
CREATE TABLE IF NOT EXISTS x_i_90
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_90 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_90 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_90 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_90
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_90
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_90;

DELIMITER //

CREATE PROCEDURE STD_90()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_90 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_90 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 90-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_90);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_90 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_90 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_90 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_90 (order_date, related_warehouse, CT1_sku, items_sold_90days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_90();




/* 120 days */

DROP TABLE IF EXISTS x_bar_120;
CREATE TABLE IF NOT EXISTS x_bar_120
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/120,2) AS avg_items_sold_120days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_120 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_120 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_120 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_120;
CREATE TABLE IF NOT EXISTS x_i_120
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_120 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_120 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_120 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_120
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_120
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_120;

DELIMITER //

CREATE PROCEDURE STD_120()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_120 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_120 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 120-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_120);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_120 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_120 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_120 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_120 (order_date, related_warehouse, CT1_sku, items_sold_120days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_120();




/* 180 days */

DROP TABLE IF EXISTS x_bar_180;
CREATE TABLE IF NOT EXISTS x_bar_180
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/180,2) AS avg_items_sold_180days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_180 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_180 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_180 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_180;
CREATE TABLE IF NOT EXISTS x_i_180
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_180 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_180 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_180 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_180
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_180
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_180;

DELIMITER //

CREATE PROCEDURE STD_180()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_180 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_180 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 180-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_180);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_180 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_180 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_180 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_180 (order_date, related_warehouse, CT1_sku, items_sold_180days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_180();




/* 365 days */

DROP TABLE IF EXISTS x_bar_365;
CREATE TABLE IF NOT EXISTS x_bar_365
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/365,2) AS avg_items_sold_365days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_365 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_365 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_365 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_365;
CREATE TABLE IF NOT EXISTS x_i_365
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_365 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_365 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_365 ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_365
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_365
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_365;

DELIMITER //

CREATE PROCEDURE STD_365()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_365 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_365 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 365-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_365);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_365 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_365 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_365 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_365 (order_date, related_warehouse, CT1_sku, items_sold_365days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_365();





/* all time */

DROP TABLE IF EXISTS x_bar_all_time;
CREATE TABLE IF NOT EXISTS x_bar_all_time
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/DATEDIFF(CURDATE(), t.product_introduction_dt),2) AS avg_items_sold_all_time,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND t.order_date > t.product_introduction_dt
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_all_time ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_all_time ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_all_time ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_all_time;
CREATE TABLE IF NOT EXISTS x_i_all_time
SELECT
		t.order_date,
		t.product_introduction_dt,
		t.related_warehouse,
		t.CT1_sku,
		SUM(t.item_quantity) AS items_sold_all_time
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
AND t.item_quantity > 0
AND t.order_date > t.product_introduction_dt
GROUP BY 	t.order_date,
			t.product_introduction_dt,
			t.related_warehouse,
			t.CT1_sku
;

ALTER TABLE x_i_all_time ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_all_time ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_all_time ADD INDEX (`CT1_sku`) USING BTREE;


SELECT * 
FROM x_bar_all_time
WHERE related_warehouse = 'Cloud Fulfilment'
AND CT1_sku = 'SYSTU10'
;

SELECT * 
FROM x_i_all_time
WHERE related_warehouse = 'Teréz körút 50.'
AND CT1_sku = 'BIFM386+0225+200D'
;



DROP PROCEDURE IF EXISTS STD_all_time;

DELIMITER //

CREATE PROCEDURE STD_all_time()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_all_time b
		LEFT JOIN (SELECT product_introduction_dt, related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_all_time GROUP BY product_introduction_dt, related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = DATEDIFF(CURDATE(), i.product_introduction_dt)-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_all_time);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_all_time WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_all_time WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_all_time WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_all_time (order_date, related_warehouse, CT1_sku, items_sold_all_time) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS run_all_time;

DELIMITER //

CREATE PROCEDURE run_all_time()
BEGIN

    IF DAYOFWEEK(CURRENT_DATE) = 7
		THEN CALL STD_all_time();
	END IF;
 

END;
//
DELIMITER ;


CALL run_all_time();




/* teszt vege */




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_02;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_02
SELECT DISTINCT
		x_i_30.related_warehouse,
		x_i_30.CT1_sku,
		ROUND(STDDEV_SAMP(x_i_30.items_sold_30days),2) AS items_sold_30days_std,
		ROUND(STDDEV_SAMP(x_i_60.items_sold_60days),2) AS items_sold_60days_std
FROM x_i_30
LEFT JOIN x_i_60
ON 	(x_i_30.related_warehouse = x_i_60.related_warehouse AND x_i_30.CT1_sku = x_i_60.CT1_sku)
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
		ROUND(STDDEV_SAMP(x_i_90.items_sold_90days),2) AS items_sold_90days_std
FROM BASE_TABLE_INVENTORY_02 t02
LEFT JOIN x_i_90
ON 	(t02.related_warehouse = x_i_90.related_warehouse AND t02.CT1_sku = x_i_90.CT1_sku)
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
		ROUND(STDDEV_SAMP(x_i_120.items_sold_120days),2) AS items_sold_120days_std
FROM BASE_TABLE_INVENTORY_03 t03
LEFT JOIN x_i_120
ON	(t03.related_warehouse = x_i_120.related_warehouse AND t03.CT1_sku = x_i_120.CT1_sku)
GROUP BY 
		t03.related_warehouse,
		t03.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`related_warehouse`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_05;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_05
SELECT DISTINCT
		t04.*,
		ROUND(STDDEV_SAMP(x_i_180.items_sold_180days),2) AS items_sold_180days_std
FROM BASE_TABLE_INVENTORY_04 t04
LEFT JOIN x_i_180
ON	(t04.related_warehouse = x_i_180.related_warehouse AND t04.CT1_sku = x_i_180.CT1_sku)
GROUP BY 
		t04.related_warehouse,
		t04.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_05 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_05 ADD INDEX (`related_warehouse`) USING BTREE;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_06;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_06
SELECT DISTINCT
		t05.*,
		ROUND(STDDEV_SAMP(x_i_365.items_sold_365days),2) AS items_sold_365days_std
FROM BASE_TABLE_INVENTORY_05 t05
LEFT JOIN x_i_365
ON	(t05.related_warehouse = x_i_365.related_warehouse AND t05.CT1_sku = x_i_365.CT1_sku)
GROUP BY 
		t05.related_warehouse,
		t05.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_06 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_06 ADD INDEX (`related_warehouse`) USING BTREE;






DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_07;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_07
SELECT DISTINCT
		t06.*,
		ROUND(STDDEV_SAMP(x_i_all_time.items_sold_all_time),2) AS items_sold_all_time_std
FROM BASE_TABLE_INVENTORY_06 t06
LEFT JOIN x_i_all_time
ON	(t06.related_warehouse = x_i_all_time.related_warehouse AND t06.CT1_sku = x_i_all_time.CT1_sku)
GROUP BY 
		t06.related_warehouse,
		t06.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_07 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_07 ADD INDEX (`related_warehouse`) USING BTREE;





DROP TABLE IF EXISTS BASE_TABLE_INVENTORY;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY
SELECT DISTINCT m.*,
s.items_sold_30days_std AS invoice_items_sold_30days_std,
s.items_sold_60days_std AS invoice_items_sold_60days_std,
s.items_sold_90days_std AS invoice_items_sold_90days_std,
s.items_sold_120days_std AS invoice_items_sold_120days_std,
s.items_sold_180days_std AS invoice_items_sold_180days_std,
s.items_sold_365days_std AS invoice_items_sold_365days_std,
s.items_sold_all_time_std AS invoice_items_sold_all_time_std,
CASE 	WHEN m.stock_warehouse_id = 1 THEN i.`001_terez_korut_41`
		WHEN m.stock_warehouse_id = 10 THEN i.`010_terez_korut_50`
		WHEN m.stock_warehouse_id = 15 THEN i.`015_cloud_fulfilment`
		WHEN m.stock_warehouse_id = 17 THEN i.`017_pueblo_torrequebrada`
END  AS buffer_level
FROM BASE_TABLE_INVENTORY_01 m
LEFT JOIN BASE_TABLE_INVENTORY_07 s
ON (m.stock_sku = s.CT1_sku
AND m.stock_warehouse = s.related_warehouse)
LEFT JOIN zoho_inventory_min_stock i
ON m.stock_sku = i.sku
;


ALTER TABLE BASE_TABLE_INVENTORY ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_warehouse`) USING BTREE;
