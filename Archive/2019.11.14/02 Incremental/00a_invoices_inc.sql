/*error correction */
UPDATE outgoing_bills SET related_division = 'Optika - IT' WHERE related_webshop = 'LenteContatto.it';
UPDATE outgoing_bills SET related_division = 'Optika - RO' WHERE related_webshop = 'netOptica.ro';
UPDATE outgoing_bills SET item_sku = 'AOA_MIRR' WHERE item_sku = 'AO_MIRR';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'GPSe' AND shipping_country = 'HUN';
UPDATE outgoing_bills SET shipping_method = 'GLS' WHERE shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'Személyes átvétel';
UPDATE outgoing_bills SET related_division = 'Optika - HU' WHERE related_division = 'Egyebek';

UPDATE outgoing_bills SET shipping_name = 'Nagy Petra', billing_name = 'Nagy Petra' WHERE related_email = 'petranagy19@gmail.com';
UPDATE outgoing_bills SET shipping_name = 'Szeghalmi Katalin' WHERE related_email = 'szeghalmi.kati@yahoo.com' AND lower(billing_name) LIKE '%szeghalmi%';




UPDATE outgoing_bills o
INNER JOIN IN_net_purchase_price_correction p
ON o.erp_id = p.erp_id AND o.item_sku = p.sku
SET o.item_net_purchase_price_in_base_currency = p.item_net_purchase_price_in_base_currency
WHERE p.item_net_purchase_price_in_base_currency IS NOT NULL
;

UPDATE outgoing_bills o
INNER JOIN IN_exchange_rate_correction x
ON o.erp_id = x.erp_id
SET o.exchange_rate_of_currency = x.exchange_rate_of_currency
WHERE x.erp_id IS NOT NULL
;

UPDATE outgoing_bills o
INNER JOIN IN_email_correction e
ON o.related_email = e.old_email
SET o.related_email = e.new_email
WHERE e.old_email IS NOT NULL
;


ALTER TABLE outgoing_bills ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `billing_name` (`billing_name`) USING BTREE;

ALTER TABLE outgoing_bills DROP our_bank_account_number;



