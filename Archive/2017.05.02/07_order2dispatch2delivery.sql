DROP TABLE IF EXISTS BASE_06_TABLE_aux;
CREATE TABLE BASE_06_TABLE_aux
SELECT 	DISTINCT
		erp_id,
		IF(pickup_name = '', real_name, pickup_name) AS pickup_name,
		gender,
		salutation
FROM BASE_06_TABLE
;

ALTER TABLE BASE_06_TABLE_aux ADD PRIMARY KEY (erp_id);
ALTER TABLE BASE_06_TABLE_aux ADD INDEX `pickup_name` (`pickup_name`) USING BTREE;
ALTER TABLE BASE_06_TABLE_aux ADD INDEX `gender` (`gender`) USING BTREE;
ALTER TABLE BASE_06_TABLE_aux ADD INDEX `salutation` (`salutation`) USING BTREE;



DROP TABLE IF EXISTS tracking_data_ini_01;
CREATE TABLE tracking_data_ini_01
SELECT 	 s.*, 
		c.track_id AS courier_track_id,
		c.date AS courier_date,
		c.status_key AS courier_status_key,
		c.status AS courier_status,
		c.package_location_name AS courier_package_location_name,
		w.domain AS webshop_domain,
		w.name AS webshop_name,
		p.unique_name_key AS partner_unique_name_key,
		p.courier_name AS partner_courier_name,
		p.telephone AS partner_telephone,
		p.courier_homepage AS partner_courier_homepage,
		p.courier_tracking_uri AS partner_courier_tracking_url,
		p.type AS partner_type,
		e.subject AS email_subject,
		e.msg AS email_msg,
		eq.track_id AS email_queue_track_id,
		eq.address AS email_queue_address,		
		eq.subject AS email_queue_subject,
		eq.msg AS email_queue_msg,
		eq.created AS email_queue_created,
		eq.sent AS email_queue_sent, 
		eq.is_sent AS email_queue_is_sent,
		m.state_status
FROM its_status_raw_data s
LEFT JOIN its_courier_status_raw_data c
ON s.id = c.track_id
LEFT JOIN its_webshops w
ON s.webshop_id = w.id
LEFT JOIN its_delivery_partners p
ON s.partner_id = p.id
LEFT JOIN its_emails e
ON (s.partner_id = e.partner_id AND s.webshop_id = e.webshop_id)
LEFT JOIN its_email_queue eq
ON s.id = eq.track_id
LEFT JOIN its_status_matching m
ON (p.id = m.partner_key AND c.status = m.courier_comment)
;

ALTER TABLE tracking_data_ini_01 ADD INDEX `id` (`id`) USING BTREE;
ALTER TABLE tracking_data_ini_01 ADD INDEX `parent_id` (`parent_id`) USING BTREE;

DROP TABLE IF EXISTS tracking_data_ini_02;
CREATE TABLE tracking_data_ini_02
SELECT 	 a.*, 
		b.pickup_name,
		b.gender,
		b.salutation
		FROM tracking_data_ini_01 a
LEFT JOIN BASE_06_TABLE_aux AS b
ON a.reference_id = b.erp_id
;

ALTER TABLE tracking_data_ini_02 ADD INDEX `id` (`id`) USING BTREE;
ALTER TABLE tracking_data_ini_02 ADD INDEX `parent_id` (`parent_id`) USING BTREE;
ALTER TABLE tracking_data_ini_02 ADD INDEX `courier_status_key` (`courier_status_key`) USING BTREE;

DROP TABLE IF EXISTS tracking_data_consolidator;
CREATE TABLE tracking_data_consolidator
SELECT DISTINCT b.id,
b.reference_id,
b.backup_reference_id,
b.webshop_id,
b.lang_code,
a.partner_id,
a.label_id,
a.type,
a.email,
a.destination_country_iso2,
a.destination_country_iso3,
b.parent_id,
a.created,
a.updated,
a.end_state,
a.courier_track_id,
a.courier_date,
a.courier_status_key,
a.courier_status,
a.courier_package_location_name,
b.webshop_domain,
b.webshop_name,
a.partner_unique_name_key,
a.partner_courier_name,
a.partner_telephone,
a.partner_courier_homepage,
a.partner_courier_tracking_url,
a.partner_type,
b.email_subject,
b.email_msg,
b.email_queue_track_id,
b.email_queue_address,
b.email_queue_subject,
b.email_queue_msg,
b.email_queue_created,
b.email_queue_sent,
b.email_queue_is_sent,
b.state_status,
b.pickup_name,
b.gender,
b.salutation
FROM `tracking_data_ini_02` a, `tracking_data_ini_02` b
WHERE a.id = b.parent_id
AND b.parent_id IS NOT NULL
ORDER by b.id, a.courier_status_key
;

ALTER TABLE tracking_data_consolidator ADD INDEX `id` (`id`) USING BTREE;
ALTER TABLE tracking_data_consolidator ADD INDEX `parent_id` (`parent_id`) USING BTREE;


DROP TABLE IF EXISTS sm_tracking_data;
CREATE TABLE sm_tracking_data
SELECT DISTINCT *
FROM tracking_data_ini_02
WHERE reference_id <> ''
UNION
SELECT DISTINCT *
FROM tracking_data_consolidator
;


