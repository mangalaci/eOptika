/* SINGLE-MULTIPLE USER BLOCK: START */
DROP TABLE IF EXISTS multiple_lens_user;
CREATE TABLE IF NOT EXISTS multiple_lens_user
SELECT z.user_id,
		CASE
			WHEN IFNULL(z.num_of_pwr_per_trx_over_limit,0) + z.pwr_diff_over_limit = 0 THEN 'single user'
			ELSE 'multi user'
		END AS multi_user_account
FROM
(
SELECT v.user_id,
/* ha 1 trx-ben több, mint 2-féle dioptria van (1 vagy 2 szemre ), akkor biztosan nem csak magának vette */
	CASE WHEN MAX(num_of_pwr_per_trx) > 2 THEN 1 ELSE 0
	END AS num_of_pwr_per_trx_over_limit,
/* ha 2 különböző trx (pwr+cyl) per tétel átlagának különbsége nagyobb, mint 0.25, amennyiben mind a két trx-ben legalább 2-féle lencse volt, akkor biztosan nem magának vette */
		CASE WHEN MAX(ABS(CASE WHEN num_of_pwr_per_trx > 1 THEN avg_pwr_per_item END))-MIN(ABS(CASE WHEN num_of_pwr_per_trx > 1 THEN avg_pwr_per_item END)) > 0.25  THEN 1 ELSE 0
		END AS pwr_diff_over_limit
FROM
(
SELECT 	user_id,
		erp_invoice_id,
		SUM(DISTINCT lens_pwr+IFNULL(lens_cyl,0))/COUNT(DISTINCT (lens_pwr+IFNULL(lens_cyl,0))) AS avg_pwr_per_item,
        COUNT(DISTINCT lens_pwr) AS num_of_pwr_per_trx
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 360 DAY) AND contact_lens_last_purchase
GROUP BY user_id, erp_invoice_id
) v
GROUP BY user_id
) z
;

ALTER TABLE multiple_lens_user ADD PRIMARY KEY (user_id);

UPDATE BASE_03_TABLE as b
SET b.multi_user_account = (SELECT m.multi_user_account FROM multiple_lens_user as m WHERE b.user_id = m.user_id)
;

UPDATE BASE_03_TABLE o 
SET o.multi_user_account = 'no lens yet'
WHERE o.multi_user_account IS NULL
;


/* két szem szétválasztása */
DROP TABLE IF EXISTS user_eye_pwr;
CREATE TABLE IF NOT EXISTS user_eye_pwr
SELECT 	user_id, 
		MAX(lens_pwr) AS pwr_eye1,
		CASE WHEN MAX(lens_pwr) = MIN(lens_pwr) THEN '' ELSE MIN(lens_pwr) END AS pwr_eye2
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 360 DAY) AND contact_lens_last_purchase
AND multi_user_account = 0
GROUP BY user_id
;

ALTER TABLE user_eye_pwr ADD PRIMARY KEY (user_id);
/*ALTER TABLE BASE_03_TABLE ADD PRIMARY KEY (id);*/


UPDATE BASE_03_TABLE as b
SET 
b.pwr_eye1 = (SELECT m.pwr_eye1 FROM user_eye_pwr as m WHERE b.user_id = m.user_id),
b.pwr_eye2 = (SELECT m.pwr_eye2 FROM user_eye_pwr as m WHERE b.user_id = m.user_id)
;

/* SINGLE-MULTIPLE USER BLOCK: END */



/* TYPICAL LENS, SOUTION, EYE DROPS CALCULATION: START */



/*
https://stackoverflow.com/questions/34505799/how-to-pass-dynamic-table-name-into-mysql-procedure-with-this-query
*/

