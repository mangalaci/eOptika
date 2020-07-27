DROP TABLE IF EXISTS BASE_03_TABLE_aux;
CREATE TABLE BASE_03_TABLE_aux
SELECT 	DISTINCT
		origin,
		item_id, 
		erp_invoice_id, 
		shipping_method, 
		related_division, 
		payment_method, 
		shipping_country_standardized, 
		CT1_SKU, 
		CT1_SKU_name, 
		CT2_pack, 
		last_modified_date, 
		connected_order_erp_id,
		IF(pickup_name = '', personal_name, pickup_name) AS pickup_name,
		gender,
		salutation
FROM item_list_union
;


ALTER TABLE BASE_03_TABLE_aux ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
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
LEFT JOIN erp_webshops w
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

/*ALTER TABLE tracking_data_ini_01 ADD PRIMARY KEY `id` (`id`) USING BTREE;*/
ALTER TABLE tracking_data_ini_01 ADD INDEX `parent_id` (`parent_id`) USING BTREE;
ALTER TABLE tracking_data_ini_01 ADD INDEX `reference_id` (`reference_id`) USING BTREE;


ALTER TABLE `tracking_data_ini_01` ADD `pickup_name` VARCHAR(100);
ALTER TABLE `tracking_data_ini_01` ADD `gender` VARCHAR(20);
ALTER TABLE `tracking_data_ini_01` ADD `salutation` VARCHAR(64);


UPDATE
tracking_data_ini_01 AS a
LEFT JOIN BASE_03_TABLE_aux b
ON a.reference_id = b.erp_invoice_id
SET
a.pickup_name = b.pickup_name,
a.gender = b.gender,
a.salutation = b.salutation
;






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
FROM `tracking_data_ini_01` a, `tracking_data_ini_01` b
WHERE a.id = b.parent_id
AND b.parent_id IS NOT NULL
ORDER by b.id, a.courier_status_key
;

ALTER TABLE tracking_data_consolidator ADD INDEX `id` (`id`) USING BTREE;
ALTER TABLE tracking_data_consolidator ADD INDEX `parent_id` (`parent_id`) USING BTREE;


DROP TABLE IF EXISTS sm_tracking_data;
CREATE TABLE sm_tracking_data
SELECT DISTINCT *
FROM tracking_data_ini_01
WHERE reference_id <> ''
UNION
SELECT DISTINCT *
FROM tracking_data_consolidator
;



ALTER TABLE sm_tracking_data ADD INDEX `reference_id` (`reference_id`) USING BTREE;




/* state_status lehet delivered vagy returned */



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