ALTER TABLE sm_tracking_data ADD `new_id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`new_id`);
ALTER TABLE sm_tracking_data ADD INDEX `reference_id` (`reference_id`) USING BTREE;




/* state_status lehet delivered vagy returned */


-- 1. TIME ORDER TO DISPATCH
/*WEBSHOPOS rendelés kiszállítással*/
DROP TABLE IF EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_01;
CREATE TABLE IF NOT EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_01
SELECT sql_id, erp_id, shipping_method, related_division, payment_method, shipping_country, CT1_SKU, CT1_SKU_name, CT2_pack, processed, connected_order_erp_id
FROM BASE_06_TABLE
WHERE connected_order_erp_id <> ''
AND origin = 'invoices'
LIMIT 0
;

ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD PRIMARY KEY (sql_id);
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `connected_order_erp_id` (`connected_order_erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `CT1_SKU` (`CT1_SKU`) USING BTREE;


INSERT INTO TIME_ORDER_TO_DISPATCH_CARRIER_01
SELECT DISTINCT sql_id, erp_id, shipping_method, related_division, payment_method, shipping_country, CT1_SKU, CT1_SKU_name, CT2_pack, processed, connected_order_erp_id
FROM BASE_06_TABLE
WHERE connected_order_erp_id <> ''
AND origin = 'invoices'
;



DROP TABLE IF EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_02;
CREATE TABLE IF NOT EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_02
SELECT sql_id, erp_id, processed, item_sku
FROM incoming_orders
WHERE deletion_comment <> 'Automatikus törlés módosítás miatt'
AND item_type = 'T'
LIMIT 0
;

ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_02 ADD PRIMARY KEY (sql_id);
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_02 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_02 ADD INDEX `item_sku` (`item_sku`) USING BTREE;

INSERT INTO TIME_ORDER_TO_DISPATCH_CARRIER_02
SELECT DISTINCT	sql_id, erp_id, processed, item_sku
FROM incoming_orders
WHERE deletion_comment <> 'Automatikus törlés módosítás miatt'
AND item_type = 'T'
;


DROP TABLE IF EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_03;
CREATE TABLE IF NOT EXISTS TIME_ORDER_TO_DISPATCH_CARRIER_03
SELECT DISTINCT sz.sql_id,
				sz.erp_id,
				r.erp_id AS r_erp_id,
				sz.shipping_method,
				sz.related_division,
				r.processed AS rendeles_felvesz,
				sz.processed AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.processed) AS time_order_to_dispatch
FROM TIME_ORDER_TO_DISPATCH_CARRIER_01 AS sz
LEFT JOIN TIME_ORDER_TO_DISPATCH_CARRIER_02 AS r
ON (sz.connected_order_erp_id = r.erp_id AND sz.CT1_SKU = r.item_sku)
LIMIT 0
;

ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_03 ADD INDEX (sql_id);
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_03 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_03 ADD INDEX `r_erp_id` (`r_erp_id`) USING BTREE;


INSERT INTO TIME_ORDER_TO_DISPATCH_CARRIER_03
SELECT DISTINCT sz.sql_id,
				sz.erp_id,
				r.erp_id AS r_erp_id,
				sz.shipping_method,
				sz.related_division,
				r.processed AS rendeles_felvesz,
				sz.processed AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.processed) AS time_order_to_dispatch
FROM TIME_ORDER_TO_DISPATCH_CARRIER_01 AS sz
LEFT JOIN TIME_ORDER_TO_DISPATCH_CARRIER_02 AS r
ON (sz.connected_order_erp_id = r.erp_id AND sz.CT1_SKU = r.item_sku)
;


/*WEBSHOPOS rendelés személyes átvétellel*/
DROP TABLE IF EXISTS TIME_ORDER_TO_DISPATCH_PICKUP;
CREATE TABLE TIME_ORDER_TO_DISPATCH_PICKUP
SELECT * /* a külső SELECT azért kell, mert van pár számla, amihez több rendelés is tartozik */
FROM
(
SELECT DISTINCT sz.sql_id,
				sz.erp_id,
				r.erp_id AS r_erp_id,
				sz.shipping_method,
				sz.related_division,
				r.processed AS rendeles_felvesz,
				sz.processed AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.processed) AS time_order_to_dispatch
FROM BASE_06_TABLE AS sz
LEFT JOIN delivery_notes AS b 
ON ((sz.connected_delivery_note_erp_id = b.erp_id) AND (sz.CT1_SKU=b.item_sku))
LEFT JOIN incoming_orders AS r 
ON ((b.erp_id_of_order = r.erp_id) AND(b.item_sku=r.item_sku))
WHERE sz.connected_delivery_note_erp_id <> ''
) t
GROUP BY sql_id
ORDER BY r_erp_id
LIMIT 0
;

ALTER TABLE TIME_ORDER_TO_DISPATCH_PICKUP ADD PRIMARY KEY (sql_id);
ALTER TABLE TIME_ORDER_TO_DISPATCH_PICKUP ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_PICKUP ADD INDEX `r_erp_id` (`r_erp_id`) USING BTREE;


INSERT INTO TIME_ORDER_TO_DISPATCH_PICKUP
SELECT * /* a külső SELECT azért kell, mert van pár számla, amihez több rendelés is tartozik */
FROM
(
SELECT DISTINCT sz.sql_id,
				sz.erp_id,
				r.erp_id AS r_erp_id,
				sz.shipping_method,
				sz.related_division,
				r.processed AS rendeles_felvesz,
				sz.processed AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.processed) AS time_order_to_dispatch
