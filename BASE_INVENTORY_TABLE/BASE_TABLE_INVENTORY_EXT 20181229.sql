DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_01;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_01
SELECT  
		UPPER(i.item_sku) AS stock_sku,
		i.item_name_hun AS stock_name_hun,
		i.warehouse_id AS stock_warehouse_id,
		i.warehouse AS stock_warehouse,
		ROUND(i.actual_quantity) AS stock_actual_quantity,
		b.related_division,
		b.related_webshop,
		a.CT2_sku,
		a.CT2_pack,
		a.CT3_product,
		a.CT3_product_short,
		a.CT4_product_brand,
		a.CT5_manufacturer,
		a.product_group,
		a.lens_type,
		a.is_color,
		a.wear_duration,
		a.quantity_in_a_pack,
		a.qty_per_storage_unit,
		a.pack_size,
		a.package_unit,
		a.box_width,
		a.box_height,
		a.box_depth,
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
		b.num_of_users_all_time AS invoice_num_of_users_all_time
		
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		t.LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days,
		SUM(t.item_quantity) AS items_sold_all_time,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_365days,
		SUM(t.revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.erp_invoice_id END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.erp_invoice_id END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.erp_invoice_id END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.erp_invoice_id END) AS num_of_transactions_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.erp_invoice_id END) AS num_of_transactions_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.erp_invoice_id END) AS num_of_transactions_365days,
		COUNT(DISTINCT t.erp_invoice_id) AS num_of_transactions_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.user_id END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.user_id END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.user_id END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.user_id END) AS num_of_users_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.user_id END) AS num_of_users_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.user_id END) AS num_of_users_365days,
		COUNT(DISTINCT t.user_id) AS num_of_users_all_time

FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
GROUP BY 
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		t.LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse
LEFT JOIN ab_cikkto_full a
ON i.item_sku = a.CT1_sku
LEFT JOIN 
(
SELECT 	CT1_sku, 
		related_warehouse,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Reserved ELSE 0 END) AS sum_reserved_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Ordered ELSE 0 END) AS sum_ordered_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Reserved ELSE 0 END) AS sum_reserved_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Ordered ELSE 0 END) AS sum_ordered_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Reserved ELSE 0 END) AS sum_reserved_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Ordered ELSE 0 END) AS sum_ordered_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Reserved ELSE 0 END) AS sum_reserved_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Ordered ELSE 0 END) AS sum_ordered_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Reserved ELSE 0 END) AS sum_reserved_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Ordered ELSE 0 END) AS sum_ordered_180days,		
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Reserved ELSE 0 END) AS sum_reserved_365days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Ordered ELSE 0 END) AS sum_ordered_365days

FROM inventory_service_level
GROUP BY CT1_sku, related_warehouse
) s
ON i.item_sku = s.CT1_sku AND i.warehouse = s.related_warehouse
WHERE i.warehouse_id <> 16
;


ALTER TABLE BASE_TABLE_INVENTORY_EXT_01 ADD INDEX (`stock_sku`) USING BTREE;



ALTER TABLE BASE_03_TABLE ADD INDEX (`related_warehouse`) USING BTREE;



DROP TABLE IF EXISTS x_bar_30_EXT;
CREATE TABLE IF NOT EXISTS x_bar_30_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/30,2) AS avg_items_sold_30days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_30_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_30_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_30_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_30_EXT;
CREATE TABLE IF NOT EXISTS x_i_30_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_30_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_30_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_30_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_30_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_30_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_30_EXT;

DELIMITER //

CREATE PROCEDURE STD_30_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_30_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_30_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 30-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_30_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_30_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_30_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_30_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_30_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_30_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_30_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_30days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_30_EXT();



/* 60 days */

DROP TABLE IF EXISTS x_bar_60_EXT;
CREATE TABLE IF NOT EXISTS x_bar_60_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/60,2) AS avg_items_sold_60days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_60_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_60_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_60_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_60_EXT;
CREATE TABLE IF NOT EXISTS x_i_60_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_60_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_60_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_60_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_60_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_60_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_60_EXT;

DELIMITER //

CREATE PROCEDURE STD_60_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_60_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_60_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 60-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_60_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_60_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_60_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_60_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_60_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_60_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_60_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_60days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_60_EXT();





/* 90 days */

