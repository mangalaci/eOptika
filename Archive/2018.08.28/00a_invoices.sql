﻿/*error correction */

UPDATE outgoing_bills SET related_division = 'Optika - IT' WHERE related_webshop = 'LenteContatto.it';
UPDATE outgoing_bills SET related_division = 'Optika - RO' WHERE related_webshop = 'netOptica.ro';
UPDATE outgoing_bills SET item_sku = 'AOA_MIRR' WHERE item_sku = 'AO_MIRR';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'GPSe' AND shipping_country = 'HUN';
UPDATE outgoing_bills SET shipping_method = 'GLS' WHERE shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'Személyes átvétel';
UPDATE outgoing_bills SET related_division = 'Optika - HU' WHERE related_division = 'Egyebek';

UPDATE outgoing_bills SET shipping_name = 'Nagy Petra', billing_name = 'Nagy Petra' WHERE related_email = 'petranagy19@gmail.com';




UPDATE outgoing_bills o
LEFT JOIN IN_net_purchase_price_correction p
ON o.erp_id = p.erp_id AND o.item_sku = p.sku
SET o.item_net_purchase_price_in_base_currency = p.item_net_purchase_price_in_base_currency
WHERE p.item_net_purchase_price_in_base_currency IS NOT NULL
;

UPDATE outgoing_bills o
LEFT JOIN IN_exchange_rate_correction x
ON o.erp_id = x.erp_id
SET o.exchange_rate_of_currency = x.exchange_rate_of_currency
WHERE x.erp_id IS NOT NULL
;

UPDATE outgoing_bills o
LEFT JOIN IN_email_correction e
ON o.related_email = e.old_email
SET o.related_email = e.new_email
WHERE e.old_email IS NOT NULL
;


ALTER TABLE outgoing_bills ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `billing_name` (`billing_name`) USING BTREE;

ALTER TABLE outgoing_bills DROP our_bank_account_number;


DROP TABLE IF EXISTS INVOICES_00;
CREATE TABLE IF NOT EXISTS INVOICES_00 LIKE outgoing_bills;
ALTER TABLE INVOICES_00 ADD user_type VARCHAR(17) NOT NULL;
ALTER TABLE INVOICES_00 ADD related_email_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_phone_aux VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_flg VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_flg VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_trim_wo_pickup VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_trim_wo_pickup VARCHAR(100);
ALTER TABLE INVOICES_00 ADD health_insurance VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_real VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_pickup VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_business VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_real VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_pickup VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_business VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_city_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_country_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_city_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_country_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_city_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD real_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD real_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_country VARCHAR(100);

ALTER TABLE INVOICES_00 ADD business_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD business_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD business_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_country VARCHAR(100);

ALTER TABLE INVOICES_00 ADD pickup_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD pickup_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD pickup_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_country VARCHAR(100);

ALTER TABLE INVOICES_00 ADD catchment_area VARCHAR(30);
ALTER TABLE INVOICES_00 ADD shipping_phone_clean VARCHAR(100);




ALTER TABLE INVOICES_00 ADD full_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD first_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD last_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD gender VARCHAR(20);
ALTER TABLE INVOICES_00 ADD salutation VARCHAR(64);
ALTER TABLE INVOICES_00 ADD lens_material VARCHAR(100);
ALTER TABLE INVOICES_00 ADD product_introduction_dt DATE;

