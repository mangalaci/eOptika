DROP TABLE IF EXISTS AGGR_ORDER_ABR;
CREATE TABLE AGGR_ORDER_ABR
SELECT 
erp_invoice_id,
contact_lens_vol,
solution_vol,
eye_drops_vol,
order_value
FROM AGGR_ORDER
;

ALTER TABLE AGGR_ORDER_ABR ADD PRIMARY KEY (`erp_invoice_id`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit_hi_vol;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit_hi_vol
SELECT 
CT1_sku,
AVG(time_order_to_dispatch) + STD(time_order_to_dispatch) AS tolerance_limit
FROM `BASE_03_TABLE`
WHERE product_group = 'Contact lenses'
GROUP BY CT1_sku
HAVING COUNT(*) > 6
;

ALTER TABLE dispatch_time_tolerance_limit_hi_vol ADD PRIMARY KEY (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit_lo_vol;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit_lo_vol
SELECT a.CT1_sku, b.tolerance_limit
FROM
(
SELECT 
CT1_sku,
CT2_sku,
COUNT(*)
FROM `BASE_03_TABLE`
WHERE product_group = 'Contact lenses'
GROUP BY CT1_sku, CT2_sku
HAVING COUNT(*) <= 6
ORDER BY 3 DESC
) a
LEFT JOIN
(
SELECT 
CT2_sku,
AVG(time_order_to_dispatch) + STD(time_order_to_dispatch) AS tolerance_limit,
COUNT(*)
FROM `BASE_03_TABLE`
WHERE product_group = 'Contact lenses'
GROUP BY CT2_sku
ORDER BY 3 DESC
) b
ON a.CT2_sku = b.CT2_sku
;

ALTER TABLE dispatch_time_tolerance_limit_lo_vol ADD PRIMARY KEY (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit
SELECT *
FROM dispatch_time_tolerance_limit_hi_vol
UNION
SELECT *
FROM dispatch_time_tolerance_limit_lo_vol
;

ALTER TABLE dispatch_time_tolerance_limit ADD PRIMARY KEY (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS AGGR_USER_UNSANITIZED;
CREATE TABLE IF NOT EXISTS AGGR_USER_UNSANITIZED
SELECT
		t.user_id,
		t.user_active_flg,
		REPLACE(REPLACE(special_char_replace(t.primary_email),' ',''),'  ','') AS primary_email,
		t.secondary_email,
		t.shipping_phone,
		t.personal_name,
		t.personal_address,
		t.personal_zip_code,
		t.personal_city,
		t.personal_city_size,	
		t.personal_province,
		t.personal_country,	
		t.pickup_name,
		t.pickup_address,
		t.pickup_zip_code,
		t.pickup_city,
		t.pickup_city_size,	
		t.pickup_province,
		t.pickup_country,
		t.business_name,
		t.business_address,
		t.business_zip_code,
		t.business_city,
		t.business_city_size,	
		t.business_province,
		t.business_country,
		t.health_insurance,
		t.catchment_area,
		t.personal_location_catchment_area,
		t.pickup_location_catchment_area,		
		COUNT(DISTINCT t.erp_invoice_id) AS num_of_orders,
		COUNT(t.item_id) AS num_of_items,
		MAX(t.last_modified_date) AS last_purchase,
		t.one_before_last_purchase,
		t.billing_country_standardized,
		t.billing_zip_code,
		t.billing_city,
		t.shipping_country_standardized,
		t.shipping_zip_code,
		t.shipping_city,
		t.related_division,
		ROUND(SUM(t.item_net_purchase_price_in_base_currency*t.item_quantity),0) AS item_net_purchase_price_in_base_currency,
		ROUND(SUM(t.item_net_sale_price_in_currency*t.item_quantity),0) AS item_net_sale_price_in_currency,
		ROUND(SUM(t.item_gross_sale_price_in_currency*t.item_quantity),0) AS item_gross_sale_price_in_currency,
		ROUND(SUM(t.item_net_sale_price_in_base_currency*t.item_quantity),0) AS item_net_sale_price_in_base_currency,
		ROUND(SUM(t.item_gross_sale_price_in_base_currency*t.item_quantity),0) AS item_gross_sale_price_in_base_currency,
		ROUND(SUM(t.item_quantity),0) AS item_quantity,
		ROUND(SUM(t.item_revenue_in_local_currency),0) AS item_revenue_in_local_currency,
		ROUND(SUM(t.item_vat_value_in_local_currency),0) AS item_vat_value_in_local_currency,
		ROUND(SUM(t.item_revenue_in_base_currency),0) AS item_revenue_in_base_currency,
		ROUND(SUM(t.item_vat_in_base_currency),0) AS item_vat_in_base_currency,
		ROUND(SUM(t.item_gross_revenue_in_base_currency),0) AS item_gross_revenue_in_base_currency,
		t.user_type,
		t.gender,
		t.full_name,
		t.first_name,
		t.last_name,
		t.salutation,
		ROUND(SUM(t.revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(CASE WHEN t.invoice_year IN (2015,2016) THEN t.revenues_wdisc_in_base_currency END),0) AS revenues_wdisc_2015_2016,		
		ROUND(SUM(t.revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(t.gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(t.gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(t.`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(t.`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		t.primary_newsletter_flg,
		t.secondary_newsletter_flg,
		t.cohort_id,
		t.cohort_month_since,
		t.user_cum_transactions,
		t.user_cum_gross_revenue_in_base_currency,
		t.related_webshop,
		SUM(t.net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(t.net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(t.`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(t.`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		SUM(t.net_invoiced_shipping_costs_in_base_currency) AS net_invoiced_shipping_costs_in_base_currency,
		SUM(t.shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(t.packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(t.payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		t.repeat_buyer,
		t.contact_lens_user,
		t.solution_user,
		t.eye_drops_user,
		t.sunglass_user,
		t.vitamin_user,
		t.frames_user,
		t.lenses_for_spectacles_user,
		t.contact_lens_trials_user,
		t.spectacles_user,
		t.other_product_user,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.revenues_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_revenues_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.gross_margin_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_gross_margin_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.net_margin_wodisc_in_base_currency ELSE 0 END ELSE 0 END), 0) AS first_year_contact_lens_net_margin_wodisc_in_base_currency,
		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(t.item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) AS first_year_contact_lens_boxes,
		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  >= 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(t.item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) AS after_first_year_contact_lens_boxes,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END)), 2) AS first_year_contact_lens_projected_boxes,

	CASE WHEN typical_wear_duration_eye2 IS NOT NULL THEN
		ROUND(
		((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END))))
		, 2) 
	ELSE 
		ROUND(
		((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END)))
		, 2) 	
	END	AS first_year_contact_lens_overuse_ratio, /* függ attól, hogy egy, vagy két szemre hord lencsét*/

		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days*t.item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_days_covered,
		720 AS one_year_contact_lens_max_days_covered,
		MAX(t.date_lenses_run_out) AS date_lenses_run_out,
		MAX(t.date_lens_cleaners_run_out) AS date_lens_cleaners_run_out,
		t.contact_lens_last_purchase,
		t.last_modified_date,
		t.multi_user_account,
		t.pwr_eye1,
		t.pwr_eye2,
		t.typical_wear_duration_eye1,
		t.typical_wear_duration_eye2,
		t.typical_wear_days_eye1,
		t.typical_wear_days_eye2,		
		t.bc_eye1,
		t.bc_eye2,
		t.cyl_eye1,
		t.cyl_eye2,
		t.ax_eye1,
		t.ax_eye2,
		t.dia_eye1,
		t.dia_eye2,
		t.add_eye1,
		t.add_eye2,
		t.clr_eye1,
		t.clr_eye2,
		t.typical_lens_type_eye1,
		t.typical_lens_type_eye2,
		t.typical_lens_eye1_CT1,
		t.typical_lens_eye2_CT1,
		t.typical_lens_eye1_CT2,
		t.typical_lens_eye2_CT2,
		t.typical_solution_CT2,
		t.typical_eye_drop_CT2,
		t.typical_lens_eye1_CT3,
		t.typical_lens_eye2_CT3,
		t.typical_solution_CT3,
		t.typical_eye_drop_CT3,
		t.typical_lens_eye1_CT4,
		t.typical_lens_eye2_CT4,
		t.typical_solution_CT4,
		t.typical_eye_drop_CT4,
		t.typical_lens_eye1_CT5,
		t.typical_lens_eye2_CT5,
		t.typical_solution_CT5,
		t.typical_eye_drop_CT5,
		t.typical_lens_pack_size,
		t.typical_solution_pack_size,
		t.typical_eye_drop_pack_size,
		t.last_shipping_method,
		t.last_payment_method,
		t.newsletter_current,
		t.newsletter_ever,
		t.loyalty_points,
		MAX(t.experiment) AS experiment,
		CASE 
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE t.personal_province
		END AS personal_geogr_region,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN CT2_pack END) AS elso_lencse_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN CT3_product_short END) AS elso_lencse_CT3,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lens cleaners' THEN CT2_pack END) AS elso_folyadek_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lens cleaners' THEN CT3_product_short END) AS elso_folyadek_CT3,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Eye drops' THEN CT2_pack END) AS elso_szemcsepp_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN lens_type END) AS elso_lens_type,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN is_color END) AS elso_is_color,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN wear_days END) AS elso_wear_days,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN wear_duration END) AS elso_wear_duration,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN pack_size END) AS elso_pack_size,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' AND t.time_order_to_dispatch > d.tolerance_limit THEN 1 ELSE 0 END) AS elso_lens_too_slow_dispatch,
		
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.shipping_method END) AS elso_shipping_method,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.payment_method END) AS elso_payment_method,		
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_month END) AS elso_order_month,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_weekday END) AS elso_order_weekday,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_week_in_month END) AS elso_order_week_in_month,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.source_of_trx END) AS elso_source_of_trx,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.trx_marketing_channel END) AS elso_trx_marketing_channel,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.coupon_code END) AS elso_coupon_code,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.personal_geogr_region END) AS elso_personal_geogr_region,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.pickup_geogr_region END) AS elso_pickup_geogr_region,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.contact_lens_vol END) AS elso_contact_lens_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.solution_vol END) AS elso_solution_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.eye_drops_vol END) AS elso_eye_drops_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.order_value END) AS elso_order_value,
		AVG(time_order_to_dispatch),
		CASE WHEN DATE(created) = DATE(last_purchase) THEN time_order_to_dispatch END AS last_time_order_to_dispatch,
		brand_switcher_same_manufacturer,
		brand_and_manufacturer_switcher,
		CASE 	WHEN TRIM(t.primary_email) = '.eoptika kft.@eoptikafiktiv.hu' THEN NULL
				WHEN TRIM(p.pred) = 1 THEN '1-time'
				WHEN TRIM(p.pred) = 2 THEN 'repeat'
				ELSE NULL 
		END AS repeat_prediction,
		CASE 	WHEN TRIM(t.primary_email) = '.eoptika kft.@eoptikafiktiv.hu' THEN NULL
				WHEN TRIM(p_i.pred) = 1 THEN 'active'
				WHEN TRIM(p_i.pred) = 2 THEN 'inactive'
				ELSE NULL 
		END AS active_prediction,
		'2018-01-07' AS repeat_prediction_date,
		'2018-01-07' AS active_prediction_date,
		MAX(CASE 
				WHEN t.trx_rank = 2 AND DATEDIFF(t.created, t.first_purchase)  < 391 THEN 'yes'
				ELSE 'no'
		END) AS second_purchase_within_391_days
		
		FROM (SELECT * FROM BASE_03_TABLE ORDER BY created DESC /*azért kell csökkenő sorrendben, mert ha a user_id alatt több név is van, akkor az utolsót vegyük*/) t
