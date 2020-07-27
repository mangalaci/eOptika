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
		END AS Tag23
FROM SM_EVENT r
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
		'User:Deactivate'  AS Tag23
FROM SM_USER r
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
		CONCAT('item_type:',r.item_type) AS Tag24
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
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


DROP TABLE IF EXISTS SM_TAG_02;
CREATE TABLE IF NOT EXISTS SM_TAG_02
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag FROM SM_TAG_PURCHASE
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag FROM SM_TAG_USER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag1 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag2 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag3 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag4 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag5 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag6 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag7 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag8 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag9 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag10 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag11 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag12 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag13 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag14 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag15 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag16 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag17 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag18 AS Tag FROM SM_TAG_OTHER
    UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag19 AS Tag FROM SM_TAG_OTHER
   UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag20 AS Tag FROM SM_TAG_OTHER
   UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag21 AS Tag FROM SM_TAG_OTHER
   UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag22 AS Tag FROM SM_TAG_OTHER
   UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag23 AS Tag FROM SM_TAG_OTHER
   UNION
SELECT buyer_email, erp_invoice_id, Entity, Type, Tag24 AS Tag FROM SM_TAG_OTHER
;

ALTER TABLE `SM_TAG_02` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



DROP TABLE IF EXISTS SM_TAG;
CREATE TABLE IF NOT EXISTS SM_TAG
SELECT * 
FROM `SM_TAG_02`
WHERE Tag IS NOT NULL 
ORDER BY buyer_email, erp_invoice_id, Entity, Type
;

ALTER TABLE `SM_TAG` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



