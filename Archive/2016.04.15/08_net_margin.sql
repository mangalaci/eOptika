
DROP TABLE IF EXISTS BASE_08_TABLE;
CREATE TABLE BASE_08_TABLE
SELECT 	a.*, 
		CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
		b.net_margin*(a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value) 
		ELSE 0 END AS net_margin_wodisc_in_base_currency,
		NULL AS net_margin_wdisc_in_base_currency,
		
		CASE WHEN item_quantity > 0 THEN
		(b.net_margin*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value)/(a.item_net_value_in_currency*a.exchange_rate_of_currency) 
		ELSE 0 END AS `net_margin_wodisc_%`,
		NULL AS `net_margin_wdisc_%`,
		
		CASE WHEN item_quantity > 0 THEN
		b.shipping_cost*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
		ELSE 0 END AS shipping_cost_in_base_currency,
		CASE WHEN item_quantity > 0 THEN
		b.packaging_cost*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
		ELSE 0 END AS packaging_cost_in_base_currency,
		CASE WHEN item_quantity > 0 THEN
		b.payment_fee*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
		ELSE 0 END AS payment_cost_in_base_currency,
		
		a.item_net_value_in_currency*a.exchange_rate_of_currency AS item_revenue_in_base_currency,
		a.item_vat_value_in_currency*a.exchange_rate_of_currency AS item_vat_in_base_currency,
		a.item_gross_value_in_currency*a.exchange_rate_of_currency AS item_gross_revenue_in_base_currency,
		
		(a.gross_margin_wodisc_in_base_currency - a.gross_margin_wdisc_in_base_currency) AS discount_amount_in_base_currency
FROM 
(
SELECT 	m.*, n.order_value
FROM BASE_07_TABLE m LEFT JOIN
(
SELECT erp_id, SUM(item_net_value_in_currency*exchange_rate_of_currency) AS order_value
FROM BASE_07_TABLE 
WHERE item_quantity > 0 /*ahol storno van, oda csak a pozitív rendelési értékre osztunk logisztikai költséget*/
GROUP BY erp_id
) n
ON m.erp_id = n.erp_id
) a 
LEFT JOIN net_margin b
ON a.erp_id = b.order_id
;




ALTER TABLE BASE_08_TABLE CHANGE `sql_id` `item_id` INT(10) COMMENT 'Unique ID given by the KPI system to each item';
ALTER TABLE BASE_08_TABLE CHANGE `erp_id` `erp_invoice_id` VARCHAR(255) COMMENT 'Order number given by the ERP system automatically. First 2 characters:
SO - Hungary
SI - Italy
SR - Romania
SS - Slovakia
Follow by the year (11, 12, 13, etc)';
ALTER TABLE BASE_08_TABLE CHANGE `reference_id` `reference_id` VARCHAR(255) COMMENT 'Order number coming from the webstore automatically or in case of manual entry it is a free text cell. This goes through on all the tables.';
ALTER TABLE BASE_08_TABLE CHANGE `created` `created` DATETIME COMMENT 'Date of entry creation. Hour and minute set to zero';
ALTER TABLE BASE_08_TABLE CHANGE `fulfillment_date` `fulfillment_date` DATETIME COMMENT 'Fulfillment date from invoice';
ALTER TABLE BASE_08_TABLE CHANGE `due_date` `due_date` DATETIME COMMENT '(Payment) Due date from invoice';
ALTER TABLE BASE_08_TABLE CHANGE `payment_method` `payment_method` VARCHAR(255) COMMENT 'Payment method (values: Bankkártya, Kupon, Készpénz, Online fizetés, Paypal, Utánvét, Átutalás)';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_method` `shipping_method` VARCHAR(100) COMMENT 'Method of shipping: GLS, GPSe, MPL, Pick-Pack, Sprinter, Személyes átvétel, TOF';
ALTER TABLE BASE_08_TABLE CHANGE `our_bank_account_number` `our_bank_account_number` VARCHAR(255) COMMENT 'eOptika"s bank account number from invoice (HUF and EUR CIB accounts, and SK, RO accounts)';
ALTER TABLE BASE_08_TABLE CHANGE `related_division` `related_division` VARCHAR(255) COMMENT 'Which business division generated the order:
eOptika - HU, RO, IT, SK';
ALTER TABLE BASE_08_TABLE CHANGE `related_email` `buyer_email` VARCHAR(255) COMMENT 'Email address for buyer';
ALTER TABLE BASE_08_TABLE CHANGE `billing_name` `billing_name` VARCHAR(255) COMMENT 'Billing info for user and other user data';
ALTER TABLE BASE_08_TABLE CHANGE `billing_country` `billing_country` VARCHAR(100) COMMENT 'Billing info for user';
ALTER TABLE BASE_08_TABLE CHANGE `billing_zip_code` `billing_zip_code` VARCHAR(20) COMMENT 'Billing info for user';
ALTER TABLE BASE_08_TABLE CHANGE `billing_city` `billing_city` VARCHAR(50) COMMENT 'Billing info for user';
ALTER TABLE BASE_08_TABLE CHANGE `billing_address` `billing_address` VARCHAR(255) COMMENT 'Billing info for user';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_name` `shipping_name` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_country` `shipping_country` VARCHAR(100) COMMENT 'Shipping info';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_zip_code` `shipping_zip_code` VARCHAR(20) COMMENT 'Shipping info';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_city` `shipping_city` VARCHAR(50) COMMENT 'Shipping info';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_address` `shipping_address` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_08_TABLE CHANGE `shipping_phone` `shipping_phone` VARCHAR(20) COMMENT 'Shipping info';

