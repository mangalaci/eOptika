
/*error correction */
UPDATE outgoing_bills SET exchange_rate_of_currency = 359.31 WHERE erp_id = 'SE17/E000489';
UPDATE outgoing_bills SET exchange_rate_of_currency = 1 WHERE erp_id = 'SP17/E000199';
UPDATE outgoing_bills SET related_division = 'Optika - IT' WHERE related_webshop = 'LenteContatto.it';
UPDATE outgoing_bills SET related_division = 'Optika - RO' WHERE related_webshop = 'netOptica.ro';
UPDATE outgoing_bills SET item_sku = 'AOA_MIRR' WHERE item_sku = 'AO_MIRR';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'GPSe' AND shipping_country = 'HUN';
UPDATE outgoing_bills SET shipping_method = 'GLS' WHERE shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA';
UPDATE outgoing_bills SET shipping_method = 'Pickup in person' WHERE shipping_method = 'Személyes átvétel';
UPDATE outgoing_bills SET related_division = 'Optika - HU' WHERE related_division = 'Egyebek';
UPDATE outgoing_bills SET related_email = 'judit.carfleet@gmail.com' WHERE related_email = 'judit.toth@carfleet.hu';
UPDATE outgoing_bills SET related_email = 'bokcsilla2@gmail.com' WHERE related_email = 'bokcsilla@citromail.hu';
UPDATE outgoing_bills SET shipping_name = 'Nagy Petra', billing_name = 'Nagy Petra' WHERE related_email = 'petranagy19@gmail.com';

UPDATE outgoing_bills SET related_email = 'niklszilvi@vipmail.hu' WHERE related_email = 'niklszilvi@indamail.hu';
UPDATE outgoing_bills SET related_email = 'paulyuk.aniko@gmail.com' WHERE related_email = 'paulyuk.aniko@gmail.hu';
UPDATE outgoing_bills SET related_email = 'mia3374@freemail.hu' WHERE related_email = 'vrabel.tunde@freemail.hu';
UPDATE outgoing_bills SET related_email = 'bacso.szabo.renata@gmail.com' WHERE related_email = 'bacso.szabo.renata@gamil.com';
UPDATE outgoing_bills SET related_email = 'bogicica2011@gmail.com' WHERE related_email = 'varga0107@gmail.com';
UPDATE outgoing_bills SET related_email = 'edina.kiss1975@gmail.hu' WHERE related_email = 'edina.kiss1975@gmai.hu';
UPDATE outgoing_bills SET related_email = 'kaufancsa@gmail.com' WHERE related_email = 'kaufancs@gmail.com';
UPDATE outgoing_bills SET related_email = 'kokenybela23@gmail.com' WHERE related_email = 'kokenybela@citromail.hu';
UPDATE outgoing_bills SET related_email = 'wunderleeva2@gmail.com' WHERE related_email = 'wunderleva2@gmail.com';
UPDATE outgoing_bills SET related_email = 'daranyia@digikabel.hu' WHERE related_email = 'daranyia@upcmail.hu';
UPDATE outgoing_bills SET related_email = 'daranyia@digikabel.hu' WHERE related_email = 'daranyia@digimail.hu';
UPDATE outgoing_bills SET related_email = 'sandortimea@hotmail.com' WHERE related_email = 'sandortmea@hotmail.com';
UPDATE outgoing_bills SET related_email = 'attila.turai@freemail.hu' WHERE related_email = 'kismehecskecsillag@gmail.com';
UPDATE outgoing_bills SET related_email = 'k.g.evelin@gmail.com' WHERE related_email = 'k.g.evelin@citromail.hu';
UPDATE outgoing_bills SET related_email = 'tibor.tth90@gmail.com' WHERE related_email = 'limpcall@freemail.hu';
UPDATE outgoing_bills SET related_email = 'szanyi98@gmail.com' WHERE related_email = 'szanyio8@gmail.com';
UPDATE outgoing_bills SET related_email = 'balazsbotabalu@gmail.com' WHERE related_email = 'balazsbotabalu@gmail.hu';
UPDATE outgoing_bills SET related_email = 'grozervera7@gmail.com' WHERE related_email = 'grozervera@gmail.com';
UPDATE outgoing_bills SET related_email = 'ercsi1978@gmail.com' WHERE related_email = 'ercsi@gmail.com';
UPDATE outgoing_bills SET related_email = 'marton.lilla.st@gmail.com' WHERE related_email = 'marton.lilla.st@sargataxi.hu';
UPDATE outgoing_bills SET related_email = 'gere.ildiko75@gmail.com' WHERE related_email = 'gere.ildiko75@digikabel.hu';
UPDATE outgoing_bills SET related_email = 'sinanita24@gmail.com' WHERE related_email = 'anita@mail24.at';
UPDATE outgoing_bills SET related_email = 'horvathanna8702@freemail.hu' WHERE related_email = 'horvathann8702@freemail.hu';
UPDATE outgoing_bills SET related_email = 'adanyimonica@gmail.com' WHERE related_email = 'adanyimoninca@gmail.com';