FROM BASE_06_TABLE AS sz
LEFT JOIN delivery_notes AS b 
ON ((sz.connected_delivery_note_erp_id = b.erp_id) AND (sz.CT1_SKU=b.item_sku))
LEFT JOIN incoming_orders AS r 
ON ((b.erp_id_of_order = r.erp_id) AND(b.item_sku=r.item_sku))
WHERE sz.connected_delivery_note_erp_id <> ''
) t
GROUP BY sql_id
ORDER BY r_erp_id
;




DROP TABLE IF EXISTS TIME_ORDER_TO_DISPATCH;
CREATE TABLE TIME_ORDER_TO_DISPATCH
SELECT *
FROM TIME_ORDER_TO_DISPATCH_CARRIER_03
UNION 
SELECT *
FROM  TIME_ORDER_TO_DISPATCH_PICKUP
;



ALTER TABLE TIME_ORDER_TO_DISPATCH ADD INDEX `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH ADD INDEX `erp_id` (`erp_id`) USING BTREE;


/*
r.processed = azért kell a processed mezőt használni a created helyett, mert ha a rendelés nem a webről jött,
 hanem az ERP-ben képződött, akkor csak dátum található, óra-perc nem. 
 Mindig az eredeti rendeléstől kell számolni ebben az esetben, nem a módosított rendeléssel 
 (így kapunk teljes időt, ami a valóságot tükrözi).

 
*/

-- 2. TIME DISPATCH TO DELIVERY
DROP TABLE IF EXISTS tracking_stat;
SET @@group_concat_max_len = 5000000;
SET @sql = NULL;
SELECT
  GROUP_CONCAT(DISTINCT
    CONCAT(
      'MAX(IF(courier_status_key = ''',
      courier_status_key,
      ''', courier_date, NULL)) AS ''',
      courier_status_key,''''
    )
  ) INTO @sql
FROM
  sm_tracking_data
  WHERE end_state = 1;

SET @sql = CONCAT('CREATE TABLE tracking_stat SELECT reference_id, ', @sql, ' FROM sm_tracking_data WHERE end_state = 1 GROUP BY reference_id');

  PREPARE stmt FROM @sql;
  EXECUTE stmt;
;


DROP TABLE IF EXISTS tracking_stat_handling_time_dom_01;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_dom_01
SELECT   	reference_id,
			TIMESTAMPDIFF(MINUTE,`1`,`7`)/60 AS hour_diff_1_7,
			TIMESTAMPDIFF(MINUTE,`1`,`8`)/60 AS hour_diff_1_8,
			TIMESTAMPDIFF(MINUTE,`1`,`12`)/60 AS hour_diff_1_12,
			TIMESTAMPDIFF(MINUTE,`1`,`14`)/60 AS hour_diff_1_14,
			TIMESTAMPDIFF(MINUTE,`1`,`29`)/60 AS hour_diff_1_29,
			TIMESTAMPDIFF(MINUTE,`1`,`32`)/60 AS hour_diff_1_32,
			TIMESTAMPDIFF(MINUTE,`1`,`35`)/60 AS hour_diff_1_35,
			TIMESTAMPDIFF(MINUTE,`1`,`13`)/60 AS hour_diff_1_13
FROM `tracking_stat`
WHERE `1` IS NOT NULL
;

ALTER TABLE tracking_stat_handling_time_dom_01 ADD PRIMARY KEY (reference_id);




DROP TABLE IF EXISTS tracking_stat_handling_time_dom_02;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_dom_02
SELECT   	reference_id,
			hour_diff_1_7,
			COALESCE(hour_diff_1_8,hour_diff_1_7) AS hour_diff_1_8,
			COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7)) AS hour_diff_1_12,
			COALESCE(hour_diff_1_14,COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7))) AS hour_diff_1_14,
			COALESCE(hour_diff_1_29,COALESCE(hour_diff_1_14,COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7)))) AS hour_diff_1_29,
			COALESCE(hour_diff_1_32,COALESCE(hour_diff_1_29,COALESCE(hour_diff_1_14,COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7))))) AS hour_diff_1_32,
			COALESCE(hour_diff_1_35,COALESCE(hour_diff_1_32,COALESCE(hour_diff_1_29,COALESCE(hour_diff_1_14,COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7)))))) AS hour_diff_1_35,
			COALESCE(hour_diff_1_13,COALESCE(hour_diff_1_35,COALESCE(hour_diff_1_32,COALESCE(hour_diff_1_29,COALESCE(hour_diff_1_14,COALESCE(hour_diff_1_12,COALESCE(hour_diff_1_8,hour_diff_1_7))))))) AS hour_diff_1_13

FROM `tracking_stat_handling_time_dom_01`
;

ALTER TABLE tracking_stat_handling_time_dom_02 ADD PRIMARY KEY (reference_id);




DROP TABLE IF EXISTS tracking_stat_handling_time_dhl_01;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_dhl_01
SELECT   	reference_id,
			TIMESTAMPDIFF(MINUTE,`20`,`21`)/60 AS hour_diff_20_21,
			TIMESTAMPDIFF(MINUTE,`20`,`22`)/60 AS hour_diff_20_22,
			TIMESTAMPDIFF(MINUTE,`20`,`23`)/60 AS hour_diff_20_23,
			TIMESTAMPDIFF(MINUTE,`20`,`24`)/60 AS hour_diff_20_24,
			TIMESTAMPDIFF(MINUTE,`20`,`25`)/60 AS hour_diff_20_25,
			TIMESTAMPDIFF(MINUTE,`20`,`19`)/60 AS hour_diff_20_19,
            TIMESTAMPDIFF(MINUTE,`20`,`17`)/60 AS hour_diff_20_17,
            TIMESTAMPDIFF(MINUTE,`20`,`16`)/60 AS hour_diff_20_16,
            TIMESTAMPDIFF(MINUTE,`20`,`18`)/60 AS hour_diff_20_18       
FROM `tracking_stat`
WHERE `20` IS NOT NULL
;

ALTER TABLE tracking_stat_handling_time_dhl_01 ADD PRIMARY KEY (reference_id);

DROP TABLE IF EXISTS tracking_stat_handling_time_dhl_02;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_dhl_02
SELECT   	reference_id,
			hour_diff_20_21,
			COALESCE(hour_diff_20_22,hour_diff_20_21) AS hour_diff_20_22,
			COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21)) AS hour_diff_20_23,
			COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21))) AS hour_diff_20_24,
			COALESCE(hour_diff_20_25,COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21)))) AS hour_diff_20_25,
			COALESCE(hour_diff_20_19,COALESCE(hour_diff_20_25,COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21))))) AS hour_diff_20_19,
			COALESCE(hour_diff_20_17,COALESCE(hour_diff_20_19,COALESCE(hour_diff_20_25,COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21)))))) AS hour_diff_20_17,
			COALESCE(hour_diff_20_16,COALESCE(hour_diff_20_17,COALESCE(hour_diff_20_19,COALESCE(hour_diff_20_25,COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21))))))) AS hour_diff_20_16,
			COALESCE(hour_diff_20_18,COALESCE(hour_diff_20_16,COALESCE(hour_diff_20_17,COALESCE(hour_diff_20_19,COALESCE(hour_diff_20_25,COALESCE(hour_diff_20_24,COALESCE(hour_diff_20_23,COALESCE(hour_diff_20_22,hour_diff_20_21)))))))) AS hour_diff_20_18

FROM `tracking_stat_handling_time_dhl_01`
;

ALTER TABLE tracking_stat_handling_time_dhl_02 ADD PRIMARY KEY (reference_id);


DROP TABLE IF EXISTS tracking_stat_handling_time;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time
SELECT reference_id, hour_diff_1_13 AS time_dispatch_to_delivery
FROM tracking_stat_handling_time_dom_02
UNION
SELECT reference_id, hour_diff_20_18 AS time_dispatch_to_delivery 
FROM tracking_stat_handling_time_dhl_02
;

ALTER TABLE tracking_stat_handling_time ADD PRIMARY KEY (reference_id);



DROP TABLE IF EXISTS BASE_07_TABLE;
CREATE TABLE IF NOT EXISTS BASE_07_TABLE
SELECT  DISTINCT
		b.*,
		b.item_net_value_in_currency*b.exchange_rate_of_currency AS item_revenue_in_base_currency,
		b.item_vat_value_in_currency*b.exchange_rate_of_currency AS item_vat_in_base_currency,
		b.item_gross_value_in_currency*b.exchange_rate_of_currency AS item_gross_revenue_in_base_currency,
		d.time_order_to_dispatch,
		t.time_dispatch_to_delivery,
		CASE 	WHEN (b.reference_id REGEXP '^V[A-Z][1-9][0-9]/[0-9]{5,6}' OR b.reference_id = '') THEN 'offline'
				ELSE 'online' 
		END AS source_of_trx
FROM BASE_06_TABLE b
LEFT JOIN TIME_ORDER_TO_DISPATCH d
ON b.sql_id = d.sql_id
LEFT JOIN tracking_stat_handling_time t
ON b.erp_id = t.reference_id
;


ALTER TABLE BASE_07_TABLE CHANGE `reference_id` `reference_id` VARCHAR(255) COMMENT 'Order number coming from the webstore automatically or in case of manual entry it is a free text cell. This goes through on all the tables.';
ALTER TABLE BASE_07_TABLE CHANGE `created` `created` DATETIME COMMENT 'Date of entry creation. Hour and minute set to zero';
ALTER TABLE BASE_07_TABLE CHANGE `fulfillment_date` `fulfillment_date` DATETIME COMMENT 'Fulfillment date from invoice';
ALTER TABLE BASE_07_TABLE CHANGE `due_date` `due_date` DATETIME COMMENT '(Payment) Due date from invoice';
ALTER TABLE BASE_07_TABLE CHANGE `payment_method` `payment_method` VARCHAR(255) COMMENT 'Payment method (values: Bankkártya, Kupon, Készpénz, Online fizetés, Paypal, Utánvét, Átutalás)';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_method` `shipping_method` VARCHAR(100) COMMENT 'Method of shipping: GLS, GPSe, MPL, Pick-Pack, Sprinter, Személyes átvétel, TOF';
ALTER TABLE BASE_07_TABLE CHANGE `our_bank_account_number` `our_bank_account_number` VARCHAR(255) COMMENT 'eOptika bank account number from invoice (HUF and EUR CIB accounts, and SK, RO accounts)';
ALTER TABLE BASE_07_TABLE CHANGE `related_division` `related_division` VARCHAR(255) COMMENT 'Which business division generated the order: eOptika - HU, RO, IT, SK, UK';
ALTER TABLE BASE_07_TABLE CHANGE `billing_name` `billing_name` VARCHAR(255) COMMENT 'Billing info for user and other user data';
ALTER TABLE BASE_07_TABLE CHANGE `billing_country` `billing_country` VARCHAR(100) COMMENT 'Billing info for user';
ALTER TABLE BASE_07_TABLE CHANGE `billing_zip_code` `billing_zip_code` VARCHAR(20) COMMENT 'Billing info for user';
ALTER TABLE BASE_07_TABLE CHANGE `billing_city` `billing_city` VARCHAR(50) COMMENT 'Billing info for user';
ALTER TABLE BASE_07_TABLE CHANGE `billing_address` `billing_address` VARCHAR(255) COMMENT 'Billing info for user';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_name` `shipping_name` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_country` `shipping_country` VARCHAR(100) COMMENT 'Shipping info';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_zip_code` `shipping_zip_code` VARCHAR(20) COMMENT 'Shipping info';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_city` `shipping_city` VARCHAR(50) COMMENT 'Shipping info';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_address` `shipping_address` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_phone` `shipping_phone` VARCHAR(20) COMMENT 'Shipping info';

