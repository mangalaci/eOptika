DROP TABLE IF EXISTS AGGR_ORDER;
CREATE TABLE AGGR_ORDER
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
FROM
(
SELECT 	origin,
		erp_invoice_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		billing_country_standardized,
		billing_zip_code,
		billing_city_clean,
		shipping_country_standardized,
		shipping_zip_code,
		shipping_city,
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
		invoice_yearmonth,
		invoice_year,
		invoice_month,
		invoice_day_in_month,
		invoice_hour,
		cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		NULL AS order_date_and_time,
		order_year,
		order_month,
		order_day_in_month,
		order_weekday,
		order_week_in_month,
		packaging_deadline,
		related_webshop,
		trx_marketing_channel,
		num_of_purch,
		trx_rank,
		SUM(order_value) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(SUM(net_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `net_margin_wodisc_%`,
		ROUND(SUM(net_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `net_margin_wdisc_%`,
		ROUND(SUM(shipping_cost_in_base_currency),0) AS shipping_cost_in_base_currency,
		ROUND(SUM(packaging_cost_in_base_currency),0) AS packaging_cost_in_base_currency,
		ROUND(SUM(payment_cost_in_base_currency),0) AS payment_cost_in_base_currency,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS contact_lens_trx,
		MAX(CASE WHEN product_group  = 'Solutions' THEN 1 ELSE 0 END) AS solution_trx,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS eye_drops_trx,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_trx,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS vitamin_trx
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
GROUP BY erp_invoice_id
) u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id
;


ALTER TABLE `AGGR_ORDER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);