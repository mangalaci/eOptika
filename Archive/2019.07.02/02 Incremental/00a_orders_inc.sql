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

/* az utolsó módosítás előtti rendelések törlése BEGIN */
DROP TABLE IF EXISTS order_first;
CREATE TABLE IF NOT EXISTS order_first
SELECT SUBSTRING_INDEX(erp_id, '/', 2) AS root_erp_id, MIN(created) AS first_created
FROM incoming_orders
GROUP BY SUBSTRING_INDEX(erp_id, '/', 2)
;

ALTER TABLE order_first ADD PRIMARY KEY (`root_erp_id`) USING BTREE;


UPDATE incoming_orders i
LEFT JOIN order_first f
ON SUBSTRING_INDEX(i.erp_id, '/', 2) = f.root_erp_id
SET i.created = f.first_created
;



DROP TABLE IF EXISTS order_last;
CREATE TABLE IF NOT EXISTS order_last
SELECT SUBSTRING_INDEX(erp_id, '/', 2) AS root_erp_id, MAX(erp_id) AS last_erp_id
FROM incoming_orders
WHERE erp_id LIKE '%/%/%'
GROUP BY SUBSTRING_INDEX(erp_id, '/', 2)
;


ALTER TABLE order_last ADD PRIMARY KEY (`root_erp_id`) USING BTREE;
ALTER TABLE order_last ADD UNIQUE (`last_erp_id`) USING BTREE;


DROP TABLE IF EXISTS orders_before_last;
CREATE TABLE IF NOT EXISTS orders_before_last
SELECT *
FROM incoming_orders p, order_last l
WHERE SUBSTRING_INDEX(p.erp_id, '/', 2) = l.root_erp_id
AND p.erp_id <> l.last_erp_id
;

ALTER TABLE orders_before_last ADD PRIMARY KEY (`sql_id`) USING BTREE;


DROP TABLE IF EXISTS orders_dedupl;
CREATE TABLE IF NOT EXISTS orders_dedupl LIKE incoming_orders;
INSERT INTO orders_dedupl
SELECT m.*
FROM incoming_orders m
WHERE m.erp_id NOT IN
(
SELECT erp_id 
FROM orders_before_last
)
;

/* az utolsó módosítás előtti rendelések törlése END */



