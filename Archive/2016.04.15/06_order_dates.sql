ALTER TABLE incoming_orders DROP PRIMARY KEY;
ALTER TABLE incoming_orders DROP INDEX erp_id;
ALTER TABLE incoming_orders DROP INDEX reference_id;

ALTER TABLE incoming_orders ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE incoming_orders ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE incoming_orders ADD INDEX `reference_id` (`reference_id`) USING BTREE;

DROP TABLE IF EXISTS BASE_06_TABLE;
CREATE TABLE BASE_06_TABLE
SELECT 	a.*,
		b.created AS order_date_and_time,
		YEAR(b.created) AS order_year,
		MONTH(b.created) AS order_month,
		DAY(b.created) AS order_day_in_month,
		weekday(b.created) AS order_weekday,
		WEEK(b.created) - WEEK(DATE_SUB(b.created, INTERVAL DAYOFMONTH(b.created)-1 DAY)) + 1 AS order_week_in_month, 
		HOUR(b.created) AS order_hour,
		b.packaging_deadline
FROM BASE_05_TABLE a LEFT JOIN 
(
	SELECT erp_id, related_division, created, packaging_deadline
	FROM incoming_orders
	GROUP BY erp_id, related_division, created, packaging_deadline
) b
ON a.connected_order_erp_id = b.erp_id
LIMIT 0;

INSERT INTO  BASE_06_TABLE
SELECT 	a.*,
		b.created AS order_date_and_time,
		YEAR(b.created) AS order_year,
		MONTH(b.created) AS order_month,
		DAY(b.created) AS order_day_in_month,
		weekday(b.created) AS order_weekday,
		WEEK(b.created) - WEEK(DATE_SUB(b.created, INTERVAL DAYOFMONTH(b.created)-1 DAY)) + 1 AS order_week_in_month, 
		HOUR(b.created) AS order_hour,
		b.packaging_deadline
FROM BASE_05_TABLE a LEFT JOIN 
(
	SELECT erp_id, related_division, created, packaging_deadline
	FROM incoming_orders
	GROUP BY erp_id, related_division, created, packaging_deadline
) b
ON a.connected_order_erp_id = b.erp_id
;


ALTER TABLE BASE_06_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;