CALL TypicalProduct('typical_wear_days_eye1', 'pwr_eye1', 'wear_days', "'Contact lenses'");
ALTER TABLE typical_wear_days_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_days_eye2', 'pwr_eye2', 'wear_days', "'Contact lenses'");
ALTER TABLE typical_wear_days_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_duration_eye1', 'pwr_eye1', 'wear_duration', "'Contact lenses'");
ALTER TABLE typical_wear_duration_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_duration_eye2', 'pwr_eye2', 'wear_duration', "'Contact lenses'");
ALTER TABLE typical_wear_duration_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('bc_eye1', 'pwr_eye1', 'lens_bc', "'Contact lenses'");
ALTER TABLE bc_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('bc_eye2', 'pwr_eye2', 'lens_bc', "'Contact lenses'");
ALTER TABLE bc_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('cyl_eye1', 'pwr_eye1', 'lens_cyl', "'Contact lenses'");
ALTER TABLE cyl_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('cyl_eye2', 'pwr_eye2', 'lens_cyl', "'Contact lenses'");
ALTER TABLE cyl_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('ax_eye1', 'pwr_eye1', 'lens_ax', "'Contact lenses'");
ALTER TABLE ax_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('ax_eye2', 'pwr_eye2', 'lens_ax', "'Contact lenses'");
ALTER TABLE ax_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('dia_eye1', 'pwr_eye1', 'lens_dia', "'Contact lenses'");
ALTER TABLE dia_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('dia_eye2', 'pwr_eye2', 'lens_dia', "'Contact lenses'");
ALTER TABLE dia_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('add_eye1', 'pwr_eye1', 'lens_add', "'Contact lenses'");
ALTER TABLE add_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('add_eye2', 'pwr_eye2', 'lens_add', "'Contact lenses'");
ALTER TABLE add_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('clr_eye1', 'pwr_eye1', 'lens_clr', "'Contact lenses'");
ALTER TABLE clr_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('clr_eye2', 'pwr_eye2', 'lens_clr', "'Contact lenses'");
ALTER TABLE clr_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_type_eye1', 'pwr_eye1', 'lens_type', "'Contact lenses'");
ALTER TABLE typical_lens_type_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_type_eye2', 'pwr_eye2', 'lens_type', "'Contact lenses'");
ALTER TABLE typical_lens_type_eye2 ADD PRIMARY KEY (user_id);


CALL TypicalProduct('typical_lens_eye1_CT1', 'pwr_eye1', 'CT1_SKU_name', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT1', 'pwr_eye2', 'CT1_SKU_name', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT1_sku', 'pwr_eye1', 'CT1_SKU', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT1_sku ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT1_sku', 'pwr_eye2', 'CT1_SKU', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT1_sku ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT2', 'pwr_eye1', 'CT2_pack', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT2', 'pwr_eye2', 'CT2_pack', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT2', 'lens_pwr', 'CT2_pack', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT2', 'lens_pwr', 'CT2_pack', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT3', 'pwr_eye1', 'CT3_product', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT3', 'pwr_eye2', 'CT3_product', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT3', 'lens_pwr', 'CT3_product', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT3', 'lens_pwr', 'CT3_product', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT4', 'pwr_eye1', 'CT4_product_brand', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT4', 'pwr_eye2', 'CT4_product_brand', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT4', 'lens_pwr', 'CT4_product_brand', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT4', 'lens_pwr', 'CT4_product_brand', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT5', 'pwr_eye1', 'CT5_manufacturer', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT5', 'pwr_eye2', 'CT5_manufacturer', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT5', 'lens_pwr', 'CT5_manufacturer', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT5', 'lens_pwr', 'CT5_manufacturer', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_pack_size', 'lens_pwr', 'pack_size', "'Contact lenses'");
ALTER TABLE typical_lens_pack_size ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_pack_size', 'lens_pwr', 'pack_size', "'Contact lens cleaners'");
ALTER TABLE typical_solution_pack_size ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_pack_size', 'lens_pwr', 'pack_size', "'Eye drops'");
ALTER TABLE typical_eye_drop_pack_size ADD PRIMARY KEY (user_id);



UPDATE
typical_features AS m
LEFT JOIN typical_wear_days_eye1 s
ON m.user_id = s.user_id
SET m.typical_wear_days_eye1 = s.typical_wear_days_eye1
;

UPDATE
typical_features AS m
LEFT JOIN typical_wear_days_eye2 s
ON m.user_id = s.user_id
SET m.typical_wear_days_eye2 = s.typical_wear_days_eye2
;

UPDATE
typical_features AS m
LEFT JOIN typical_wear_duration_eye1 s
ON m.user_id = s.user_id
SET m.typical_wear_duration_eye1 = s.typical_wear_duration_eye1
;

UPDATE
typical_features AS m
LEFT JOIN typical_wear_duration_eye2 s
ON m.user_id = s.user_id
SET m.typical_wear_duration_eye2 = s.typical_wear_duration_eye2
;

UPDATE
typical_features AS m
LEFT JOIN bc_eye1 s
ON m.user_id = s.user_id
SET m.bc_eye1 = s.bc_eye1
;