ALTER TABLE BASE_07_TABLE CHANGE `real_name` `personal_name` VARCHAR(255) COMMENT 'Personal name of user';
ALTER TABLE BASE_07_TABLE CHANGE `real_zip_code` `personal_zip_code` VARCHAR(20) COMMENT 'Zip code of place where user lives';
ALTER TABLE BASE_07_TABLE CHANGE `real_city` `personal_city` VARCHAR(50) COMMENT 'City where user lives';
ALTER TABLE BASE_07_TABLE CHANGE `real_address` `personal_address` VARCHAR(255) COMMENT 'Personal address';
ALTER TABLE BASE_07_TABLE CHANGE `real_province` `personal_province` VARCHAR(255) COMMENT 'Personal address';
ALTER TABLE BASE_07_TABLE CHANGE `real_city_size` `personal_city_size` VARCHAR(255) COMMENT 'Personal address';


ALTER TABLE BASE_07_TABLE CHANGE `related_webshop` `related_webshop` VARCHAR(50) COMMENT 'Webshop the order coming from: LenteContatto.it, b2b, eMAG.hu, eOptika.hu, lealkudtuk.hu, napszemuvegcenter.hu, napszemuvegplaza.hu, netoptika.ro, netoptika.sk, policenapszemuveg.hu, vatera.hu. Not every item has a value., From incoming_orders table';
ALTER TABLE BASE_07_TABLE CHANGE `currency` `currency` VARCHAR(3) COMMENT 'Currency of the order (EUR, HUF, RON)';
ALTER TABLE BASE_07_TABLE CHANGE `exchange_rate_of_currency` `exchange_rate_of_currency` FLOAT COMMENT 'Exchange rate - Hungarian Central Bank mid-rate.';
ALTER TABLE BASE_07_TABLE CHANGE `related_comment` `related_comment` VARCHAR(255) COMMENT 'Comment written on the invoice - free text column, not useful';
ALTER TABLE BASE_07_TABLE CHANGE `related_warehouse` `related_warehouse` VARCHAR(255) COMMENT 'Warehouse the item coming from (values: Anyagok - Teréz körút, Eszközök - Teréz körút, Baross utca, Teréz körút, Táblás utca)';
ALTER TABLE BASE_07_TABLE CHANGE `item_type` `item_type` VARCHAR(2) COMMENT 'T - Termék (Product), S - Szolgáltatás (Service)';
ALTER TABLE BASE_07_TABLE CHANGE `item_comment` `item_comment` VARCHAR(255) COMMENT 'Free text column for comments - manual and automamtic entries as well.';
ALTER TABLE BASE_07_TABLE CHANGE `item_vat_rate` `item_vat_rate` FLOAT COMMENT 'VAT - country dependent';
ALTER TABLE BASE_07_TABLE CHANGE `item_net_purchase_price_in_base_currency` `item_net_purchase_price_in_base_currency` FLOAT COMMENT 'Net purchase price in HUF - FIFO method.';
ALTER TABLE BASE_07_TABLE CHANGE `item_net_sale_price_in_currency` `item_net_sale_price_in_currency` FLOAT COMMENT 'Net sale price - in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `item_gross_sale_price_in_currency` `item_gross_sale_price_in_currency` FLOAT COMMENT 'Gross sale price - in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `item_net_sale_price_in_base_currency` `item_net_sale_price_in_base_currency` FLOAT COMMENT 'Item net price in HUF';
ALTER TABLE BASE_07_TABLE CHANGE `item_gross_sale_price_in_base_currency` `item_gross_sale_price_in_base_currency` FLOAT COMMENT 'Item gross price in HUF';
ALTER TABLE BASE_07_TABLE CHANGE `item_quantity` `item_quantity` INT(10) COMMENT 'Quantity';
ALTER TABLE BASE_07_TABLE CHANGE `unit_of_quantity_hun` `unit_of_quantity_hun` VARCHAR(20) COMMENT 'Unit HU';
ALTER TABLE BASE_07_TABLE CHANGE `unit_of_quantity_eng` `unit_of_quantity_eng` VARCHAR(20) COMMENT 'Unit EN';
ALTER TABLE BASE_07_TABLE CHANGE `item_weight_in_kg` `item_weight_in_kg` FLOAT COMMENT 'Weight of the item (from ITEMS table) * Quantity';
ALTER TABLE BASE_07_TABLE CHANGE `connected_order_erp_id` `connected_order_erp_id` VARCHAR(20) COMMENT 'Refers to incoming_orders table erp_idq column.';
ALTER TABLE BASE_07_TABLE CHANGE `connected_delivery_note_erp_id` `connected_delivery_note_erp_id` VARCHAR(20) COMMENT 'Refers to delivery_notes table erp_id column.';
ALTER TABLE BASE_07_TABLE CHANGE `item_is_canceled` `item_is_canceled` VARCHAR(20) COMMENT 'Yes if order/item is deleted.';
ALTER TABLE BASE_07_TABLE CHANGE `cancellation_comment` `cancellation_comment` VARCHAR(255) COMMENT 'Comment about cancellation - free text';
ALTER TABLE BASE_07_TABLE CHANGE `is_canceled` `is_canceled` VARCHAR(20) COMMENT 'Yes if order/item is canceled. Melyikre kell szurni? Értékek: Yes, No, Élő, Storno';
ALTER TABLE BASE_07_TABLE CHANGE `related_email_clean` `buyer_email` VARCHAR(100) COMMENT 'Megtisztitott email cim';
ALTER TABLE BASE_07_TABLE CHANGE `primary_email` `primary_email` VARCHAR(100) COMMENT 'Elsődleged email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.';
ALTER TABLE BASE_07_TABLE CHANGE `secondary_email` `secondary_email` VARCHAR(100) COMMENT 'Másodlagos email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.';
ALTER TABLE BASE_07_TABLE CHANGE `user_type` `user_type` VARCHAR(20) COMMENT 'Vevo-kategorizalas (B2C, B2B, B2B2C, Egeszsegpenztar)';

