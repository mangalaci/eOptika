DROP TABLE IF EXISTS COHORT_01_first_last_purchase;

CREATE TABLE IF NOT EXISTS COHORT_01_first_last_purchase
SELECT user_id, related_division, user_type,
     CONCAT(YEAR(MIN(processed)),'_',LPAD(MONTH(MIN(processed)),2,'0')) AS date_of_first_purchase,
     CONCAT(YEAR(MAX(processed)),'_',LPAD(MONTH(MAX(processed)),2,'0')) AS date_of_last_purchase,
	 MAX(processed) AS last_purchase,
     COUNT(DISTINCT erp_id) AS user_cum_transactions,
     SUM(item_gross_value_in_currency*exchange_rate_of_currency) AS user_cum_gross_revenue_in_base_currency,
     CASE WHEN COUNT(DISTINCT erp_id) > 1 THEN 'repeat' ELSE '1-time' END num_of_purch
     FROM BASE_04c_TABLE
GROUP BY user_id
LIMIT 0;

ALTER TABLE COHORT_01_first_last_purchase ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE COHORT_01_first_last_purchase ADD INDEX `date_of_first_purchase` (`date_of_first_purchase`) USING BTREE;
ALTER TABLE COHORT_01_first_last_purchase ADD INDEX `date_of_last_purchase` (`date_of_last_purchase`) USING BTREE;

INSERT INTO COHORT_01_first_last_purchase
SELECT DISTINCT
     user_id, related_division, user_type,
     CONCAT(YEAR(MIN(processed)),'_',LPAD(MONTH(MIN(processed)),2,'0')) AS date_of_first_purchase,
     CONCAT(YEAR(MAX(processed)),'_',LPAD(MONTH(MAX(processed)),2,'0')) AS date_of_last_purchase,
	 MAX(processed) AS last_purchase,
     COUNT(DISTINCT erp_id) AS user_cum_transactions,
     SUM(item_gross_value_in_currency*exchange_rate_of_currency) AS user_cum_gross_revenue_in_base_currency,
     CASE WHEN COUNT(DISTINCT erp_id) > 1 THEN 'repeat' ELSE '1-time' END num_of_purch
     FROM BASE_04c_TABLE
	 WHERE origin = 'invoices'
GROUP BY user_id;


DROP TABLE IF EXISTS BASE_05a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_05a_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
	b.last_purchase,
    CONCAT(YEAR(a.processed),'_',LPAD(MONTH(a.processed),2,'0')) AS invoice_yearmonth,
    YEAR(a.processed) AS invoice_year,
    QUARTER(a.processed) AS invoice_quarter,
    MONTH(a.processed) AS invoice_month,
    DAY(a.processed) AS invoice_day_in_month,
    HOUR(a.processed) AS invoice_hour,
	
	YEAR(a.created) AS order_year,
	QUARTER(a.created) AS order_quarter,
	MONTH(a.created) AS order_month,
	DAY(a.created) AS order_day_in_month,
	weekday(a.created) AS order_weekday,
	WEEK(a.created) - WEEK(DATE_SUB(a.created, INTERVAL DAYOFMONTH(a.created)-1 DAY)) + 1 AS order_week_in_month,
	HOUR(a.created) AS order_hour,
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(a.processed, '%Y-%m-%d')) AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04c_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id
LIMIT 0;

ALTER TABLE BASE_05a_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;
ALTER TABLE BASE_05a_TABLE ADD INDEX `origin` (`origin`) USING BTREE;