ALTER TABLE INVOICES_00 ADD CT1_SKU VARCHAR(100);
ALTER TABLE INVOICES_00 ADD CT1_SKU_name VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT2_pack VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT3_product VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT3_product_short VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT4_product_brand VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT5_manufacturer VARCHAR(255);
ALTER TABLE INVOICES_00 ADD group_id INT(6);
ALTER TABLE INVOICES_00 ADD barcode VARCHAR(255);
ALTER TABLE INVOICES_00 ADD goods_nomenclature_code INT(10);
ALTER TABLE INVOICES_00 ADD packaging VARCHAR(255);
ALTER TABLE INVOICES_00 ADD quantity_in_a_pack INT(5);
ALTER TABLE INVOICES_00 ADD estimated_supplier_lead_time INT(10);
ALTER TABLE INVOICES_00 ADD net_weight_in_kg FLOAT(13,6);
ALTER TABLE INVOICES_00 ADD CT2_sku VARCHAR(100);
ALTER TABLE INVOICES_00 ADD lens_bc DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_pwr DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_cyl DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_ax DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_dia DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_add VARCHAR(10);
ALTER TABLE INVOICES_00 ADD lens_clr VARCHAR(10);
ALTER TABLE INVOICES_00 ADD product_group VARCHAR(255);
ALTER TABLE INVOICES_00 ADD lens_type VARCHAR(32);
ALTER TABLE INVOICES_00 ADD is_color INT(1);
ALTER TABLE INVOICES_00 ADD wear_days INT(10);
ALTER TABLE INVOICES_00 ADD wear_duration VARCHAR(100);
ALTER TABLE INVOICES_00 ADD qty_per_storage_unit INT(1);
ALTER TABLE INVOICES_00 ADD box_width DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD box_height DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD box_depth DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD pack_size VARCHAR(10);
ALTER TABLE INVOICES_00 ADD package_unit VARCHAR(10);
ALTER TABLE INVOICES_00 ADD revenues_wdisc_in_local_currency FLOAT;
ALTER TABLE INVOICES_00 ADD revenues_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD gross_margin_wodisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD gross_margin_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD `gross_margin_wodisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD `gross_margin_wdisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD shipping_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD packaging_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD payment_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_revenue_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_vat_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_gross_revenue_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD net_invoiced_shipping_costs FLOAT;
ALTER TABLE INVOICES_00 ADD net_margin_wodisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD net_margin_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD `net_margin_wodisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD `net_margin_wdisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD coupon_code VARCHAR(100);
ALTER TABLE INVOICES_00 ADD trx_coupon_code VARCHAR(100);


