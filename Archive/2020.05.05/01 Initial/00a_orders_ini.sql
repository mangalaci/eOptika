/*HIBAJAVÍTÓ */
UPDATE incoming_orders SET related_division = 'Optika - IT' WHERE related_webshop = 'LenteContatto.it';
UPDATE incoming_orders SET related_division = 'Optika - RO' WHERE related_webshop = 'netOptica.ro';
UPDATE incoming_orders SET item_sku = 'AOA_MIRR' WHERE item_sku = 'AO_MIRR';
UPDATE incoming_orders SET shipping_method = 'Pickup in person' WHERE shipping_method = 'GPSe' AND shipping_country = 'HUN';
UPDATE incoming_orders SET shipping_method = 'GLS' WHERE shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA';
UPDATE incoming_orders SET shipping_method = 'Pickup in person' WHERE shipping_method = 'Személyes átvétel';
UPDATE incoming_orders SET related_division = 'Optika - HU' WHERE related_division = 'Egyebek';

UPDATE incoming_orders SET shipping_name = 'Nagy Petra', billing_name = 'Nagy Petra' WHERE related_email = 'petranagy19@gmail.com';


UPDATE incoming_orders i
INNER JOIN IN_exchange_rate_correction x
ON i.erp_id = x.erp_id
SET i.exchange_rate_of_currency = x.exchange_rate_of_currency
WHERE x.erp_id IS NOT NULL
;


UPDATE incoming_orders
set created = CASE WHEN TIME(created) = '00:00:00' THEN processed ELSE created END
;

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


