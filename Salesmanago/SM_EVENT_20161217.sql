DROP TABLE IF EXISTS SM_EVENT_OTHER;
CREATE TABLE SM_EVENT_OTHER
SELECT 	DISTINCT 
		'Other' AS `Type`,
		u.buyer_email,
		u.revenues_wdisc_in_base_currency AS `Value`,
		NULL AS Description,
		u.item_quantity AS Product, 
		CONCAT(p.pickup_zip_code,', ',p.pickup_city,', ',u.province,', ',p.shipping_country_standardized) AS Location,
		DATE(u.created) AS Date,
		TIME(u.created) AS Time,
		'Items Sold' AS Detail1,
		u.origin AS Detail2,		
		u.`gross_margin_wdisc_%` AS Detail3,
		u.gross_margin_wdisc_in_base_currency AS Detail4,
		u.`net_margin_wdisc_%` AS Detail5,
		u.net_margin_wdisc_in_base_currency AS Detail6,
		u.CT1_SKU AS Detail7,
		u.CT1_SKU_name AS Detail8,
		u.CT2_pack AS Detail9,
		u.CT3_product AS Detail10,
		u.CT3_product_short AS Detail11,
		u.CT4_product_brand AS Detail12,
		u.CT5_manufacturer AS Detail13,
		u.lens_bc AS Detail14,
		u.lens_pwr AS Detail15,
		u.lens_cyl AS Detail16,
		u.lens_ax AS Detail17,
		u.lens_dia AS Detail18,
		u.lens_add AS Detail19,
		u.lens_clr AS Detail20,
		u.last_modified_date
FROM 
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		last_modified_date,
		SUM(item_quantity) AS item_quantity,
		user_type,
		province,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		CT1_SKU,
		CT1_SKU_name,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		lens_bc,
		lens_pwr,
		lens_cyl,
		lens_ax,
		lens_dia,
		lens_add,
		lens_clr
FROM (SELECT * FROM BASE_08_TABLE WHERE origin = 'invoices' ORDER BY created DESC) r
GROUP BY item_id
) u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON u.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON u.reference_id = d.hivszam
WHERE LENGTH(u.buyer_email) > 3

UNION

SELECT 	DISTINCT 
		'Other' AS `Type`,
		u.buyer_email,
		u.revenues_wdisc_in_base_currency AS `Value`,
		NULL AS Description,
		u.item_quantity AS Product, 
		CONCAT(p.pickup_zip_code,', ',p.pickup_city,', ',u.province,', ',p.shipping_country_standardized) AS Location,
		DATE(u.created) AS Date,
		TIME(u.created) AS Time,
		'Items Sold' AS Detail1,
		u.origin AS Detail2,		
		u.`gross_margin_wdisc_%` AS Detail3,
		u.gross_margin_wdisc_in_base_currency AS Detail4,
		u.`net_margin_wdisc_%` AS Detail5,
		u.net_margin_wdisc_in_base_currency AS Detail6,
		u.CT1_SKU AS Detail7,
		u.CT1_SKU_name AS Detail8,
		u.CT2_pack AS Detail9,
		u.CT3_product AS Detail10,
		u.CT3_product_short AS Detail11,
		u.CT4_product_brand AS Detail12,
		u.CT5_manufacturer AS Detail13,
		u.lens_bc AS Detail14,
		u.lens_pwr AS Detail15,
		u.lens_cyl AS Detail16,
		u.lens_ax AS Detail17,
		u.lens_dia AS Detail18,
		u.lens_add AS Detail19,
		u.lens_clr AS Detail20,
		u.last_modified_date
FROM 
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		last_modified_date,
		SUM(item_quantity) AS item_quantity,
		user_type,
		province,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		CT1_SKU,
		CT1_SKU_name,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		lens_bc,
		lens_pwr,
		lens_cyl,
		lens_ax,
		lens_dia,
		lens_add,
		lens_clr
FROM (SELECT * FROM BASE_08_TABLE WHERE origin = 'orders' ORDER BY created DESC) r
GROUP BY item_id
) u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON u.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON u.reference_id = d.hivszam
WHERE LENGTH(u.buyer_email) > 3
;


ALTER TABLE `SM_EVENT_OTHER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_EVENT_OTHER` ADD UNIQUE( `buyer_email`, `Detail3`, `Detail4`, `Detail5`, `Detail6`, `Detail7`, `last_modified_date`);



