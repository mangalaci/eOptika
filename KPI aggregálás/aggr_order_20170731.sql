DROP TABLE IF EXISTS AGGR_ORDER;
CREATE TABLE AGGR_ORDER
SELECT 	
		origin,
		primary_email,
		secondary_email,
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
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		fulfillment_date,
		billing_country_standardized,
		shipping_country_standardized,
		item_is_canceled,
		last_modified_date,
		last_modified_by,
		related_warehouse,
		payment_method,
		shipping_method,
		related_division,
		currency,
		exchange_rate_of_currency,
		item_vat_rate,
		ROUND(SUM(item_net_purchase_price_in_base_currency*item_quantity),0) AS item_net_purchase_price_in_base_currency,
		ROUND(SUM(item_net_sale_price_in_currency*item_quantity),0) AS item_net_sale_price_in_currency,
		ROUND(SUM(item_gross_sale_price_in_currency*item_quantity),0) AS item_gross_sale_price_in_currency,
		ROUND(SUM(item_net_sale_price_in_base_currency*item_quantity),0) AS item_net_sale_price_in_base_currency,
		ROUND(SUM(item_gross_sale_price_in_base_currency*item_quantity),0) AS item_gross_sale_price_in_base_currency,
		SUM(item_quantity) AS item_quantity,
		ROUND(SUM(item_revenue_in_local_currency),0) AS item_revenue_in_local_currency,
		ROUND(SUM(item_vat_value_in_local_currency),0) AS item_vat_value_in_local_currency,
		ROUND(SUM(item_revenue_in_base_currency),0) AS item_revenue_in_base_currency,
		ROUND(SUM(item_vat_in_base_currency),0) AS item_vat_in_base_currency,
		ROUND(SUM(item_gross_revenue_in_base_currency),0) AS item_gross_revenue_in_base_currency,
		ROUND(SUM(item_weight_in_kg),3) AS item_weight_in_kg,
		user_type,
		salutation,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		primary_newsletter_flg,
		secondary_newsletter_flg,
		cohort_id,
		last_purchase,
		time_order_to_dispatch,
		time_dispatch_to_delivery,
		CASE WHEN origin = 'invoices' THEN invoice_yearmonth ELSE NULL END AS invoice_yearmonth,
		CASE WHEN origin = 'invoices' THEN invoice_year ELSE NULL END AS invoice_year,
		CASE WHEN origin = 'invoices' THEN invoice_quarter ELSE NULL END AS invoice_quarter,
		CASE WHEN origin = 'invoices' THEN invoice_month ELSE NULL END AS invoice_month,
		CASE WHEN origin = 'invoices' THEN invoice_day_in_month ELSE NULL END AS invoice_day_in_month,
		CASE WHEN origin = 'invoices' THEN invoice_hour ELSE NULL END AS invoice_hour,
		cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		NULL AS order_date_and_time,
		CASE WHEN origin = 'orders' THEN order_year ELSE NULL END AS order_year,
		CASE WHEN origin = 'orders' THEN order_quarter ELSE NULL END AS order_quarter,
		CASE WHEN origin = 'orders' THEN order_month ELSE NULL END AS order_month,
		CASE WHEN origin = 'orders' THEN order_day_in_month ELSE NULL END AS order_day_in_month,
		CASE WHEN origin = 'orders' THEN order_weekday ELSE NULL END AS order_weekday,
		CASE WHEN origin = 'orders' THEN order_week_in_month ELSE NULL END AS order_week_in_month,
		related_webshop,
		trx_marketing_channel,
		repeat_buyer,
		trx_rank,
		source_of_trx,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,	
		ROUND(SUM(shipping_cost_in_base_currency),0) AS shipping_cost_in_base_currency,
		ROUND(SUM(packaging_cost_in_base_currency),0) AS packaging_cost_in_base_currency,
		ROUND(SUM(payment_cost_in_base_currency),0) AS payment_cost_in_base_currency,		
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS contact_lens_trx,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS solution_trx,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS eye_drops_trx,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_trx,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS vitamin_trx,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS frames_trx,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS glass_lenses_trx,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS other_product_trx,
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
		coupon_code,
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
FROM BASE_09_TABLE
GROUP BY erp_invoice_id
;


ALTER TABLE AGGR_ORDER ADD PRIMARY KEY (`erp_invoice_id`) USING BTREE;