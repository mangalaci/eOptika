DROP TABLE IF EXISTS COHORT_01_first_last_purchase;

CREATE TABLE IF NOT EXISTS COHORT_01_first_last_purchase
SELECT user_id, related_division, user_type,
     CONCAT(YEAR(MIN(created)),'_',LPAD(MONTH(MIN(created)),2,'0')) AS date_of_first_purchase,
     CONCAT(YEAR(MAX(created)),'_',LPAD(MONTH(MAX(created)),2,'0')) AS date_of_last_purchase,
     COUNT(DISTINCT erp_id) AS user_cum_transactions,
     SUM(item_gross_value_in_currency*exchange_rate_of_currency) AS user_cum_gross_revenue_in_base_currency,
     CASE WHEN COUNT(DISTINCT erp_id) > 1 THEN 'repeat' ELSE '1-time' END num_of_purch
     FROM BASE_04_TABLE
GROUP BY user_id
LIMIT 0;
ALTER TABLE COHORT_01_first_last_purchase ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE COHORT_01_first_last_purchase ADD INDEX `date_of_first_purchase` (`date_of_first_purchase`) USING BTREE;
ALTER TABLE COHORT_01_first_last_purchase ADD INDEX `date_of_last_purchase` (`date_of_last_purchase`) USING BTREE;

INSERT INTO COHORT_01_first_last_purchase
SELECT DISTINCT
     user_id, related_division, user_type,
     CONCAT(YEAR(MIN(created)),'_',LPAD(MONTH(MIN(created)),2,'0')) AS date_of_first_purchase,
     CONCAT(YEAR(MAX(created)),'_',LPAD(MONTH(MAX(created)),2,'0')) AS date_of_last_purchase,
     COUNT(DISTINCT erp_id) AS user_cum_transactions,
     SUM(item_gross_value_in_currency*exchange_rate_of_currency) AS user_cum_gross_revenue_in_base_currency,
     CASE WHEN COUNT(DISTINCT erp_id) > 1 THEN 'repeat' ELSE '1-time' END num_of_purch
     FROM BASE_04_TABLE
	 WHERE origin = 'invoices'
GROUP BY user_id;


DROP TABLE IF EXISTS BASE_05a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05a_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
    CONCAT(year(a.created),'_',lpad(MONTH(a.created),2,'0')) AS invoice_yearmonth,
    YEAR(a.created) AS invoice_year,
    MONTH(a.created) AS invoice_month,
    DAY(a.created) AS invoice_day_in_month,
    HOUR(a.created) AS invoice_hour,
	YEAR(a.packaging_deadline) AS order_year,
	MONTH(a.packaging_deadline) AS order_month,
	DAY(a.packaging_deadline) AS order_day_in_month,
	weekday(a.packaging_deadline) AS order_weekday,
	WEEK(a.packaging_deadline) - WEEK(DATE_SUB(a.packaging_deadline, INTERVAL DAYOFMONTH(a.packaging_deadline)-1 DAY)) + 1 AS order_week_in_month, 
	HOUR(a.packaging_deadline) AS order_hour,
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(a.created, '%Y-%m-%d')) AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id
LIMIT 0;

ALTER TABLE BASE_05a_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `origin` (`origin`) USING BTREE;

INSERT INTO BASE_05a_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
    CASE WHEN a.origin = 'invoices' THEN CONCAT(YEAR(a.created),'_',lpad(MONTH(a.created),2,'0')) ELSE NULL END AS invoice_yearmonth,
    CASE WHEN a.origin = 'invoices' THEN YEAR(a.created) ELSE NULL END AS invoice_year,
    CASE WHEN a.origin = 'invoices' THEN MONTH(a.created) ELSE NULL END AS invoice_month,
    CASE WHEN a.origin = 'invoices' THEN DAY(a.created) ELSE NULL END AS invoice_day_in_month,
    CASE WHEN a.origin = 'invoices' THEN HOUR(a.created) ELSE NULL END AS invoice_hour,
	CASE WHEN a.origin = 'orders' THEN YEAR(a.packaging_deadline) ELSE NULL END AS order_year,
	CASE WHEN a.origin = 'orders' THEN MONTH(a.packaging_deadline) ELSE NULL END AS order_month,
	CASE WHEN a.origin = 'orders' THEN DAY(a.packaging_deadline) ELSE NULL END AS order_day_in_month,
	CASE WHEN a.origin = 'orders' THEN weekday(a.packaging_deadline) ELSE NULL END AS order_weekday,
	CASE WHEN a.origin = 'orders' THEN WEEK(a.packaging_deadline) - WEEK(DATE_SUB(a.packaging_deadline, INTERVAL DAYOFMONTH(a.packaging_deadline)-1 DAY)) + 1 ELSE NULL END AS order_week_in_month,
	CASE WHEN a.origin = 'orders' THEN HOUR(a.packaging_deadline) ELSE NULL END AS order_hour,
	CASE WHEN a.origin = 'invoices' THEN
		TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(a.created, '%Y-%m-%d')) 
	END AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id;



DROP TABLE IF EXISTS BASE_05b_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05b_TABLE LIKE BASE_05a_TABLE;

ALTER TABLE `BASE_05b_TABLE` ADD `order_year2` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05b_TABLE` ADD `order_month2` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05b_TABLE` ADD `order_day_in_month2` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05b_TABLE` ADD `order_weekday2` INT(1) DEFAULT NULL;
ALTER TABLE `BASE_05b_TABLE` ADD `order_week_in_month2` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05b_TABLE` ADD `order_hour2` INT(2) DEFAULT NULL;


