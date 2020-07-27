

/*hiányzó related_webshop kitöltése: BEGIN*/
UPDATE
BASE_03_TABLE
SET
	related_webshop =  CASE WHEN (source_of_trx = 'offline' AND related_webshop = '') THEN 'offline' END,
	related_webshop =  CASE WHEN (source_of_trx = 'online' AND related_webshop = '') THEN 'Other' END,
	related_webshop =  CASE WHEN (related_webshop = 'eoptika.hu') THEN 'eOptika.hu' END
;
/*hiányzó related_webshop kitöltése: END*/




/* vásárlási emlékeztető hozzáadása */
ALTER TABLE BASE_03_TABLE ADD INDEX `wear_days` (`wear_days`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `item_quantity` (`item_quantity`) USING BTREE;



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
BASE_03_TABLE AS b
LEFT JOIN IN_LVCR_item AS i 
ON b.CT2_pack = i.Description
SET
b.LVCR_item_flg = CASE WHEN i.Description IS NOT NULL THEN 1 ELSE 0 END
;


UPDATE
BASE_03_TABLE AS b
LEFT JOIN IN_GDPR_opt_out AS i 
ON b.buyer_email = i.email
SET
b.GDPR_status = i.GDPR_status
;




/* PRODUCT GROUP 2 (szemüveg részei együtt): START */

DROP TABLE IF EXISTS BASE_08c_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08c_TABLE
SELECT 	erp_invoice_id
FROM BASE_03_TABLE
GROUP BY erp_invoice_id
HAVING SUM(CASE WHEN product_group = 'Lenses for spectacles' THEN 1 ELSE 0 END)*SUM(CASE WHEN product_group = 'Frames' THEN 1 ELSE 0 END) > 0
;

ALTER TABLE BASE_08c_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;



UPDATE
BASE_03_TABLE AS b
LEFT JOIN BASE_08c_TABLE AS c 
ON b.erp_invoice_id = c.erp_invoice_id
SET
b.product_group_2 = CASE WHEN c.erp_invoice_id IS NOT NULL AND (b.product_group IN ('Frames', 'Lenses for spectacles', 'Eye tests') OR CT2_pack IN ('Szemüvegkellékek', 'Munkadíjak')) THEN 'Spectacles' ELSE b.product_group END
;

/* PRODUCT GROUP 2 (szemüveg részei együtt): END */



/* EXPERIMENT mező hozzáadása : START */


/* 'CL-THX10W' kapott, és beváltotta */
UPDATE BASE_03_TABLE m
LEFT JOIN
(
SELECT user_id, created
FROM `BASE_03_TABLE` 
WHERE origin = 'invoices'
AND CT1_SKU = 'CL-THX10W'
AND trx_rank = 1
) s
ON m.user_id = s.user_id 
SET m.experiment = CASE WHEN s.user_id IS NOT NULL THEN 'CL-THX10W-YES' ELSE NULL END
WHERE m.origin = 'invoices' 
AND m.related_division = 'Optika - HU' 
AND m.coupon_code = 'THX10W' 
AND m.trx_rank = 2
;

/* 'CL-THX10W' kapott, de nem váltotta be */
UPDATE BASE_03_TABLE m
LEFT JOIN
(
SELECT user_id, created
FROM `BASE_03_TABLE` 
WHERE origin = 'invoices'
AND CT1_SKU = 'CL-THX10W'
AND trx_rank = 1
) s
ON m.user_id = s.user_id 
SET m.experiment = CASE WHEN s.user_id IS NOT NULL THEN 'CL-THX10W-NO' ELSE NULL END
WHERE m.origin = 'invoices' 
AND m.related_division = 'Optika - HU' 
AND m.coupon_code IS NULL
AND m.trx_rank = 2
;

/* EXPERIMENT mező hozzáadása: END */







DROP TABLE IF EXISTS BASE_10_TABLE;
CREATE TABLE IF NOT EXISTS BASE_10_TABLE
SELECT *
FROM BASE_03_TABLE
;


ALTER TABLE BASE_10_TABLE ADD PRIMARY KEY (`id`) USING BTREE;


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