ALTER TABLE BASE_08_TABLE CHANGE `related_webshop` `related_webshop` VARCHAR(20) COMMENT 'Webshop the order coming from: LenteContatto.it, b2b, eMAG.hu, eOptika.hu, lealkudtuk.hu, napszemuvegcenter.hu, napszemuvegplaza.hu, netoptika.ro, netoptika.sk, policenapszemuveg.hu, vatera.hu. Not every item has a value.';
ALTER TABLE BASE_08_TABLE CHANGE `currency` `currency` VARCHAR(3) COMMENT 'Currency of the order (EUR, HUF, RON)';
ALTER TABLE BASE_08_TABLE CHANGE `exchange_rate_of_currency` `exchange_rate_of_currency` FLOAT COMMENT 'Exchange rate - Hungarian Central Bank mid-rate.';
ALTER TABLE BASE_08_TABLE CHANGE `related_comment` `related_comment` VARCHAR(255) COMMENT 'Comment written on the invoice - free text column, not useful';
ALTER TABLE BASE_08_TABLE CHANGE `related_warehouse` `related_warehouse` VARCHAR(255) COMMENT 'Warehouse the item coming from (values: Anyagok - Teréz körút, Eszközök - Teréz körút, Baross utca, Teréz körút, Táblás utca)';
ALTER TABLE BASE_08_TABLE CHANGE `item_type` `item_type` VARCHAR(2) COMMENT 'T - Termék (Product), S - Szolgáltatás (Service)';
ALTER TABLE BASE_08_TABLE CHANGE `item_comment` `item_comment` VARCHAR(255) COMMENT 'Free text column for comments - manual and automamtic entries as well.';
ALTER TABLE BASE_08_TABLE CHANGE `item_vat_rate` `item_vat_rate` FLOAT COMMENT 'VAT - country dependent';
ALTER TABLE BASE_08_TABLE CHANGE `item_net_purchase_price_in_base_currency` `item_net_purchase_price_in_base_currency` FLOAT COMMENT 'Net purchase price in HUF - FIFO method.';
ALTER TABLE BASE_08_TABLE CHANGE `item_net_sale_price_in_currency` `item_net_sale_price_in_currency` FLOAT COMMENT 'Net sale price - in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `item_gross_sale_price_in_currency` `item_gross_sale_price_in_currency` FLOAT COMMENT 'Gross sale price - in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `item_net_sale_price_in_base_currency` `item_net_sale_price_in_base_currency` FLOAT COMMENT 'Item net price in HUF';
ALTER TABLE BASE_08_TABLE CHANGE `item_gross_sale_price_in_base_currency` `item_gross_sale_price_in_base_currency` FLOAT COMMENT 'Item gross price in HUF';
ALTER TABLE BASE_08_TABLE CHANGE `item_quantity` `item_quantity` INT(10) COMMENT 'Quantity';
ALTER TABLE BASE_08_TABLE CHANGE `unit_of_quantity_hun` `unit_of_quantity_hun` VARCHAR(20) COMMENT 'Unit HU';
ALTER TABLE BASE_08_TABLE CHANGE `unit_of_quantity_eng` `unit_of_quantity_eng` VARCHAR(20) COMMENT 'Unit EN';
ALTER TABLE BASE_08_TABLE CHANGE `item_net_value_in_currency` `item_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Net Price - in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `item_vat_value_in_currency` `item_vat_value_in_local_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `item_gross_value_in_currency` `item_gross_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Gross Price - in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `item_revenue_in_base_currency` `item_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Net Price - in base currency' AFTER item_gross_revenue_in_local_currency;
ALTER TABLE BASE_08_TABLE CHANGE `item_vat_in_base_currency` `item_vat_in_base_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in base currency' AFTER item_revenue_in_base_currency;
ALTER TABLE BASE_08_TABLE CHANGE `item_gross_revenue_in_base_currency` `item_gross_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Gross Price - in HUF' AFTER item_vat_in_base_currency;

