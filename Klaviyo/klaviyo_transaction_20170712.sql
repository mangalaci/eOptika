
/*Hungary*/
DROP TABLE IF EXISTS KLAVIYO_ORDER_HU;
CREATE TABLE IF NOT EXISTS KLAVIYO_ORDER_HU
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		erp_invoice_id AS `Placed Order//erp_invoice_id`,
		created AS `Placed Order//created`,
		fulfillment_date AS `Placed Order//fulfillment_date`,
		primary_email AS `Person//Email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		billing_zip_code AS `Person//billing_zip_code`,
		billing_city AS `Person//billing_city`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		shipping_zip_code AS `Person//shipping_zip_code`,
		shipping_city AS `Person//shipping_city`,	
		related_webshop AS `Person//related_webshop`,
		related_warehouse AS `Person//related_warehouse`,		
		item_quantity AS `Placed Order//item_quantity`,		
		item_weight_in_kg AS `Placed Order//item_weight_in_kg`,		
		shipping_method AS `Placed Order//shipping_method`,		
		payment_method AS `Placed Order//payment_method`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Placed Order//revenues_wdisc_in_base_currency`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Placed Order//gross_margin_wdisc_in_base_currency`,
		order_year AS `Placed Order//order_year`,
		order_month AS `Placed Order//order_month`,
		order_day_in_month AS `Placed Order//order_day_in_month`,
		order_weekday AS `Placed Order//order_weekday`,
		order_week_in_month AS `Placed Order//order_week_in_month`,
		order_hour AS `Placed Order//order_hour`,
		trx_marketing_channel AS `Placed Order//trx_marketing_channel`,
		trx_rank AS `Placed Order//trx_rank`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Placed Order//contact_lens_trx`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Placed Order//solution_trx`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Placed Order//eye_drops_trx`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Placed Order//sunglass_trx`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Placed Order//vitamin_trx`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Placed Order//frames_trx`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Placed Order//glass_lenses_trx`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Placed Order//other_product_trx`,		
		coupon_code AS `Placed Order//coupon_code`,
		source AS `Placed Order//source`,
		medium AS `Placed Order//medium`,
		campaign AS `Placed Order//campaign`,
		pack_size AS `Placed Order//pack_size`,
		LVCR_item_flg AS `Placed Order//LVCR_item_flg`,
		source_of_trx AS `Placed Order//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Placed Order//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - HU'
GROUP BY erp_invoice_id
ORDER BY created
;


ALTER TABLE KLAVIYO_ORDER_HU ADD PRIMARY KEY (`Placed Order//erp_invoice_id`) USING BTREE;








/*SERBIA*/
DROP TABLE IF EXISTS KLAVIYO_ORDER_RS;
CREATE TABLE IF NOT EXISTS KLAVIYO_ORDER_RS
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		erp_invoice_id AS `Placed Order//erp_invoice_id`,
		created AS `Placed Order//created`,
		fulfillment_date AS `Placed Order//fulfillment_date`,
		primary_email AS `Person//Email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		billing_zip_code AS `Person//billing_zip_code`,
		billing_city AS `Person//billing_city`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		shipping_zip_code AS `Person//shipping_zip_code`,
		shipping_city AS `Person//shipping_city`,	
		related_webshop AS `Person//related_webshop`,
		related_warehouse AS `Person//related_warehouse`,		
		item_quantity AS `Placed Order//item_quantity`,		
		item_weight_in_kg AS `Placed Order//item_weight_in_kg`,		
		shipping_method AS `Placed Order//shipping_method`,		
		payment_method AS `Placed Order//payment_method`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Placed Order//revenues_wdisc_in_base_currency`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Placed Order//gross_margin_wdisc_in_base_currency`,
		order_year AS `Placed Order//order_year`,
		order_month AS `Placed Order//order_month`,
		order_day_in_month AS `Placed Order//order_day_in_month`,
		order_weekday AS `Placed Order//order_weekday`,
		order_week_in_month AS `Placed Order//order_week_in_month`,
		order_hour AS `Placed Order//order_hour`,
		trx_marketing_channel AS `Placed Order//trx_marketing_channel`,
		trx_rank AS `Placed Order//trx_rank`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Placed Order//contact_lens_trx`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Placed Order//solution_trx`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Placed Order//eye_drops_trx`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Placed Order//sunglass_trx`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Placed Order//vitamin_trx`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Placed Order//frames_trx`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Placed Order//glass_lenses_trx`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Placed Order//other_product_trx`,		
		coupon_code AS `Placed Order//coupon_code`,
		source AS `Placed Order//source`,
		medium AS `Placed Order//medium`,
		campaign AS `Placed Order//campaign`,
		pack_size AS `Placed Order//pack_size`,
		LVCR_item_flg AS `Placed Order//LVCR_item_flg`,
		source_of_trx AS `Placed Order//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Placed Order//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - RS'
GROUP BY erp_invoice_id
ORDER BY created
;


ALTER TABLE KLAVIYO_ORDER_RS ADD PRIMARY KEY (`Placed Order//erp_invoice_id`) USING BTREE;