/* törölt rendelések */
INSERT INTO ORDERS_00
SELECT 		i.*,
			1 as new_entry,
			NULL AS related_legal_entity,
			NULL AS user_type,
			TRIM('\r' FROM TRIM('\n' FROM TRIM('\t' FROM TRIM(REPLACE(REPLACE((
				CASE
				 WHEN i.related_email  LIKE '%freeemail.hu' THEN REPLACE(i.related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN i.related_email  LIKE '%gmai.com' THEN REPLACE(i.related_email, 'gmai.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmal.com' THEN REPLACE(i.related_email, 'gmal.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gamil.com' THEN REPLACE(i.related_email, 'gamil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gnail.com' THEN REPLACE(i.related_email, 'gnail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmaikl.com' THEN REPLACE(i.related_email, 'gmaikl.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%mail.com' THEN REPLACE(i.related_email, 'g-mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%g.mail.com' THEN REPLACE(i.related_email, 'g.mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gail.com' THEN REPLACE(i.related_email, 'gail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmsil.com' THEN REPLACE(i.related_email, 'gmsil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmali.com' THEN REPLACE(i.related_email, 'gmali.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmil.com' THEN REPLACE(i.related_email, 'gmil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmai.hu' THEN REPLACE(i.related_email, 'gmai.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmal.hu' THEN REPLACE(i.related_email, 'gmal.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gamil.hu' THEN REPLACE(i.related_email, 'gamil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gnail.hu' THEN REPLACE(i.related_email, 'gnail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmaikl.hu' THEN REPLACE(i.related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%mail.hu' THEN REPLACE(i.related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%g.mail.hu' THEN REPLACE(i.related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gail.hu' THEN REPLACE(i.related_email, 'gail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmsil.hu' THEN REPLACE(i.related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmali.hu' THEN REPLACE(i.related_email, 'gmali.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmil.hu' THEN REPLACE(i.related_email, 'gmil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%cirtomail.com' THEN REPLACE(i.related_email, 'cirtomail.com', 'citromail.com')
				 WHEN i.related_email  LIKE '%undefined' THEN REPLACE(i.related_email, 'undefined', '')
				 WHEN i.related_email  = '#' THEN REPLACE(i.related_email, '#', '')
				 WHEN i.related_email  = 'Array' THEN REPLACE(i.related_email, 'Array', '')
				 ELSE i.related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as related_email_clean,
			 
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '')
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
				special_char_replace(o.billing_city) AS billing_city_clean,
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
				NULL AS pickup_location_catchment_area,
				NULL AS personal_location_catchment_area,				
				NULL AS shipping_phone_clean,
				NULL AS full_name,
				NULL AS first_name,
				NULL AS last_name,
				NULL AS gender,
				NULL AS salutation,
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
				NULL AS geometry,
				NULL AS focus_nr,
				NULL AS coating,
				NULL AS supplies,
				NULL AS refraction_index,
				NULL AS diameter,
				NULL AS decentralized_diameter,	
				NULL AS channel_width,
				NULL AS blue_control,
				NULL AS uv_control,
				NULL AS photo_chrome,
				NULL AS color,
				NULL AS color_percentage,
				NULL AS color_gradient,
				NULL AS prism,
				NULL AS polarized,
				NULL AS material_type,
				NULL AS material_name,
				NULL AS water_content,
				NULL AS frame_color_front,
				NULL AS frame_shape,
				NULL AS frame_size_D1,
				NULL AS rame_size_D2,
				NULL AS frame_size_D3,
				NULL AS frame_size_D4,
				NULL AS frame_size_D5,
				NULL AS frame_size_D6,
				NULL AS frame_material,
				NULL AS frame_flex,
				NULL AS frame_matt,
				NULL AS best_seller,
	
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id


FROM orders_dedupl i
WHERE i.sql_id > (SELECT max(sql_id) FROM ORDERS_002)
AND i.deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
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
			1 as new_entry,
			NULL AS related_legal_entity,
			NULL AS user_type,
			TRIM('\r' FROM TRIM('\n' FROM TRIM('\t' FROM TRIM(REPLACE(REPLACE((
				CASE
				 WHEN i.related_email  LIKE '%freeemail.hu' THEN REPLACE(i.related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN i.related_email  LIKE '%gmai.com' THEN REPLACE(i.related_email, 'gmai.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmal.com' THEN REPLACE(i.related_email, 'gmal.com', 'gmail.com')				 
				 WHEN i.related_email  LIKE '%gamil.com' THEN REPLACE(i.related_email, 'gamil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gnail.com' THEN REPLACE(i.related_email, 'gnail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmaikl.com' THEN REPLACE(i.related_email, 'gmaikl.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%mail.com' THEN REPLACE(i.related_email, 'g-mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%g.mail.com' THEN REPLACE(i.related_email, 'g.mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gail.com' THEN REPLACE(i.related_email, 'gail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmsil.com' THEN REPLACE(i.related_email, 'gmsil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmali.com' THEN REPLACE(i.related_email, 'gmali.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmil.com' THEN REPLACE(i.related_email, 'gmil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmai.hu' THEN REPLACE(i.related_email, 'gmai.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmal.hu' THEN REPLACE(i.related_email, 'gmal.hu', 'gmail.hu')				 
				 WHEN i.related_email  LIKE '%gamil.hu' THEN REPLACE(i.related_email, 'gamil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gnail.hu' THEN REPLACE(i.related_email, 'gnail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmaikl.hu' THEN REPLACE(i.related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%mail.hu' THEN REPLACE(i.related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%g.mail.hu' THEN REPLACE(i.related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gail.hu' THEN REPLACE(i.related_email, 'gail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmsil.hu' THEN REPLACE(i.related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmali.hu' THEN REPLACE(i.related_email, 'gmali.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmil.hu' THEN REPLACE(i.related_email, 'gmil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%cirtomail.com' THEN REPLACE(i.related_email, 'cirtomail.com', 'citromail.com')
				 WHEN i.related_email  LIKE '%undefined' THEN REPLACE(i.related_email, 'undefined', '')
				 WHEN i.related_email  = '#' THEN REPLACE(i.related_email, '#', '')
				 WHEN i.related_email  = 'Array' THEN REPLACE(i.related_email, 'Array', '')				 
				 ELSE i.related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as related_email_clean,
			 
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') 
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
				NULL AS pickup_location_catchment_area,
				NULL AS personal_location_catchment_area,				
				NULL AS shipping_phone_clean,
				NULL AS full_name,
				NULL AS first_name,
				NULL AS last_name,
				NULL AS gender,
				NULL AS salutation,
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
				NULL AS geometry,
				NULL AS focus_nr,
				NULL AS coating,
				NULL AS supplies,
				NULL AS refraction_index,
				NULL AS diameter,
				NULL AS decentralized_diameter,		
				NULL AS channel_width,
				NULL AS blue_control,
				NULL AS uv_control,
				NULL AS photo_chrome,
				NULL AS color,
				NULL AS color_percentage,
				NULL AS color_gradient,
				NULL AS prism,
				NULL AS polarized,
				NULL AS material_type,
				NULL AS material_name,
				NULL AS water_content,
				
				NULL AS frame_color_front,
				NULL AS frame_shape,
				NULL AS frame_size_D1,
				NULL AS rame_size_D2,
				NULL AS frame_size_D3,
				NULL AS frame_size_D4,
				NULL AS frame_size_D5,
				NULL AS frame_size_D6,
				NULL AS frame_material,
				NULL AS frame_flex,
				NULL AS frame_matt,
				NULL AS best_seller,
				
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id
				
FROM orders_dedupl i
LEFT JOIN asd
ON i.erp_id = asd.connected_erp_id
WHERE i.created > (SELECT max(created) FROM ORDERS_002)
AND asd.connected_erp_id IS NULL
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
;





DROP TABLE IF EXISTS ORDERS_00a1;
CREATE TABLE IF NOT EXISTS ORDERS_00a1
SELECT 		sql_id,
			erp_id,
			created,
			TRIM('\r' FROM TRIM('\n' FROM TRIM('\t' FROM TRIM(REPLACE(REPLACE((
			CASE
				 WHEN i.related_email  LIKE '%freeemail.hu' THEN REPLACE(i.related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN i.related_email  LIKE '%gmai.com' THEN REPLACE(i.related_email, 'gmai.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmal.com' THEN REPLACE(i.related_email, 'gmal.com', 'gmail.com')				 
				 WHEN i.related_email  LIKE '%gamil.com' THEN REPLACE(i.related_email, 'gamil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gnail.com' THEN REPLACE(i.related_email, 'gnail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmaikl.com' THEN REPLACE(i.related_email, 'gmaikl.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%mail.com' THEN REPLACE(i.related_email, 'g-mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%g.mail.com' THEN REPLACE(i.related_email, 'g.mail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gail.com' THEN REPLACE(i.related_email, 'gail.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmsil.com' THEN REPLACE(i.related_email, 'gmsil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmali.com' THEN REPLACE(i.related_email, 'gmali.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmil.com' THEN REPLACE(i.related_email, 'gmil.com', 'gmail.com')
				 WHEN i.related_email  LIKE '%gmai.hu' THEN REPLACE(i.related_email, 'gmai.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmal.hu' THEN REPLACE(i.related_email, 'gmal.hu', 'gmail.hu')				 
				 WHEN i.related_email  LIKE '%gamil.hu' THEN REPLACE(i.related_email, 'gamil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gnail.hu' THEN REPLACE(i.related_email, 'gnail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmaikl.hu' THEN REPLACE(i.related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%mail.hu' THEN REPLACE(i.related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%g.mail.hu' THEN REPLACE(i.related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gail.hu' THEN REPLACE(i.related_email, 'gail.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmsil.hu' THEN REPLACE(i.related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmali.hu' THEN REPLACE(i.related_email, 'gmali.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%gmil.hu' THEN REPLACE(i.related_email, 'gmil.hu', 'gmail.hu')
				 WHEN i.related_email  LIKE '%cirtomail.com' THEN REPLACE(i.related_email, 'cirtomail.com', 'citromail.com')
				 WHEN i.related_email  LIKE '%undefined' THEN REPLACE(i.related_email, 'undefined', '')
				 WHEN i.related_email  = '#' THEN REPLACE(i.related_email, '#', '')
				 WHEN i.related_email  = 'Array' THEN REPLACE(i.related_email, 'Array', '')				 
				 ELSE i.related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as related_email_clean,

			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') AS shipping_phone_aux,
	
	/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	special_char_replace(billing_city) AS billing_city_clean
	
FROM ORDERS_00 i
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
FROM orders_dedupl t1
LEFT JOIN orders_dedupl t2
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




/* felcserélt shipping_phone és related_email javítása */
/* ha a telefonszámban van @, de az email címben nincs */

UPDATE ORDERS_00
SET
    related_email_clean = shipping_phone
WHERE shipping_phone LIKE '%@%'
AND related_email NOT LIKE '%@%' 
;


UPDATE ORDERS_00
SET
    shipping_phone = related_email
WHERE shipping_phone =  related_email_clean
;

/* ha az email cím '+3'-mal vagy '+4'-gyel kezdődik */
UPDATE ORDERS_00
SET
    shipping_phone = related_email_clean
WHERE related_email_clean LIKE ('+3%')
OR related_email_clean LIKE ('+4%')
;


UPDATE ORDERS_00
SET
    related_email_clean = ''
WHERE related_email LIKE ('+3%')
OR related_email LIKE ('+4%')
;


UPDATE ORDERS_00
SET
    related_email_clean = ''
WHERE related_email_clean NOT LIKE '%@%'
;