ALTER TABLE BASE_07_TABLE CHANGE `CT1_SKU` `CT1_SKU` VARCHAR(50) COMMENT 'SKU / SKU - Termektorzsbol SKU kod, elso szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `CT1_SKU_name` `CT1_SKU_name` VARCHAR(100) COMMENT 'Termektorzsbol SKU neve, elso szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `CT2_pack` `CT2_pack` VARCHAR(100) COMMENT 'Kiszereles / Pack - masodik szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `CT3_product` `CT3_product` VARCHAR(100) COMMENT 'Termek / Product - harmadik szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `CT3_product_short` `CT3_product_short` VARCHAR(100) COMMENT 'Termek / Product - harmadik szintu kategorizalas, de a szférikus és a tórikus összevonva';
ALTER TABLE BASE_07_TABLE CHANGE `CT4_product_brand` `CT4_product_brand` VARCHAR(100) COMMENT 'Termekmarka / Product brand - negyedik szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `CT5_manufacturer` `CT5_manufacturer` VARCHAR(100) COMMENT 'Gyarto / Manufacturer - Gyarto neve, otodik szintu kategorizalas';
ALTER TABLE BASE_07_TABLE CHANGE `product_group` `product_group` VARCHAR(100) COMMENT 'Lehetseges ertekek: Lencse, Folyadek, Szemcsepp, Egyebek, Napszemuveg, Szemuveg, Szallitasi dij';
ALTER TABLE BASE_07_TABLE CHANGE `lens_type` `lens_type` VARCHAR(100) COMMENT 'Lehetseges ertekek: Szferikus, Torikus, BiFokalis, Multifokalis, Ures. Torikusba betenni azokat, amik tobb kategoriaba is kerulhetnek. Progressziv lencsek a multifokalis kategoriakba keruljenek';
ALTER TABLE BASE_07_TABLE CHANGE `is_color` `is_color` INT(1) COMMENT 'Színes-e a lencse?';
ALTER TABLE BASE_07_TABLE CHANGE `wear_days` `wear_days` INT(3) COMMENT 'Mennyi ideig használható az egész doboz?';
ALTER TABLE BASE_07_TABLE CHANGE `wear_duration` `wear_duration` VARCHAR(20) COMMENT 'Mennyi ideig használható egy db lencse a dobozból?';
ALTER TABLE BASE_07_TABLE CHANGE `revenues_wdisc_in_local_currency` `revenues_wdisc_in_local_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `revenues_wdisc_in_base_currency` `revenues_wdisc_in_base_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in base currency';
ALTER TABLE BASE_07_TABLE CHANGE `gross_margin_wodisc_in_base_currency` `gross_margin_wodisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (eredeti)';
ALTER TABLE BASE_07_TABLE CHANGE `gross_margin_wdisc_in_base_currency` `gross_margin_wdisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (modositott)';
ALTER TABLE BASE_07_TABLE CHANGE `gross_margin_wodisc_%` `gross_margin_wodisc_%` FLOAT COMMENT 'Gross margin % (eredeti)';
ALTER TABLE BASE_07_TABLE CHANGE `gross_margin_wdisc_%` `gross_margin_wdisc_%` FLOAT COMMENT 'Gross margin % (modositott)';
ALTER TABLE BASE_07_TABLE CHANGE `cohort_id` `cohort_id` VARCHAR(10) COMMENT 'Cohort ID (ev, honap)';
ALTER TABLE BASE_07_TABLE CHANGE `last_purchase` `last_purchase` DATETIME COMMENT 'Date of last purchase of the user (ev, honap, nap)';
ALTER TABLE BASE_07_TABLE CHANGE `invoice_year` `invoice_year` INT(4) COMMENT 'Year of invoicing (number)';
ALTER TABLE BASE_07_TABLE CHANGE `invoice_month` `invoice_month` INT(2) COMMENT 'Month of invoicing (1 to 12, number)';
ALTER TABLE BASE_07_TABLE CHANGE `invoice_quarter` `invoice_quarter` INT(1) COMMENT 'Quarter of invoicing (1 to 4, number)';
ALTER TABLE BASE_07_TABLE CHANGE `invoice_day_in_month` `invoice_day_in_month` INT(2) COMMENT 'Calendar day of invoicing (1 to 31, number)';
ALTER TABLE BASE_07_TABLE CHANGE `invoice_hour` `invoice_hour` INT(2) COMMENT 'Hour of invoicing (0 to 23, number, rounded down)';
ALTER TABLE BASE_07_TABLE CHANGE `order_year` `order_year` INT(4) COMMENT 'Year of order received (number)';
ALTER TABLE BASE_07_TABLE CHANGE `order_month` `order_month` INT(2) COMMENT 'Month of order received (1 to 12, number)';
ALTER TABLE BASE_07_TABLE CHANGE `order_quarter` `order_quarter` INT(1) COMMENT 'Quarter of order received (1 to 4, number)';
ALTER TABLE BASE_07_TABLE CHANGE `order_day_in_month` `order_day_in_month` INT(2) COMMENT 'Calendar day of order received (1 to 31, number)';
ALTER TABLE BASE_07_TABLE CHANGE `order_hour` `order_hour` INT(2) COMMENT 'Hour of order received ( 1 to 24, number, rounded down)';
ALTER TABLE BASE_07_TABLE CHANGE `order_weekday` `order_weekday` INT(1) COMMENT 'Weekday code of order received (1 to 7, number)';
ALTER TABLE BASE_07_TABLE CHANGE `order_week_in_month` `order_week_in_month` INT(1) COMMENT 'Monthly week code of order received (1 to 5, number)';
ALTER TABLE BASE_07_TABLE CHANGE `cohort_month_since` `cohort_month_since` INT(6) COMMENT 'Hanyadik honapban tortent a tranzakcio a user elso vasarlasa ota (amikor bekerult a cohortba). Csak számláknál értelmezhető!';
ALTER TABLE BASE_07_TABLE CHANGE `user_cum_transactions` `user_cum_transactions` FLOAT COMMENT 'Hány tranzakciója volt eddig a usernek. Az ügyfelet leíró mező, nem a tételt vagy a rendelést!!!';
ALTER TABLE BASE_07_TABLE CHANGE `user_cum_gross_revenue_in_base_currency` `user_cum_gross_revenue_in_base_currency` FLOAT COMMENT 'User kumulativ AFA-s arbevetele eddig';
ALTER TABLE BASE_07_TABLE CHANGE `trx_marketing_channel` `trx_marketing_channel` VARCHAR(100) COMMENT 'Marketing csatorna: melyik marketing csatornan jott be a megrendeles';
ALTER TABLE BASE_07_TABLE CHANGE `net_margin_wodisc_in_base_currency` `net_margin_wodisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency (eredeti) Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_07_TABLE CHANGE `net_margin_wdisc_in_base_currency` `net_margin_wdisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency  (modositott)  Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_07_TABLE CHANGE `net_margin_wodisc_%` `net_margin_wodisc_%` FLOAT COMMENT 'Net margin % (eredeti)';
ALTER TABLE BASE_07_TABLE CHANGE `net_margin_wdisc_%` `net_margin_wdisc_%` FLOAT COMMENT 'Net margin % (modositott)';
ALTER TABLE BASE_07_TABLE CHANGE `shipping_cost_in_base_currency` `shipping_cost_in_base_currency` FLOAT COMMENT 'Shipping cost in base currency';
ALTER TABLE BASE_07_TABLE CHANGE `payment_cost_in_base_currency` `payment_cost_in_base_currency` FLOAT COMMENT 'Payment cost in base currency';
ALTER TABLE BASE_07_TABLE CHANGE `packaging_cost_in_base_currency` `packaging_cost_in_base_currency` FLOAT COMMENT 'Packaging cost in base currency';
ALTER TABLE BASE_07_TABLE CHANGE `barcode` `barcode` VARCHAR(100) COMMENT 'Barcode, From Adams items table';
ALTER TABLE BASE_07_TABLE CHANGE `goods_nomenclature_code` `goods_nomenclature_code` VARCHAR(20) COMMENT 'Customs Tariff Number - CTN, From Adams items table';
ALTER TABLE BASE_07_TABLE CHANGE `packaging` `packaging` VARCHAR(50) COMMENT 'Unit name of the item (tekercs, karton, etc), From Adams items table';
ALTER TABLE BASE_07_TABLE CHANGE `quantity_in_a_pack` `quantity_in_a_pack` DOUBLE COMMENT 'How many item is in a pack., From Adams items table';
ALTER TABLE BASE_07_TABLE CHANGE `estimated_supplier_lead_time` `estimated_supplier_lead_time` INT(3) COMMENT 'Estimated time of delivery, From Adams items table';
ALTER TABLE BASE_07_TABLE CHANGE `qty_per_storage_unit` `qty_per_storage_unit` INT(6) COMMENT 'How many boxes fits a storage unit, From Adams item_groups table';
ALTER TABLE BASE_07_TABLE CHANGE `box_width` `box_width` INT(6) COMMENT 'Box width, From Adams item_groups table';
ALTER TABLE BASE_07_TABLE CHANGE `box_height` `box_height` INT(6) COMMENT 'Box height, From Adams item_groups table';
ALTER TABLE BASE_07_TABLE CHANGE `box_depth` `box_depth` INT(6) COMMENT 'Box depth, From Adams item_groups table';
ALTER TABLE BASE_07_TABLE CHANGE `packaging_deadline` `packaging_deadline` DATETIME COMMENT 'Fulfilment deadline - as a default it is the same date when we recieve the order. Can be owerwritten by customer service dept if the customer ask to deliver it later on (or after) a specific date., From Adams incoming_order table';
ALTER TABLE BASE_07_TABLE CHANGE `num_of_purch` `num_of_purch` VARCHAR(20) COMMENT 'Visszatérő, vagy egyszeri vásárló';

