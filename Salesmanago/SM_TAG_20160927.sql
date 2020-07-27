/*ALTER TABLE SM_TAG_PURCHASE ADD `lastUpdated` TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;*/

DROP TABLE IF EXISTS SM_TAG_PURCHASE;
CREATE TABLE IF NOT EXISTS SM_TAG_PURCHASE
SELECT 	DISTINCT
		buyer_email,
		erp_invoice_id,
		'External event' AS Entity,
		'Purchase' AS Type,		
		CASE 	WHEN r.origin = 'invoices' THEN 'Order:Completed' ELSE 'Order:Cancelled' END AS Tag1,
		CASE 	WHEN r.related_division = 'Optika - HU' THEN 'Division:Hungary'
				WHEN r.related_division = 'Optika - IT' THEN 'Division:Italy'
				WHEN r.related_division = 'Optika - UK' THEN 'Division:United Kingdom'
				WHEN r.related_division = 'Optika - RO' THEN 'Division:Romania'
				WHEN r.related_division = 'Optika - SK' THEN 'Division:Slovakia'
				ELSE 'Division:N/A'
		END AS Tag2,
		CONCAT('CountryBill:',r.billing_country_standardized) AS Tag3,
		CONCAT('CountryShip:',r.shipping_country_standardized) AS Tag4,
		CONCAT('Province:',r.province) AS Tag5,
		CONCAT('Webshop:',r.related_webshop) AS Tag6,
		CONCAT('Shipping:',r.shipping_method) AS Tag7,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('Payment:',r.payment_method) 
				ELSE 'Payment:N/A'
		END AS Tag8,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceYM:',r.invoice_yearmonth)
				ELSE 'InvoiceYM:N/A'
		END AS Tag9,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceM:',r.invoice_month)
				ELSE 'InvoiceM:N/A'
		END AS Tag10,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceY:',r.invoice_year)
				ELSE 'InvoiceY:N/A'
		END AS Tag11,
		CASE 	WHEN r.order_year IS NULL THEN 'OrderY:N/A'
				ELSE CONCAT('OrderY:',r.order_year) 
		END AS Tag12,
		CASE 	WHEN r.order_day_in_month IS NULL THEN 'OrderD:N/A'
				ELSE CONCAT('OrderD:',r.order_day_in_month) 
		END AS Tag13,
		CASE 	WHEN r.trx_marketing_channel IS NULL THEN 'MarketingChannel:N/A'
				ELSE CONCAT('MarketingChannel:',r.trx_marketing_channel)
		END AS Tag14,
		CASE 	WHEN r.num_of_purch IS NULL THEN 'CumTransactions:N/A'
				ELSE CONCAT('CumTransactions:',r.num_of_purch)
		END AS Tag15,
		CASE 	WHEN r.contact_lens_trx  = 1 THEN 'Products:contact_lens_trx'
		END AS Tag16,
		CASE 	WHEN r.solution_trx  = 1 THEN 'Products:solution_trx'
		END AS Tag17,		
		CASE 	WHEN r.eye_drops_trx  = 1 THEN 'Products:eye_drops_trx'
		END AS Tag18,		
		CASE 	WHEN r.sunglass_trx  = 1 THEN 'Products:sunglass_trx'
		END AS Tag19,		
		CASE 	WHEN r.vitamin_trx  = 1 THEN 'Products:vitamin_trx'
		END AS Tag20,	
		CASE 	WHEN r.frames_trx  = 1 THEN 'Products:frames_trx'
		END AS Tag21,	
		CASE 	WHEN r.glass_lenses_trx  = 1 THEN 'Products:glass_lenses_trx'
		END AS Tag22,
		CASE 	WHEN r.other_product_trx  = 1 THEN 'Products:other_product_trx'
		END AS Tag23,
		last_modified_date
FROM AGGR_ORDER r
LIMIT 0
;