INSERT INTO INVOICES_00
SELECT 
			o.*,
			1 as new_entry,
			NULL AS related_legal_entity,
			NULL AS user_type,
			TRIM('\r' FROM TRIM('\n' FROM TRIM('\t' FROM TRIM(REPLACE(REPLACE((
				CASE
				 WHEN o.related_email  LIKE '%freeemail.hu' THEN REPLACE(o.related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN o.related_email  LIKE '%gmai.com' THEN REPLACE(o.related_email, 'gmai.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmal.com' THEN REPLACE(o.related_email, 'gmal.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gamil.com' THEN REPLACE(o.related_email, 'gamil.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gnail.com' THEN REPLACE(o.related_email, 'gnail.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmaikl.com' THEN REPLACE(o.related_email, 'gmaikl.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%mail.com' THEN REPLACE(o.related_email, 'g-mail.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%g.mail.com' THEN REPLACE(o.related_email, 'g.mail.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gail.com' THEN REPLACE(o.related_email, 'gail.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmsil.com' THEN REPLACE(o.related_email, 'gmsil.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmali.com' THEN REPLACE(o.related_email, 'gmali.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmil.com' THEN REPLACE(o.related_email, 'gmil.com', 'gmail.com')
				 WHEN o.related_email  LIKE '%gmai.hu' THEN REPLACE(o.related_email, 'gmai.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gmal.hu' THEN REPLACE(o.related_email, 'gmal.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gamil.hu' THEN REPLACE(o.related_email, 'gamil.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gnail.hu' THEN REPLACE(o.related_email, 'gnail.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gmaikl.hu' THEN REPLACE(o.related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%mail.hu' THEN REPLACE(o.related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%g.mail.hu' THEN REPLACE(o.related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gail.hu' THEN REPLACE(o.related_email, 'gail.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gmsil.hu' THEN REPLACE(o.related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gmali.hu' THEN REPLACE(o.related_email, 'gmali.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%gmil.hu' THEN REPLACE(o.related_email, 'gmil.hu', 'gmail.hu')
				 WHEN o.related_email  LIKE '%cirtomail.com' THEN REPLACE(o.related_email, 'cirtomail.com', 'citromail.com')
				 WHEN o.related_email  LIKE '%undefined' THEN REPLACE(o.related_email, 'undefined', '')
				 WHEN o.related_email  = '#' THEN REPLACE(o.related_email, '#', '')
				 WHEN o.related_email  = 'Array' THEN REPLACE(o.related_email, 'Array', '')
				 ELSE o.related_email
			 END), '  ', ' '), ',hu', '.hu'))))) as buyer_email,
		 
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(o.shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') 
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
				NULL AS shipping_city_standardized,
				NULL AS shipping_country_standardized,
				NULL AS billing_city_standardized,
				NULL AS billing_country_standardized,
				NULL AS personal_name,
				NULL AS personal_address,
				NULL AS personal_zip_code,
				NULL AS personal_country,
				NULL AS business_name,
				NULL AS business_address,
				NULL AS business_zip_code,
				NULL AS business_country,
				NULL AS pickup_name,
				NULL AS pickup_address,
				NULL AS pickup_zip_code,
				NULL AS pickup_country,
				NULL AS catchment_area,
				NULL AS pickup_location_catchment_area,
				NULL AS personal_location_catchment_area,
				NULL AS shipping_phone_clean,
				NULL AS personal_province,
				NULL AS personal_city_size,
				NULL AS personal_city,
				NULL AS business_province,
				NULL AS business_city_size,
				NULL AS business_city,
				NULL AS pickup_province,
				NULL AS pickup_city_size,
				NULL AS pickup_city,
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
				
				NULL AS revenues_wdisc_in_local_currency,
				NULL AS revenues_wdisc_in_base_currency,
				NULL AS gross_margin_wodisc_in_base_currency,
				NULL AS gross_margin_wdisc_in_base_currency,
				NULL AS `gross_margin_wodisc_%`,
				NULL AS `gross_margin_wdisc_%`,
				NULL AS shipping_cost_in_base_currency,
				NULL AS packaging_cost_in_base_currency,
				NULL AS payment_cost_in_base_currency,
				NULL AS item_revenue_in_base_currency,
				NULL AS item_vat_in_base_currency,
				NULL AS item_gross_revenue_in_base_currency,
				NULL AS net_invoiced_shipping_costs,
				NULL AS net_margin_wodisc_in_base_currency,
				NULL AS net_margin_wdisc_in_base_currency,
				NULL AS `net_margin_wodisc_%`,
				NULL AS `net_margin_wdisc_%`,
				NULL AS coupon_code,
				NULL AS trx_coupon_code,
				NULL AS bonus_rate,
				NULL AS private_label_product
FROM outgoing_bills o
	   inner join DWH_RUN_PARAMS p
          on p.last_max_sql_id < o.sql_id -- csak az előző futás óta létrejött számlák kellenek
WHERE LOWER(o.is_canceled) in ('no', 'élő')
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	o.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
/*removing test user*/
AND o.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND o.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing Előleg records*/
AND o.item_name_hun NOT IN ('Előleg')
;


update DWH_RUN_PARAMS
   set last_max_sql_id = (select max(sql_id) from INVOICES_00), 
       last_date_of_run = now()
;


/* AND o.sql_id not in (SELECT sql_id FROM BASE_03_TABLE where origin = 'invoices')*/


/* el kell dönteni, hogy a vesszőt tartalmazó emailek 2 email címet választanak el, vagy a pontot írták el vesszőre */
UPDATE INVOICES_00
SET
    buyer_email = 
			CASE 
			WHEN LENGTH(buyer_email) - LENGTH(REPLACE(buyer_email, '@', '')) = 1 
			THEN REPLACE(buyer_email, ',', '') 
			ELSE SUBSTR(buyer_email,1,LOCATE(',', buyer_email)-1)
		END
WHERE buyer_email LIKE '%,%'
AND new_entry = 1 /*csak az uj sorokat updateeljük*/
;



/* felcserélt shipping_phone és related_email javítása */
/* ha a telefonszámban van @, de az email címben nincs */

UPDATE INVOICES_00
SET
    buyer_email = shipping_phone
WHERE shipping_phone LIKE '%@%'
AND related_email NOT LIKE '%@%' 
AND new_entry = 1 /*csak az uj sorokat updateeljük*/
;


UPDATE INVOICES_00
SET
    shipping_phone = related_email
WHERE shipping_phone =  buyer_email
AND new_entry = 1 /*csak az uj sorokat updateeljük*/
;


/* ha az email cím '+3'-mal vagy '+4'-gyel kezdődik */
UPDATE INVOICES_00
SET
    shipping_phone = buyer_email
WHERE buyer_email LIKE ('+3%')
OR buyer_email LIKE ('+4%')
;


UPDATE INVOICES_00
SET
    buyer_email = ''
WHERE related_email LIKE ('+3%')
OR related_email LIKE ('+4%')
;


UPDATE INVOICES_00
SET
    buyer_email = ''
WHERE buyer_email NOT LIKE '%@%'
AND new_entry = 1 /*csak az uj sorokat updateeljük*/
	;
