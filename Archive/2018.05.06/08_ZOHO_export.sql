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




UPDATE /* wear_days kiszámítása egyik szemre */
BASE_03_TABLE AS u
LEFT JOIN typical_wear_days_eye1 r
ON r.user_id = u.user_id
SET u.typical_wear_days_eye1 = r.typical_wear_days_eye1
;

UPDATE /* wear_days kiszámítása másik szemre */
BASE_03_TABLE AS u
LEFT JOIN typical_wear_days_eye2 r
ON r.user_id = u.user_id
SET u.typical_wear_days_eye2 = r.typical_wear_days_eye2
;

UPDATE /* wear_duration kiszámítása egyik szemre */
BASE_03_TABLE AS u
LEFT JOIN typical_wear_duration_eye1 r
ON r.user_id = u.user_id
SET u.typical_wear_duration_eye1 = r.typical_wear_duration_eye1
;

UPDATE /* wear_duration kiszámítása másik szemre */
BASE_03_TABLE AS u
LEFT JOIN typical_wear_duration_eye2 r
ON r.user_id = u.user_id
SET u.typical_wear_duration_eye2 = r.typical_wear_duration_eye2
;

UPDATE /* typical bc 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN bc_eye1 r
ON r.user_id = u.user_id
SET u.bc_eye1 = r.bc_eye1
;

UPDATE /* typical bc 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN bc_eye2 r
ON r.user_id = u.user_id
SET u.bc_eye2 = r.bc_eye2
;

UPDATE /* typical cyl 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN cyl_eye1 r
ON r.user_id = u.user_id
SET u.cyl_eye1 = r.cyl_eye1
;

UPDATE /* typical cyl 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN cyl_eye2 r
ON r.user_id = u.user_id
SET u.cyl_eye2 = r.cyl_eye2
;

UPDATE /* typical ax 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN ax_eye1 r
ON r.user_id = u.user_id
SET u.ax_eye1 = r.ax_eye1
;

UPDATE /* typical ax 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN ax_eye2 r
ON r.user_id = u.user_id
SET u.ax_eye2 = r.ax_eye2
;

UPDATE /* typical dia 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN dia_eye1 r
ON r.user_id = u.user_id
SET u.dia_eye1 = r.dia_eye1
;

UPDATE /* typical dia 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN dia_eye2 r
ON r.user_id = u.user_id
SET u.dia_eye2 = r.dia_eye2
;

UPDATE /* typical add 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN add_eye1 r
ON r.user_id = u.user_id
SET u.add_eye1 = r.add_eye1
;

UPDATE /* typical add 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN add_eye2 r
ON r.user_id = u.user_id
SET u.add_eye2 = r.add_eye2
;

UPDATE /* typical clr 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN clr_eye1 r
ON r.user_id = u.user_id
SET u.clr_eye1 = r.clr_eye1
;

UPDATE /* typical clr 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN clr_eye2 r
ON r.user_id = u.user_id
SET u.clr_eye2 = r.clr_eye2
;

UPDATE /* typical type 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_type_eye1 r
ON r.user_id = u.user_id
SET u.typical_lens_type_eye1 = r.typical_lens_type_eye1
;

UPDATE /* typical type 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_type_eye2 r
ON r.user_id = u.user_id
SET u.typical_lens_type_eye2 = r.typical_lens_type_eye2
;

UPDATE /* typical lens 1 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye1_CT1 r
ON r.user_id = u.user_id
SET u.typical_lens_eye1_CT1 = r.typical_lens_eye1_CT1
;

UPDATE /* typical lens 2 kiszámítása*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye2_CT1 r
ON r.user_id = u.user_id
SET u.typical_lens_eye2_CT1 = r.typical_lens_eye2_CT1
;

UPDATE /*typical lens 1 kiszámítása CT2 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye1_CT2 r
ON r.user_id = u.user_id
SET u.typical_lens_eye1_CT2 = r.typical_lens_eye1_CT2
;

UPDATE /*typical lens 2 kiszámítása CT2 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye2_CT2 r
ON r.user_id = u.user_id
SET u.typical_lens_eye2_CT2 = r.typical_lens_eye2_CT2
;

UPDATE /*typical solution kiszámítása CT2 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_solution_CT2 r
ON r.user_id = u.user_id
SET u.typical_solution_CT2 = r.typical_solution_CT2
;

UPDATE /*typical eye drop kiszámítása CT2 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_eye_drop_CT2 r
ON r.user_id = u.user_id
SET u.typical_eye_drop_CT2 = r.typical_eye_drop_CT2
;

UPDATE /*typical lens 1 kiszámítása CT3 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye1_CT3 r
ON r.user_id = u.user_id
SET u.typical_lens_eye1_CT3 = r.typical_lens_eye1_CT3
;

UPDATE /*typical lens 2 kiszámítása CT3 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye2_CT3 r
ON r.user_id = u.user_id
SET u.typical_lens_eye2_CT3 = r.typical_lens_eye2_CT3
;

UPDATE /*typical solution kiszámítása CT3 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_solution_CT3 r
ON r.user_id = u.user_id
SET u.typical_solution_CT3 = r.typical_solution_CT3
;

UPDATE /*typical eye drop kiszámítása CT3 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_eye_drop_CT3 r
ON r.user_id = u.user_id
SET u.typical_eye_drop_CT3 = r.typical_eye_drop_CT3
;

UPDATE /*typical lens 1 kiszámítása CT4 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye1_CT4 r
ON r.user_id = u.user_id
SET u.typical_lens_eye1_CT4 = r.typical_lens_eye1_CT4
;

UPDATE /*typical lens 2 kiszámítása CT4 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye2_CT4 r
ON r.user_id = u.user_id
SET u.typical_lens_eye2_CT4 = r.typical_lens_eye2_CT4
;

UPDATE /*typical solution kiszámítása CT4 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_solution_CT4 r
ON r.user_id = u.user_id
SET u.typical_solution_CT4 = r.typical_solution_CT4
;

UPDATE /*typical eye drop kiszámítása CT4 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_eye_drop_CT4 r
ON r.user_id = u.user_id
SET u.typical_eye_drop_CT4 = r.typical_eye_drop_CT4
;

UPDATE /*typical lens 1 kiszámítása CT5 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye1_CT5 r
ON r.user_id = u.user_id
SET u.typical_lens_eye1_CT5 = r.typical_lens_eye1_CT5
;

UPDATE /*typical lens 2 kiszámítása CT5 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_eye2_CT5 r
ON r.user_id = u.user_id
SET u.typical_lens_eye2_CT5 = r.typical_lens_eye2_CT5
;

UPDATE /*typical solution kiszámítása CT5 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_solution_CT5 r
ON r.user_id = u.user_id
SET u.typical_solution_CT5 = r.typical_solution_CT5
;

UPDATE /*typical eye drop kiszámítása CT5 szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_eye_drop_CT5 r
ON r.user_id = u.user_id
SET u.typical_eye_drop_CT5 = r.typical_eye_drop_CT5
;

UPDATE /*typical lens kiszámítása pack size szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_lens_pack_size r
ON r.user_id = u.user_id
SET u.typical_lens_pack_size = r.typical_lens_pack_size
;

UPDATE /*typical solution kiszámítása pack size szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_solution_pack_size r
ON r.user_id = u.user_id
SET u.typical_solution_pack_size = r.typical_solution_pack_size
;

UPDATE /*typical eye drop kiszámítása pack size szinten*/
BASE_03_TABLE AS u
LEFT JOIN typical_eye_drop_pack_size r
ON r.user_id = u.user_id
SET u.typical_eye_drop_pack_size = r.typical_eye_drop_pack_size
;