DROP TABLE IF EXISTS ORDERS_00;
CREATE TABLE IF NOT EXISTS ORDERS_00 LIKE incoming_orders;
ALTER TABLE ORDERS_00 ADD new_entry INT(1);
ALTER TABLE ORDERS_00 ADD related_legal_entity VARCHAR(100) NOT NULL;
ALTER TABLE ORDERS_00 ADD `user_type` VARCHAR(17) NOT NULL;
ALTER TABLE ORDERS_00 ADD INDEX `billing_name` (`billing_name`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `deletion_comment` (`deletion_comment`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `is_deleted` (`is_deleted`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `item_type` (`item_type`) USING BTREE;
ALTER TABLE ORDERS_00 ADD buyer_email VARCHAR(100);
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
ALTER TABLE ORDERS_00 ADD personal_name VARCHAR(100);
ALTER TABLE ORDERS_00 ADD personal_address VARCHAR(255);
ALTER TABLE ORDERS_00 ADD personal_zip_code VARCHAR(10);
ALTER TABLE ORDERS_00 ADD personal_city VARCHAR(100);
ALTER TABLE ORDERS_00 ADD personal_city_size VARCHAR(100);
ALTER TABLE ORDERS_00 ADD personal_province VARCHAR(100);
ALTER TABLE ORDERS_00 ADD personal_country VARCHAR(100);
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
ALTER TABLE ORDERS_00 ADD pickup_location_catchment_area VARCHAR(30);
ALTER TABLE ORDERS_00 ADD personal_location_catchment_area VARCHAR(30);
ALTER TABLE ORDERS_00 ADD full_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD first_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD last_name VARCHAR(64);
ALTER TABLE ORDERS_00 ADD gender VARCHAR(20);
ALTER TABLE ORDERS_00 ADD salutation VARCHAR(64);
ALTER TABLE ORDERS_00 ADD product_introduction_dt TIMESTAMP;

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
ALTER TABLE ORDERS_00 ADD `geometry` VARCHAR(10);
ALTER TABLE ORDERS_00 ADD `focus_nr` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `coating` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `supplies` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `refraction_index` DECIMAL(6,2);
ALTER TABLE ORDERS_00 ADD `diameter` INT;
ALTER TABLE ORDERS_00 ADD `decentralized_diameter` INT;
ALTER TABLE ORDERS_00 ADD `channel_width` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `blue_control` VARCHAR(10);
ALTER TABLE ORDERS_00 ADD `uv_control` VARCHAR(10);
ALTER TABLE ORDERS_00 ADD `photo_chrome` VARCHAR(10);
ALTER TABLE ORDERS_00 ADD `color` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `color_percentage` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `color_gradient` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `prism` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `polarized` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `material_type` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `material_name` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `water_content` VARCHAR(100);
ALTER TABLE ORDERS_00 ADD `frame_color_front` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `frame_shape` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `frame_size_D1` INT;
ALTER TABLE ORDERS_00 ADD `frame_size_D2` INT;
ALTER TABLE ORDERS_00 ADD `frame_size_D3` INT;
ALTER TABLE ORDERS_00 ADD `frame_size_D4` INT;
ALTER TABLE ORDERS_00 ADD `frame_size_D5` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `frame_size_D6` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `frame_material` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `frame_flex` INT;
ALTER TABLE ORDERS_00 ADD `frame_matt` VARCHAR(255);
ALTER TABLE ORDERS_00 ADD `best_seller` TEXT;
ALTER TABLE ORDERS_00 ADD `private_label_product` INT;

ALTER TABLE ORDERS_00 ADD revenues_wdisc_in_local_currency FLOAT;
ALTER TABLE ORDERS_00 ADD revenues_wdisc_in_base_currency FLOAT;
ALTER TABLE ORDERS_00 ADD connected_order_erp_id VARCHAR(255);
ALTER TABLE ORDERS_00 ADD connected_delivery_note_erp_id VARCHAR(255);


/* törölt rendelések */
INSERT INTO ORDERS_00
SELECT 		i.*,
			1 AS new_entry,
			NULL AS related_legal_entity,
			CASE
				 WHEN lower(shipping_name) LIKE '%eoptika%' THEN 'B2C'
				 WHEN lower(billing_name)  LIKE '%eoptika%' THEN 'B2C'			
				 WHEN lower(shipping_name) LIKE '%optik%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%optik%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%optic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%optic%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%ottic%' THEN 'B2B2C Optician'				 
				 WHEN lower(shipping_name) LIKE 'látszerész%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE 'látszerész%' THEN 'B2B2C Optician'

				 WHEN lower(shipping_name)  LIKE '% kft%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% bt' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% bt.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% zrt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% nyrt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% kkt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%múzeum%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%központ%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%iskola%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% egyetem%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%óvoda%' THEN 'B2B'
				 WHEN upper(shipping_name)  LIKE '%NÉBIH%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% egyesület%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% alapítvány%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% foundation%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% association%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% gmbh%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% ltd.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% plc.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% ltda%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% fiók%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% limited%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.r.l.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.r.o.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.p.a.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.n.c.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.a.s.%' THEN 'B2B'
				 ELSE 'B2C'
			 END AS user_type,
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
				 /* el kell dönteni, hogy a vesszőt tartalmazó emailek 2 email címet választanak el, vagy a pontot írták el vesszőre */
				 WHEN related_email LIKE '%,%' then 
					CASE 
						WHEN LENGTH(related_email) - LENGTH(REPLACE(related_email, '@', '')) = 1 
						THEN REPLACE(related_email, ',', '') 
						ELSE SUBSTR(related_email,1,LOCATE(',', related_email)-1)
					END
				 /* felcserélt shipping_phone és related_email javítása */
				 /* ha a telefonszámban van @, de az email címben nincs */
				 WHEN shipping_phone LIKE '%@%' AND related_email NOT LIKE '%@%' THEN related_email = shipping_phone
        
				 WHEN related_email LIKE ('+3%') OR related_email LIKE ('+4%') THEN ''

				 WHEN related_email NOT LIKE '%@%' THEN ''
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as buyer_email,
			 
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
				
				NULL AS personal_name,
				NULL AS personal_address,
				NULL AS personal_zip_code,
				NULL AS personal_city_size,
				NULL AS personal_city,
				NULL AS personal_province,
				NULL AS personal_country,

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
				NULL AS group_id,
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
				NULL AS private_label_product,
	
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id
				
FROM  orders_dedupl i
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
			1 AS new_entry,
			NULL AS related_legal_entity,
			CASE
				 WHEN lower(shipping_name) LIKE '%optik%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%optik%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%optic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%optic%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(shipping_name) LIKE '%ottic%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE '%ottic%' THEN 'B2B2C Optician'				 
				 WHEN lower(shipping_name) LIKE 'látszerész%' THEN 'B2B2C Optician'
				 WHEN lower(billing_name)  LIKE 'látszerész%' THEN 'B2B2C Optician'

				 WHEN lower(shipping_name)  LIKE '% kft%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% bt' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% bt.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% zrt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% nyrt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% kkt%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%múzeum%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%központ%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%iskola%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% egyetem%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '%óvoda%' THEN 'B2B'
				 WHEN upper(shipping_name)  LIKE '%NÉBIH%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% egyesület%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% alapítvány%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% foundation%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% association%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% gmbh%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% ltd.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% plc.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% ltda%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% fiók%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% limited%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.r.l.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.r.o.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.p.a.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.n.c.%' THEN 'B2B'
				 WHEN lower(shipping_name)  LIKE '% s.a.s.%' THEN 'B2B'
				 ELSE 'B2C'
			 END AS user_type,
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
				 /* el kell dönteni, hogy a vesszőt tartalmazó emailek 2 email címet választanak el, vagy a pontot írták el vesszőre */
				 WHEN related_email LIKE '%,%' then 
					CASE 
						WHEN LENGTH(related_email) - LENGTH(REPLACE(related_email, '@', '')) = 1 
						THEN REPLACE(related_email, ',', '') 
						ELSE SUBSTR(related_email,1,LOCATE(',', related_email)-1)
					END
				 /* felcserélt shipping_phone és related_email javítása */
				 /* ha a telefonszámban van @, de az email címben nincs */
				 WHEN shipping_phone LIKE '%@%' AND related_email NOT LIKE '%@%' THEN related_email = shipping_phone
        
				 WHEN related_email LIKE ('+3%') OR related_email LIKE ('+4%') THEN ''

				 WHEN related_email NOT LIKE '%@%' THEN ''
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as buyer_email,
			 
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
				NULL AS personal_name,
				NULL AS personal_address,
				NULL AS personal_zip_code,
				NULL AS personal_city_size,
				NULL AS personal_city,
				NULL AS personal_province,
				NULL AS personal_country,
				
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
				NULL AS group_id,
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
				NULL AS private_label_product,
				
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS connected_order_erp_id,
				NULL AS connected_delivery_note_erp_id
				
FROM  orders_dedupl i
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
				 /* el kell dönteni, hogy a vesszőt tartalmazó emailek 2 email címet választanak el, vagy a pontot írták el vesszőre */
				 WHEN related_email LIKE '%,%' then 
					CASE 
						WHEN LENGTH(related_email) - LENGTH(REPLACE(related_email, '@', '')) = 1 
						THEN REPLACE(related_email, ',', '') 
						ELSE SUBSTR(related_email,1,LOCATE(',', related_email)-1)
					END
				 /* felcserélt shipping_phone és related_email javítása */
				 /* ha a telefonszámban van @, de az email címben nincs */
				 WHEN shipping_phone LIKE '%@%' AND related_email NOT LIKE '%@%' THEN related_email = shipping_phone
        
				 WHEN related_email LIKE ('+3%') OR related_email LIKE ('+4%') THEN ''

				 WHEN related_email NOT LIKE '%@%' THEN ''
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as buyer_email,

			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') AS shipping_phone_aux,
	
	/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	special_char_replace(billing_city) AS billing_city_clean
	
FROM ORDERS_00
;

ALTER TABLE ORDERS_00a1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `created` (`created`) USING BTREE;
ALTER TABLE ORDERS_00a1 CHANGE `buyer_email` `buyer_email` VARCHAR(255);


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00a1 AS s ON m.sql_id = s.sql_id
SET
    m.buyer_email = s.buyer_email,
    m.billing_city_clean = s.billing_city_clean,
    m.shipping_phone_aux = s.shipping_phone_aux
;



ALTER TABLE ORDERS_00 ADD INDEX `shipping_city` (`shipping_city`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `billing_city` (`billing_city`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `billing_country_standardized` (`billing_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `new_entry` (`new_entry`) USING BTREE;