DROP TABLE IF EXISTS tracking_stat_handling_time_01;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_01
SELECT *, 
			LEAST(`1`,
			COALESCE(`100`,'2990-01-01'),
			COALESCE(`101`,'2990-01-01'),
			COALESCE(`102`,'2990-01-01'),
			COALESCE(`103`,'2990-01-01'),
			COALESCE(`104`,'2990-01-01'),
			COALESCE(`105`,'2990-01-01'),
			COALESCE(`106`,'2990-01-01'),
			COALESCE(`107`,'2990-01-01'),
			COALESCE(`108`,'2990-01-01'),
			COALESCE(`109`,'2990-01-01'),
			COALESCE(`110`,'2990-01-01'),
			COALESCE(`111`,'2990-01-01'),
			COALESCE(`112`,'2990-01-01'),
			COALESCE(`113`,'2990-01-01'),
			COALESCE(`114`,'2990-01-01'),
			COALESCE(`116`,'2990-01-01'),
			COALESCE(`117`,'2990-01-01'),
			COALESCE(`118`,'2990-01-01'),
			COALESCE(`119`,'2990-01-01'),
			COALESCE(`12`,'2990-01-01'),
			COALESCE(`120`,'2990-01-01'),
			COALESCE(`122`,'2990-01-01'),
			COALESCE(`124`,'2990-01-01'),
			COALESCE(`13`,'2990-01-01'),
			COALESCE(`14`,'2990-01-01'),
			COALESCE(`15`,'2990-01-01'),
			COALESCE(`16`,'2990-01-01'),
			COALESCE(`17`,'2990-01-01'),
			COALESCE(`18`,'2990-01-01'),
			COALESCE(`19`,'2990-01-01'),
			COALESCE(`20`,'2990-01-01'),
			COALESCE(`21`,'2990-01-01'),
			COALESCE(`22`,'2990-01-01'),
			COALESCE(`23`,'2990-01-01'),
			COALESCE(`24`,'2990-01-01'),
			COALESCE(`25`,'2990-01-01'),
			COALESCE(`28`,'2990-01-01'),
			COALESCE(`29`,'2990-01-01'),
			COALESCE(`30`,'2990-01-01'),
			COALESCE(`31`,'2990-01-01'),
			COALESCE(`32`,'2990-01-01'),
			COALESCE(`33`,'2990-01-01'),
			COALESCE(`34`,'2990-01-01'),
			COALESCE(`35`,'2990-01-01'),
			COALESCE(`36`,'2990-01-01'),
			COALESCE(`37`,'2990-01-01'),
			COALESCE(`38`,'2990-01-01'),
			COALESCE(`39`,'2990-01-01'),
			COALESCE(`40`,'2990-01-01'),
			COALESCE(`41`,'2990-01-01'),
			COALESCE(`42`,'2990-01-01'),
			COALESCE(`43`,'2990-01-01'),
			COALESCE(`44`,'2990-01-01'),
			COALESCE(`45`,'2990-01-01'),
			COALESCE(`46`,'2990-01-01'),
			COALESCE(`47`,'2990-01-01'),
			COALESCE(`48`,'2990-01-01'),
			COALESCE(`49`,'2990-01-01'),
			COALESCE(`50`,'2990-01-01'),
			COALESCE(`52`,'2990-01-01'),
			COALESCE(`53`,'2990-01-01'),
			COALESCE(`54`,'2990-01-01'),
			COALESCE(`55`,'2990-01-01'),
			COALESCE(`56`,'2990-01-01'),
			COALESCE(`57`,'2990-01-01'),
			COALESCE(`58`,'2990-01-01'),
			COALESCE(`59`,'2990-01-01'),
			COALESCE(`6`,'2990-01-01'),
			COALESCE(`60`,'2990-01-01'),
			COALESCE(`61`,'2990-01-01'),
			COALESCE(`62`,'2990-01-01'),
			COALESCE(`63`,'2990-01-01'),
			COALESCE(`64`,'2990-01-01'),
			COALESCE(`65`,'2990-01-01'),
			COALESCE(`66`,'2990-01-01'),
			COALESCE(`67`,'2990-01-01'),
			COALESCE(`68`,'2990-01-01'),
			COALESCE(`69`,'2990-01-01'),
			COALESCE(`7`,'2990-01-01'),
			COALESCE(`70`,'2990-01-01'),
			COALESCE(`71`,'2990-01-01'),
			COALESCE(`72`,'2990-01-01'),
			COALESCE(`73`,'2990-01-01'),
			COALESCE(`74`,'2990-01-01'),
			COALESCE(`75`,'2990-01-01'),
			COALESCE(`76`,'2990-01-01'),
			COALESCE(`77`,'2990-01-01'),
			COALESCE(`78`,'2990-01-01'),
			COALESCE(`79`,'2990-01-01'),
			COALESCE(`8`,'2990-01-01'),
			COALESCE(`80`,'2990-01-01'),
			COALESCE(`81`,'2990-01-01'),
			COALESCE(`82`,'2990-01-01'),
			COALESCE(`83`,'2990-01-01'),
			COALESCE(`84`,'2990-01-01'),
			COALESCE(`85`,'2990-01-01'),
			COALESCE(`86`,'2990-01-01'),
			COALESCE(`87`,'2990-01-01'),
			COALESCE(`88`,'2990-01-01'),
			COALESCE(`89`,'2990-01-01'),
			COALESCE(`90`,'2990-01-01'),
			COALESCE(`91`,'2990-01-01'),
			COALESCE(`92`,'2990-01-01'),
			COALESCE(`93`,'2990-01-01'),
			COALESCE(`94`,'2990-01-01'),
			COALESCE(`95`,'2990-01-01'),
			COALESCE(`96`,'2990-01-01'),
			COALESCE(`97`,'2990-01-01'),
			COALESCE(`98`,'2990-01-01'),
			COALESCE(`99`,'2990-01-01')
			) as delivery_start,
			GREATEST(`1`,
			COALESCE(`100`,'1990-01-01'),
			COALESCE(`101`,'1990-01-01'),
			COALESCE(`102`,'1990-01-01'),
			COALESCE(`103`,'1990-01-01'),
			COALESCE(`104`,'1990-01-01'),
			COALESCE(`105`,'1990-01-01'),
			COALESCE(`106`,'1990-01-01'),
			COALESCE(`107`,'1990-01-01'),
			COALESCE(`108`,'1990-01-01'),
			COALESCE(`109`,'1990-01-01'),
			COALESCE(`110`,'1990-01-01'),
			COALESCE(`111`,'1990-01-01'),
			COALESCE(`112`,'1990-01-01'),
			COALESCE(`113`,'1990-01-01'),
			COALESCE(`114`,'1990-01-01'),
			COALESCE(`116`,'1990-01-01'),
			COALESCE(`117`,'1990-01-01'),
			COALESCE(`118`,'1990-01-01'),
			COALESCE(`119`,'1990-01-01'),
			COALESCE(`12`,'1990-01-01'),
			COALESCE(`120`,'1990-01-01'),
			COALESCE(`122`,'1990-01-01'),
			COALESCE(`124`,'1990-01-01'),
			COALESCE(`13`,'1990-01-01'),
			COALESCE(`14`,'1990-01-01'),
			COALESCE(`15`,'1990-01-01'),
			COALESCE(`16`,'1990-01-01'),
			COALESCE(`17`,'1990-01-01'),
			COALESCE(`18`,'1990-01-01'),
			COALESCE(`19`,'1990-01-01'),
			COALESCE(`20`,'1990-01-01'),
			COALESCE(`21`,'1990-01-01'),
			COALESCE(`22`,'1990-01-01'),
			COALESCE(`23`,'1990-01-01'),
			COALESCE(`24`,'1990-01-01'),
			COALESCE(`25`,'1990-01-01'),
			COALESCE(`28`,'1990-01-01'),
			COALESCE(`29`,'1990-01-01'),
			COALESCE(`30`,'1990-01-01'),
			COALESCE(`31`,'1990-01-01'),
			COALESCE(`32`,'1990-01-01'),
			COALESCE(`33`,'1990-01-01'),
			COALESCE(`34`,'1990-01-01'),
			COALESCE(`35`,'1990-01-01'),
			COALESCE(`36`,'1990-01-01'),
			COALESCE(`37`,'1990-01-01'),
			COALESCE(`38`,'1990-01-01'),
			COALESCE(`39`,'1990-01-01'),
			COALESCE(`40`,'1990-01-01'),
			COALESCE(`41`,'1990-01-01'),
			COALESCE(`42`,'1990-01-01'),
			COALESCE(`43`,'1990-01-01'),
			COALESCE(`44`,'1990-01-01'),
			COALESCE(`45`,'1990-01-01'),
			COALESCE(`46`,'1990-01-01'),
			COALESCE(`47`,'1990-01-01'),
			COALESCE(`48`,'1990-01-01'),
			COALESCE(`49`,'1990-01-01'),
			COALESCE(`50`,'1990-01-01'),
			COALESCE(`52`,'1990-01-01'),
			COALESCE(`53`,'1990-01-01'),
			COALESCE(`54`,'1990-01-01'),
			COALESCE(`55`,'1990-01-01'),
			COALESCE(`56`,'1990-01-01'),
			COALESCE(`57`,'1990-01-01'),
			COALESCE(`58`,'1990-01-01'),
			COALESCE(`59`,'1990-01-01'),
			COALESCE(`6`,'1990-01-01'),
			COALESCE(`60`,'1990-01-01'),
			COALESCE(`61`,'1990-01-01'),
			COALESCE(`62`,'1990-01-01'),
			COALESCE(`63`,'1990-01-01'),
			COALESCE(`64`,'1990-01-01'),
			COALESCE(`65`,'1990-01-01'),
			COALESCE(`66`,'1990-01-01'),
			COALESCE(`67`,'1990-01-01'),
			COALESCE(`68`,'1990-01-01'),
			COALESCE(`69`,'1990-01-01'),
			COALESCE(`7`,'1990-01-01'),
			COALESCE(`70`,'1990-01-01'),
			COALESCE(`71`,'1990-01-01'),
			COALESCE(`72`,'1990-01-01'),
			COALESCE(`73`,'1990-01-01'),
			COALESCE(`74`,'1990-01-01'),
			COALESCE(`75`,'1990-01-01'),
			COALESCE(`76`,'1990-01-01'),
			COALESCE(`77`,'1990-01-01'),
			COALESCE(`78`,'1990-01-01'),
			COALESCE(`79`,'1990-01-01'),
			COALESCE(`8`,'1990-01-01'),
			COALESCE(`80`,'1990-01-01'),
			COALESCE(`81`,'1990-01-01'),
			COALESCE(`82`,'1990-01-01'),
			COALESCE(`83`,'1990-01-01'),
			COALESCE(`84`,'1990-01-01'),
			COALESCE(`85`,'1990-01-01'),
			COALESCE(`86`,'1990-01-01'),
			COALESCE(`87`,'1990-01-01'),
			COALESCE(`88`,'1990-01-01'),
			COALESCE(`89`,'1990-01-01'),
			COALESCE(`90`,'1990-01-01'),
			COALESCE(`91`,'1990-01-01'),
			COALESCE(`92`,'1990-01-01'),
			COALESCE(`93`,'1990-01-01'),
			COALESCE(`94`,'1990-01-01'),
			COALESCE(`95`,'1990-01-01'),
			COALESCE(`96`,'1990-01-01'),
			COALESCE(`97`,'1990-01-01'),
			COALESCE(`98`,'1990-01-01'),
			COALESCE(`99`,'1990-01-01')
			) as delivery_end