INSERT INTO INVOICES_00
SELECT 
			o.*,
			MAX(CASE 		WHEN u.user_type = 'Private insurance' THEN 'Private insurance'
							WHEN u.user_type = 'B2B2C' THEN 'B2B2C'
							WHEN u.user_type = 'B2C' THEN 'B2C'
							WHEN u.user_type = 'B2B' THEN 'B2B'
							WHEN u.user_type IS NULL THEN 'B2C'		
							ELSE u.user_type
				END) AS user_type,
			TRIM('\r' FROM TRIM('\n' FROM TRIM('\t' FROM TRIM(REPLACE(REPLACE((
				CASE
				 WHEN related_email  LIKE '%freeemail.hu' THEN REPLACE(related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN related_email  LIKE '%gmai.com' THEN REPLACE(related_email, 'gmai.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmal.com' THEN REPLACE(related_email, 'gmal.com', 'gmail.com')				 
				 WHEN related_email  LIKE '%gamil.com' THEN REPLACE(related_email, 'gamil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gnail.com' THEN REPLACE(related_email, 'gnail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmaikl.com' THEN REPLACE(related_email, 'gmaikl.com', 'gmail.com')
				 WHEN related_email  LIKE '%mail.com' THEN REPLACE(related_email, 'g-mail.com', 'gmail.com')
				 WHEN related_email  LIKE '%g.mail.com' THEN REPLACE(related_email, 'g.mail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gail.com' THEN REPLACE(related_email, 'gail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmsil.com' THEN REPLACE(related_email, 'gmsil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmali.com' THEN REPLACE(related_email, 'gmali.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmil.com' THEN REPLACE(related_email, 'gmil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmai.hu' THEN REPLACE(related_email, 'gmai.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmal.hu' THEN REPLACE(related_email, 'gmal.hu', 'gmail.hu')				 
				 WHEN related_email  LIKE '%gamil.hu' THEN REPLACE(related_email, 'gamil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gnail.hu' THEN REPLACE(related_email, 'gnail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmaikl.hu' THEN REPLACE(related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%mail.hu' THEN REPLACE(related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%g.mail.hu' THEN REPLACE(related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gail.hu' THEN REPLACE(related_email, 'gail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmsil.hu' THEN REPLACE(related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmali.hu' THEN REPLACE(related_email, 'gmali.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmil.hu' THEN REPLACE(related_email, 'gmil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%cirtomail.com' THEN REPLACE(related_email, 'cirtomail.com', 'citromail.com')
				 WHEN related_email  LIKE '%undefined' THEN REPLACE(related_email, 'undefined', '')
				 WHEN related_email  = '#' THEN REPLACE(related_email, '#', '')
				 WHEN related_email  = 'Array' THEN REPLACE(related_email, 'Array', '')				 
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as related_email_clean,
		 
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') 
				AS shipping_phone_aux,
				
				NULL AS shipping_name_flg,
				NULL AS billing_name_flg,
				NULL AS shipping_name_trim,
				NULL AS billing_name_trim,
				NULL AS shipping_name_trim_wo_pickup,
				NULL AS billing_name_trim_wo_pickup,
				NULL AS health_insurance,
				NULL AS shipping_name_real,
				NULL AS shipping_name_pickup,
				NULL AS shipping_name_business,
				NULL AS billing_name_real,
				NULL AS billing_name_pickup,
				NULL AS billing_name_business,
				
				/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
				special_char_replace(billing_city) AS billing_city_clean,
				NULL AS shipping_city_standardized,
				NULL AS shipping_country_standardized,
				NULL AS billing_city_standardized,
				NULL AS billing_country_standardized,
				NULL AS real_name,
				NULL AS real_address,
				NULL AS real_zip_code,
				NULL AS real_country,
				NULL AS business_name,
				NULL AS business_address,
				NULL AS business_zip_code,
				NULL AS business_country,
				NULL AS pickup_name,
				NULL AS pickup_address,
				NULL AS pickup_zip_code,
				NULL AS pickup_country,
				NULL AS catchment_area,
				NULL AS shipping_phone_clean,
				NULL AS real_province,
				NULL AS real_city_size,
				NULL AS real_city,
				NULL AS business_province,
				NULL AS business_city_size,
				NULL AS business_city,
				NULL AS pickup_province,
				NULL AS pickup_city_size,
				NULL AS pickup_city,	
				NULL AS full_name,
				NULL AS first_name,
				NULL AS last_name,
				NULL AS gender,
				NULL AS salutation,
				NULL AS lens_material,
				NULL AS product_introduction_dt,
				NULL AS CT1_SKU,
				NULL AS CT1_SKU_name,
				NULL AS CT2_pack,
				NULL AS CT3_product,
				NULL AS CT3_product_short,
				NULL AS CT4_product_brand,
				NULL AS CT5_manufacturer,
				NULL AS group_idIndex,
				NULL AS barcode,
				NULL AS goods_nomenclature_code,
				NULL AS packaging,
				NULL AS quantity_in_a_pack,
				NULL AS estimated_supplier_lead_time,
				NULL AS net_weight_in_kg,
				NULL AS CT2_sku,
				NULL AS lens_bc,
				NULL AS lens_pwr,
				NULL AS lens_cyl,
				NULL AS lens_ax,
				NULL AS lens_dia,
				NULL AS lens_add,
				NULL AS lens_clr,
				NULL AS product_group,
				NULL AS lens_type,
				NULL AS is_color,
				NULL AS wear_days,
				NULL AS wear_duration,	
				NULL AS qty_per_storage_unit,
				NULL AS box_width,
				NULL AS box_height,
				NULL AS box_depth,
				NULL AS pack_size,
				NULL AS package_unit,
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS gross_margin_wodisc_in_base_currency,
				NULL AS gross_margin_wdisc_in_base_currency,
				NULL AS `gross_margin_wodisc_%`,
				NULL AS `gross_margin_wdisc_%`,
				NULL AS shipping_cost_in_base_currency,
				NULL AS packaging_cost_in_base_currency,
				NULL AS payment_cost_in_base_currency,
				NULL AS item_revenue_in_base_currency,
				NULL AS item_vat_in_base_currency,
				NULL AS item_gross_revenue_in_base_currency,
				NULL AS net_invoiced_shipping_costs,
				NULL AS net_margin_wodisc_in_base_currency,
				NULL AS net_margin_wdisc_in_base_currency,
				NULL AS `net_margin_wodisc_%`,
				NULL AS `net_margin_wdisc_%`,
				NULL AS coupon_code,
				NULL AS trx_coupon_code
				
FROM outgoing_bills o LEFT JOIN IN_user_type u
ON ((o.shipping_country = u.country)
AND LOWER(o.billing_name) LIKE CONCAT('%', u.search_string, '%') 
	OR LOWER(o.shipping_name) LIKE CONCAT('%', u.search_string, '%'))
WHERE	LOWER(o.is_canceled) in ('no', 'élő')
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	o.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
/*removing test user*/
AND o.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND o.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing Előleg records*/
AND o.item_name_hun NOT IN ('Előleg')
GROUP BY o.sql_id
;

ALTER TABLE INVOICES_00 ADD INDEX `created` (`created`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX `shipping_city` (`shipping_city`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX `billing_city` (`billing_city`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX `billing_country_standardized` (`billing_country_standardized`) USING BTREE;


/* el kell dönteni, hogy a vesszőt tartalmazó emailek 2 email címet választanak el, vagy a pontot írták el veszőre */
UPDATE INVOICES_00
SET
    related_email_clean = 
			CASE 
			WHEN LENGTH(related_email_clean) - LENGTH(REPLACE(related_email_clean, '@', '')) = 1 
			THEN REPLACE(related_email_clean, ',', '') 
			ELSE SUBSTR(related_email_clean,1,LOCATE(',', related_email_clean)-1)
		END
WHERE related_email_clean LIKE '%,%'
;