ALTER TABLE BASE_07_TABLE CHANGE `pack_size` `pack_size` FLOAT(10,2) COMMENT 'Kiszerelés: a dobozban hány db lencse vagy ml folyadék van?';
ALTER TABLE BASE_07_TABLE CHANGE `package_unit` `package_unit` VARCHAR(10) COMMENT 'Kiszerelés mértékegysége: db vagy ml?';
ALTER TABLE BASE_07_TABLE CHANGE `lens_material` `lens_material` VARCHAR(100) COMMENT 'Lencse alapanyaga';
ALTER TABLE BASE_07_TABLE CHANGE `product_introduction_dt` `product_introduction_dt` DATE COMMENT 'A termék bevezetésének a dátuma';



ALTER TABLE BASE_07_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;


ALTER TABLE BASE_07_TABLE CHANGE `origin` `origin` VARCHAR(25) COMMENT 'Invoices = paid invoices; Orders = cancelled order. Invoices+Orders = all orders' AFTER id;
ALTER TABLE BASE_07_TABLE CHANGE `sql_id` `item_id` INT(10) COMMENT 'Unique ID given by the KPI system to each item';
ALTER TABLE BASE_07_TABLE CHANGE `erp_id` `erp_invoice_id` VARCHAR(255) COMMENT 'Order number given by the ERP system automatically. First 2 characters:
SO - Hungary
SI - Italy
SR - Romania
SS - Slovakia
Follow by the year (11, 12, 13, etc)';
ALTER TABLE BASE_07_TABLE CHANGE `item_net_value_in_currency` `item_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Net Price - in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `item_vat_value_in_currency` `item_vat_value_in_local_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `item_gross_value_in_currency` `item_gross_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Gross Price - in local currency';
ALTER TABLE BASE_07_TABLE CHANGE `cancelled_bill_erp_id` `ERP_cancelled_invoice_ID` VARCHAR(255) COMMENT 'In case of cancelled order, the invoice number (erp_id) of the original order. Or the cancellation note ID in case of the original cancelled invoice.';
ALTER TABLE BASE_07_TABLE CHANGE `processed` `last_modified_date` DATETIME COMMENT 'Last date something happened with the item (or anything with same erp_id)';
ALTER TABLE BASE_07_TABLE CHANGE `user` `last_modified_by` VARCHAR(255) COMMENT 'User who created or last modified the item.';
ALTER TABLE BASE_07_TABLE CHANGE `item_revenue_in_base_currency` `item_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Net Price - in base currency' AFTER item_gross_revenue_in_local_currency;
ALTER TABLE BASE_07_TABLE CHANGE `item_vat_in_base_currency` `item_vat_in_base_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in base currency' AFTER item_revenue_in_base_currency;
ALTER TABLE BASE_07_TABLE CHANGE `item_gross_revenue_in_base_currency` `item_gross_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Gross Price - in HUF' AFTER item_vat_in_base_currency;
ALTER TABLE BASE_07_TABLE CHANGE `user_id` `user_id` INT(10) COMMENT 'Egyedi ügyfél azonosító' AFTER reference_id;
ALTER TABLE BASE_07_TABLE CHANGE `billing_country_standardized` `billing_country_standardized` VARCHAR(100) COMMENT 'English name of country of billing address' AFTER billing_country;
ALTER TABLE BASE_07_TABLE CHANGE `shipping_country_standardized` `shipping_country_standardized` VARCHAR(100) COMMENT 'English name of country of shipment destination' AFTER shipping_country;

ALTER TABLE BASE_07_TABLE CHANGE `lens_clr` `lens_clr` VARCHAR(25) COMMENT 'Lencse színe' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_add` `lens_add` VARCHAR(25) COMMENT 'Lencse ADD-je' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_dia` `lens_dia` DECIMAL(6,2) COMMENT 'Lencse DIA-je' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_ax` `lens_ax` DECIMAL(6,2) COMMENT 'Lencse AX-je' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_cyl` `lens_cyl` DECIMAL(6,2) COMMENT 'Lencse AX-je' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_pwr` `lens_pwr` DECIMAL(6,2) COMMENT 'Lencse cilinder értéke' AFTER wear_duration;
ALTER TABLE BASE_07_TABLE CHANGE `lens_bc` `lens_bc` DECIMAL(6,2) COMMENT 'Lencse BC-je' AFTER wear_duration;