ALTER TABLE BASE_08_TABLE CHANGE `item_weight_in_kg` `item_weight_in_kg` FLOAT COMMENT 'Weight of the item * Quantity';
ALTER TABLE BASE_08_TABLE CHANGE `connected_order_erp_id` `connected_order_erp_id` VARCHAR(20) COMMENT 'Refers to "incoming_orders" table "erp_id" column.';
ALTER TABLE BASE_08_TABLE CHANGE `connected_delivery_note_erp_id` `connected_delivery_note_erp_id` VARCHAR(20) COMMENT 'Refers to "delivery_notes" table "erp_id" column.';
ALTER TABLE BASE_08_TABLE CHANGE `item_is_canceled` `item_is_canceled` FLOAT COMMENT '"Yes" if order/item is deleted.';
ALTER TABLE BASE_08_TABLE CHANGE `cancelled_bill_erp_id` `ERP_cancelled_invoice_ID` FLOAT COMMENT 'In case of cancelled order, the invoice number (erp_id) of the original order. Or the cancellation note ID in case of the original cancelled invoice.';
ALTER TABLE BASE_08_TABLE CHANGE `cancellation_comment` `cancellation_comment` FLOAT COMMENT 'Comment about cancellation - free text';
ALTER TABLE BASE_08_TABLE CHANGE `is_canceled` `is_canceled` FLOAT COMMENT '"Yes" if order/item is canceled. Melyikre kell szurni? Értékek: Yes, No, Élő, Storno';
ALTER TABLE BASE_08_TABLE CHANGE `processed` `last_modified_date` FLOAT COMMENT 'Last date something happened with the item (or anything with same erp_id)';
ALTER TABLE BASE_08_TABLE CHANGE `user` `last_modified_by` FLOAT COMMENT 'User who created or last modified the item.';
ALTER TABLE BASE_08_TABLE CHANGE `related_email_clean` `related_email_clean` VARCHAR(100) COMMENT 'Megtisztitott email cim';
ALTER TABLE BASE_08_TABLE CHANGE `user_type` `user_type` VARCHAR(20) COMMENT 'Vevo-kategorizalas (B2C, B2B, B2B2C, Egeszsegpenztar)';
ALTER TABLE BASE_08_TABLE CHANGE `reminder_day` `reminder_day` DATE COMMENT 'Az a nap, amikor az emlékeztetőt kapta';

ALTER TABLE BASE_08_TABLE CHANGE `CT1_SKU` `CT1_SKU` VARCHAR(50) COMMENT 'SKU / SKU - Termektorzsbol SKU kod, elso szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `CT1_SKU_name` `CT1_SKU_name` VARCHAR(100) COMMENT 'Termektorzsbol SKU neve, elso szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `CT2_pack` `CT2_pack` VARCHAR(100) COMMENT 'Kiszereles / Pack - masodik szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `CT3_product` `CT3_product` VARCHAR(100) COMMENT 'Termek / Product - harmadik szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `CT4_product_brand` `CT4_product_brand` VARCHAR(100) COMMENT 'Termekmarka / Product brand - negyedik szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `CT5_manufacturer` `CT5_manufacturer` VARCHAR(100) COMMENT 'Gyarto / Manufacturer - Gyarto neve, otodik szintu kategorizalas';
ALTER TABLE BASE_08_TABLE CHANGE `product_group` `product_group` VARCHAR(100) COMMENT 'Lehetseges ertekek: Lencse, Folyadek, Szemcsepp, Egyebek, Napszemuveg, Szemuveg, Szallitasi dij';
ALTER TABLE BASE_08_TABLE CHANGE `lens_type` `lens_type` VARCHAR(100) COMMENT 'Lehetseges ertekek: Szferikus, Torikus, BiFokalis, Multifokalis, Ures. Torikusba betenni azokat, amik tobb kategoriaba is kerulhetnek. Progressziv lencsek a multifokalis kategoriakba keruljenek';
ALTER TABLE BASE_08_TABLE CHANGE `is_color` `is_color` VARCHAR(10) COMMENT 'Színes-e a lencse?';
ALTER TABLE BASE_08_TABLE CHANGE `wear_days` `wear_days` VARCHAR(20) COMMENT 'Mennyi ideig használható a csomag?';

