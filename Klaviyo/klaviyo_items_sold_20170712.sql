
/*Hungary*/
DROP TABLE IF EXISTS KLAVIYO_ITEMS_SOLD_HU;
CREATE TABLE IF NOT EXISTS KLAVIYO_ITEMS_SOLD_HU
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		created AS `Ordered//created`,
		fulfillment_date AS `Ordered//fulfillment_date`,
		currency AS `Ordered//currency`,
		related_warehouse AS `Ordered//related_warehouse`,
		item_net_sale_price_in_base_currency AS `Ordered//item_net_sale_price_in_base_currency`,
		item_quantity AS `Ordered//item_quantity`,
		CT1_SKU AS `Ordered//CT1_SKU`,
		CT1_SKU_name AS `Ordered//CT1_SKU_name`,
		CT2_sku AS `Ordered//CT2_sku`,
		CT2_pack AS `Ordered//CT2_pack`,
		primary_email AS `Person//Email`,
		CT3_product_short AS `Ordered//CT3_product_short`,
		CT4_product_brand AS `Ordered//CT4_product_brand`,
		CT5_manufacturer AS `Ordered//CT5_manufacturer`,
		product_group AS `Ordered//product_group`,
		lens_type AS `Ordered//lens_type`,
		is_color AS `Ordered//is_color`,
		wear_duration AS `Ordered//wear_duration`,
		wear_days AS `Ordered//wear_days`,
		item_type	AS `Ordered//item_type`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Ordered//revenues_wdisc_in_base_currency`,
		trx_marketing_channel AS `Ordered//trx_marketing_channel`,
		trx_rank AS `Ordered//trx_rank`,
		lens_bc AS `Ordered//lens_bc`,
		lens_pwr AS `Ordered//lens_pwr`,
		lens_cyl AS `Ordered//lens_cyl`,
		lens_ax AS `Ordered//lens_ax`,
		lens_dia AS `Ordered//lens_dia`,
		lens_add AS `Ordered//lens_add`,		
		lens_clr AS `Ordered//lens_clr`,
		coupon_code AS `Ordered//coupon_code`,
		source AS `Ordered//source`,
		medium AS `Ordered//medium`,
		campaign AS `Ordered//campaign`,
		pack_size AS `Ordered//pack_size`,
		LVCR_item_flg AS `Ordered//LVCR_item_flg`,
		source_of_trx AS `Ordered//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Ordered//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - HU'
GROUP BY item_id
ORDER BY created
;


ALTER TABLE KLAVIYO_ITEMS_SOLD_HU ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE KLAVIYO_ITEMS_SOLD_HU ADD INDEX (`Person//Email`) USING BTREE;







/*SERBIA*/
DROP TABLE IF EXISTS KLAVIYO_ITEMS_SOLD_RS;
CREATE TABLE IF NOT EXISTS KLAVIYO_ITEMS_SOLD_RS
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		created AS `Ordered//created`,
		fulfillment_date AS `Ordered//fulfillment_date`,
		currency AS `Ordered//currency`,
		related_warehouse AS `Ordered//related_warehouse`,
		item_net_sale_price_in_base_currency AS `Ordered//item_net_sale_price_in_base_currency`,
		item_quantity AS `Ordered//item_quantity`,
		CT1_SKU AS `Ordered//CT1_SKU`,
		CT1_SKU_name AS `Ordered//CT1_SKU_name`,
		CT2_sku AS `Ordered//CT2_sku`,
		CT2_pack AS `Ordered//CT2_pack`,
		primary_email AS `Person//Email`,
		CT3_product_short AS `Ordered//CT3_product_short`,
		CT4_product_brand AS `Ordered//CT4_product_brand`,
		CT5_manufacturer AS `Ordered//CT5_manufacturer`,
		product_group AS `Ordered//product_group`,
		lens_type AS `Ordered//lens_type`,
		is_color AS `Ordered//is_color`,
		wear_duration AS `Ordered//wear_duration`,
		wear_days AS `Ordered//wear_days`,
		item_type	AS `Ordered//item_type`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Ordered//revenues_wdisc_in_base_currency`,
		trx_marketing_channel AS `Ordered//trx_marketing_channel`,
		trx_rank AS `Ordered//trx_rank`,
		lens_bc AS `Ordered//lens_bc`,
		lens_pwr AS `Ordered//lens_pwr`,
		lens_cyl AS `Ordered//lens_cyl`,
		lens_ax AS `Ordered//lens_ax`,
		lens_dia AS `Ordered//lens_dia`,
		lens_add AS `Ordered//lens_add`,		
		lens_clr AS `Ordered//lens_clr`,
		coupon_code AS `Ordered//coupon_code`,
		source AS `Ordered//source`,
		medium AS `Ordered//medium`,
		campaign AS `Ordered//campaign`,
		pack_size AS `Ordered//pack_size`,
		LVCR_item_flg AS `Ordered//LVCR_item_flg`,
		source_of_trx AS `Ordered//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Ordered//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - RS'
GROUP BY item_id
ORDER BY created
;



ALTER TABLE KLAVIYO_ITEMS_SOLD_RS ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE KLAVIYO_ITEMS_SOLD_RS ADD INDEX (`Person//Email`) USING BTREE;