DROP TABLE IF EXISTS x_bar_90_EXT;
CREATE TABLE IF NOT EXISTS x_bar_90_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/90,2) AS avg_items_sold_90days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_90_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_90_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_90_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_90_EXT;
CREATE TABLE IF NOT EXISTS x_i_90_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_90_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_90_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_90_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_90_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_90_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_90_EXT;

DELIMITER //

CREATE PROCEDURE STD_90_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_90_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_90_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 90-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_90_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_90_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_90_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_90_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_90_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_90_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_90_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_90days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_90_EXT();




/* 120 days */


DROP TABLE IF EXISTS x_bar_120_EXT;
CREATE TABLE IF NOT EXISTS x_bar_120_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/120,2) AS avg_items_sold_120days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_120_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_120_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_120_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_120_EXT;
CREATE TABLE IF NOT EXISTS x_i_120_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_120_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_120_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_120_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_120_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_120_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_120_EXT;

DELIMITER //

CREATE PROCEDURE STD_120_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_120_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_120_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 120-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_120_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_120_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_120_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_120_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_120_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_120_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_120_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_120days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_120_EXT();





/* 180 days */

DROP TABLE IF EXISTS x_bar_180_EXT;
CREATE TABLE IF NOT EXISTS x_bar_180_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/180,2) AS avg_items_sold_180days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_180_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_180_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_180_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_180_EXT;
CREATE TABLE IF NOT EXISTS x_i_180_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_180_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_180_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_180_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_180_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_180_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_180_EXT;

DELIMITER //

CREATE PROCEDURE STD_180_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_180_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_180_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 180-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_180_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_180_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_180_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_180_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_180_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_180_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_180_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_180days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_180_EXT();






/* 365 days */

DROP TABLE IF EXISTS x_bar_365_EXT;
CREATE TABLE IF NOT EXISTS x_bar_365_EXT
SELECT
		t.related_warehouse,
		t.related_division,
		t.related_webshop,		
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/365,2) AS avg_items_sold_365days,
		0 AS missing_days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku
;

ALTER TABLE x_bar_365_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_365_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_365_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_365_EXT;
CREATE TABLE IF NOT EXISTS x_i_365_EXT
SELECT
		t.order_date,
		t.related_warehouse,
		t.related_division,
		t.related_webshop,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days
FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
WHERE t.origin = 'invoices'
AND t.item_quantity > 0
AND DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY 	t.order_date,
			t.related_warehouse,
			t.related_division,
			t.related_webshop,
			t.CT1_sku
;

ALTER TABLE x_i_365_EXT ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_365_EXT ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_365_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE x_i_365_EXT ADD INDEX (`related_webshop`) USING BTREE;
ALTER TABLE x_i_365_EXT ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_365_EXT;

DELIMITER //

CREATE PROCEDURE STD_365_EXT()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_365_EXT b
		LEFT JOIN (SELECT related_warehouse, related_division, related_webshop, CT1_sku, COUNT(*) AS selling_days FROM x_i_365_EXT GROUP BY related_warehouse, related_division, related_webshop, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 365-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_365_EXT);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_365_EXT WHERE id = b);