FROM `tracking_stat`
WHERE 1
;


ALTER TABLE tracking_stat_handling_time_01 ADD PRIMARY KEY (reference_id);



DROP TABLE IF EXISTS tracking_stat_handling_time_02;
CREATE TABLE IF NOT EXISTS tracking_stat_handling_time_02
SELECT 
		reference_id,
		coalesce(TIMESTAMPDIFF(hour,delivery_start, delivery_end),0) as time_dispatch_to_delivery
from tracking_stat_handling_time_01
;


ALTER TABLE tracking_stat_handling_time_02 ADD PRIMARY KEY (reference_id);





UPDATE
BASE_03_TABLE AS b
LEFT JOIN tracking_stat_handling_time_02 t
ON b.erp_invoice_id = t.reference_id
SET
b.time_dispatch_to_delivery = t.time_dispatch_to_delivery,
b.item_revenue_in_base_currency = b.item_revenue_in_local_currency*b.exchange_rate_of_currency,
b.item_vat_in_base_currency = b.item_vat_value_in_local_currency*b.exchange_rate_of_currency,
b.item_gross_revenue_in_base_currency = b.item_gross_revenue_in_local_currency*b.exchange_rate_of_currency,
b.source_of_trx = 
			CASE 	WHEN (b.reference_id REGEXP '^V[A-Z][1-9][0-9]/[0-9]{5,6}' OR b.reference_id = '') THEN 'offline'
					ELSE 'online' 
			END
;




UPDATE
BASE_00i_TABLE_inc AS b
LEFT JOIN tracking_stat_handling_time_02 t
ON b.erp_invoice_id = t.reference_id
SET
b.time_dispatch_to_delivery = t.time_dispatch_to_delivery,
b.item_revenue_in_base_currency = b.item_revenue_in_local_currency*b.exchange_rate_of_currency,
b.item_vat_in_base_currency = b.item_vat_value_in_local_currency*b.exchange_rate_of_currency,
b.item_gross_revenue_in_base_currency = b.item_gross_revenue_in_local_currency*b.exchange_rate_of_currency,
b.source_of_trx = 
			CASE 	WHEN (b.reference_id REGEXP '^V[A-Z][1-9][0-9]/[0-9]{5,6}' OR b.reference_id = '') THEN 'offline'
					ELSE 'online' 
			END
;