ALTER TABLE outgoing_bills ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE outgoing_bills ADD INDEX `billing_name` (`billing_name`) USING BTREE;


DROP TABLE IF EXISTS INVOICES_00;
CREATE TABLE IF NOT EXISTS INVOICES_00 LIKE outgoing_bills;
ALTER TABLE INVOICES_00 ADD user_type VARCHAR(17) NOT NULL;
ALTER TABLE INVOICES_00 ADD related_email_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_phone_aux VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_name_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_name_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_city_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD shipping_country_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD billing_country_standardized VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD real_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD real_city_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD business_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD business_city_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_name VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_address VARCHAR(255);
ALTER TABLE INVOICES_00 ADD pickup_zip_code VARCHAR(10);
ALTER TABLE INVOICES_00 ADD pickup_city_trim VARCHAR(100);
ALTER TABLE INVOICES_00 ADD catchment_area VARCHAR(30);
ALTER TABLE INVOICES_00 ADD shipping_phone_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_name_clean VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD real_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD business_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_province VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_city_size VARCHAR(100);
ALTER TABLE INVOICES_00 ADD pickup_city VARCHAR(100);
ALTER TABLE INVOICES_00 ADD full_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD first_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD last_name VARCHAR(64);
ALTER TABLE INVOICES_00 ADD gender VARCHAR(20);
ALTER TABLE INVOICES_00 ADD salutation VARCHAR(64);
ALTER TABLE INVOICES_00 ADD lens_material VARCHAR(100);
ALTER TABLE INVOICES_00 ADD product_introduction_dt DATE;


