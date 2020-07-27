DROP TABLE IF EXISTS SM_USER;
CREATE TABLE IF NOT EXISTS SM_USER
SELECT 		buyer_email,
			r.real_name AS buyer_name,
			r.real_address AS real_street_address,
			u.shipping_phone,
			r.billing_zip_code,
			r.real_city,
			u.province,
			u.billing_country_standardized,
			NULL AS Status,
			NULL AS Fax,
			NULL AS Company,
			NULL AS Birthday,
			NULL AS External_id,
			u.num_of_orders AS order_number,
			u.revenues_wdisc_in_base_currency AS order_summary,
			u.salutation,
			u.last_purchase,
			p.pickup_zip_code AS shipping_zip_code,
			u.city_size,
			u.`gross_margin_wdisc_%`,
			u.`net_margin_wdisc_%`,
			l.typical_lens,
			s.typical_solution,
			e.typical_eye_drop AS typical_eyedrop,
			u.first_year_contact_lens_projected_boxes,
			u.first_year_contact_lens_overuse_ratio,
			p.pickup_city AS shipping_city,
			u.cohort_month_since,
			NULL AS nameday,
			u.gross_margin_wdisc_in_base_currency,
			u.net_margin_wdisc_in_base_currency,
			u.last_modified_date
FROM
(
SELECT 	
		buyer_email,
		shipping_phone,
		NULL AS phone_number_type,
		salutation,
		NULL AS language_formality,
		COUNT(item_id) AS num_of_items,		
		COUNT(DISTINCT erp_invoice_id) AS num_of_orders,
		user_id,
		MAX(created) AS last_purchase,
		related_division,
		billing_country_standardized,
		related_webshop,
		NULL AS redundant_user,
		province,
		city_size,

		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,		
		cohort_month_since,
		SUM(net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,	
			  SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_boxes,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS first_year_contact_lens_projected_boxes,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS first_year_contact_lens_overuse_ratio,
		SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days*item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_days_covered,
		720 AS one_year_contact_lens_max_days_covered,
		last_modified_date
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
WHERE origin = 'invoices'
AND LENGTH(buyer_email) > 3
AND buyer_email <> 'undefined'
GROUP BY user_id
) u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id

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
FROM BASE_08_TABLE	
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
FROM BASE_08_TABLE	
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
FROM BASE_08_TABLE	
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
FROM BASE_08_TABLE	
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
FROM BASE_08_TABLE	
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
FROM BASE_08_TABLE	
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


ALTER TABLE `SM_USER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_USER` ADD UNIQUE `buyer_email` (`buyer_email`);
ALTER TABLE `SM_USER` ADD `is_deleted` BOOLEAN DEFAULT 0;
