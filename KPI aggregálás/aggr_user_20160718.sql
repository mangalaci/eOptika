DROP TABLE IF EXISTS AGGR_USER;
CREATE TABLE IF NOT EXISTS AGGR_USER
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
	END	AS pickup_geogr_region,
			l.typical_lens,
			s.typical_solution,
			e.typical_eye_drop
FROM
(
SELECT 	user_id,
		COUNT(DISTINCT erp_invoice_id) AS num_of_orders,
		COUNT(item_id) AS num_of_items,
		MAX(created) AS last_purchase,
		billing_country_standardized,
		billing_zip_code,
		billing_city,
		shipping_country_standardized,
		shipping_zip_code,
		shipping_city,		
		related_division,
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
		ROUND(SUM(CASE WHEN invoice_year IN (2015,2016) THEN revenues_wdisc_in_base_currency END),0) AS revenues_wdisc_2015_2016,		
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
		related_webshop,
		SUM(net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(SUM(net_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `net_margin_wodisc_%`,
		ROUND(SUM(net_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `net_margin_wdisc_%`,		
		SUM(shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		num_of_purch,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS contact_lens_user,
		MAX(CASE WHEN product_group  = 'Solutions' THEN 1 ELSE 0 END) AS solution_user,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS eye_drops_user,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_user,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS vitamin_user,
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
SELECT 	user_id, ct2_pack AS typical_lens
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
) l
ON u.user_id = l.user_id
/*typical solution kiszámítása*/
LEFT JOIN
(
SELECT 	user_id, ct2_pack AS typical_solution
FROM
(
SELECT 	user_id, ct2_pack, COUNT(*) AS num_of_purchase
FROM BASE_08_TABLE	
WHERE origin = 'invoices'
AND product_group  = 'Solutions'
GROUP BY user_id, ct2_pack	
ORDER BY 3 DESC
) z
GROUP BY user_id
) s
ON u.user_id = s.user_id
/*typical eye drop kiszámítása*/
LEFT JOIN
(
SELECT 	user_id, ct2_pack AS typical_eye_drop
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
) e
ON u.user_id = e.user_id
;

ALTER TABLE `AGGR_USER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);