UPDATE
typical_features AS m
LEFT JOIN bc_eye2 s
ON m.user_id = s.user_id
SET m.bc_eye2 = s.bc_eye2
;

UPDATE
typical_features AS m
LEFT JOIN cyl_eye1 s
ON m.user_id = s.user_id
SET m.cyl_eye1 = s.cyl_eye1
;

UPDATE
typical_features AS m
LEFT JOIN cyl_eye2 s
ON m.user_id = s.user_id
SET m.cyl_eye2 = s.cyl_eye2
;

UPDATE
typical_features AS m
LEFT JOIN ax_eye1 s
ON m.user_id = s.user_id
SET m.ax_eye1 = s.ax_eye1
;

UPDATE
typical_features AS m
LEFT JOIN ax_eye2 s
ON m.user_id = s.user_id
SET m.ax_eye2 = s.ax_eye2
;

UPDATE
typical_features AS m
LEFT JOIN dia_eye1 s
ON m.user_id = s.user_id
SET m.dia_eye1 = s.dia_eye1
;

UPDATE
typical_features AS m
LEFT JOIN dia_eye2 s
ON m.user_id = s.user_id
SET m.dia_eye2 = s.dia_eye2
;

UPDATE
typical_features AS m
LEFT JOIN add_eye1 s
ON m.user_id = s.user_id
SET m.add_eye1 = s.add_eye1
;

UPDATE
typical_features AS m
LEFT JOIN add_eye2 s
ON m.user_id = s.user_id
SET m.add_eye2 = s.add_eye2
;

UPDATE
typical_features AS m
LEFT JOIN clr_eye1 s
ON m.user_id = s.user_id
SET m.clr_eye1 = s.clr_eye1
;

UPDATE
typical_features AS m
LEFT JOIN clr_eye2 s
ON m.user_id = s.user_id
SET m.clr_eye2 = s.clr_eye2
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_type_eye1 s
ON m.user_id = s.user_id
SET m.typical_lens_type_eye1 = s.typical_lens_type_eye1
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_type_eye2 s
ON m.user_id = s.user_id
SET m.typical_lens_type_eye2 = s.typical_lens_type_eye2
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT1 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT1 = s.typical_lens_eye1_CT1
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT1_sku s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT1_sku = s.typical_lens_eye1_CT1_sku
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT1 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT1 = s.typical_lens_eye2_CT1
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT1_sku s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT1_sku = s.typical_lens_eye2_CT1_sku
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT2 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT2 = s.typical_lens_eye1_CT2
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT2 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT2 = s.typical_lens_eye2_CT2
;

UPDATE
typical_features AS m
LEFT JOIN typical_solution_CT2 s
ON m.user_id = s.user_id
SET m.typical_solution_CT2 = s.typical_solution_CT2
;

UPDATE
typical_features AS m
LEFT JOIN typical_eye_drop_CT2 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT2 = s.typical_eye_drop_CT2
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT3 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT3 = s.typical_lens_eye1_CT3
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT3 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT3 = s.typical_lens_eye2_CT3
;

UPDATE
typical_features AS m
LEFT JOIN typical_solution_CT3 s
ON m.user_id = s.user_id
SET m.typical_solution_CT3 = s.typical_solution_CT3
;

UPDATE
typical_features AS m
LEFT JOIN typical_eye_drop_CT3 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT3 = s.typical_eye_drop_CT3
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT4 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT4 = s.typical_lens_eye1_CT4
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT4 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT4 = s.typical_lens_eye2_CT4
;

UPDATE
typical_features AS m
LEFT JOIN typical_solution_CT4 s
ON m.user_id = s.user_id
SET m.typical_solution_CT4 = s.typical_solution_CT4
;

UPDATE
typical_features AS m
LEFT JOIN typical_eye_drop_CT4 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT4 = s.typical_eye_drop_CT4
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye1_CT5 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT5 = s.typical_lens_eye1_CT5
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_eye2_CT5 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT5 = s.typical_lens_eye2_CT5
;

UPDATE
typical_features AS m
LEFT JOIN typical_solution_CT5 s
ON m.user_id = s.user_id
SET m.typical_solution_CT5 = s.typical_solution_CT5
;

UPDATE
typical_features AS m
LEFT JOIN typical_eye_drop_CT5 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT5 = s.typical_eye_drop_CT5
;

