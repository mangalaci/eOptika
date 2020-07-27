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
ALTER TABLE BASE_08_TABLE ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `wear_days` (`wear_days`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `CT2_pack` (`CT2_pack`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `item_quantity` (`item_quantity`) USING BTREE;



DROP TABLE IF EXISTS BASE_08a_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08a_TABLE
SELECT erp_invoice_id, CT2_pack, CONCAT(order_year, '-', order_month, '-', order_day_in_month) AS order_date, wear_days, MAX(time_order_to_dispatch)/24 AS time_order_to_dispatch, MAX(IFNULL(time_dispatch_to_delivery,0))/24 AS time_dispatch_to_delivery, SUM(item_quantity) AS sum_item_quantity
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
CREATE TABLE IF NOT EXISTS BASE_08b_TABLE LIKE BASE_08_TABLE;
ALTER TABLE BASE_08b_TABLE ADD covered_days_over_dt DATETIME COMMENT 'The date when placing a new order for a contact lens user is due.';



INSERT INTO BASE_08b_TABLE
SELECT	b.*,
/*b.item_id, b.erp_invoice_id, b.CT2_pack, t.sum_item_quantity, b.shipping_method, b.wear_days,t.order_date, t.time_order_to_dispatch, t.time_dispatch_to_delivery,*/
		MAX(DATE_ADD(t.order_date, INTERVAL t.wear_days*t.sum_item_quantity/2 + t.time_order_to_dispatch + t.time_dispatch_to_delivery DAY)) AS covered_days_over_dt
FROM BASE_08_TABLE b
LEFT JOIN
BASE_08a_TABLE t
ON (b.erp_invoice_id = t.erp_invoice_id AND b.CT2_pack = t.CT2_pack)
WHERE origin = 'invoices'
GROUP BY b.id
;



DROP TABLE IF EXISTS BASE_08_TABLE;
ALTER TABLE BASE_08b_TABLE RENAME BASE_08_TABLE;


DROP TABLE IF EXISTS BASE_08a_TABLE;
DROP TABLE IF EXISTS BASE_08b_TABLE;


DROP TABLE IF EXISTS AGGR_USER_REAL_ADDRESS;
CREATE TABLE IF NOT EXISTS AGGR_USER_REAL_ADDRESS
SELECT DISTINCT t.*,
				MIN(CASE WHEN t.shipping_country_standardized <> 'Hungary' THEN 'Overseas'
					 WHEN LENGTH(TRIM(real_zip_code)) > 4 THEN 'Overseas'
					 ELSE
						CASE WHEN i.Megye IS NULL AND j.Megye IS NOT NULL THEN j.Megye
							 WHEN t.real_city IS NULL THEN NULL
 							 WHEN t.real_city = '' THEN NULL
							 WHEN i.Megye IS NULL AND j.Megye IS NULL THEN 'Overseas'
							 ELSE i.Megye
						END					
				END) AS real_province
FROM
(
SELECT user_id, shipping_method, shipping_country_standardized, real_name, real_address, real_zip_code, real_city,
billing_name,
billing_zip_code, 
billing_city, 
billing_address
FROM
(
SELECT DISTINCT user_id, 
created,
billing_name,

billing_zip_code, 
billing_city, 
billing_address, 
shipping_name,
shipping_name_clean,
shipping_country_standardized,
shipping_zip_code,
shipping_city,
shipping_address,
shipping_method,
CASE WHEN billing_name LIKE '%Egészségpénztár%'
		OR billing_name LIKE '%Egészség-%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR LOWER(billing_name) LIKE '%irodai átvétel%'
		OR LOWER(billing_name) LIKE '%alulj%'		
		THEN
			CASE WHEN shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR LOWER(shipping_name) LIKE '%irodai átvétel%'
					OR LOWER(shipping_name) LIKE '%alulj%'		
					THEN NULL
				ELSE shipping_name_clean
			END
		ELSE billing_name
END AS real_name,

CASE WHEN billing_name LIKE '%Egészségpénztár%'
		OR billing_name LIKE '%Egészség-%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR billing_name LIKE '%MÁV%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR billing_address LIKE '%Egészségpénztár%'
		OR billing_address LIKE '%/TOF%'
		OR billing_address LIKE '%PPP%'
		OR billing_address LIKE '%/ PM%'
		OR billing_address LIKE '%/EP%'
		OR LOWER(billing_address) LIKE '%sprinter%'
		OR LOWER(billing_address) LIKE '%exon 2000%'
		OR LOWER(billing_address) LIKE '%omv%'
		OR LOWER(billing_address) LIKE '%mol %'
		OR LOWER(billing_address) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_address) LIKE '%relay%'
		OR LOWER(billing_address) LIKE '%inmedió%'
		OR LOWER(billing_address) LIKE '%irodai átvétel%'
		OR LOWER(billing_address) LIKE '%alulj%'
		THEN
			CASE WHEN shipping_name LIKE '%Egészségpénztár%'
					OR shipping_name LIKE '%Egészség-%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'					
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_address LIKE '%/TOF%'
					OR shipping_address LIKE '%PPP%'
					OR shipping_address LIKE '%/ PM%'
					OR shipping_address LIKE '%/EP%'
					OR shipping_address LIKE '%MÁV%'					
					OR LOWER(shipping_address) LIKE '%sprinter%'
					OR LOWER(shipping_address) LIKE '%exon 2000%'
					OR LOWER(shipping_address) LIKE '%omv%'
					OR LOWER(shipping_address) LIKE '%mol %'
					OR LOWER(shipping_address) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_address) LIKE '%relay%'
					OR LOWER(shipping_address) LIKE '%inmedió%'
					OR LOWER(shipping_address) LIKE '%irodai átvétel%'
					OR LOWER(shipping_address) LIKE '%alulj%'
					OR LOWER(shipping_address) LIKE '%váci utca 38%'					
					THEN NULL
				ELSE shipping_address
			END 
		ELSE billing_address
END AS real_address,

CASE WHEN billing_name LIKE '%Egészségpénztár%'
		OR billing_name LIKE '%Egészség-%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR billing_address LIKE '%Egészségpénztár%'
		OR billing_address LIKE '%/TOF%'
		OR billing_address LIKE '%PPP%'
		OR billing_address LIKE '%/ PM%'
		OR billing_address LIKE '%/EP%'
		OR LOWER(billing_address) LIKE '%sprinter%'
		OR LOWER(billing_address) LIKE '%exon 2000%'
		OR LOWER(billing_address) LIKE '%omv%'
		OR LOWER(billing_address) LIKE '%mol %'
		OR LOWER(billing_address) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_address) LIKE '%relay%'
		OR LOWER(billing_address) LIKE '%inmedió%'
		OR LOWER(billing_address) LIKE '%alulj%'		
		THEN 			
			CASE WHEN shipping_name LIKE '%Egészségpénztár%'
					OR shipping_name LIKE '%Egészség-%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_address LIKE '%/TOF%'
					OR shipping_address LIKE '%PPP%'
					OR shipping_address LIKE '%/ PM%'
					OR shipping_address LIKE '%/EP%'
					OR shipping_address LIKE '%MÁV%'
					OR LOWER(shipping_address) LIKE '%sprinter%'
					OR LOWER(shipping_address) LIKE '%exon 2000%'
					OR LOWER(shipping_address) LIKE '%omv%'
					OR LOWER(shipping_address) LIKE '%mol %'
					OR LOWER(shipping_address) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_address) LIKE '%relay%'
					OR LOWER(shipping_address) LIKE '%inmedió%'
					OR LOWER(shipping_address) LIKE '%alulj%'
					OR LOWER(shipping_address) LIKE '%irodai átvétel%'
					OR LOWER(shipping_address) LIKE '%váci utca 38%'
					THEN NULL
				ELSE shipping_zip_code
			END
		ELSE billing_zip_code
