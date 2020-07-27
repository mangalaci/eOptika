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


DROP TABLE IF EXISTS BASE_05_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
    CONCAT(year(created),'_',lpad(MONTH(created),2,'0')) AS invoice_yearmonth,
    YEAR(created) AS invoice_year,
    MONTH(created) AS invoice_month,
    DAY(created) AS invoice_day_in_month,
    HOUR(created) AS invoice_hour,
	YEAR(created) AS order_year,
	MONTH(created) AS order_month,
	DAY(created) AS order_day_in_month,
	weekday(created) AS order_weekday,
	WEEK(created) - WEEK(DATE_SUB(created, INTERVAL DAYOFMONTH(created)-1 DAY)) + 1 AS order_week_in_month, 
	HOUR(created) AS order_hour,
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(created, '%Y-%m-%d')) AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id
LIMIT 0;

ALTER TABLE BASE_05_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_05_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;


INSERT INTO BASE_05_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
    CONCAT(year(created),'_',lpad(MONTH(created),2,'0')) AS invoice_yearmonth,
    YEAR(created) AS invoice_year,
    MONTH(created) AS invoice_month,
    DAY(created) AS invoice_day_in_month,
    HOUR(created) AS invoice_hour,
	YEAR(created) AS order_year,
	MONTH(created) AS order_month,
	DAY(created) AS order_day_in_month,
	weekday(created) AS order_weekday,
	WEEK(created) - WEEK(DATE_SUB(created, INTERVAL DAYOFMONTH(created)-1 DAY)) + 1 AS order_week_in_month, 
	HOUR(created) AS order_hour,	
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(created, '%Y-%m-%d')) AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id;