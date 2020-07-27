﻿/*HIBAJAVÍTÓ */
UPDATE incoming_orders SET related_division = 'Optika - IT' WHERE related_webshop = 'LenteContatto.it';
UPDATE incoming_orders SET related_division = 'Optika - RO' WHERE related_webshop = 'netOptica.ro';
UPDATE incoming_orders SET item_sku = 'AOA_MIRR' WHERE item_sku = 'AO_MIRR';
UPDATE incoming_orders SET shipping_method = 'Pickup in person' WHERE shipping_method = 'GPSe' AND shipping_country = 'HUN';
UPDATE incoming_orders SET shipping_method = 'GLS' WHERE shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA';
UPDATE incoming_orders SET shipping_method = 'Pickup in person' WHERE shipping_method = 'Személyes átvétel';
UPDATE incoming_orders SET related_division = 'Optika - HU' WHERE related_division = 'Egyebek';

UPDATE incoming_orders SET shipping_name = 'Nagy Petra', billing_name = 'Nagy Petra' WHERE related_email = 'petranagy19@gmail.com';


UPDATE incoming_orders i
LEFT JOIN IN_email_correction e
ON i.related_email = e.old_email
SET i.related_email = e.new_email
WHERE i.related_email = e.old_email
;



DROP TABLE IF EXISTS ORDERS_00;
CREATE TABLE IF NOT EXISTS ORDERS_00 LIKE incoming_orders;
ALTER TABLE ORDERS_00 ADD `user_type` VARCHAR(17) NOT NULL;
ALTER TABLE ORDERS_00 ADD INDEX `billing_name` (`billing_name`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `deletion_comment` (`deletion_comment`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `is_deleted` (`is_deleted`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `item_type` (`item_type`) USING BTREE;
ALTER TABLE ORDERS_00 ADD related_email_clean VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_phone_aux VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_flg VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_flg VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_trim VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_trim VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_trim_wo_pickup VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_trim_wo_pickup VARCHAR(100);
ALTER TABLE ORDERS_00 ADD health_insurance VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_real VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_pickup VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_name_business VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_real VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_pickup VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_name_business VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_city_clean VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_country_standardized VARCHAR(100);
ALTER TABLE ORDERS_00 ADD shipping_city_standardized VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_country_standardized VARCHAR(100);
ALTER TABLE ORDERS_00 ADD billing_city_standardized VARCHAR(100);
ALTER TABLE ORDERS_00 ADD real_name VARCHAR(100);
ALTER TABLE ORDERS_00 ADD real_address VARCHAR(255);
ALTER TABLE ORDERS_00 ADD real_zip_code VARCHAR(10);
ALTER TABLE ORDERS_00 ADD real_city VARCHAR(100);
ALTER TABLE ORDERS_00 ADD real_city_size VARCHAR(100);
ALTER TABLE ORDERS_00 ADD real_province VARCHAR(100);
ALTER TABLE ORDERS_00 ADD real_country VARCHAR(100);
ALTER TABLE ORDERS_00 ADD business_name VARCHAR(100);
ALTER TABLE ORDERS_00 ADD business_address VARCHAR(255);
ALTER TABLE ORDERS_00 ADD business_zip_code VARCHAR(10);
ALTER TABLE ORDERS_00 ADD business_city VARCHAR(100);
ALTER TABLE ORDERS_00 ADD business_city_size VARCHAR(100);
ALTER TABLE ORDERS_00 ADD business_province VARCHAR(100);
ALTER TABLE ORDERS_00 ADD business_country VARCHAR(100);
ALTER TABLE ORDERS_00 ADD pickup_name VARCHAR(100);
ALTER TABLE ORDERS_00 ADD pickup_address VARCHAR(255);
ALTER TABLE ORDERS_00 ADD pickup_zip_code VARCHAR(10);
ALTER TABLE ORDERS_00 ADD pickup_city VARCHAR(100);
ALTER TABLE ORDERS_00 ADD pickup_city_size VARCHAR(100);
ALTER TABLE ORDERS_00 ADD pickup_province VARCHAR(100);
ALTER TABLE ORDERS_00 ADD pickup_country VARCHAR(100);

ALTER TABLE ORDERS_00 ADD shipping_phone_clean VARCHAR(100);
ALTER TABLE ORDERS_00 ADD catchment_area VARCHAR(30);
ALTER TABLE ORDERS_00 ADD full_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD first_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD last_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD gender VARCHAR(20);
ALTER TABLE ORDERS_00 ADD salutation VARCHAR(64);
ALTER TABLE ORDERS_00 ADD lens_material VARCHAR(100);
ALTER TABLE ORDERS_00 ADD product_introduction_dt DATE;

ALTER TABLE ORDERS_00 ADD CT1_SKU VARCHAR(100);
ALTER TABLE ORDERS_00 ADD CT1_SKU_name VARCHAR(255);
ALTER TABLE ORDERS_00 ADD CT2_pack VARCHAR(255);
ALTER TABLE ORDERS_00 ADD CT3_product VARCHAR(255);
ALTER TABLE ORDERS_00 ADD CT3_product_short VARCHAR(255);
ALTER TABLE ORDERS_00 ADD CT4_product_brand VARCHAR(255);
ALTER TABLE ORDERS_00 ADD CT5_manufacturer VARCHAR(255);
ALTER TABLE ORDERS_00 ADD group_id INT(6);
ALTER TABLE ORDERS_00 ADD barcode VARCHAR(255);
ALTER TABLE ORDERS_00 ADD goods_nomenclature_code INT(10);
ALTER TABLE ORDERS_00 ADD packaging VARCHAR(255);
ALTER TABLE ORDERS_00 ADD quantity_in_a_pack INT(5);
ALTER TABLE ORDERS_00 ADD estimated_supplier_lead_time INT(10);
ALTER TABLE ORDERS_00 ADD net_weight_in_kg FLOAT(13,6);
ALTER TABLE ORDERS_00 ADD CT2_sku VARCHAR(100);
ALTER TABLE ORDERS_00 ADD lens_bc DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD lens_pwr DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD lens_cyl DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD lens_ax DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD lens_dia DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD lens_add VARCHAR(10);
ALTER TABLE ORDERS_00 ADD lens_clr VARCHAR(10);
ALTER TABLE ORDERS_00 ADD product_group VARCHAR(255);
ALTER TABLE ORDERS_00 ADD lens_type VARCHAR(32);
ALTER TABLE ORDERS_00 ADD is_color INT(1);
ALTER TABLE ORDERS_00 ADD wear_days INT(10);
ALTER TABLE ORDERS_00 ADD wear_duration VARCHAR(100);
ALTER TABLE ORDERS_00 ADD qty_per_storage_unit INT(1);
ALTER TABLE ORDERS_00 ADD box_width DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD box_height DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD box_depth DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD pack_size VARCHAR(10);
ALTER TABLE ORDERS_00 ADD package_unit VARCHAR(10);
ALTER TABLE ORDERS_00 ADD revenues_wdisc_in_local_currency FLOAT;
ALTER TABLE ORDERS_00 ADD revenues_wdisc_in_base_currency FLOAT;
ALTER TABLE ORDERS_00 ADD connected_order_erp_id VARCHAR(255);
ALTER TABLE ORDERS_00 ADD connected_delivery_note_erp_id VARCHAR(255);


/* törölt rendelések */
INSERT INTO ORDERS_00
SELECT 		i.*,
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
				
				NULL AS billing_city_clean,
				NULL AS shipping_country_standardized,
				NULL AS shipping_city_standardized,
				NULL AS billing_country_standardized,
				NULL AS billing_city_standardized,
				
				NULL AS real_name,
				NULL AS real_address,
				NULL AS real_zip_code,
				NULL AS real_city_size,
				NULL AS real_city,
				NULL AS real_province,
				NULL AS real_country,

				NULL AS business_name,
				NULL AS business_address,
				NULL AS business_zip_code,
				NULL AS business_city_size,
				NULL AS business_city,
				NULL AS business_province,
				NULL AS business_country,
				
				NULL AS pickup_name,
				NULL AS pickup_address,
				NULL AS pickup_zip_code,
				NULL AS pickup_city_size,
				NULL AS pickup_city,
				NULL AS pickup_province,
				NULL AS pickup_country,
				
				NULL AS catchment_area,
				NULL AS shipping_phone_clean,
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
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id
				
FROM  incoming_orders i
LEFT JOIN IN_user_type u
ON (LOWER(i.billing_name) LIKE CONCAT('%', u.search_string, '%') OR LOWER(i.shipping_name) LIKE CONCAT('%', u.search_string, '%'))
WHERE i.deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
AND i.is_deleted = 'yes'
AND LOWER(i.deletion_comment) NOT LIKE '%dupl%'
AND LOWER(i.deletion_comment) NOT LIKE '%teszt%'
/*removing test user*/
AND i.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND i.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	i.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
AND i.item_group_name <> 'Szállítási díjak'
/*removing Előleg records*/
AND i.item_type = 'T'
GROUP BY sql_id
ORDER BY created DESC /*a legutolsó user_type miatt kell*/
;


/* *** A számlázott erp_id-k összesítése: ELEJE *** */
DROP TABLE IF EXISTS asd;
CREATE TABLE IF NOT EXISTS asd
SELECT DISTINCT CASE WHEN connected_order_erp_id = '' THEN d.erp_id_of_order 
ELSE connected_order_erp_id 
END AS connected_erp_id
FROM outgoing_bills b
LEFT JOIN delivery_notes AS d 
ON b.connected_delivery_note_erp_id = d.erp_id
;

DELETE FROM asd 
WHERE connected_erp_id = ''
OR connected_erp_id IS NULL
;

ALTER TABLE asd ADD PRIMARY KEY (`connected_erp_id`) USING BTREE;


/* *** A számlázott erp_id-k összesítése: VÉGE *** */


/* nyitott rendelések */
INSERT INTO ORDERS_00
SELECT 		i.*,
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
				NULL AS billing_city_clean,
				NULL AS shipping_country_standardized,
				NULL AS shipping_city_standardized,
				NULL AS billing_country_standardized,
				NULL AS billing_city_standardized,
				NULL AS real_name,
				NULL AS real_address,
				NULL AS real_zip_code,
				NULL AS real_city_size,
				NULL AS real_city,
				NULL AS real_province,
				NULL AS real_country,
				
				NULL AS business_name,
				NULL AS business_address,
				NULL AS business_zip_code,
				NULL AS business_city_size,
				NULL AS business_city,
				NULL AS business_province,
				NULL AS business_country,
				
				NULL AS pickup_name,
				NULL AS pickup_address,
				NULL AS pickup_zip_code,
				NULL AS pickup_city_size,
				NULL AS pickup_city,
				NULL AS pickup_province,
				NULL AS pickup_country,	

				NULL AS catchment_area,
				NULL AS shipping_phone_clean,

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
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id
				
FROM  incoming_orders i
LEFT JOIN IN_user_type u
ON (LOWER(i.billing_name) LIKE CONCAT('%', u.search_string, '%') OR LOWER(i.shipping_name) LIKE CONCAT('%', u.search_string, '%'))
LEFT JOIN asd
ON i.erp_id = asd.connected_erp_id
WHERE asd.connected_erp_id IS NULL
AND i.deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
AND i.is_deleted = 'no'
AND LOWER(i.deletion_comment) NOT LIKE '%dupl%'
AND LOWER(i.deletion_comment) NOT LIKE '%teszt%'
/*removing test user*/
AND i.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND i.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	i.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
AND i.item_group_name <> 'Szállítási díjak'
/*removing Előleg records*/
AND i.item_type = 'T'
GROUP BY sql_id
ORDER BY created DESC /*a legutolsó user_type miatt kell*/
;





DROP TABLE IF EXISTS ORDERS_00a1;
CREATE TABLE IF NOT EXISTS ORDERS_00a1
SELECT 		sql_id,
			erp_id,
			created,
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

			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') AS shipping_phone_aux,
	
	/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	special_char_replace(billing_city) AS billing_city_clean
	
FROM ORDERS_00
;

ALTER TABLE ORDERS_00a1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `created` (`created`) USING BTREE;
ALTER TABLE ORDERS_00a1 CHANGE `related_email_clean` `related_email_clean` VARCHAR(255);




DROP TABLE IF EXISTS orig_created_table;
CREATE TABLE IF NOT EXISTS orig_created_table
SELECT DISTINCT t1.erp_id,
t1.created,
CASE WHEN TIME(t2.created) = '00:00:00' THEN t2.processed ELSE t2.created END AS orig_created
FROM incoming_orders t1
LEFT JOIN incoming_orders t2
ON SUBSTRING_INDEX(t1.erp_id, '/', 2) = t2.erp_id
;

ALTER TABLE orig_created_table ADD PRIMARY KEY (`erp_id`) USING BTREE;


UPDATE ORDERS_00a1 AS m
        INNER JOIN
    orig_created_table AS s ON m.erp_id = s.erp_id
SET 
    m.created = s.orig_created
;


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00a1 AS s ON m.sql_id = s.sql_id
SET
    m.related_email_clean = s.related_email_clean,
    m.billing_city_clean = s.billing_city_clean,
    m.shipping_phone_aux = s.shipping_phone_aux
;

ALTER TABLE ORDERS_00 ADD INDEX `shipping_city` (`shipping_city`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `billing_city` (`billing_city`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `billing_country_standardized` (`billing_country_standardized`) USING BTREE;