END AS real_zip_code,

CASE WHEN billing_name LIKE '%Egészségpénztár%'
		OR billing_name LIKE '%Egészség-%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR billing_address LIKE '%Egészségpénztár%'
		OR billing_address LIKE '%/TOF%'
		OR billing_address LIKE '%PPP%'
		OR billing_address LIKE '%/ PM%'
		OR billing_address LIKE '%/EP%'
		OR LOWER(billing_address) LIKE '%sprinter%'
		OR LOWER(billing_address) LIKE '%exon 2000%'
		OR LOWER(billing_address) LIKE '%omv%'
		OR LOWER(billing_address) LIKE '%mol %'
		OR LOWER(billing_address) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_address) LIKE '%relay%'
		OR LOWER(billing_address) LIKE '%inmedió%'
		OR LOWER(billing_address) LIKE '%alulj%'
		THEN
			CASE WHEN shipping_name LIKE '%Egészségpénztár%'
					OR shipping_name LIKE '%Egészség-%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR LOWER(shipping_name) LIKE '%irodai átvétel%'
					OR shipping_address LIKE '%/TOF%'
					OR shipping_address LIKE '%PPP%'
					OR shipping_address LIKE '%/ PM%'
					OR shipping_address LIKE '%/EP%'
					OR shipping_address LIKE '%MÁV%'
					OR LOWER(shipping_address) LIKE '%sprinter%'
					OR LOWER(shipping_address) LIKE '%exon 2000%'
					OR LOWER(shipping_address) LIKE '%omv%'
					OR LOWER(shipping_address) LIKE '%mol %'
					OR LOWER(shipping_address) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_address) LIKE '%relay%'
					OR LOWER(shipping_address) LIKE '%inmedió%'
					OR LOWER(shipping_address) LIKE '%alulj%'
					OR LOWER(shipping_address) LIKE '%irodai átvétel%'
					OR LOWER(shipping_address) LIKE '%váci utca 38%'
					THEN NULL
				ELSE shipping_city
			END 
		ELSE billing_city
END AS real_city

FROM BASE_08_TABLE
ORDER BY user_id, created DESC
) z
GROUP BY user_id
) t
LEFT JOIN IN_iranyitoszamok i
ON CASE WHEN t.shipping_country_standardized = 'Hungary' THEN SUBSTR(t.real_zip_code, 1, 4) = i.irsz END
LEFT JOIN IN_iranyitoszamok j
ON CASE WHEN t.shipping_country_standardized = 'Hungary' THEN t.real_city = j.Telepules
END
GROUP BY user_id
;