INSERT INTO BASE_05a_TABLE
SELECT  a.*, 
    b.date_of_first_purchase AS cohort_id,
	b.last_purchase,
    CASE WHEN a.origin = 'invoices' THEN CONCAT(YEAR(a.processed),'_',lpad(MONTH(a.processed),2,'0')) END AS invoice_yearmonth,
    CASE WHEN a.origin = 'invoices' THEN YEAR(a.processed) END AS invoice_year,
    CASE WHEN a.origin = 'invoices' THEN QUARTER(a.processed) END AS invoice_quarter,
    CASE WHEN a.origin = 'invoices' THEN MONTH(a.processed) END AS invoice_month,
    CASE WHEN a.origin = 'invoices' THEN DAY(a.processed) END AS invoice_day_in_month,
    CASE WHEN a.origin = 'invoices' THEN HOUR(a.processed) END AS invoice_hour,
	
	CASE WHEN a.origin = 'orders' THEN YEAR(a.created) END AS order_year,
	CASE WHEN a.origin = 'orders' THEN QUARTER(a.created) END AS order_quarter,
	CASE WHEN a.origin = 'orders' THEN MONTH(a.created) END AS order_month,
	CASE WHEN a.origin = 'orders' THEN DAY(a.created) END AS order_day_in_month,
	CASE WHEN a.origin = 'orders' THEN weekday(a.created) END AS order_weekday,
	CASE WHEN a.origin = 'orders' THEN WEEK(a.created) - WEEK(DATE_SUB(a.created, INTERVAL DAYOFMONTH(a.created)-1 DAY)) + 1 END AS order_week_in_month,
	CASE WHEN a.origin = 'orders' THEN HOUR(a.created) END AS order_hour,
	CASE WHEN a.origin = 'invoices' THEN
		TIMESTAMPDIFF(MONTH, STR_TO_DATE(REPLACE(CONCAT(b.date_of_first_purchase,'-28'), '_', '-'), '%Y-%m-%d'), STR_TO_DATE(a.processed, '%Y-%m-%d')) 
	END AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.num_of_purch
FROM BASE_04c_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id
;


/*WEBSHOPOS rendelés kiszállítással*/
UPDATE BASE_05a_TABLE AS sz
        INNER JOIN
    incoming_orders AS r ON (sz.connected_order_erp_id = r.erp_id AND sz.CT1_SKU = r.item_sku)
SET 
    sz.order_year = YEAR(r.created),
	sz.order_quarter = QUARTER(r.created),
	sz.order_month = MONTH(r.created),
	sz.order_day_in_month = DAY(r.created),
	sz.order_weekday = WEEKDAY(r.created),
	sz.order_week_in_month = WEEK(r.created) - WEEK(DATE_SUB(r.created, INTERVAL DAYOFMONTH(r.created)-1 DAY)) + 1,
	sz.order_hour = HOUR(r.created)
;



/*WEBSHOPOS rendelés személyes átvétellel*/
UPDATE BASE_05a_TABLE AS sz
        INNER JOIN
    delivery_notes AS b ON ((sz.connected_delivery_note_erp_id = b.erp_id) AND (sz.CT1_SKU=b.item_sku))
        INNER JOIN
    incoming_orders AS r ON ((b.erp_id_of_order = r.erp_id) AND(b.item_sku=r.item_sku))	
SET 
    sz.order_year = YEAR(r.created),
    sz.order_quarter = QUARTER(r.created),
	sz.order_month = MONTH(r.created),
	sz.order_day_in_month = DAY(r.created),
	sz.order_weekday = WEEKDAY(r.created),
	sz.order_week_in_month = WEEK(r.created) - WEEK(DATE_SUB(r.created, INTERVAL DAYOFMONTH(r.created)-1 DAY)) + 1,
	sz.order_hour = HOUR(r.created)
;


/*OFFLINE vásárlás (utcáról bejött)*/
UPDATE BASE_05a_TABLE
SET
    order_year = YEAR(created),
    order_quarter = QUARTER(created),
	order_month = MONTH(created),
	order_day_in_month = DAY(created),
	order_weekday = WEEKDAY(created),
	order_week_in_month = WEEK(created) - WEEK(DATE_SUB(created, INTERVAL DAYOFMONTH(created)-1 DAY)) + 1,
	order_hour = HOUR(created)
WHERE order_year IS NULL
;