ALTER TABLE `SM_TAG_PURCHASE` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Entity` (`Entity`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Type` (`Type`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag1` (`Tag1`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag2` (`Tag2`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag3` (`Tag3`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag4` (`Tag4`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag5` (`Tag5`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag6` (`Tag6`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag7` (`Tag7`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag8` (`Tag8`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag9` (`Tag9`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag10` (`Tag10`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag11` (`Tag11`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag12` (`Tag12`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag13` (`Tag13`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag14` (`Tag14`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag15` (`Tag15`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag16` (`Tag16`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag17` (`Tag17`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag18` (`Tag18`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag19` (`Tag19`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag20` (`Tag20`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag21` (`Tag21`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag22` (`Tag22`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `Tag23` (`Tag23`) USING BTREE;
ALTER TABLE `SM_TAG_PURCHASE` ADD INDEX `last_modified_date` (`last_modified_date`) USING BTREE;



INSERT INTO SM_TAG_PURCHASE
SELECT 	DISTINCT
		NULL AS id,
		buyer_email,
		erp_invoice_id,
		'External event' AS Entity,
		'Purchase' AS Type,		
		CASE 	WHEN r.origin = 'invoices' THEN 'Order:Completed' ELSE 'Order:Cancelled' END AS Tag1,
		CASE 	WHEN r.related_division = 'Optika - HU' THEN 'Division:Hungary'
				WHEN r.related_division = 'Optika - IT' THEN 'Division:Italy'
				WHEN r.related_division = 'Optika - UK' THEN 'Division:United Kingdom'
				WHEN r.related_division = 'Optika - RO' THEN 'Division:Romania'
				WHEN r.related_division = 'Optika - SK' THEN 'Division:Slovakia'
				ELSE 'Division:N/A'
		END AS Tag2,
		CONCAT('CountryBill:',r.billing_country_standardized) AS Tag3,
		CONCAT('CountryShip:',r.shipping_country_standardized) AS Tag4,
		CONCAT('Province:',r.province) AS Tag5,
		CONCAT('Webshop:',r.related_webshop) AS Tag6,
		CONCAT('Shipping:',r.shipping_method) AS Tag7,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('Payment:',r.payment_method) 
				ELSE 'Payment:N/A'
		END AS Tag8,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceYM:',r.invoice_yearmonth)
				ELSE 'InvoiceYM:N/A'
		END AS Tag9,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceM:',r.invoice_month)
				ELSE 'InvoiceM:N/A'
		END AS Tag10,
		CASE 	WHEN r.origin = 'invoices' THEN CONCAT('InvoiceY:',r.invoice_year)
				ELSE 'InvoiceY:N/A'
		END AS Tag11,
		CASE 	WHEN r.order_year IS NULL THEN 'OrderY:N/A'
				ELSE CONCAT('OrderY:',r.order_year) 
		END AS Tag12,
		CASE 	WHEN r.order_day_in_month IS NULL THEN 'OrderD:N/A'
				ELSE CONCAT('OrderD:',r.order_day_in_month) 
		END AS Tag13,
		CASE 	WHEN r.trx_marketing_channel IS NULL THEN 'MarketingChannel:N/A'
				ELSE CONCAT('MarketingChannel:',r.trx_marketing_channel)
		END AS Tag14,
		CASE 	WHEN r.num_of_purch IS NULL THEN 'CumTransactions:N/A'
				ELSE CONCAT('CumTransactions:',r.num_of_purch)
		END AS Tag15,
		CASE 	WHEN r.contact_lens_trx  = 1 THEN 'Products:contact_lens_trx'
		END AS Tag16,
		CASE 	WHEN r.solution_trx  = 1 THEN 'Products:solution_trx'
		END AS Tag17,		
		CASE 	WHEN r.eye_drops_trx  = 1 THEN 'Products:eye_drops_trx'
		END AS Tag18,		
		CASE 	WHEN r.sunglass_trx  = 1 THEN 'Products:sunglass_trx'
		END AS Tag19,		
		CASE 	WHEN r.vitamin_trx  = 1 THEN 'Products:vitamin_trx'
		END AS Tag20,	
		CASE 	WHEN r.frames_trx  = 1 THEN 'Products:frames_trx'
		END AS Tag21,	
		CASE 	WHEN r.glass_lenses_trx  = 1 THEN 'Products:glass_lenses_trx'
		END AS Tag22,
		CASE 	WHEN r.other_product_trx  = 1 THEN 'Products:other_product_trx'
		END AS Tag23,
		last_modified_date
FROM AGGR_ORDER r
WHERE LENGTH(buyer_email) > 3
;



DROP TABLE IF EXISTS SM_TAG_USER;
CREATE TABLE IF NOT EXISTS SM_TAG_USER
SELECT 	buyer_email,
		NULL AS erp_invoice_id,
		'User' AS Entity,
		'User' AS Type,
		CONCAT('CountryBill:',r.billing_country_standardized) AS Tag1,
		CONCAT('Province:',r.province) AS Tag2,
		'Phone:Mobile' AS Tag3,
		'Formality:Formal' AS Tag4,
		CASE 	WHEN r.related_division = 'Optika - HU' THEN 'Division:Hungary'
				WHEN r.related_division = 'Optika - IT' THEN 'Division:Italy'
				WHEN r.related_division = 'Optika - UK' THEN 'Division:United Kingdom'
				WHEN r.related_division = 'Optika - RO' THEN 'Division:Romania'
				WHEN r.related_division = 'Optika - SK' THEN 'Division:Slovakia'
				ELSE 'Division:N/A'
		END AS Tag5,
		CONCAT('CountryShip:',r.shipping_country_standardized) AS Tag6,
		CONCAT('Webshop:',r.related_webshop) AS Tag7,
		CONCAT('UserType:',r.user_type) AS Tag8,
		CONCAT('Gender:',r.gender) AS Tag9,
		CONCAT('Newsletter:',r.newsletter) AS Tag10,
		CONCAT('CohortID:',r.cohort_id) AS Tag11,
		CASE 	WHEN r.contact_lens_user  = 1 THEN 'Products:contact_lens_user'
		END AS Tag12,
		CASE 	WHEN r.solution_user  = 1 THEN 'Products:solution_user'
		END AS Tag13,
		CASE 	WHEN r.eye_drops_user  = 1 THEN 'Products:eye_drops_user'
		END AS Tag14,
		CASE 	WHEN r.sunglass_user  = 1 THEN 'Products:sunglass_user'
		END AS Tag15,
		CASE 	WHEN r.vitamin_user  = 1 THEN 'Products:vitamin_user'
		END AS Tag16,
		CASE 	WHEN r.frames_user  = 1 THEN 'Products:frames_user'
		END AS Tag17,
		CASE 	WHEN r.glass_lenses_user  = 1 THEN 'Products:glass_lenses_user'
		END AS Tag18,
		CASE 	WHEN r.other_product_user  = 1 THEN 'Products:other_product_user'
		END AS Tag19,
		'Language:' AS Tag20,
		'PrefChannel:' AS Tag21,
		'User:Alias' AS Tag22,
		'User:Deactivate'  AS Tag23,
		last_modified_date
FROM AGGR_USER r
WHERE LENGTH(buyer_email) > 3
LIMIT 0
;


ALTER TABLE `SM_TAG_USER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_TAG_USER` CHANGE `erp_invoice_id` `erp_invoice_id` VARCHAR(255);
ALTER TABLE `SM_TAG_USER` ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Entity` (`Entity`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Type` (`Type`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag1` (`Tag1`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag2` (`Tag2`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag3` (`Tag3`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag4` (`Tag4`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag5` (`Tag5`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag6` (`Tag6`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag7` (`Tag7`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag8` (`Tag8`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag9` (`Tag9`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag10` (`Tag10`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag11` (`Tag11`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag12` (`Tag12`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag13` (`Tag13`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag14` (`Tag14`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag15` (`Tag15`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag16` (`Tag16`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag17` (`Tag17`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag18` (`Tag18`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag19` (`Tag19`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag20` (`Tag20`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag21` (`Tag21`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag22` (`Tag22`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `Tag23` (`Tag23`) USING BTREE;
ALTER TABLE `SM_TAG_USER` ADD INDEX `last_modified_date` (`last_modified_date`) USING BTREE;




INSERT INTO SM_TAG_USER
SELECT 	NULL AS id,
		buyer_email,
		NULL AS erp_invoice_id,
		'User' AS Entity,
		'User' AS Type,
		CONCAT('CountryBill:',r.billing_country_standardized) AS Tag1,
		CONCAT('Province:',r.province) AS Tag2,
		'Phone:Mobile' AS Tag3,
		'Formality:Formal' AS Tag4,
		CASE 	WHEN r.related_division = 'Optika - HU' THEN 'Division:Hungary'
				WHEN r.related_division = 'Optika - IT' THEN 'Division:Italy'
				WHEN r.related_division = 'Optika - UK' THEN 'Division:United Kingdom'
				WHEN r.related_division = 'Optika - RO' THEN 'Division:Romania'
				WHEN r.related_division = 'Optika - SK' THEN 'Division:Slovakia'
				ELSE 'Division:N/A'
		END AS Tag5,
		CONCAT('CountryShip:',r.shipping_country_standardized) AS Tag6,
		CONCAT('Webshop:',r.related_webshop) AS Tag7,
		CONCAT('UserType:',r.user_type) AS Tag8,
		CONCAT('Gender:',r.gender) AS Tag9,
		CONCAT('Newsletter:',r.newsletter) AS Tag10,
		CONCAT('CohortID:',r.cohort_id) AS Tag11,
		CASE 	WHEN r.contact_lens_user  = 1 THEN 'Products:contact_lens_user'
		END AS Tag12,
		CASE 	WHEN r.solution_user  = 1 THEN 'Products:solution_user'
		END AS Tag13,
		CASE 	WHEN r.eye_drops_user  = 1 THEN 'Products:eye_drops_user'
		END AS Tag14,
		CASE 	WHEN r.sunglass_user  = 1 THEN 'Products:sunglass_user'
		END AS Tag15,
		CASE 	WHEN r.vitamin_user  = 1 THEN 'Products:vitamin_user'
		END AS Tag16,
		CASE 	WHEN r.frames_user  = 1 THEN 'Products:frames_user'
		END AS Tag17,
		CASE 	WHEN r.glass_lenses_user  = 1 THEN 'Products:glass_lenses_user'
		END AS Tag18,
		CASE 	WHEN r.other_product_user  = 1 THEN 'Products:other_product_user'
		END AS Tag19,
		'Language:' AS Tag20,
		'PrefChannel:' AS Tag21,
		'User:Alias' AS Tag22,
		'User:Deactivate'  AS Tag23,
		last_modified_date
FROM AGGR_USER r
WHERE LENGTH(buyer_email) > 3
;


DROP TABLE IF EXISTS SM_TAG_OTHER;
CREATE TABLE IF NOT EXISTS SM_TAG_OTHER
SELECT 	buyer_email,
		erp_invoice_id,
		'External event' AS Entity,
		'Other' AS Type,
		'Event:Item_sold' AS Tag1,
		CONCAT('CT1_SKU:',r.CT1_SKU) AS Tag2,
		CONCAT('CT1_SKU_name:',r.CT1_SKU_name) AS Tag3,
		CONCAT('CT2_pack:',r.CT2_pack) AS Tag4,
		CONCAT('CT3_product:',r.CT3_product) AS Tag5,
		CONCAT('CT3_product_short:',r.CT3_product_short) AS Tag6,
		CONCAT('CT4_product_brand:',r.CT4_product_brand) AS Tag7,
		CONCAT('CT5_manufacturer:',r.CT5_manufacturer) AS Tag8,
		CASE 	WHEN r.lens_bc IS NOT NULL THEN CONCAT('lens_bc:',r.lens_bc)
		END AS Tag9,
		CASE 	WHEN r.lens_pwr IS NOT NULL THEN CONCAT('lens_pwr:',r.lens_pwr)
		END AS Tag10,
		CASE 	WHEN r.lens_cyl IS NOT NULL THEN CONCAT('lens_cyl:',r.lens_cyl)
		END AS Tag11,	
		CASE 	WHEN r.lens_ax IS NOT NULL THEN CONCAT('lens_ax:',r.lens_ax)
		END AS Tag12,
		CASE 	WHEN r.lens_dia IS NOT NULL THEN CONCAT('lens_dia:',r.lens_dia)
		END AS Tag13,
		CASE 	WHEN r.lens_add IS NOT NULL THEN CONCAT('lens_add:',r.lens_add)
		END AS Tag14,
		CASE 	WHEN r.lens_clr IS NOT NULL THEN CONCAT('lens_clr:',r.lens_clr) 
		END AS Tag15,
		CASE 	WHEN r.pack_size IS NOT NULL THEN CONCAT('package_size:',r.pack_size)
		END AS Tag16,
		CASE 	WHEN r.package_unit IS NOT NULL THEN CONCAT('package_type:',r.package_unit)
		END AS Tag17,
		CASE 	WHEN r.origin = 'invoices' THEN 'Order:Completed' ELSE 'Order:Cancelled' END AS Tag18,
		CONCAT('product_group:',r.product_group) AS Tag19,
		CONCAT('lens_type:',r.lens_type) AS Tag20,
		CONCAT('is_color:',r.is_color) AS Tag21,
		CONCAT('wear_duration:',r.wear_duration) AS Tag22,
		CONCAT('wear_days:',r.wear_days) AS Tag23,
		CONCAT('item_type:',r.item_type) AS Tag24,
		last_modified_date
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
WHERE LENGTH(buyer_email) > 3
LIMIT 0
;

ALTER TABLE `SM_TAG_OTHER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Entity` (`Entity`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Type` (`Type`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag1` (`Tag1`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag2` (`Tag2`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag3` (`Tag3`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag4` (`Tag4`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag5` (`Tag5`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag6` (`Tag6`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag7` (`Tag7`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag8` (`Tag8`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag9` (`Tag9`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag10` (`Tag10`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag11` (`Tag11`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag12` (`Tag12`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag13` (`Tag13`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag14` (`Tag14`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag15` (`Tag15`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag16` (`Tag16`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag17` (`Tag17`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag18` (`Tag18`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag19` (`Tag19`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag20` (`Tag20`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag21` (`Tag21`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag22` (`Tag22`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag23` (`Tag23`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `Tag24` (`Tag24`) USING BTREE;
ALTER TABLE `SM_TAG_OTHER` ADD INDEX `last_modified_date` (`last_modified_date`) USING BTREE;


INSERT INTO SM_TAG_OTHER
SELECT 	NULL AS id,
		buyer_email,
		erp_invoice_id,
		'External event' AS Entity,
		'Other' AS Type,
		'Event:Item_sold' AS Tag1,
		CONCAT('CT1_SKU:',r.CT1_SKU) AS Tag2,
		CONCAT('CT1_SKU_name:',r.CT1_SKU_name) AS Tag3,
		CONCAT('CT2_pack:',r.CT2_pack) AS Tag4,
		CONCAT('CT3_product:',r.CT3_product) AS Tag5,
		CONCAT('CT3_product_short:',r.CT3_product_short) AS Tag6,
		CONCAT('CT4_product_brand:',r.CT4_product_brand) AS Tag7,
		CONCAT('CT5_manufacturer:',r.CT5_manufacturer) AS Tag8,
		CASE 	WHEN r.lens_bc IS NOT NULL THEN CONCAT('lens_bc:',r.lens_bc)
		END AS Tag9,
		CASE 	WHEN r.lens_pwr IS NOT NULL THEN CONCAT('lens_pwr:',r.lens_pwr)
		END AS Tag10,
		CASE 	WHEN r.lens_cyl IS NOT NULL THEN CONCAT('lens_cyl:',r.lens_cyl)
		END AS Tag11,	
		CASE 	WHEN r.lens_ax IS NOT NULL THEN CONCAT('lens_ax:',r.lens_ax)
		END AS Tag12,
		CASE 	WHEN r.lens_dia IS NOT NULL THEN CONCAT('lens_dia:',r.lens_dia)
		END AS Tag13,
		CASE 	WHEN r.lens_add IS NOT NULL THEN CONCAT('lens_add:',r.lens_add)
		END AS Tag14,
		CASE 	WHEN r.lens_clr IS NOT NULL THEN CONCAT('lens_clr:',r.lens_clr) 
		END AS Tag15,
		CASE 	WHEN r.pack_size IS NOT NULL THEN CONCAT('package_size:',r.pack_size)
		END AS Tag16,
		CASE 	WHEN r.package_unit IS NOT NULL THEN CONCAT('package_type:',r.package_unit)
		END AS Tag17,
		CASE 	WHEN r.origin = 'invoices' THEN 'Order:Completed' ELSE 'Order:Cancelled' END AS Tag18,
		CONCAT('product_group:',r.product_group) AS Tag19,
		CONCAT('lens_type:',r.lens_type) AS Tag20,
		CONCAT('is_color:',r.is_color) AS Tag21,
		CONCAT('wear_duration:',r.wear_duration) AS Tag22,
		CONCAT('wear_days:',r.wear_days) AS Tag23,
		CONCAT('item_type:',r.item_type) AS Tag24,
		last_modified_date
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
WHERE LENGTH(buyer_email) > 3
;




DROP TABLE IF EXISTS SM_TAG;
CREATE TABLE IF NOT EXISTS SM_TAG
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag, last_modified_date
FROM SM_TAG_PURCHASE
LIMIT 0;


ALTER TABLE SM_TAG ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE SM_TAG ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE SM_TAG ADD INDEX `Entity` (`Entity`) USING BTREE;
ALTER TABLE SM_TAG ADD INDEX `Type` (`Type`) USING BTREE;
ALTER TABLE SM_TAG ADD INDEX `Tag` (`Tag`) USING BTREE;
ALTER TABLE SM_TAG ADD INDEX `last_modified_date` (`last_modified_date`) USING BTREE;
ALTER TABLE SM_TAG ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE SM_TAG ADD `is_deleted` BOOLEAN DEFAULT 0;


INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag1 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag2 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag3 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag4 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag5 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag6 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag7 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag8 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag9 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag10 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag11 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag12 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag13 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag14 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag15 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag16 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag17 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag18 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag19 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag20 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag21 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag22 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_PURCHASE WHERE Tag23 IS NOT NULL;

INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag1 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag2 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag3 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag4 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag5 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag6 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag7 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag8 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag9 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag10 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag11 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag12 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag13 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag14 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag15 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag16 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag17 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag18 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag19 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag20 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag21 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag22 IS NOT NULL;
INSERT INTO SM_TAG	
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_USER WHERE Tag23 IS NOT NULL;

INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag1 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag2 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag3 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag4 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag5 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag6 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag7 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag8 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag9 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag10 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag11 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag12 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag13 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag14 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag15 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag16 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag17 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag18 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag19 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag20 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag21 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag22 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag23 IS NOT NULL;
INSERT INTO SM_TAG
SELECT DISTINCT NULL AS id, buyer_email, erp_invoice_id, Entity, Type, Tag24 AS Tag, last_modified_date, 0 AS is_deleted FROM SM_TAG_OTHER WHERE Tag24 IS NOT NULL;
;


ALTER TABLE `SM_TAG` ADD UNIQUE( `buyer_email`, `Tag`, `last_modified_date`, `is_deleted`);