DROP TABLE IF EXISTS SM_EVENT_PURCHASE;
CREATE TABLE SM_EVENT_PURCHASE
SELECT 	DISTINCT 
		'Purchase' AS `Type`,
		u1.buyer_email,
		u1.revenues_wdisc_in_base_currency AS `Value`,
		NULL AS Description,
		u1.num_of_items AS Product,
		CONCAT(p.pickup_zip_code,', ',p.pickup_city,', ',u1.province,', ',p.shipping_country_standardized) AS Location,
		DATE(u1.created) AS Date,
		TIME(u1.created) AS Time,
		'Transactions' AS Detail1,
		u1.`gross_margin_wdisc_%` AS Detail2,
		u1.gross_margin_wdisc_in_base_currency AS Detail3,
		u1.`net_margin_wdisc_%` AS Detail4,
		u1.net_margin_wdisc_in_base_currency AS Detail5,
		u1.origin AS Detail6,
		CASE 	WHEN u1.related_division = 'Optika - HU' THEN 'Hungary'
				WHEN u1.related_division = 'Optika - IT' THEN 'Italy'
				WHEN u1.related_division = 'Optika - UK' THEN 'United Kingdom'
				WHEN u1.related_division = 'Optika - RO' THEN 'Romania'
				WHEN u1.related_division = 'Optika - SK' THEN 'Slovakia'
				ELSE 'N/A'
		END AS Detail7,
		u1.related_webshop AS Detail8,
		u1.user_cum_transactions AS Detail9,
		u1.newsletter AS Detail10,
		/*reminder_date*/
		covered_days_over_dt AS Detail11,
		u1.trx_marketing_channel AS Detail12,
		NULL AS Detail13,
		NULL AS Detail14,
		NULL AS Detail15,
		NULL AS Detail16,
		NULL AS Detail17,
		NULL AS Detail18,
		u1.due_date AS Detail19,
		u1.currency AS Detail20,
		u1.last_modified_date
FROM
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		last_modified_date,
		related_warehouse,
		related_division,
		currency,
		exchange_rate_of_currency,
		SUM(item_quantity) AS item_quantity,
		province,
		reminder_day_dt,
		reminder_day_flg,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		newsletter,
		user_cum_transactions,
		related_webshop,
		trx_marketing_channel,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		wear_days,
		covered_days_over_dt
FROM (SELECT * FROM BASE_08_TABLE WHERE origin = 'invoices' ORDER BY created DESC) r
GROUP BY erp_invoice_id
) u1
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u1.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u1.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON u1.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON u1.reference_id = d.hivszam
WHERE LENGTH(u1.buyer_email) > 3
AND buyer_email <> 'undefined'

UNION

SELECT 	DISTINCT 
		'Purchase' AS `Type`,
		u1.buyer_email,
		u1.revenues_wdisc_in_base_currency AS `Value`,
		NULL AS Description,
		u1.num_of_items AS Product,
		CONCAT(p.pickup_zip_code,', ',p.pickup_city,', ',u1.province,', ',p.shipping_country_standardized) AS Location,
		DATE(u1.created) AS Date,
		TIME(u1.created) AS Time,
		'Transactions' AS Detail1,
		u1.`gross_margin_wdisc_%` AS Detail2,
		u1.gross_margin_wdisc_in_base_currency AS Detail3,
		u1.`net_margin_wdisc_%` AS Detail4,
		u1.net_margin_wdisc_in_base_currency AS Detail5,
		u1.origin AS Detail6,
		CASE 	WHEN u1.related_division = 'Optika - HU' THEN 'Hungary'
				WHEN u1.related_division = 'Optika - IT' THEN 'Italy'
				WHEN u1.related_division = 'Optika - UK' THEN 'United Kingdom'
				WHEN u1.related_division = 'Optika - RO' THEN 'Romania'
				WHEN u1.related_division = 'Optika - SK' THEN 'Slovakia'
				ELSE 'N/A'
		END AS Detail7,
		u1.related_webshop AS Detail8,
		u1.user_cum_transactions AS Detail9,
		u1.newsletter AS Detail10,
		/*reminder_date*/
		covered_days_over_dt AS Detail11,
		u1.trx_marketing_channel AS Detail12,
		NULL AS Detail13,
		NULL AS Detail14,
		NULL AS Detail15,
		NULL AS Detail16,
		NULL AS Detail17,
		NULL AS Detail18,
		u1.due_date AS Detail19,
		u1.currency AS Detail20,
		u1.last_modified_date
FROM
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		last_modified_date,
		related_warehouse,
		related_division,
		currency,
		exchange_rate_of_currency,
		SUM(item_quantity) AS item_quantity,
		province,
		reminder_day_dt,
		reminder_day_flg,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		newsletter,
		user_cum_transactions,
		related_webshop,
		trx_marketing_channel,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		wear_days,
		covered_days_over_dt
FROM (SELECT * FROM BASE_08_TABLE WHERE origin = 'orders' ORDER BY created DESC) r
GROUP BY erp_invoice_id
) u1
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u1.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u1.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON u1.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON u1.reference_id = d.hivszam
WHERE LENGTH(u1.buyer_email) > 3
AND buyer_email <> 'undefined'
;

ALTER TABLE `SM_EVENT_PURCHASE` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_EVENT_PURCHASE` ADD UNIQUE( `buyer_email`, `Value`, `Product`, `Detail3`, `Detail4`, `Detail7`, `Detail8`, `Detail11`, `last_modified_date`);


DROP TABLE IF EXISTS SM_EVENT;
CREATE TABLE SM_EVENT
SELECT *
FROM SM_EVENT_PURCHASE
    UNION
SELECT * 
FROM SM_EVENT_OTHER
;

ALTER TABLE `SM_EVENT` DROP `id`;
ALTER TABLE `SM_EVENT` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_EVENT` ADD `is_deleted` BOOLEAN DEFAULT 0;

ALTER TABLE `SM_EVENT` ADD UNIQUE( `buyer_email`, `Value`, `Product`, `Detail3`, `Detail4`, `Detail5`, `Detail6`, `Detail7`, `Detail8`, `Detail11`, `last_modified_date`);
