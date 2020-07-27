DROP TABLE IF EXISTS AGGR_USER_UNSANITIZED;
CREATE TABLE IF NOT EXISTS AGGR_USER_UNSANITIZED
SELECT
		user_id,
		primary_email,
		secondary_email,
		shipping_phone,
		personal_name,
		personal_address,
		personal_zip_code,
		personal_city,
		personal_province,
		personal_city_size,		
		pickup_name,
		pickup_address,
		pickup_zip_code,
		pickup_city,
		catchment_area,
		business_name,
		business_address,
		business_zip_code,
		business_city,
		COUNT(DISTINCT erp_invoice_id) AS num_of_orders,
		COUNT(item_id) AS num_of_items,
		MAX(last_modified_date) AS last_purchase,
		one_before_last_purchase,
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
		gender,
		full_name,
		first_name,
		last_name,
		salutation,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(CASE WHEN invoice_year IN (2015,2016) THEN revenues_wdisc_in_base_currency END),0) AS revenues_wdisc_2015_2016,		
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		primary_newsletter_flg,
		secondary_newsletter_flg,
		cohort_id,
		cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		related_webshop,
		SUM(net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		SUM(shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		repeat_buyer,
		contact_lens_user,
		solution_user,
		eye_drops_user,
		sunglass_user,
		vitamin_user,
		frames_user,
		spectacles_user,
		other_product_user,	
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN revenues_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_revenues_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN gross_margin_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_gross_margin_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN net_margin_wodisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_net_margin_wodisc_in_base_currency,
		SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) AS first_year_contact_lens_boxes,
		SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  >= 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) AS after_first_year_contact_lens_boxes,		
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS first_year_contact_lens_projected_boxes,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS first_year_contact_lens_overuse_ratio,
		SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days*item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_days_covered,
		720 AS one_year_contact_lens_max_days_covered,
		MAX(date_lenses_run_out) AS date_lenses_run_out,
		contact_lens_last_purchase,
		last_modified_date,
		multi_user_account,
		pwr_eye1,
		pwr_eye2,
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
		typical_eye_drop_pack_size,
		last_shipping_method,
		last_payment_method,
		newsletter_current,
		newsletter_ever,
		loyalty_points,
		CASE 
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE personal_province
		END AS personal_geogr_region
FROM (SELECT * FROM BASE_09_TABLE ORDER BY created DESC /*azért kell csökkenő sorrendben, mert ha a user_id alatt több név is van, akkor az utolsót vegyük*/) t
WHERE origin = 'invoices'
GROUP BY user_id
ORDER BY created
;

ALTER TABLE AGGR_USER_UNSANITIZED ADD PRIMARY KEY (`user_id`) USING BTREE;


DROP TABLE IF EXISTS AGGR_USER_SANITIZED;
CREATE TABLE IF NOT EXISTS AGGR_USER_SANITIZED
SELECT *
FROM AGGR_USER_UNSANITIZED
;

ALTER TABLE AGGR_USER_SANITIZED ADD PRIMARY KEY (`user_id`) USING BTREE;

UPDATE AGGR_USER_SANITIZED SET primary_email = NULL WHERE primary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET secondary_email = NULL WHERE secondary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET full_name = NULL WHERE full_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET first_name = NULL WHERE first_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET last_name = NULL WHERE last_name IS NOT NULL;