ALTER TABLE INVOICES_00 ADD CT1_SKU VARCHAR(100);
ALTER TABLE INVOICES_00 ADD CT1_SKU_name VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT2_pack VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT3_product VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT3_product_short VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT4_product_brand VARCHAR(255);
ALTER TABLE INVOICES_00 ADD CT5_manufacturer VARCHAR(255);
ALTER TABLE INVOICES_00 ADD group_id INT(6);
ALTER TABLE INVOICES_00 ADD barcode VARCHAR(255);
ALTER TABLE INVOICES_00 ADD goods_nomenclature_code INT(10);
ALTER TABLE INVOICES_00 ADD packaging VARCHAR(255);
ALTER TABLE INVOICES_00 ADD quantity_in_a_pack INT(5);
ALTER TABLE INVOICES_00 ADD estimated_supplier_lead_time INT(10);
ALTER TABLE INVOICES_00 ADD net_weight_in_kg FLOAT(13,6);
ALTER TABLE INVOICES_00 ADD CT2_sku VARCHAR(100);
ALTER TABLE INVOICES_00 ADD lens_bc DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_pwr DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_cyl DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_ax DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_dia DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD lens_add VARCHAR(10);
ALTER TABLE INVOICES_00 ADD lens_clr VARCHAR(10);
ALTER TABLE INVOICES_00 ADD product_group VARCHAR(255);
ALTER TABLE INVOICES_00 ADD lens_type VARCHAR(32);
ALTER TABLE INVOICES_00 ADD is_color INT(1);
ALTER TABLE INVOICES_00 ADD wear_days INT(10);
ALTER TABLE INVOICES_00 ADD wear_duration VARCHAR(100);
ALTER TABLE INVOICES_00 ADD qty_per_storage_unit INT(1);
ALTER TABLE INVOICES_00 ADD box_width DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD box_height DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD box_depth DECIMAL(6,2);
ALTER TABLE INVOICES_00 ADD pack_size VARCHAR(10);
ALTER TABLE INVOICES_00 ADD package_unit VARCHAR(10);
ALTER TABLE INVOICES_00 ADD revenues_wdisc_in_local_currency FLOAT;
ALTER TABLE INVOICES_00 ADD revenues_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD gross_margin_wodisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD gross_margin_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD `gross_margin_wodisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD `gross_margin_wdisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD shipping_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD packaging_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD payment_cost_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_revenue_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_vat_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD item_gross_revenue_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD net_invoiced_shipping_costs FLOAT;
ALTER TABLE INVOICES_00 ADD net_margin_wodisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD net_margin_wdisc_in_base_currency FLOAT;
ALTER TABLE INVOICES_00 ADD `net_margin_wodisc_%` FLOAT;
ALTER TABLE INVOICES_00 ADD `net_margin_wdisc_%` FLOAT;