ALTER TABLE BASE_08_TABLE CHANGE `user_id` `user_id` INT(10) COMMENT 'Egyedi ügyfél azonosító' AFTER reference_id;


ALTER TABLE BASE_08_TABLE CHANGE `revenues_wdisc_in_local_currency` `revenues_wdisc_in_local_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in local currency';
ALTER TABLE BASE_08_TABLE CHANGE `revenues_wdisc_in_base_currency` `revenues_wdisc_in_base_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in base currency';
ALTER TABLE BASE_08_TABLE CHANGE `gross_margin_wodisc_in_base_currency` `gross_margin_wodisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (eredeti)';
ALTER TABLE BASE_08_TABLE CHANGE `gross_margin_wdisc_in_base_currency` `gross_margin_wdisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (modositott)';
ALTER TABLE BASE_08_TABLE CHANGE `gross_margin_wodisc_%` `gross_margin_wodisc_%` FLOAT COMMENT 'Gross margin % (eredeti)';
ALTER TABLE BASE_08_TABLE CHANGE `gross_margin_wdisc_%` `gross_margin_wdisc_%` FLOAT COMMENT 'Gross margin % (modositott)';
ALTER TABLE BASE_08_TABLE CHANGE `cohort_id` `cohort_id` VARCHAR(10) COMMENT 'Cohort ID (ev, honap)';
ALTER TABLE BASE_08_TABLE CHANGE `invoice_year` `invoice_year` INT(4) COMMENT 'Year of invoicing (number)';
ALTER TABLE BASE_08_TABLE CHANGE `invoice_month` `invoice_month` INT(2) COMMENT 'Month of invoicing (1 to 12, number)';
ALTER TABLE BASE_08_TABLE CHANGE `invoice_day_in_month` `invoice_day_in_month` INT(2) COMMENT 'Calendar day of invoicing (1 to 31, number)';
ALTER TABLE BASE_08_TABLE CHANGE `invoice_hour` `invoice_hour` TIME COMMENT 'Hour of invoicing ( 1 to 24, number, rounded down)';


ALTER TABLE BASE_08_TABLE CHANGE `order_year` `order_year` INT(4) COMMENT 'Year of order received (number)';
ALTER TABLE BASE_08_TABLE CHANGE `order_month` `order_month` INT(2) COMMENT 'Month of order received (1 to 12, number)';
ALTER TABLE BASE_08_TABLE CHANGE `order_day_in_month` `order_day_in_month` INT(2) COMMENT 'Calendar day of order received (1 to 31, number)';
ALTER TABLE BASE_08_TABLE CHANGE `order_hour` `order_hour` TIME COMMENT 'Hour of order received ( 1 to 24, number, rounded down)';
ALTER TABLE BASE_08_TABLE CHANGE `order_weekday` `order_weekday` INT(1) COMMENT 'Weekday code of order received (1 to 7, number)';
ALTER TABLE BASE_08_TABLE CHANGE `order_week_in_month` `order_week_in_month` INT(1) COMMENT 'Monthly week code of order received (1 to 5, number)';


ALTER TABLE BASE_08_TABLE CHANGE `cohort_month_since` `cohort_month_since` INT(6) COMMENT 'Hanyadik honapban tortent a tranzakcio a user elso vasarlasa ota (amikor bekerult a cohortba)';
ALTER TABLE BASE_08_TABLE CHANGE `user_cum_transactions` `user_cum_transactions` FLOAT COMMENT 'User hanyadik tranzakcioja';
ALTER TABLE BASE_08_TABLE CHANGE `user_cum_gross_revenue_in_base_currency` `user_cum_gross_revenue_in_base_currency` FLOAT COMMENT 'User kumulativ AFA-s arbevetele eddig';
ALTER TABLE BASE_08_TABLE CHANGE `first_marketing_channel` `first_marketing_channel` VARCHAR(100) COMMENT 'Marketing csatorna: melyik marketing csatornan jott be az ügyfél';
ALTER TABLE BASE_08_TABLE CHANGE `trx_marketing_channel` `trx_marketing_channel` VARCHAR(100) COMMENT 'Marketing csatorna: melyik marketing csatornan jott be a megrendeles';

