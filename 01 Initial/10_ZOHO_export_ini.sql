/* vásárlási emlékeztető hozzáadása START */


DROP TABLE IF EXISTS BASE_08a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08a_TABLE
SELECT 	erp_invoice_id,
		CT1_sku,
		CONCAT(order_year, '-', order_month, '-', order_day_in_month) AS order_date,
		wear_days,
		pack_size,
		product_group,
		MAX(IFNULL(time_order_to_dispatch,0))/24 AS time_order_to_dispatch,
		MAX(IFNULL(time_dispatch_to_delivery,0))/24 AS time_dispatch_to_delivery,
		SUM(ABS(item_quantity)) AS sum_item_quantity
FROM BASE_03_TABLE
WHERE origin = 'invoices'
GROUP BY erp_invoice_id, CT1_sku, buyer_email, product_group, wear_days, order_date
;

ALTER TABLE BASE_08a_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `CT1_sku` (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS BASE_08b_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08b_TABLE
SELECT 	erp_invoice_id, COUNT(DISTINCT CT1_SKU) AS num_of_different_sku
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND product_group = 'Contact Lenses'
GROUP BY erp_invoice_id
;

ALTER TABLE BASE_08b_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;


UPDATE
BASE_03_TABLE AS t
LEFT JOIN BASE_08a_TABLE AS a
ON (t.erp_invoice_id = a.erp_invoice_id AND t.CT1_sku = a.CT1_sku)
LEFT JOIN BASE_08b_TABLE AS b
ON (t.erp_invoice_id = b.erp_invoice_id)
SET
t.date_lenses_run_out =
CASE WHEN t.product_group = 'Contact Lenses' AND b.num_of_different_sku = 1 THEN
	CASE 	WHEN t.origin = 'invoices'
			THEN DATE_ADD(a.order_date, INTERVAL a.wear_days*a.sum_item_quantity/2 + COALESCE(a.time_order_to_dispatch,0) + COALESCE(a.time_dispatch_to_delivery,0) DAY)
			ELSE ''
	END
	WHEN t.product_group = 'Contact Lenses' AND b.num_of_different_sku > 1 THEN
	CASE 	WHEN t.origin = 'invoices'
			THEN DATE_ADD(a.order_date, INTERVAL a.wear_days*a.sum_item_quantity + COALESCE(a.time_order_to_dispatch,0) + COALESCE(a.time_dispatch_to_delivery,0) DAY)
			ELSE ''
	END
END,
t.date_lens_cleaners_run_out =
CASE WHEN t.product_group = 'Contact Lens Cleaners' AND b.num_of_different_sku = 1 THEN
	CASE 	WHEN t.origin = 'invoices'
			THEN DATE_ADD(a.order_date, INTERVAL a.pack_size*a.sum_item_quantity/4 + COALESCE(a.time_order_to_dispatch,0) + COALESCE(a.time_dispatch_to_delivery,0) DAY)
			ELSE ''
	END
	WHEN t.product_group = 'Contact Lens Cleaners' AND b.num_of_different_sku > 1 THEN
	CASE 	WHEN t.origin = 'invoices'
			THEN DATE_ADD(a.order_date, INTERVAL a.pack_size*a.sum_item_quantity/8 + COALESCE(a.time_order_to_dispatch,0) + COALESCE(a.time_dispatch_to_delivery,0) DAY)
			ELSE ''
	END
END

WHERE t.origin = 'invoices'
;




UPDATE
AGGR_USER_UNSANITIZED AS u
INNER JOIN 
(
select 	user_id,
		max(date_lenses_run_out) as min_date_lenses_run_out, 
		max(date_lens_cleaners_run_out) as min_date_lens_cleaners_run_out
from BASE_03_TABLE
group by user_id
) r
ON r.user_id = u.user_id
SET	u.date_lenses_run_out = min_date_lenses_run_out,
	u.date_lens_cleaners_run_out = min_date_lens_cleaners_run_out
;



/* vásárlási emlékeztető hozzáadása END */





DROP TABLE IF EXISTS BASE_10_TABLE;
CREATE TABLE IF NOT EXISTS BASE_10_TABLE
SELECT *
FROM BASE_03_TABLE
;


ALTER TABLE BASE_10_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_10_TABLE ADD INDEX `last_update` (`last_update`) USING BTREE;

UPDATE BASE_10_TABLE 
SET 
	buyer_email = NULL,
	primary_email = NULL,
	secondary_email = NULL,
	personal_name = NULL,
	personal_address = NULL,
	pickup_name = NULL,
	pickup_address = NULL,
	business_name = NULL,
	business_address = NULL,
	shipping_name = NULL,
	billing_name = NULL,
	shipping_phone = NULL,
	full_name = NULL,
	first_name = NULL,
	last_name = NULL
;
