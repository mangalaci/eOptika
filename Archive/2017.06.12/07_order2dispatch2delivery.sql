DROP TABLE IF EXISTS BASE_03_TABLE_aux;
CREATE TABLE BASE_03_TABLE_aux
SELECT 	DISTINCT
		erp_id,
		IF(pickup_name = '', personal_name, pickup_name) AS pickup_name,
		gender,
		salutation
FROM BASE_03_TABLE
;

ALTER TABLE BASE_03_TABLE_aux ADD PRIMARY KEY (erp_id);
ALTER TABLE BASE_03_TABLE_aux ADD INDEX `pickup_name` (`pickup_name`) USING BTREE;
ALTER TABLE BASE_03_TABLE_aux ADD INDEX `gender` (`gender`) USING BTREE;
ALTER TABLE BASE_03_TABLE_aux ADD INDEX `salutation` (`salutation`) USING BTREE;



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
LEFT JOIN BASE_03_TABLE_aux AS b
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
SELECT sql_id, erp_id, shipping_method, related_division, payment_method, shipping_country, CT1_SKU, CT1_SKU_name, CT2_pack, last_modified_date, connected_order_erp_id
FROM BASE_03_TABLE
WHERE connected_order_erp_id <> ''
AND origin = 'invoices'
LIMIT 0
;

ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD PRIMARY KEY (sql_id);
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `connected_order_erp_id` (`connected_order_erp_id`) USING BTREE;
ALTER TABLE TIME_ORDER_TO_DISPATCH_CARRIER_01 ADD INDEX `CT1_SKU` (`CT1_SKU`) USING BTREE;


INSERT INTO TIME_ORDER_TO_DISPATCH_CARRIER_01
SELECT DISTINCT sql_id, erp_id, shipping_method, related_division, payment_method, shipping_country, CT1_SKU, CT1_SKU_name, CT2_pack, last_modified_date, connected_order_erp_id
FROM BASE_03_TABLE
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
				sz.last_modified_date AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date) AS time_order_to_dispatch
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
				sz.last_modified_date AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date) AS time_order_to_dispatch
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
				sz.last_modified_date AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date) AS time_order_to_dispatch
FROM BASE_03_TABLE AS sz
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
				sz.last_modified_date AS postazas,
				TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date) AS time_order_to_dispatch
FROM BASE_03_TABLE AS sz
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
r.last_modified_date = azért kell a last_modified_date mezőt használni a created helyett, mert ha a rendelés nem a webről jött,
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


UPDATE
BASE_03_TABLE AS b
LEFT JOIN TIME_ORDER_TO_DISPATCH d
ON b.sql_id = d.sql_id
LEFT JOIN tracking_stat_handling_time t
ON b.erp_id = t.reference_id
SET
b.item_revenue_in_base_currency = b.item_revenue_in_local_currency*b.exchange_rate_of_currency,
b.item_vat_in_base_currency = b.item_vat_value_in_local_currency*b.exchange_rate_of_currency,
b.item_gross_revenue_in_base_currency = b.item_gross_revenue_in_local_currency*b.exchange_rate_of_currency,
b.time_order_to_dispatch = d.time_order_to_dispatch,
b.time_dispatch_to_delivery = t.time_dispatch_to_delivery,
b.source_of_trx = 
			CASE 	WHEN (b.reference_id REGEXP '^V[A-Z][1-9][0-9]/[0-9]{5,6}' OR b.reference_id = '') THEN 'offline'
					ELSE 'online' 
			END
;

ALTER TABLE BASE_03_TABLE CHANGE `sql_id` `item_id` INT(10);
ALTER TABLE BASE_03_TABLE CHANGE `erp_id` `erp_invoice_id` VARCHAR(20);
ALTER TABLE BASE_03_TABLE CHANGE `related_email_clean` `buyer_email` VARCHAR(200);