ALTER TABLE BASE_08_TABLE CHANGE `net_margin_wodisc_in_base_currency` `net_margin_wodisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency (eredeti) Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_08_TABLE CHANGE `net_margin_wdisc_in_base_currency` `net_margin_wdisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency  (modositott)  Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_08_TABLE CHANGE `net_margin_wodisc_%` `net_margin_wodisc_%` FLOAT COMMENT 'Net margin % (eredeti)';
ALTER TABLE BASE_08_TABLE CHANGE `net_margin_wdisc_%` `net_margin_wdisc_%` FLOAT COMMENT 'Net margin % (modositott)';


ALTER TABLE BASE_08_TABLE CHANGE `shipping_cost_in_base_currency` `shipping_cost_in_base_currency` FLOAT COMMENT 'Shipping cost in base currency';
ALTER TABLE BASE_08_TABLE CHANGE `payment_cost_in_base_currency` `payment_cost_in_base_currency` FLOAT COMMENT 'Payment cost in base currency';
ALTER TABLE BASE_08_TABLE CHANGE `packaging_cost_in_base_currency` `packaging_cost_in_base_currency` FLOAT COMMENT 'Packaging cost in base currency';


ALTER TABLE BASE_08_TABLE CHANGE `barcode` `barcode` VARCHAR(100) COMMENT 'Barcode, From Adam"s "items" table';
ALTER TABLE BASE_08_TABLE CHANGE `goods_nomenclature_code` `goods_nomenclature_code` VARCHAR(20) COMMENT 'Customs Tariff Number - CTN, From Adam"s "items" table';
ALTER TABLE BASE_08_TABLE CHANGE `packaging` `packaging` VARCHAR(50) COMMENT 'Unit name of the item (tekercs, karton, etc), From Adam"s "items" table';
ALTER TABLE BASE_08_TABLE CHANGE `quantity_in_a_pack` `quantity_in_a_pack` DOUBLE COMMENT 'How many item is in a pack., From Adam"s "items" table';
ALTER TABLE BASE_08_TABLE CHANGE `estimated_supplier_lead_time` `estimated_supplier_lead_time` VARCHAR(50) COMMENT 'Estimated time of delivery, From Adam"s "items" table';
ALTER TABLE BASE_08_TABLE CHANGE `qty_per_storageunit` `qty_per_storageunit` INT(6) COMMENT 'How many boxes fits a storage unit, From Adam"s "item_groups" table';
ALTER TABLE BASE_08_TABLE CHANGE `box_width` `box_width` INT(6) COMMENT 'Box width, From Adam"s "item_groups" table';
ALTER TABLE BASE_08_TABLE CHANGE `box_height` `box_height` INT(6) COMMENT 'Box height, From Adam"s "item_groups" table';
ALTER TABLE BASE_08_TABLE CHANGE `box_depth` `box_depth` INT(6) COMMENT 'Box depth, From Adam"s "item_groups" table';


ALTER TABLE BASE_08_TABLE CHANGE `packaging_deadline` `packaging_deadline` DATETIME COMMENT 'Fulfilment deadline - as a default it is the same date when we recieve the order. Can be owerwritten by customer service dept if the customer ask to deliver it later on (or after) a specific date., From Adam"s "incoming_order" table';
ALTER TABLE BASE_08_TABLE CHANGE `related_webshop` `related_webshop` VARCHAR(50) COMMENT 'Webshop the order coming from: LenteContatto.it, b2b, eMAG.hu, eOptika.hu, lealkudtuk.hu, napszemuvegcenter.hu, napszemuvegplaza.hu, netoptika.ro, netoptika.sk, policenapszemuveg.hu, vatera.hu. Not every item has a value., From Adam"s "incoming_order" table';

ALTER TABLE BASE_08_TABLE CHANGE `billing_country_standardized` `billing_country_standardized` VARCHAR(100) COMMENT 'English name of country of billing address' AFTER billing_country;
ALTER TABLE BASE_08_TABLE CHANGE `shipping_country_standardized` `shipping_country_standardized` VARCHAR(100) COMMENT 'English name of country of shipment destination' AFTER shipping_country;



ALTER TABLE BASE_08_TABLE ADD PRIMARY KEY (`item_id`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_08_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;