LEFT JOIN AGGR_ORDER_ABR o
ON t.erp_invoice_id = o.erp_invoice_id
LEFT JOIN dispatch_time_tolerance_limit d
ON t.CT1_sku = d.CT1_sku
LEFT JOIN prediction_1_time p
ON t.primary_email = p.email
LEFT JOIN prediction_inactive p_i
ON t.primary_email = p_i.email

LEFT JOIN
(
SELECT 	user_id,
		CASE 	WHEN COUNT(DISTINCT CT3_product_short) > 1 AND COUNT(DISTINCT CT5_manufacturer) = 1 
			THEN 1 ELSE 0 
		END AS brand_switcher_same_manufacturer,
		CASE 	WHEN COUNT(DISTINCT CT3_product_short) > 1 AND COUNT(DISTINCT CT5_manufacturer) > 1 
			THEN 1 ELSE 0 
		END AS brand_and_manufacturer_switcher
FROM BASE_03_TABLE		
WHERE	repeat_buyer = 'repeat' 
AND multi_user_account = 'single user' 
AND contact_lens_user = 1
AND product_group = 'Contact lenses' 
GROUP BY user_id
) s
ON t.user_id = s.user_id
WHERE t.origin = 'invoices'
GROUP BY t.user_id
ORDER BY t.created
;

ALTER TABLE AGGR_USER_UNSANITIZED ADD PRIMARY KEY (`user_id`) USING BTREE;

UPDATE AGGR_USER_UNSANITIZED SET primary_email = 'email_blacklist' WHERE primary_email = 'evagorda@gmail.com';
UPDATE AGGR_USER_UNSANITIZED SET secondary_email = 'email_blacklist' WHERE secondary_email = 'evagorda@gmail.com';


DROP TABLE IF EXISTS AGGR_USER_SANITIZED;
CREATE TABLE IF NOT EXISTS AGGR_USER_SANITIZED
SELECT *
FROM AGGR_USER_UNSANITIZED
;

ALTER TABLE AGGR_USER_SANITIZED ADD PRIMARY KEY (`user_id`) USING BTREE;

UPDATE AGGR_USER_SANITIZED SET primary_email = NULL WHERE primary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET secondary_email = NULL WHERE secondary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET full_name = NULL WHERE full_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET first_name = NULL WHERE first_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET last_name = NULL WHERE last_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET personal_name = NULL WHERE personal_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET pickup_name = NULL WHERE pickup_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET business_name = NULL WHERE business_name IS NOT NULL;

