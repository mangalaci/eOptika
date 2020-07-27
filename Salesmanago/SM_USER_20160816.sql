DROP TABLE IF EXISTS SM_USER;
CREATE TABLE IF NOT EXISTS SM_USER
SELECT 		buyer_email,
			r.real_name AS buyer_name,
			u.shipping_phone,
			u.phone_number_type,
			u.addressing,
			u.language_formality,
			u.num_of_items,
			u.num_of_orders,
			u.user_id,
			u.last_purchase,
			u.related_division,
			u.billing_country_standardized,
			r.billing_zip_code,
			r.billing_city,
			p.shipping_country_standardized,
			p.pickup_zip_code AS shipping_zip_code,
			p.pickup_city AS shipping_city,
			u.related_webshop,
			u.redundant_user,
			u.item_net_purchase_price_in_base_currency,
			u.item_net_sale_price_in_currency,
			u.item_gross_sale_price_in_currency,
			u.item_net_sale_price_in_base_currency,
			u.item_gross_sale_price_in_base_currency,
			u.item_quantity,
			u.item_revenue_in_local_currency,
			u.item_vat_value_in_local_currency,
			u.item_revenue_in_base_currency,
			u.item_vat_in_base_currency,
			u.item_gross_revenue_in_base_currency,
			u.user_type,
			u.province,
			u.city_size,
			u.gender,
			u.reminder_day_dt,
			u.reminder_day_flg,
			u.revenues_wdisc_in_local_currency,	
			u.revenues_wdisc_in_base_currency,
			u.gross_margin_wodisc_in_base_currency,
			u.gross_margin_wdisc_in_base_currency,
			u.`gross_margin_wodisc_%`,
			u.`gross_margin_wdisc_%`,
			u.newsletter,
			u.cohort_id,
			u.cohort_month_since,
			u.user_cum_transactions,
			u.user_cum_gross_revenue_in_base_currency,
			u.net_margin_wodisc_in_base_currency,
			u.net_margin_wdisc_in_base_currency,
			u.`net_margin_wodisc_%`,
			u.`net_margin_wdisc_%`,		
			u.shipping_cost_in_base_currency,
			u.packaging_cost_in_base_currency,
			u.payment_cost_in_base_currency,
			u.num_of_purch,
			u.contact_lens_user,
			u.solution_user,
			u.eye_drops_user,
			u.sunglass_user,
			u.vitamin_user,
			u.first_year_contact_lens_revenues_wdisc_in_base_currency,
			u.first_year_contact_lens_gross_margin_wdisc_in_base_currency,
			u.first_year_contact_lens_net_margin_wodisc_in_base_currency,
			u.first_year_contact_lens_boxes,
			u.first_year_contact_lens_projected_boxes,
			u.first_year_contact_lens_overuse_ratio,
			u.first_year_contact_lens_days_covered,
			u.one_year_contact_lens_max_days_covered,
			l.typical_lens,
			s.typical_solution,
			e.typical_eye_drop,
			NULL AS nameday,
			NULL AS deactivate_status,
			NULL AS deactivate_date,
			NULL AS deactivate_reason,
			NULL AS newsletter_permission
FROM
(
SELECT 	
		buyer_email,
		shipping_phone,
		NULL AS phone_number_type,
		salutation AS addressing,
		NULL AS language_formality,
		COUNT(item_id) AS num_of_items,		
		COUNT(DISTINCT erp_invoice_id) AS num_of_orders,
		user_id,
		MAX(created) AS last_purchase,
		related_division,
		billing_country_standardized,
		related_webshop,
		NULL AS redundant_user,
		ROUND(SUM(item_net_purchase_price_in_base_currency*item_quantity),0) AS item_net_purchase_price_in_base_currency,
		ROUND(SUM(item_net_sale_price_in_currency*item_quantity),0) AS item_net_sale_price_in_currency,
		ROUND(SUM(item_gross_sale_price_in_currency*item_quantity),0) AS item_gross_sale_price_in_currency,
		ROUND(SUM(item_net_sale_price_in_base_currency*item_quantity),0) AS item_net_sale_price_in_base_currency,
		ROUND(SUM(item_gross_sale_price_in_base_currency*item_quantity),0) AS item_gross_sale_price_in_base_currency,
		ROUND(SUM(item_quantity),0) AS item_quantity,
		ROUND(SUM(item_revenue_in_local_currency),0) AS item_revenue_in_local_currency,
		ROUND(SUM(item_vat_value_in_local_currency),0) AS item_vat_value_in_local_currency,
		ROUND(SUM(item_revenue_in_base_currency),0) AS item_revenue_in_base_currency,
		ROUND(SUM(item_vat_in_base_currency),0) AS item_vat_in_base_currency,
		ROUND(SUM(item_gross_revenue_in_base_currency),0) AS item_gross_revenue_in_base_currency,
		user_type,
		province,
		city_size,
		gender,
		reminder_day_dt,
		reminder_day_flg,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,	
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `gross_margin_wodisc_%`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `gross_margin_wdisc_%`,		
		newsletter,
		cohort_id,
		cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		SUM(net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(SUM(net_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `net_margin_wodisc_%`,
		ROUND(SUM(net_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `net_margin_wdisc_%`,		
		SUM(shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		num_of_purch,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS contact_lens_user,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS solution_user,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS eye_drops_user,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_user,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS vitamin_user,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_user,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS frames_user,		
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS glass_lenses_user,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS other_product_user,
		
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN revenues_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_revenues_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN gross_margin_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_gross_margin_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN net_margin_wodisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_net_margin_wodisc_in_base_currency,
			  SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_boxes,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS first_year_contact_lens_projected_boxes,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS first_year_contact_lens_overuse_ratio,
		SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days*item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_days_covered,
		720 AS one_year_contact_lens_max_days_covered
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
WHERE origin = 'invoices'
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
ALTER TABLE SM_USER ADD INDEX `user_id` (`user_id`) USING BTREE;