INSERT INTO INVOICES_00
SELECT 
			o.*,
			MAX(CASE 		WHEN u.user_type = 'Private insurance' THEN 'Private insurance'
							WHEN u.user_type = 'B2B2C' THEN 'B2B2C'
							WHEN u.user_type = 'B2C' THEN 'B2C'
							WHEN u.user_type = 'B2B' THEN 'B2B'
							WHEN u.user_type IS NULL THEN 'B2C'		
							ELSE u.user_type
				END) AS user_type,
			TRIM(REPLACE(REPLACE((CASE
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
			 END), '  ', ' '), ',hu', '.hu')) as related_email_clean,
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') 
				AS shipping_phone_aux,
			 TRIM(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(shipping_name)
			,'MKB EGÉSZSÉGPÉNZTÁR','')
			,'MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'POSTÁS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSPÉNZTÁR','')
			,'OTP EGÉSZSÉGPÉNZTÁR','')
			,'PATIKA EGÉSZSÉGPÉNZTÁR','')
			,'ARANYKOR EGÉSZSÉGPÉNZTÁR','')
			,'TEMPO EGÉSZSÉGPÉNZTÁR','')			
			,'AXA EGÉSZSÉGPÉNZTÁR','')	
			,'PRÉMIUM EGÉSZSÉGPÉNZTÁR','')	
			,'VITAMIN EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETERÖ EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETÚT EGÉSZSÉGPÉNZTÁR','')
			,'GENERALI EGÉSZSÉGPÉNZTÁR','')	
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'NAVOSZ EGÉSZSÉGPÉNZTÁR','')	
			,'QAESTOR EGÉSZSÉGPÉNZTÁR','')	
			,'ADOSZT EGÉSZSÉGPÉNZTÁR','')				
			,'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR','')		
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')
			,'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR','')
			,'KARDIREX EGÉSZSÉGPÉNZTÁR','')
			,'VASUTAS EGÉSZSÉGPÉNZTÁR','')			
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')				
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')	
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')				
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EP.','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'DANUBIUS EGÉSZSÉGPÉNZTÁR','')	
			,'EXON 2000','')
			,'OMV','')
			,'MOL ','')
			,'NEMZETI DOHÁNYBOLT','')
			,'MOL ','')
			,'OMW','')
			,'RELAY','')
			,'INMEDIO','')
			,'ALLEGROUP.HU KFT.','')
			,'OTP BANK NYRT','')
			,'/ PPP','')
			,'/PPP','')
			,'PPPP','')
			,'/ PM','')
			,'/EP','')
			,'/ TOF','')
			,'/ SPRINTER','')
			,' PP', '')
			,'/PP', '')
			,' / ', ' /')			
			,'UNDEFINED', '')
			,'()', '')
			) AS shipping_name_trim,
			TRIM(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(billing_name)
			,'MKB EGÉSZSÉGPÉNZTÁR','')
			,'MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'POSTÁS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSPÉNZTÁR','')
			,'OTP EGÉSZSÉGPÉNZTÁR','')
			,'PATIKA EGÉSZSÉGPÉNZTÁR','')
			,'ARANYKOR EGÉSZSÉGPÉNZTÁR','')
			,'TEMPO EGÉSZSÉGPÉNZTÁR','')
			,'AXA EGÉSZSÉGPÉNZTÁR','')	
			,'PRÉMIUM EGÉSZSÉGPÉNZTÁR','')	
			,'VITAMIN EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETERÖ EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETÚT EGÉSZSÉGPÉNZTÁR','')
			,'GENERALI EGÉSZSÉGPÉNZTÁR','')	
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'NAVOSZ EGÉSZSÉGPÉNZTÁR','')	
			,'QAESTOR EGÉSZSÉGPÉNZTÁR','')	
			,'ADOSZT EGÉSZSÉGPÉNZTÁR','')
			,'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR','')
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')
			,'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR','')
			,'KARDIREX EGÉSZSÉGPÉNZTÁR','')
			,'VASUTAS EGÉSZSÉGPÉNZTÁR','')			
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')	
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EP.','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'DANUBIUS EGÉSZSÉGPÉNZTÁR','')				
			,'EXON 2000','')
			,'OMV','')
			,'MOL ','')
			,'NEMZETI DOHÁNYBOLT','')		
			,'MOL ','')
			,'OMW','')
			,'RELAY','')
			,'INMEDIO','')
			,'ALLEGROUP.HU KFT.','')
			,'OTP BANK NYRT','')
			,'/ PPP','')
			,'/PPP','')
			,'PPPP','')
			,'/ PM','')
			,'/EP','')
			,'/ TOF','')
			,'/ SPRINTER','')
			,' PP', '')
			,'/PP', '')
			,' / ', ' /')			
			,'UNDEFINED', '')
			,'()', '')
			) AS billing_name_trim,
				/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') 
				AS billing_city_clean,
				NULL AS shipping_country_standardized,
				NULL AS billing_country_standardized,
				NULL AS real_name,
				NULL AS real_address,
				NULL AS real_zip_code,
				NULL AS real_city_trim,
				NULL AS business_name,
				NULL AS business_address,
				NULL AS business_zip_code,
				NULL AS business_city_trim,
				NULL AS pickup_name,
				NULL AS pickup_address,
				NULL AS pickup_zip_code,
				NULL AS pickup_city_trim,
				NULL AS catchment_area,
				NULL AS shipping_phone_clean,
				NULL AS real_name_clean,
				NULL AS real_province,
				NULL AS real_city_size,
				NULL AS real_city,
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
				NULL AS `net_margin_wdisc_%`				
				
FROM outgoing_bills o LEFT JOIN IN_user_type u
ON ((o.shipping_country = u.country)
AND LOWER(o.billing_name) LIKE CONCAT('%', u.search_string, '%') 
	OR LOWER(o.shipping_name) LIKE CONCAT('%', u.search_string, '%'))
WHERE	LOWER(o.is_canceled) in ('no', 'élő')
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	o.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
/*removing test user*/
AND o.related_email NOT IN (SELECT related_email FROM IN_test_users)
AND o.billing_name NOT IN (SELECT billing_name FROM IN_test_users)
/*removing Előleg records*/
AND o.item_name_eng NOT IN ('Előleg')
GROUP BY o.sql_id
;


ALTER TABLE INVOICES_00 ADD INDEX `created` (`created`) USING BTREE;