UPDATE
typical_features AS m
LEFT JOIN typical_lens_pack_size s
ON m.user_id = s.user_id
SET m.typical_lens_pack_size = s.typical_lens_pack_size
;

UPDATE
typical_features AS m
LEFT JOIN typical_solution_pack_size s
ON m.user_id = s.user_id
SET m.typical_solution_pack_size = s.typical_solution_pack_size
;

UPDATE
typical_features AS m
LEFT JOIN typical_eye_drop_pack_size s
ON m.user_id = s.user_id
SET m.typical_eye_drop_pack_size = s.typical_eye_drop_pack_size
;



UPDATE
BASE_03_TABLE AS u
INNER JOIN typical_features r
ON r.user_id = u.user_id
SET u.typical_wear_days_eye1 = r.typical_wear_days_eye1,
	u.typical_wear_days_eye2 = r.typical_wear_days_eye2,
	u.typical_wear_duration_eye1 = r.typical_wear_duration_eye1,
	u.typical_wear_duration_eye2 = r.typical_wear_duration_eye2,
	u.bc_eye1 = r.bc_eye1,
	u.bc_eye2 = r.bc_eye2,
	u.cyl_eye1 = r.cyl_eye1,
	u.cyl_eye2 = r.cyl_eye2,
	u.ax_eye1 = r.ax_eye1,
	u.ax_eye2 = r.ax_eye2,
	u.dia_eye1 = r.dia_eye1,
	u.dia_eye2 = r.dia_eye2,
	u.add_eye1 = r.add_eye1,
	u.add_eye2 = r.add_eye2,
	u.clr_eye1 = r.clr_eye1,
	u.clr_eye2 = r.clr_eye2,
	u.typical_lens_type_eye1 = r.typical_lens_type_eye1,
	u.typical_lens_type_eye2 = r.typical_lens_type_eye2,
	u.typical_lens_eye1_CT1 = r.typical_lens_eye1_CT1,
	u.typical_lens_eye1_CT1_sku = r.typical_lens_eye1_CT1_sku,
	u.typical_lens_eye2_CT1 = r.typical_lens_eye2_CT1,
	u.typical_lens_eye2_CT1_sku = r.typical_lens_eye2_CT1_sku,
	u.typical_lens_eye1_CT2 = r.typical_lens_eye1_CT2,
	u.typical_lens_eye2_CT2 = r.typical_lens_eye2_CT2,
	u.typical_solution_CT2 = r.typical_solution_CT2,
	u.typical_eye_drop_CT2 = r.typical_eye_drop_CT2,
	u.typical_lens_eye1_CT3 = r.typical_lens_eye1_CT3,
	u.typical_lens_eye2_CT3 = r.typical_lens_eye2_CT3,
	u.typical_solution_CT3 = r.typical_solution_CT3,
	u.typical_eye_drop_CT3 = r.typical_eye_drop_CT3,
	u.typical_lens_eye1_CT4 = r.typical_lens_eye1_CT4,
	u.typical_lens_eye2_CT4 = r.typical_lens_eye2_CT4,
	u.typical_solution_CT4 = r.typical_solution_CT4,
	u.typical_eye_drop_CT4 = r.typical_eye_drop_CT4,
	u.typical_lens_eye1_CT5 = r.typical_lens_eye1_CT5,
	u.typical_lens_eye2_CT5 = r.typical_lens_eye2_CT5,
	u.typical_solution_CT5 = r.typical_solution_CT5,
	u.typical_eye_drop_CT5 = r.typical_eye_drop_CT5,
	u.typical_lens_pack_size = r.typical_lens_pack_size,
	u.typical_solution_pack_size = r.typical_solution_pack_size,
	u.typical_eye_drop_pack_size = r.typical_eye_drop_pack_size
;




/* TYPICAL LENS, SOUTION, EYE DROPS CALCULATION: END */



/*hiányzó related_webshop kitöltése: BEGIN*/
UPDATE
BASE_03_TABLE
SET related_webshop = 'offline'
WHERE (source_of_trx = 'offline' AND related_webshop = '')
;

UPDATE
BASE_03_TABLE
SET related_webshop = 'Other'
WHERE (source_of_trx = 'online' AND related_webshop = '')
;

UPDATE
BASE_03_TABLE
SET related_webshop = 'eOptika.hu'
WHERE related_webshop = 'eoptika.hu'
;
/*hiányzó related_webshop kitöltése: END*/



/* vásárlási emlékeztető hozzáadása */

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
