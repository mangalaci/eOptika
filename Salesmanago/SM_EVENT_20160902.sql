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
		b.CT1_SKU AS Detail7,
		b.CT1_SKU_name AS Detail8,
		b.CT2_pack AS Detail9,
		b.CT3_product AS Detail10,
		b.CT3_product_short AS Detail11,
		b.CT4_product_brand AS Detail12,
		b.CT5_manufacturer AS Detail13,
		b.lens_bc AS Detail14,
		b.lens_pwr AS Detail15,
		b.lens_cyl AS Detail16,
		b.lens_ax AS Detail17,
		b.lens_dia AS Detail18,
		b.lens_add AS Detail19,
		b.lens_clr AS Detail20
FROM BASE_08_TABLE b
LEFT JOIN
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		billing_country_standardized,
		billing_zip_code,
		billing_city,
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
		full_name,
		salutation,
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
		CASE WHEN origin = 'invoices' THEN invoice_yearmonth ELSE NULL END AS invoice_yearmonth,
		CASE WHEN origin = 'invoices' THEN invoice_year ELSE NULL END AS invoice_year,
		CASE WHEN origin = 'invoices' THEN invoice_month ELSE NULL END AS invoice_month,
		CASE WHEN origin = 'invoices' THEN invoice_day_in_month ELSE NULL END AS invoice_day_in_month,
		CASE WHEN origin = 'invoices' THEN invoice_hour ELSE NULL END AS invoice_hour,
		cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		NULL AS order_date_and_time,
		CASE WHEN origin = 'orders' THEN order_year ELSE NULL END AS order_year,
		CASE WHEN origin = 'orders' THEN order_month ELSE NULL END AS order_month,
		CASE WHEN origin = 'orders' THEN order_day_in_month ELSE NULL END AS order_day_in_month,
		CASE WHEN origin = 'orders' THEN order_weekday ELSE NULL END AS order_weekday,
		CASE WHEN origin = 'orders' THEN order_week_in_month ELSE NULL END AS order_week_in_month,
		packaging_deadline,
		related_webshop,
		trx_marketing_channel,
		num_of_purch,
		trx_rank,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(SUM(net_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `net_margin_wodisc_%`,
		ROUND(SUM(net_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `net_margin_wdisc_%`,
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
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS other_product_trx
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
GROUP BY item_id
) u
ON b.erp_invoice_id = u.erp_invoice_id
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON b.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON b.reference_id = d.hivszam
WHERE b.buyer_email IN ('frouzka@gmail.com', 'bor.sandor@t-online.hu', 'ellaizabella@freemail.hu')
;

ALTER TABLE `SM_EVENT_OTHER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


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
		user_cum_transactions AS Detail9,
		u1.newsletter AS Detail10,
		/*reminder_date*/
		CASE 	WHEN d.atvdat IS NOT NULL THEN DATE_ADD(d.atvdat,INTERVAL b.wear_days + 12 DAY)
				ELSE  IF(t.courier_status_key = 13, DATE_ADD(t.courier_date,INTERVAL b.wear_days + 12 DAY),IF(t.courier_status_key = 18,DATE_ADD(t.courier_date,INTERVAL b.wear_days + 12 DAY),'9999-12-31'))
		END AS Detail11,
		u1.trx_marketing_channel AS Detail12,
		NULL AS Detail13,
		NULL AS Detail14,
		NULL AS Detail15,
		NULL AS Detail16,
		NULL AS Detail17,
		NULL AS Detail18,
		u1.due_date AS Detail19,
		u1.currency AS Detail20
FROM BASE_08_TABLE b
LEFT JOIN
(
SELECT 	origin,
		buyer_email,
		erp_invoice_id,
		reference_id,
		COUNT(item_id) AS num_of_items,
		user_id,
		created,
		due_date,
		billing_country_standardized,
		billing_zip_code,
		billing_city,
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
		full_name,
		salutation,
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
		CASE WHEN origin = 'invoices' THEN invoice_yearmonth ELSE NULL END AS invoice_yearmonth,
		CASE WHEN origin = 'invoices' THEN invoice_year ELSE NULL END AS invoice_year,
		CASE WHEN origin = 'invoices' THEN invoice_month ELSE NULL END AS invoice_month,
		CASE WHEN origin = 'invoices' THEN invoice_day_in_month ELSE NULL END AS invoice_day_in_month,
		CASE WHEN origin = 'invoices' THEN invoice_hour ELSE NULL END AS invoice_hour,
		cohort_month_since,
		
		user_cum_gross_revenue_in_base_currency,
		NULL AS order_date_and_time,
		CASE WHEN origin = 'orders' THEN order_year ELSE NULL END AS order_year,
		CASE WHEN origin = 'orders' THEN order_month ELSE NULL END AS order_month,
		CASE WHEN origin = 'orders' THEN order_day_in_month ELSE NULL END AS order_day_in_month,
		CASE WHEN origin = 'orders' THEN order_weekday ELSE NULL END AS order_weekday,
		CASE WHEN origin = 'orders' THEN order_week_in_month ELSE NULL END AS order_week_in_month,
		packaging_deadline,
		related_webshop,
		trx_marketing_channel,
		num_of_purch,
		trx_rank,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(SUM(net_margin_wodisc_in_base_currency)/SUM(item_revenue_in_base_currency),2) AS `net_margin_wodisc_%`,
		ROUND(SUM(net_margin_wdisc_in_base_currency)/SUM(revenues_wdisc_in_base_currency),2) AS `net_margin_wdisc_%`,
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
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS other_product_trx
FROM 
(SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
GROUP BY erp_invoice_id
) u1
ON b.erp_invoice_id = u1.erp_invoice_id
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u1.user_id = r.user_id
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u1.user_id = p.user_id
LEFT JOIN sm_tracking_data t
ON b.erp_invoice_id = t.reference_id
LEFT JOIN pickup_dates d
ON b.reference_id = d.hivszam
WHERE b.buyer_email IN ('frouzka@gmail.com', 'bor.sandor@t-online.hu', 'ellaizabella@freemail.hu')
;

ALTER TABLE `SM_EVENT_PURCHASE` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


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

