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

DROP TABLE IF EXISTS trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE IF NOT EXISTS trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_03_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
LIMIT 0;

ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;

INSERT INTO trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_03_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id;

DROP TABLE IF EXISTS BASE_08_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08_TABLE LIKE BASE_03_TABLE;
ALTER TABLE BASE_08_TABLE ADD `trx_rank` INT(10) NOT NULL DEFAULT 0;
ALTER TABLE BASE_08_TABLE ADD typical_lens_1 VARCHAR(64);
ALTER TABLE BASE_08_TABLE ADD typical_lens_2 VARCHAR(64);
ALTER TABLE BASE_08_TABLE ADD typical_solution VARCHAR(64);
ALTER TABLE BASE_08_TABLE ADD typical_eye_drop VARCHAR(64);


INSERT INTO BASE_08_TABLE
SELECT DISTINCT u.*,
				r.trx_rank,
				len1.typical_lens_1,
				len2.typical_lens_2,
				s.typical_solution,
				e.typical_eye_drop
FROM BASE_03_TABLE AS u 
LEFT JOIN trx_numbering AS r
ON (r.erp_invoice_id = u.erp_invoice_id AND r.user_id = u.user_id)

/* typical lens 1 kiszámítása*/
LEFT JOIN
(
SELECT 	a.user_id,
		CASE 	WHEN b.typical_lens_last_360_days IS NULL THEN COALESCE(a.typical_lens_all_time,b.typical_lens_last_360_days)
				ELSE b.typical_lens_last_360_days
				END AS typical_lens_1
FROM
(
SELECT 	user_id, CT1_sku_name AS typical_lens_all_time
FROM
(
SELECT 	user_id, CT1_sku_name, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND lens_pwr = pwr_eye1
GROUP BY user_id, CT1_sku_name	
ORDER BY COUNT(*) DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, CT1_sku_name AS typical_lens_last_360_days
FROM
(
SELECT 	user_id, CT1_sku_name, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 360 DAY) AND contact_lens_last_purchase
AND lens_pwr = pwr_eye1
GROUP BY user_id, CT1_sku_name	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) len1
ON u.user_id = len1.user_id

/* typical lens 1 kiszámítása*/
LEFT JOIN
(
SELECT 	a.user_id,
		CASE 	WHEN b.typical_lens_last_360_days IS NULL THEN COALESCE(a.typical_lens_all_time,b.typical_lens_last_360_days)
				ELSE b.typical_lens_last_360_days
				END AS typical_lens_2
FROM
(
SELECT 	user_id, CT1_sku_name AS typical_lens_all_time
FROM
(
SELECT 	user_id, CT1_sku_name, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND lens_pwr = pwr_eye2
GROUP BY user_id, CT1_sku_name	
ORDER BY COUNT(*) DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, CT1_sku_name AS typical_lens_last_360_days
FROM
(
SELECT 	user_id, CT1_sku_name, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 360 DAY) AND contact_lens_last_purchase
AND lens_pwr = pwr_eye2
GROUP BY user_id, CT1_sku_name	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) len2
ON u.user_id = len2.user_id

/*typical solution kiszámítása*/
LEFT JOIN
(
SELECT 	a.user_id,
		CASE 	WHEN b.typical_solution_last_240_days IS NULL THEN COALESCE(a.typical_solution_all_time,b.typical_solution_last_240_days)
				ELSE b.typical_solution_last_240_days
				END AS typical_solution
FROM
(
SELECT 	user_id, ct2_pack AS typical_solution_all_time
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lens cleaners'
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, ct2_pack AS typical_solution_last_240_days
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lens cleaners'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 240 DAY) AND contact_lens_last_purchase
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) s
ON u.user_id = s.user_id

/*typical eye drop kiszámítása*/
LEFT JOIN
(
SELECT 	a.user_id,
		CASE 	WHEN b.typical_eye_drop_last_240_days IS NULL THEN COALESCE(a.typical_eye_drop_all_time,b.typical_eye_drop_last_240_days)
				ELSE b.typical_eye_drop_last_240_days
				END AS typical_eye_drop
FROM
(
SELECT 	user_id, ct2_pack AS typical_eye_drop_all_time
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Eye drops'
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, ct2_pack AS typical_eye_drop_last_240_days
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Eye drops'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 240 DAY) AND contact_lens_last_purchase
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) e
ON u.user_id = e.user_id
;

/* TYPICAL LENS, SOUTION, EYE DROPS CALCULATION: END */




ALTER TABLE BASE_08_TABLE ADD one_before_last_purchase DATETIME;


DROP TABLE IF EXISTS COHORT_1_before_trx_rank;
CREATE TABLE IF NOT EXISTS COHORT_1_before_trx_rank
SELECT user_id, MAX(trx_rank) - 1 AS max_trx_rank_minus_1
FROM `BASE_08_TABLE`
GROUP by user_id
;
ALTER TABLE COHORT_1_before_trx_rank ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE COHORT_1_before_trx_rank ADD INDEX `max_trx_rank_minus_1` (`max_trx_rank_minus_1`) USING BTREE;

ALTER TABLE BASE_08_TABLE ADD INDEX `trx_rank` (`trx_rank`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `one_before_last_purchase` (`one_before_last_purchase`) USING BTREE;


DROP TABLE IF EXISTS COHORT_1_before_last_purchase;
CREATE TABLE IF NOT EXISTS COHORT_1_before_last_purchase
(
SELECT DISTINCT a.user_id, a.last_modified_date AS one_before_last_purchase
FROM `BASE_08_TABLE` a,
COHORT_1_before_trx_rank b
WHERE a.user_id = b.user_id
AND a.trx_rank = b.max_trx_rank_minus_1
)
;

ALTER TABLE COHORT_1_before_last_purchase ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE COHORT_1_before_last_purchase ADD INDEX `one_before_last_purchase` (`one_before_last_purchase`) USING BTREE;


UPDATE BASE_08_TABLE as b
SET 
b.one_before_last_purchase = (SELECT m.one_before_last_purchase FROM COHORT_1_before_last_purchase as m WHERE b.user_id = m.user_id)
;

/*hiányzó related_webshop kitöltése: BEGIN*/
UPDATE
BASE_08_TABLE
SET related_webshop = 'offline'
WHERE (source_of_trx = 'offline' AND related_webshop = '')
;

UPDATE
BASE_08_TABLE
SET related_webshop = 'Other'
WHERE (source_of_trx = 'online' AND related_webshop = '')
;

UPDATE
BASE_08_TABLE
SET related_webshop = 'eOptika.hu'
WHERE related_webshop = 'eoptika.hu'
;
/*hiányzó related_webshop kitöltése: END*/


/* vásárlási emlékeztető hozzáadása */
ALTER TABLE BASE_08_TABLE ADD INDEX `wear_days` (`wear_days`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `CT2_pack` (`CT2_pack`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `item_quantity` (`item_quantity`) USING BTREE;



DROP TABLE IF EXISTS BASE_08a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08a_TABLE
SELECT 	erp_invoice_id,
		CT2_pack,
		CONCAT(order_year, '-', order_month, '-', order_day_in_month) AS order_date,
		wear_days,
		MAX(time_order_to_dispatch)/24 AS time_order_to_dispatch,
		MAX(IFNULL(time_dispatch_to_delivery,0))/24 AS time_dispatch_to_delivery,
		SUM(item_quantity) AS sum_item_quantity
FROM BASE_08_TABLE
WHERE origin = 'invoices'
AND product_group = 'Contact Lenses'
GROUP BY erp_invoice_id, CT2_pack, buyer_email, wear_days, order_date
;


ALTER TABLE BASE_08a_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `CT2_pack` (`CT2_pack`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `order_date` (`order_date`) USING BTREE;
ALTER TABLE BASE_08a_TABLE ADD INDEX `sum_item_quantity` (`sum_item_quantity`) USING BTREE;


DROP TABLE IF EXISTS BASE_08b_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08b_TABLE
SELECT	b.item_id, 
		b.erp_invoice_id, 
		b.CT2_pack, 
		t.sum_item_quantity, 
		b.shipping_method, 
		b.wear_days,
		t.order_date, 
		t.time_order_to_dispatch, 
		t.time_dispatch_to_delivery,
		CASE 	WHEN origin = 'invoices' 
				THEN MAX(DATE_ADD(t.order_date, INTERVAL t.wear_days*t.sum_item_quantity/2 + t.time_order_to_dispatch + t.time_dispatch_to_delivery DAY))
				ELSE ''
				END AS date_lenses_run_out
FROM BASE_08_TABLE b
LEFT JOIN
BASE_08a_TABLE t
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
WHERE b.origin = 'invoices'
GROUP BY b.id
LIMIT 0;


ALTER TABLE BASE_08b_TABLE ADD INDEX `item_id` (`item_id`) USING BTREE;


INSERT INTO BASE_08b_TABLE
SELECT	DISTINCT
		b.item_id, 
		b.erp_invoice_id, 
		b.CT2_pack, 
		t.sum_item_quantity, 
		b.shipping_method, 
		b.wear_days,
		t.order_date, 
		t.time_order_to_dispatch, 
		t.time_dispatch_to_delivery,
		CASE 	WHEN origin = 'invoices' 
				THEN MAX(DATE_ADD(t.order_date, INTERVAL t.wear_days*t.sum_item_quantity/2 + t.time_order_to_dispatch + t.time_dispatch_to_delivery DAY))
				ELSE ''
				END AS date_lenses_run_out
FROM BASE_08_TABLE b
LEFT JOIN
BASE_08a_TABLE t
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
WHERE b.origin = 'invoices'
GROUP BY b.id
;



ALTER TABLE BASE_08_TABLE ADD date_lenses_run_out DATETIME COMMENT 'The date when placing a new order for a contact lens user is due.';


UPDATE BASE_08_TABLE as b
SET 
b.date_lenses_run_out = (SELECT m.date_lenses_run_out FROM BASE_08b_TABLE as m WHERE b.item_id = m.item_id)
WHERE b.origin = 'invoices'
;


DROP TABLE IF EXISTS BASE_08a_TABLE;
DROP TABLE IF EXISTS BASE_08b_TABLE;


DROP TABLE IF EXISTS BASE_09_TABLE;
CREATE TABLE IF NOT EXISTS BASE_09_TABLE LIKE BASE_08_TABLE;
ALTER TABLE BASE_09_TABLE ADD pickup_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_09_TABLE ADD personal_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_09_TABLE ADD LVCR_item_flg INT(1) NOT NULL;


INSERT INTO BASE_09_TABLE
SELECT 	 u.*
		,NULL AS pickup_geogr_region 
		,NULL AS personal_geogr_region
        ,CASE WHEN i.Description IS NOT NULL THEN 1 ELSE 0 END AS LVCR_item_flg
FROM BASE_08_TABLE u
LEFT JOIN IN_LVCR_item i
ON u.CT2_pack = i.Description
;

ALTER TABLE BASE_09_TABLE
  DROP COLUMN real_name_clean
;


DROP TABLE IF EXISTS BASE_10_TABLE;
CREATE TABLE IF NOT EXISTS BASE_10_TABLE
SELECT *
FROM BASE_09_TABLE
;


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