SET @related_division = (SELECT related_division FROM x_bar_365_EXT WHERE id = b);
SET @related_webshop = (SELECT related_webshop FROM x_bar_365_EXT WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_365_EXT WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_365_EXT WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_365_EXT (order_date, related_warehouse, related_division, related_webshop, CT1_sku, items_sold_365days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @related_division, @related_webshop, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_365_EXT();





/* all time */


/* teszt vege */




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_02;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_02
SELECT DISTINCT
		x_i_30_EXT.related_warehouse,
		x_i_30_EXT.related_division,
		x_i_30_EXT.related_webshop,
		x_i_30_EXT.CT1_sku,
		ROUND(STDDEV_SAMP(x_i_30_EXT.items_sold_30days),2) AS items_sold_30days_std,
		ROUND(STDDEV_SAMP(x_i_60_EXT.items_sold_60days),2) AS items_sold_60days_std
FROM x_i_30_EXT
LEFT JOIN x_i_60_EXT
ON 	(x_i_30_EXT.related_warehouse = x_i_60_EXT.related_warehouse AND x_i_30_EXT.CT1_sku = x_i_60_EXT.CT1_sku)
GROUP BY 
		related_warehouse,
		related_division, 
		related_webshop,
		CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_EXT_02 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_02 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_02 ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_02 ADD INDEX (`related_webshop`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_03;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_03
SELECT DISTINCT
		t02.*,
		ROUND(STDDEV_SAMP(x_i_90.items_sold_90days),2) AS items_sold_90days_std
FROM BASE_TABLE_INVENTORY_EXT_02 t02
LEFT JOIN x_i_90
ON 	(t02.related_warehouse = x_i_90.related_warehouse AND t02.CT1_sku = x_i_90.CT1_sku)
GROUP BY 
		t02.related_warehouse,
		t02.related_division,
		t02.related_webshop,
		t02.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_EXT_03 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_03 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_03 ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_03 ADD INDEX (`related_webshop`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_04;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_04
SELECT DISTINCT
		t03.*,
		ROUND(STDDEV_SAMP(x_i_120.items_sold_120days),2) AS items_sold_120days_std
FROM BASE_TABLE_INVENTORY_EXT_03 t03
LEFT JOIN x_i_120
ON	(t03.related_warehouse = x_i_120.related_warehouse AND t03.CT1_sku = x_i_120.CT1_sku)
GROUP BY 
		t03.related_warehouse,
		t03.related_division,
		t03.related_webshop,
		t03.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_EXT_04 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_04 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_04 ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_04 ADD INDEX (`related_webshop`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_05;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_05
SELECT DISTINCT
		t04.*,
		ROUND(STDDEV_SAMP(x_i_180.items_sold_180days),2) AS items_sold_180days_std
FROM BASE_TABLE_INVENTORY_EXT_04 t04
LEFT JOIN x_i_180
ON	(t04.related_warehouse = x_i_180.related_warehouse AND t04.CT1_sku = x_i_180.CT1_sku)
GROUP BY 
		t04.related_warehouse,
		t04.related_division,
		t04.related_webshop,
		t04.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_EXT_05 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_05 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_05 ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_05 ADD INDEX (`related_webshop`) USING BTREE;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT_06;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT_06
SELECT DISTINCT
		t05.*,
		ROUND(STDDEV_SAMP(x_i_365.items_sold_365days),2) AS items_sold_365days_std
FROM BASE_TABLE_INVENTORY_EXT_05 t05
LEFT JOIN x_i_365
ON	(t05.related_warehouse = x_i_365.related_warehouse AND t05.CT1_sku = x_i_365.CT1_sku)
GROUP BY 
		t05.related_warehouse,
		t05.related_division,
		t05.related_webshop,		
		t05.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_EXT_06 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_06 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_06 ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT_06 ADD INDEX (`related_webshop`) USING BTREE;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_EXT;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_EXT
SELECT DISTINCT m.*,
s.items_sold_30days_std AS invoice_items_sold_30days_std,
s.items_sold_60days_std AS invoice_items_sold_60days_std,
s.items_sold_90days_std AS invoice_items_sold_90days_std,
s.items_sold_120days_std AS invoice_items_sold_120days_std,
s.items_sold_180days_std AS invoice_items_sold_180days_std,
s.items_sold_365days_std AS invoice_items_sold_365days_std,
CASE 	WHEN m.stock_warehouse_id = 1 THEN i.`001_terez_korut_41`
		WHEN m.stock_warehouse_id = 10 THEN i.`010_terez_korut_50`
		WHEN m.stock_warehouse_id = 15 THEN i.`015_cloud_fulfilment`
		WHEN m.stock_warehouse_id = 17 THEN i.`017_pueblo_torrequebrada`
		WHEN m.stock_warehouse_id = 20 THEN i.`020_iotticait_magazzino_amalfi`		
END  AS buffer_level
FROM BASE_TABLE_INVENTORY_EXT_01 m
LEFT JOIN BASE_TABLE_INVENTORY_EXT_06 s
ON (m.stock_sku = s.CT1_sku
AND m.stock_warehouse = s.related_warehouse
AND m.related_division = s.related_division
AND m.related_webshop = s.related_webshop)
LEFT JOIN zoho_inventory_min_stock i
ON m.stock_sku = i.sku
;


ALTER TABLE BASE_TABLE_INVENTORY_EXT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_TABLE_INVENTORY_EXT ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT ADD INDEX (`stock_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT ADD INDEX (`related_division`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_EXT ADD INDEX (`related_webshop`) USING BTREE;