/*ITALY*/
DROP TABLE IF EXISTS KLAVIYO_ORDER_IT;
CREATE TABLE IF NOT EXISTS KLAVIYO_ORDER_IT
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		erp_invoice_id AS `Placed Order//erp_invoice_id`,
		created AS `Placed Order//created`,
		fulfillment_date AS `Placed Order//fulfillment_date`,
		primary_email AS `Person//Email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		billing_zip_code AS `Person//billing_zip_code`,
		billing_city AS `Person//billing_city`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		shipping_zip_code AS `Person//shipping_zip_code`,
		shipping_city AS `Person//shipping_city`,	
		related_webshop AS `Person//related_webshop`,
		related_warehouse AS `Person//related_warehouse`,		
		item_quantity AS `Placed Order//item_quantity`,		
		item_weight_in_kg AS `Placed Order//item_weight_in_kg`,		
		shipping_method AS `Placed Order//shipping_method`,		
		payment_method AS `Placed Order//payment_method`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Placed Order//revenues_wdisc_in_base_currency`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Placed Order//gross_margin_wdisc_in_base_currency`,
		order_year AS `Placed Order//order_year`,
		order_month AS `Placed Order//order_month`,
		order_day_in_month AS `Placed Order//order_day_in_month`,
		order_weekday AS `Placed Order//order_weekday`,
		order_week_in_month AS `Placed Order//order_week_in_month`,
		order_hour AS `Placed Order//order_hour`,
		trx_marketing_channel AS `Placed Order//trx_marketing_channel`,
		trx_rank AS `Placed Order//trx_rank`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Placed Order//contact_lens_trx`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Placed Order//solution_trx`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Placed Order//eye_drops_trx`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Placed Order//sunglass_trx`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Placed Order//vitamin_trx`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Placed Order//frames_trx`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Placed Order//glass_lenses_trx`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Placed Order//other_product_trx`,		
		coupon_code AS `Placed Order//coupon_code`,
		source AS `Placed Order//source`,
		medium AS `Placed Order//medium`,
		campaign AS `Placed Order//campaign`,
		pack_size AS `Placed Order//pack_size`,
		LVCR_item_flg AS `Placed Order//LVCR_item_flg`,
		source_of_trx AS `Placed Order//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Placed Order//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - IT'
GROUP BY erp_invoice_id
ORDER BY created
;


ALTER TABLE KLAVIYO_ORDER_IT ADD PRIMARY KEY (`Placed Order//erp_invoice_id`) USING BTREE;





/*UK*/




/*Croatia*/
DROP TABLE IF EXISTS KLAVIYO_ORDER_HR;
CREATE TABLE IF NOT EXISTS KLAVIYO_ORDER_HR
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		erp_invoice_id AS `Placed Order//erp_invoice_id`,
		created AS `Placed Order//created`,
		fulfillment_date AS `Placed Order//fulfillment_date`,
		primary_email AS `Person//Email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		billing_zip_code AS `Person//billing_zip_code`,
		billing_city AS `Person//billing_city`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		shipping_zip_code AS `Person//shipping_zip_code`,
		shipping_city AS `Person//shipping_city`,	
		related_webshop AS `Person//related_webshop`,
		related_warehouse AS `Person//related_warehouse`,		
		item_quantity AS `Placed Order//item_quantity`,		
		item_weight_in_kg AS `Placed Order//item_weight_in_kg`,		
		shipping_method AS `Placed Order//shipping_method`,		
		payment_method AS `Placed Order//payment_method`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Placed Order//revenues_wdisc_in_base_currency`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Placed Order//gross_margin_wdisc_in_base_currency`,
		order_year AS `Placed Order//order_year`,
		order_month AS `Placed Order//order_month`,
		order_day_in_month AS `Placed Order//order_day_in_month`,
		order_weekday AS `Placed Order//order_weekday`,
		order_week_in_month AS `Placed Order//order_week_in_month`,
		order_hour AS `Placed Order//order_hour`,
		trx_marketing_channel AS `Placed Order//trx_marketing_channel`,
		trx_rank AS `Placed Order//trx_rank`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Placed Order//contact_lens_trx`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Placed Order//solution_trx`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Placed Order//eye_drops_trx`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Placed Order//sunglass_trx`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Placed Order//vitamin_trx`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Placed Order//frames_trx`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Placed Order//glass_lenses_trx`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Placed Order//other_product_trx`,		
		coupon_code AS `Placed Order//coupon_code`,
		source AS `Placed Order//source`,
		medium AS `Placed Order//medium`,
		campaign AS `Placed Order//campaign`,
		pack_size AS `Placed Order//pack_size`,
		LVCR_item_flg AS `Placed Order//LVCR_item_flg`,
		source_of_trx AS `Placed Order//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Placed Order//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - HR'
GROUP BY erp_invoice_id
ORDER BY created
;


ALTER TABLE KLAVIYO_ORDER_HR ADD PRIMARY KEY (`Placed Order//erp_invoice_id`) USING BTREE;


