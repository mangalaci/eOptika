DROP TABLE IF EXISTS trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE IF NOT EXISTS trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_03_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
;


ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;



UPDATE
BASE_03_TABLE AS u
LEFT JOIN trx_numbering r
ON (r.erp_invoice_id = u.erp_invoice_id AND r.user_id = u.user_id)
SET
u.trx_rank = r.trx_rank
;








/*ORDER és INVOICE DATE meghatározása*/
DROP TABLE IF EXISTS order_invoice_dates;
CREATE TABLE IF NOT EXISTS order_invoice_dates
SELECT  DISTINCT
	a.origin,
	a.erp_invoice_id,
	a.reference_id,
	CASE
		WHEN SUBSTR(reference_id,1,2) IN ('EO', 'IT', 'UK') THEN SUBSTR(reference_id,3,8)
	END AS new_reference_id,
	a.created,
	a.user_id,
	a.billing_zip_code,
	a.buyer_email,
	a.personal_name,
	MAX(a.connected_order_erp_id) AS connected_order_erp_id,
	a.connected_delivery_note_erp_id,
	a.coupon_code,
	a.related_webshop,
    b.cohort_id,
	b.first_purchase,
	b.last_purchase,
	b.contact_lens_last_purchase,	
    CASE WHEN a.origin = 'invoices' THEN CONCAT(YEAR(a.last_modified_date),'_',lpad(MONTH(a.last_modified_date),2,'0')) END AS invoice_yearmonth,
    CASE WHEN a.origin = 'invoices' THEN YEAR(a.last_modified_date) END AS invoice_year,
    CASE WHEN a.origin = 'invoices' THEN QUARTER(a.last_modified_date) END AS invoice_quarter,
    CASE WHEN a.origin = 'invoices' THEN MONTH(a.last_modified_date) END AS invoice_month,
    CASE WHEN a.origin = 'invoices' THEN DAY(a.last_modified_date) END AS invoice_day_in_month,
    CASE WHEN a.origin = 'invoices' THEN HOUR(a.last_modified_date) END AS invoice_hour,
	
	CASE WHEN a.origin = 'orders' THEN YEAR(a.created) END AS order_year,
	CASE WHEN a.origin = 'orders' THEN QUARTER(a.created) END AS order_quarter,
	CASE WHEN a.origin = 'orders' THEN MONTH(a.created) END AS order_month,
	CASE WHEN a.origin = 'orders' THEN DAY(a.created) END AS order_day_in_month,
	CASE WHEN a.origin = 'orders' THEN weekday(a.created) END AS order_weekday,
	CASE WHEN a.origin = 'orders' THEN WEEK(a.created) - WEEK(DATE_SUB(a.created, INTERVAL DAYOFMONTH(a.created)-1 DAY)) + 1 END AS order_week_in_month,
	CASE WHEN a.origin = 'orders' THEN HOUR(a.created) END AS order_hour,
	CASE WHEN a.origin = 'invoices' THEN
	TIMESTAMPDIFF(MONTH, b.first_purchase, b.last_purchase)
	END AS cohort_month_since,
    b.user_cum_transactions,
    b.user_cum_gross_revenue_in_base_currency,
    b.repeat_buyer,
	b.contact_lens_user,
	b.solution_user,
	b.eye_drops_user,
	b.sunglass_user,
	b.vitamin_user,
	b.frames_user,
	b.lenses_for_spectacles_user,
	b.contact_lens_trials_user,
	b.spectacles_user,
	b.other_product_user,
	a.user_active_flg

FROM BASE_03_TABLE a LEFT JOIN COHORT_01_first_last_purchase b
ON a.user_id = b.user_id
GROUP BY a.erp_invoice_id
;


ALTER TABLE order_invoice_dates ADD PRIMARY KEY `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `reference_id` (`reference_id`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `origin` (`origin`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `related_webshop` (`related_webshop`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `new_reference_id` (`new_reference_id`) USING BTREE;
ALTER TABLE order_invoice_dates CHANGE `new_reference_id` `new_reference_id` INT(10) NULL DEFAULT NULL;

/*WEBSHOPOS rendelés kiszállítással*/
UPDATE order_invoice_dates AS sz
        INNER JOIN
    incoming_orders AS r ON (sz.connected_order_erp_id = r.erp_id)
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
UPDATE order_invoice_dates AS sz
        INNER JOIN
    delivery_notes AS b ON sz.connected_delivery_note_erp_id = b.erp_id
        INNER JOIN
    incoming_orders AS r ON b.erp_id_of_order = r.erp_id	
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
UPDATE order_invoice_dates
SET
    order_year = YEAR(created),
    order_quarter = QUARTER(created),
	order_month = MONTH(created),
	order_day_in_month = DAY(created),
	order_weekday = WEEKDAY(created),
	order_week_in_month = WEEK(created) - WEEK(DATE_SUB(created, INTERVAL DAYOFMONTH(created)-1 DAY)) + 1,
	order_hour = HOUR(created)
;