/*ITALY*/
DROP TABLE IF EXISTS KLAVIYO_ITEMS_SOLD_IT;
CREATE TABLE IF NOT EXISTS KLAVIYO_ITEMS_SOLD_IT
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		created AS `Ordered//created`,
		fulfillment_date AS `Ordered//fulfillment_date`,
		currency AS `Ordered//currency`,
		related_warehouse AS `Ordered//related_warehouse`,
		item_net_sale_price_in_base_currency AS `Ordered//item_net_sale_price_in_base_currency`,
		item_quantity AS `Ordered//item_quantity`,
		CT1_SKU AS `Ordered//CT1_SKU`,
		CT1_SKU_name AS `Ordered//CT1_SKU_name`,
		CT2_sku AS `Ordered//CT2_sku`,
		CT2_pack AS `Ordered//CT2_pack`,
		primary_email AS `Person//Email`,
		CT3_product_short AS `Ordered//CT3_product_short`,
		CT4_product_brand AS `Ordered//CT4_product_brand`,
		CT5_manufacturer AS `Ordered//CT5_manufacturer`,
		product_group AS `Ordered//product_group`,
		lens_type AS `Ordered//lens_type`,
		is_color AS `Ordered//is_color`,
		wear_duration AS `Ordered//wear_duration`,
		wear_days AS `Ordered//wear_days`,
		item_type	AS `Ordered//item_type`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Ordered//revenues_wdisc_in_base_currency`,
		trx_marketing_channel AS `Ordered//trx_marketing_channel`,
		trx_rank AS `Ordered//trx_rank`,
		lens_bc AS `Ordered//lens_bc`,
		lens_pwr AS `Ordered//lens_pwr`,
		lens_cyl AS `Ordered//lens_cyl`,
		lens_ax AS `Ordered//lens_ax`,
		lens_dia AS `Ordered//lens_dia`,
		lens_add AS `Ordered//lens_add`,		
		lens_clr AS `Ordered//lens_clr`,
		coupon_code AS `Ordered//coupon_code`,
		source AS `Ordered//source`,
		medium AS `Ordered//medium`,
		campaign AS `Ordered//campaign`,
		pack_size AS `Ordered//pack_size`,
		LVCR_item_flg AS `Ordered//LVCR_item_flg`,
		source_of_trx AS `Ordered//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Ordered//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - IT'
GROUP BY item_id
ORDER BY created
;



ALTER TABLE KLAVIYO_ITEMS_SOLD_IT ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE KLAVIYO_ITEMS_SOLD_IT ADD INDEX (`Person//Email`) USING BTREE;





/*UK*/




/*Croatia*/
DROP TABLE IF EXISTS KLAVIYO_ITEMS_SOLD_HR;
CREATE TABLE IF NOT EXISTS KLAVIYO_ITEMS_SOLD_HR
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		created AS `Ordered//created`,
		fulfillment_date AS `Ordered//fulfillment_date`,
		currency AS `Ordered//currency`,
		related_warehouse AS `Ordered//related_warehouse`,
		item_net_sale_price_in_base_currency AS `Ordered//item_net_sale_price_in_base_currency`,
		item_quantity AS `Ordered//item_quantity`,
		CT1_SKU AS `Ordered//CT1_SKU`,
		CT1_SKU_name AS `Ordered//CT1_SKU_name`,
		CT2_sku AS `Ordered//CT2_sku`,
		CT2_pack AS `Ordered//CT2_pack`,
		primary_email AS `Person//Email`,
		CT3_product_short AS `Ordered//CT3_product_short`,
		CT4_product_brand AS `Ordered//CT4_product_brand`,
		CT5_manufacturer AS `Ordered//CT5_manufacturer`,
		product_group AS `Ordered//product_group`,
		lens_type AS `Ordered//lens_type`,
		is_color AS `Ordered//is_color`,
		wear_duration AS `Ordered//wear_duration`,
		wear_days AS `Ordered//wear_days`,
		item_type	AS `Ordered//item_type`,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS `Ordered//revenues_wdisc_in_base_currency`,
		trx_marketing_channel AS `Ordered//trx_marketing_channel`,
		trx_rank AS `Ordered//trx_rank`,
		lens_bc AS `Ordered//lens_bc`,
		lens_pwr AS `Ordered//lens_pwr`,
		lens_cyl AS `Ordered//lens_cyl`,
		lens_ax AS `Ordered//lens_ax`,
		lens_dia AS `Ordered//lens_dia`,
		lens_add AS `Ordered//lens_add`,		
		lens_clr AS `Ordered//lens_clr`,
		coupon_code AS `Ordered//coupon_code`,
		source AS `Ordered//source`,
		medium AS `Ordered//medium`,
		campaign AS `Ordered//campaign`,
		pack_size AS `Ordered//pack_size`,
		LVCR_item_flg AS `Ordered//LVCR_item_flg`,
		source_of_trx AS `Ordered//source_of_trx`,
		CASE 	WHEN origin = 'invoices' THEN 'successful'
				WHEN origin = 'orders' AND is_canceled = 'yes' THEN 'cancelled'
				WHEN origin = 'orders' AND is_canceled = 'no' THEN 'pending'
				ELSE 'other'
		END AS `Ordered//status`
FROM BASE_09_TABLE
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND related_division = 'Optika - HR'
GROUP BY item_id
ORDER BY created
;



ALTER TABLE KLAVIYO_ITEMS_SOLD_HR ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE KLAVIYO_ITEMS_SOLD_HR ADD INDEX (`Person//Email`) USING BTREE;