ALTER TABLE AGGR_USER_REAL_ADDRESS ADD INDEX `user_id` (`user_id`) USING BTREE;



DROP TABLE IF EXISTS AGGR_USER_PICKUP_ADDRESS;
CREATE TABLE IF NOT EXISTS AGGR_USER_PICKUP_ADDRESS
SELECT DISTINCT t.*,
				MIN(CASE WHEN t.shipping_country_standardized <> 'Hungary' THEN 'Overseas'
					 WHEN LENGTH(TRIM(pickup_zip_code)) > 4 THEN 'Overseas'
					 ELSE
						CASE WHEN i.Megye IS NULL AND j.Megye IS NOT NULL THEN j.Megye
							 WHEN t.pickup_city IS NULL THEN NULL
 							 WHEN t.pickup_city = '' THEN NULL
							 WHEN i.Megye IS NULL AND j.Megye IS NULL THEN 'Overseas'
							 ELSE i.Megye
						END					
				END) AS pickup_province
FROM
(
SELECT user_id, shipping_method, shipping_country_standardized, pickup_name, pickup_address, pickup_zip_code, pickup_city
FROM
(
SELECT DISTINCT user_id, 
created,
billing_name,
billing_zip_code, 
billing_city, 
billing_address, 
shipping_name,
shipping_name_clean,
shipping_country_standardized,
shipping_zip_code,
shipping_city,
shipping_address,
shipping_method,
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'					
		OR billing_name LIKE '%/EP%'					
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR LOWER(billing_name) LIKE '%inmedio%'
		THEN billing_name
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'					
					OR shipping_name LIKE '%/EP%'					
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR LOWER(shipping_name) LIKE '%inmedio%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')
					THEN shipping_name_clean
				ELSE billing_name
			END
END AS pickup_name,

CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN 'Teréz krt. 41.' ELSE
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'					
		OR billing_name LIKE '%/EP%'					
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_address
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'					
					OR shipping_name LIKE '%/EP%'					
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')			
				THEN shipping_address
				ELSE billing_address
			END
END
END AS pickup_address,
CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN '1067' 
	ELSE
	CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_zip_code
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')	
				THEN shipping_zip_code
				ELSE billing_zip_code
			END
	END
END AS pickup_zip_code,
CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN 'Budapest' ELSE
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_city
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')
			THEN shipping_city
			ELSE billing_city
			END
END
END AS pickup_city
FROM BASE_08_TABLE
ORDER BY user_id, created DESC
) z
GROUP BY user_id
) t
LEFT JOIN IN_iranyitoszamok i
ON CASE WHEN t.shipping_country_standardized = 'Hungary' THEN SUBSTR(t.pickup_zip_code, 1, 4) = i.irsz
END
LEFT JOIN IN_iranyitoszamok j
ON CASE WHEN t.shipping_country_standardized = 'Hungary' THEN t.pickup_city = j.Telepules
END
GROUP BY user_id
;

ALTER TABLE AGGR_USER_PICKUP_ADDRESS ADD INDEX `user_id` (`user_id`) USING BTREE;



DROP TABLE IF EXISTS BASE_09_TABLE;
CREATE TABLE IF NOT EXISTS BASE_09_TABLE LIKE BASE_08_TABLE;
ALTER TABLE BASE_09_TABLE ADD pickup_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_09_TABLE ADD real_geogr_region VARCHAR(32) NOT NULL;


INSERT INTO BASE_09_TABLE
SELECT 	u.*,
		CASE
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN real_province IN ('Budapest') AND SUBSTR(real_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE real_province
END AS real_geogr_region,
		CASE 
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN pickup_province IN ('Budapest') AND SUBSTR(pickup_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE pickup_province
	END	AS pickup_geogr_region
FROM BASE_08_TABLE u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id
;

ALTER TABLE BASE_09_TABLE
  DROP COLUMN first_name,
  DROP COLUMN last_name
;

DELETE FROM BASE_09_TABLE
WHERE user_id IS NULL
;


DROP TABLE IF EXISTS BASE_10_TABLE;
CREATE TABLE IF NOT EXISTS BASE_10_TABLE
SELECT *
FROM BASE_09_TABLE
;


UPDATE BASE_10_TABLE SET buyer_email = NULL WHERE buyer_email IS NOT NULL;
UPDATE BASE_10_TABLE SET billing_name = NULL WHERE billing_name IS NOT NULL;
UPDATE BASE_10_TABLE SET billing_address = NULL WHERE billing_address IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_name = NULL WHERE shipping_name IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_address = NULL WHERE shipping_address IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE BASE_10_TABLE SET shipping_name_clean = NULL WHERE shipping_name_clean IS NOT NULL;
UPDATE BASE_10_TABLE SET related_email_clean = NULL WHERE related_email_clean IS NOT NULL;
UPDATE BASE_10_TABLE SET full_name = NULL WHERE full_name IS NOT NULL;