INSERT INTO BASE_05b_TABLE
SELECT DISTINCT sz.*,
				YEAR(r.packaging_deadline) AS order_year2,
				MONTH(r.packaging_deadline) AS order_month2,
				DAY(r.packaging_deadline) AS order_day_in_month2,
				WEEKDAY(r.packaging_deadline) AS order_weekday2,
				WEEK(r.packaging_deadline) - WEEK(DATE_SUB(r.packaging_deadline, INTERVAL DAYOFMONTH(r.packaging_deadline)-1 DAY)) + 1 AS order_week_in_month2,
				HOUR(r.packaging_deadline) AS order_hour2
FROM BASE_05a_TABLE AS sz
LEFT JOIN incoming_orders AS r
ON (sz.connected_order_erp_id = r.erp_id AND sz.CT1_SKU = r.item_sku)
;

DROP TABLE IF EXISTS BASE_05c_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05c_TABLE LIKE BASE_05b_TABLE;

ALTER TABLE `BASE_05c_TABLE` ADD `order_year3` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05c_TABLE` ADD `order_month3` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05c_TABLE` ADD `order_day_in_month3` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05c_TABLE` ADD `order_weekday3` INT(1) DEFAULT NULL;
ALTER TABLE `BASE_05c_TABLE` ADD `order_week_in_month3` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05c_TABLE` ADD `order_hour3` INT(2) DEFAULT NULL;

INSERT INTO BASE_05c_TABLE
SELECT DISTINCT sz.*,
				YEAR(r.packaging_deadline) AS order_year3,
				MONTH(r.packaging_deadline) AS order_month3,
				DAY(r.packaging_deadline) AS order_day_in_month3,
				WEEKDAY(r.packaging_deadline) AS order_weekday3,
				WEEK(r.packaging_deadline) - WEEK(DATE_SUB(r.packaging_deadline, INTERVAL DAYOFMONTH(r.packaging_deadline)-1 DAY)) + 1 AS order_week_in_month3,
				HOUR(r.packaging_deadline) AS order_hour3
FROM BASE_05b_TABLE AS sz
LEFT JOIN delivery_notes AS b 
ON ((sz.connected_delivery_note_erp_id = b.erp_id) AND (sz.CT1_SKU=b.item_sku))
LEFT JOIN incoming_orders AS r 
ON ((b.erp_id_of_order = r.erp_id) AND(b.item_sku=r.item_sku))
;



DROP TABLE IF EXISTS BASE_05d_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05d_TABLE LIKE BASE_05c_TABLE;

ALTER TABLE `BASE_05d_TABLE` ADD `order_year4` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05d_TABLE` ADD `order_month4` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05d_TABLE` ADD `order_day_in_month4` INT(2) DEFAULT NULL;
ALTER TABLE `BASE_05d_TABLE` ADD `order_weekday4` INT(1) DEFAULT NULL;
ALTER TABLE `BASE_05d_TABLE` ADD `order_week_in_month4` INT(4) DEFAULT NULL;
ALTER TABLE `BASE_05d_TABLE` ADD `order_hour4` INT(2) DEFAULT NULL;


INSERT INTO BASE_05d_TABLE
SELECT DISTINCT b.*,
				COALESCE(order_year,COALESCE(order_year2,COALESCE(order_year3,NULL))) AS order_year4,
				COALESCE(order_month,COALESCE(order_month2,COALESCE(order_month3,NULL))) AS order_month4,
				COALESCE(order_day_in_month,COALESCE(order_day_in_month2,COALESCE(order_day_in_month3,NULL))) AS order_day_in_month4,
				COALESCE(order_weekday,COALESCE(order_weekday2,COALESCE(order_weekday3,NULL))) AS order_weekday4,
				COALESCE(order_week_in_month,COALESCE(order_week_in_month2,COALESCE(order_week_in_month3,NULL))) AS order_week_in_month4,
				COALESCE(order_hour,COALESCE(order_hour2,COALESCE(order_hour3,NULL))) AS order_hour4
FROM BASE_05c_TABLE AS b
;


ALTER TABLE BASE_05d_TABLE
  DROP COLUMN order_year,
  DROP COLUMN order_month,
  DROP COLUMN order_day_in_month,
  DROP COLUMN order_weekday,
  DROP COLUMN order_week_in_month,
  DROP COLUMN order_hour,
  DROP COLUMN order_year2,
  DROP COLUMN order_month2,
  DROP COLUMN order_day_in_month2,
  DROP COLUMN order_weekday2,
  DROP COLUMN order_week_in_month2,
  DROP COLUMN order_hour2,
  DROP COLUMN order_year3,
  DROP COLUMN order_month3,
  DROP COLUMN order_day_in_month3,
  DROP COLUMN order_weekday3,
  DROP COLUMN order_week_in_month3,
  DROP COLUMN order_hour3
  ;


ALTER TABLE BASE_05d_TABLE CHANGE `order_year4` 			`order_year` INT(4);
ALTER TABLE BASE_05d_TABLE CHANGE `order_month4` 			`order_month` INT(2);
ALTER TABLE BASE_05d_TABLE CHANGE `order_day_in_month4` 	`order_day_in_month` INT(2);
ALTER TABLE BASE_05d_TABLE CHANGE `order_weekday4` 			`order_weekday` INT(1);
ALTER TABLE BASE_05d_TABLE CHANGE `order_week_in_month4` 	`order_week_in_month` INT(4);
ALTER TABLE BASE_05d_TABLE CHANGE `order_hour4` 			`order_hour` INT(2);
