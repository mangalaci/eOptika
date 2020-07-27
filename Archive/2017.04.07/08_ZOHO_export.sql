DROP TABLE IF EXISTS trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE IF NOT EXISTS trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_07_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
LIMIT 0;

ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;

INSERT INTO trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_07_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id;

DROP TABLE IF EXISTS BASE_08_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08_TABLE LIKE BASE_07_TABLE;
ALTER TABLE BASE_08_TABLE ADD `trx_rank` INT(10) NOT NULL DEFAULT 0;
ALTER TABLE BASE_08_TABLE ADD typical_lens VARCHAR(64);
ALTER TABLE BASE_08_TABLE ADD typical_solution VARCHAR(64);
ALTER TABLE BASE_08_TABLE ADD typical_eye_drop VARCHAR(64);


INSERT INTO BASE_08_TABLE
SELECT DISTINCT u.*,
				r.trx_rank,
				l.typical_lens,
				s.typical_solution,
				e.typical_eye_drop
FROM BASE_07_TABLE AS u LEFT JOIN 
trx_numbering AS r
ON (r.erp_invoice_id = u.erp_invoice_id AND r.user_id = u.user_id)

/*typical lens kiszámítása*/
LEFT JOIN
(
SELECT 	a.user_id,
		CASE 	WHEN b.typical_lens_last_240_days IS NULL THEN COALESCE(a.typical_lens_all_time,b.typical_lens_last_240_days)
				ELSE b.typical_lens_last_240_days
				END AS typical_lens
FROM
(
SELECT 	user_id, ct2_pack AS typical_lens_all_time
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_07_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, ct2_pack AS typical_lens_last_240_days
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_07_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(NOW(), INTERVAL 240 DAY) AND NOW()
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) l
ON u.user_id = l.user_id

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
FROM BASE_07_TABLE	
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
FROM BASE_07_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Contact lens cleaners'
AND created BETWEEN DATE_SUB(NOW(), INTERVAL 240 DAY) AND NOW()
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
FROM BASE_07_TABLE	
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
FROM BASE_07_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Eye drops'
AND created BETWEEN DATE_SUB(NOW(), INTERVAL 240 DAY) AND NOW()
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id
) e
ON u.user_id = e.user_id
;


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

UPDATE
BASE_08_TABLE AS cs
LEFT JOIN COHORT_1_before_last_purchase AS u ON cs.user_id = u.user_id
SET
cs.one_before_last_purchase = u.one_before_last_purchase
;



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
				END AS covered_days_over_dt
FROM BASE_08_TABLE b
LEFT JOIN
BASE_08a_TABLE t
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
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
				END AS covered_days_over_dt
FROM BASE_08_TABLE b
LEFT JOIN
BASE_08a_TABLE t
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
GROUP BY b.id
;



ALTER TABLE BASE_08_TABLE ADD covered_days_over_dt DATETIME COMMENT 'The date when placing a new order for a contact lens user is due.';

UPDATE
BASE_08_TABLE AS b
LEFT JOIN BASE_08b_TABLE AS t
ON (b.item_id = t.item_id)
SET
b.covered_days_over_dt = t.covered_days_over_dt
;



DROP TABLE IF EXISTS BASE_08a_TABLE;
DROP TABLE IF EXISTS BASE_08b_TABLE;


DROP TABLE IF EXISTS BASE_09_TABLE;
CREATE TABLE IF NOT EXISTS BASE_09_TABLE LIKE BASE_08_TABLE;
ALTER TABLE BASE_09_TABLE ADD pickup_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_09_TABLE ADD personal_geogr_region VARCHAR(32) NOT NULL;


INSERT INTO BASE_09_TABLE
SELECT 	u.*
		,NULL AS pickup_geogr_region 
		,NULL AS personal_geogr_region
FROM BASE_08_TABLE u
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
UPDATE BASE_10_TABLE SET business_address = NULL WHERE real_address IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_name = NULL WHERE shipping_name IS NOT NULL;
UPDATE BASE_10_TABLE SET billing_name = NULL WHERE billing_name IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE BASE_10_TABLE SET full_name = NULL WHERE full_name IS NOT NULL;
UPDATE BASE_10_TABLE SET first_name = NULL WHERE first_name IS NOT NULL;
UPDATE BASE_10_TABLE SET last_name = NULL WHERE last_name IS NOT NULL;