DROP TABLE IF EXISTS	trx_numbering,
						typical_wear_duration_eye1,
						typical_wear_duration_eye2,
						typical_wear_days_eye1,
						typical_wear_days_eye2,						
						bc_eye1,
						bc_eye2,
						cyl_eye1,
						cyl_eye2,
						ax_eye1,
						ax_eye2,
						dia_eye1,
						dia_eye2,
						add_eye1,
						add_eye2,
						clr_eye1,
						clr_eye2,
						typical_lens_type_eye1,
						typical_lens_type_eye2,
						typical_lens_eye1_CT1,
						typical_lens_eye2_CT1,
						typical_lens_eye1_CT2,
						typical_lens_eye2_CT2,
						typical_solution_CT2,
						typical_eye_drop_CT2,
						typical_lens_eye1_CT3,
						typical_lens_eye2_CT3,
						typical_solution_CT3,
						typical_eye_drop_CT3,
						typical_lens_eye1_CT4,
						typical_lens_eye2_CT4,
						typical_solution_CT4,
						typical_eye_drop_CT4,						
						typical_lens_eye1_CT5,
						typical_lens_eye2_CT5,
						typical_solution_CT5,
						typical_eye_drop_CT5,
						typical_lens_pack_size,
						typical_solution_pack_size,
						typical_eye_drop_pack_size
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
ALTER TABLE BASE_03_TABLE ADD INDEX `wear_days` (`wear_days`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `CT2_pack` (`CT2_pack`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `item_quantity` (`item_quantity`) USING BTREE;



DROP TABLE IF EXISTS BASE_08a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08a_TABLE
SELECT 	erp_invoice_id,
		CT2_pack,
		CONCAT(order_year, '-', order_month, '-', order_day_in_month) AS order_date,
		wear_days,
		MAX(IFNULL(time_order_to_dispatch,0))/24 AS time_order_to_dispatch,
		MAX(IFNULL(time_dispatch_to_delivery,0))/24 AS time_dispatch_to_delivery,
		SUM(ABS(item_quantity)) AS sum_item_quantity
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND product_group = 'Contact Lenses'
GROUP BY erp_invoice_id, CT2_pack, buyer_email, wear_days, order_date
;


ALTER TABLE BASE_08a_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `CT2_pack` (`CT2_pack`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `order_date` (`order_date`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `sum_item_quantity` (`sum_item_quantity`) USING BTREE;



UPDATE
BASE_03_TABLE AS b
LEFT JOIN BASE_08a_TABLE AS t 
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
SET
b.date_lenses_run_out = 		
	CASE 	WHEN b.origin = 'invoices'
			THEN DATE_ADD(t.order_date, INTERVAL t.wear_days*t.sum_item_quantity/2 + COALESCE(t.time_order_to_dispatch,0) + COALESCE(t.time_dispatch_to_delivery,0) DAY)
			ELSE ''
	END
WHERE b.origin = 'invoices'
AND b.product_group = 'Contact Lenses'
;


DROP TABLE IF EXISTS BASE_08a_TABLE;




UPDATE
BASE_03_TABLE AS b
LEFT JOIN IN_LVCR_item AS i 
ON b.CT2_pack = i.Description
SET
b.LVCR_item_flg = CASE WHEN i.Description IS NOT NULL THEN 1 ELSE 0 END
;


ALTER TABLE BASE_03_TABLE
  DROP COLUMN real_name_clean
;


DROP TABLE IF EXISTS BASE_10_TABLE;
CREATE TABLE IF NOT EXISTS BASE_10_TABLE
SELECT *
FROM BASE_03_TABLE
;


UPDATE BASE_03_TABLE SET personal_name = CAP_FIRST(personal_name);
UPDATE BASE_03_TABLE SET pickup_name = CAP_FIRST(pickup_name);
UPDATE BASE_03_TABLE SET business_name = CAP_FIRST(business_name);



UPDATE BASE_10_TABLE SET buyer_email = NULL WHERE buyer_email IS NOT NULL;
UPDATE BASE_10_TABLE SET primary_email = NULL WHERE primary_email IS NOT NULL;
UPDATE BASE_10_TABLE SET secondary_email = NULL WHERE secondary_email IS NOT NULL;
UPDATE BASE_10_TABLE SET personal_name = NULL WHERE personal_name IS NOT NULL;
UPDATE BASE_10_TABLE SET personal_address = NULL WHERE personal_address IS NOT NULL;
UPDATE BASE_10_TABLE SET pickup_name = NULL WHERE pickup_name IS NOT NULL;
UPDATE BASE_10_TABLE SET pickup_address = NULL WHERE pickup_address IS NOT NULL;
UPDATE BASE_10_TABLE SET business_name = NULL WHERE business_name IS NOT NULL;
UPDATE BASE_10_TABLE SET business_address = NULL WHERE business_address IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_name = NULL WHERE shipping_name IS NOT NULL;
UPDATE BASE_10_TABLE SET billing_name = NULL WHERE billing_name IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE BASE_10_TABLE SET full_name = NULL WHERE full_name IS NOT NULL;
UPDATE BASE_10_TABLE SET first_name = NULL WHERE first_name IS NOT NULL;
UPDATE BASE_10_TABLE SET last_name = NULL WHERE last_name IS NOT NULL;

