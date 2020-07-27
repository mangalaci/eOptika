DROP TABLE IF EXISTS SM_TAG_PURCHASE;
CREATE TABLE IF NOT EXISTS SM_TAG_PURCHASE

SELECT 	buyer_email,
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
		CASE 	WHEN r.product_group  = 'Contact lenses' THEN 'Products:contact_lens_trx'
		END AS Tag16,		
		CASE 	WHEN r.product_group  = 'Contact lens cleaners' THEN 'Products:solution_trx'
		END AS Tag17,
		CASE 	WHEN r.product_group  = 'Eye drops' THEN 'Products:eye_drops_trx'
		END AS Tag18,
		CASE 	WHEN r.product_group  = 'Sunglasses' THEN 'Products:sunglass_trx'
		END AS Tag19,
		CASE 	WHEN r.product_group  = 'Vitamins' THEN 'Products:vitamin_trx'
		END AS Tag20,
		CASE 	WHEN r.product_group  = 'Glasses' THEN 'Products:glasses_trx'
		END AS Tag21,
			CASE 	WHEN r.product_group  = 'Eye check' THEN 'Products:eye_check_trx'
		END AS Tag22,
			CASE 	WHEN r.product_group  = 'Other product' THEN 'Products:other_product_trx'
		END AS Tag23
		
FROM BASE_08_TABLE r
WHERE buyer_email IN ('virag_nemes@freemail.hu', 'bius203@freemail.hu', 'balazskab@gmail.com', 'davidfun@freemail.h')
GROUP BY erp_invoice_id
;

ALTER TABLE `SM_TAG_PURCHASE` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



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
		CONCAT('CohortID:',r.cohort_id) AS Tag11
		
		
FROM (SELECT * FROM BASE_08_TABLE ORDER BY created DESC) r
WHERE buyer_email IN ('virag_nemes@freemail.hu', 'bius203@freemail.hu', 'balazskab@gmail.com', 'davidfun@freemail.h')
GROUP BY buyer_email
;

ALTER TABLE `SM_TAG_USER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE `SM_TAG_USER` CHANGE `erp_invoice_id` `erp_invoice_id` VARCHAR(255);




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
;

ALTER TABLE `SM_TAG_02` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



DROP TABLE IF EXISTS SM_TAG;
CREATE TABLE IF NOT EXISTS SM_TAG
SELECT * 
FROM `SM_TAG_02`
WHERE Tag IS NOT NULL 
ORDER BY buyer_email, erp_invoice_id
;



