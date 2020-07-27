DROP TABLE IF EXISTS ab_cikkto_full;
CREATE TABLE IF NOT EXISTS ab_cikkto_full
SELECT
    i.ct_cikksz AS CT1_SKU,
    i.ct_megnev AS CT1_SKU_name,
    i.ct_megnev AS CT2_pack,
    i.ct_megnev AS CT3_product,
    i.ct_megnev AS CT3_product_short,	
    i.ct_megnev AS CT4_product_brand,
    i.ct_gyarto AS CT5_manufacturer,
    i.ct_csoport,
    i.ct_ean AS barcode,
    i.ct_vtsz AS goods_nomenclature_code,
    i.ct_kiszer AS packaging,
    i.ct_kiszmenny AS quantity_in_a_pack,
    i.ct_beszido AS estimated_supplier_lead_time
FROM ab_cikkto AS i LEFT JOIN ab_cikkcsto AS j
ON i.ct_csoport = j.cc_azon
LIMIT 0;
ALTER TABLE ab_cikkto_full ADD PRIMARY KEY (`CT1_SKU`) USING BTREE;
ALTER TABLE ab_cikkto_full ADD INDEX `ct_csoport` (`ct_csoport`) USING BTREE;

INSERT INTO ab_cikkto_full
SELECT DISTINCT 
    i.ct_cikksz AS CT1_SKU, 
        i.ct_megnev AS CT1_SKU_name,
        CASE 	WHEN j.cc_szulo = 0 THEN i.ct_megnev 
				ELSE j.cc_megnev
    END AS CT2_pack,
    CASE 	WHEN INSTR(i.ct_megnev,"(") > 0 THEN
          LEFT(i.ct_megnev,INSTR(i.ct_megnev,"(")-1)
			ELSE CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END
    END AS CT3_product,
	CASE 	
			WHEN i.ct_megnev LIKE '%1 Day Acuvue Moist%' THEN '1 Day Acuvue Moist'
			WHEN i.ct_megnev LIKE '%1 Day Acuvue TruEye%' THEN '1 Day Acuvue TruEye'
			WHEN i.ct_megnev LIKE '%1 Day Acuvue%' THEN '1 Day Acuvue'
			WHEN i.ct_megnev LIKE '%Acuvue 2%' THEN 'Acuvue 2'
			WHEN i.ct_megnev LIKE '%Acuvue Advance%' THEN 'Acuvue Advance'
			WHEN i.ct_megnev LIKE '%Acuvue Bifocal%' THEN 'Acuvue Bifocal'
			WHEN i.ct_megnev LIKE '%Acuvue Oasys%' THEN 'Acuvue Oasys'
			WHEN i.ct_megnev LIKE '%Air Optix Aqua%' THEN 'Air Optix'
			WHEN i.ct_megnev LIKE '%Air Optix Aqua Multifocal%' THEN 'Air Optix Aqua Multifocal'
			WHEN i.ct_megnev LIKE '%Air Optix Colors%' THEN 'Air Optix Colors'
			WHEN i.ct_megnev LIKE '%Air Optix For Astigmatism%' THEN 'Air Optix'
			WHEN i.ct_megnev LIKE '%Air Optix Night & Day Aqua%' THEN 'Air Optix Night & Day Aqua'
			WHEN i.ct_megnev LIKE '%Avaira%' THEN 'Avaira'
			WHEN i.ct_megnev LIKE '%Bioclear%' THEN 'Bioclear'
			WHEN i.ct_megnev LIKE '%Biofinity Multifocal%' THEN 'Biofinity Multifocal'
			WHEN i.ct_megnev LIKE '%Biofinity%' THEN 'Biofinity'
			WHEN i.ct_megnev LIKE '%Biomedics 1 Day%' THEN 'Biomedics 1 Day'
			WHEN i.ct_megnev LIKE '%Biomedics%' THEN 'Biomedics'
			WHEN i.ct_megnev LIKE '%Biotrue ONEday%' THEN 'Biotrue ONEday'
			WHEN i.ct_megnev LIKE '%Clariti 1 Day Multifocal%' THEN 'Clariti 1 Day Multifocal'		
			WHEN i.ct_megnev LIKE '%Clariti 1 Day%' THEN 'Clariti 1 Day'		
			WHEN i.ct_megnev LIKE '%Clariti Multifocal%' THEN 'Clariti Multifocal'		
			WHEN i.ct_megnev LIKE '%Clariti%' THEN 'Clariti'	
			WHEN i.ct_megnev LIKE '%Clear Comfort%' THEN 'Clear Comfort'
			WHEN i.ct_megnev LIKE '%ColourVUE TruBlends One-Day%' THEN 'ColourVUE TruBlends One-Day'
			WHEN i.ct_megnev LIKE '%ColourVUE%' THEN 'ColourVUE'
			WHEN i.ct_megnev LIKE '%Crazy%' THEN 'Crazy'
			WHEN i.ct_megnev LIKE '%Dailies AquaComfort Plus Multifocal%' THEN 'Dailies AquaComfort Plus Multifocal'
			WHEN i.ct_megnev LIKE '%Dailies AquaComfort Plus%' THEN 'Dailies AquaComfort Plus'
			WHEN i.ct_megnev LIKE '%Dailies Total 1%' THEN 'Dailies Total 1'
			WHEN i.ct_megnev LIKE '%Expressions Colors%' THEN 'Expressions Colors'
			WHEN i.ct_megnev LIKE '%Focus Dailies All Day Comfort Progressives%' THEN 'Focus Dailies All Day Comfort Progressives'
			WHEN i.ct_megnev LIKE '%Focus SoftColors%' THEN 'Focus SoftColors'
			WHEN i.ct_megnev LIKE '%Focus Dailies All Day Comfort%' THEN 'Focus Dailies All Day Comfort'	
			WHEN i.ct_megnev LIKE '%Frequency%' THEN 'Frequency'
			WHEN i.ct_megnev LIKE '%FreshLook ColorBlends%' THEN 'FreshLook ColorBlends'	
			WHEN i.ct_megnev LIKE '%FreshLook Colors%' THEN 'FreshLook Colors'
			WHEN i.ct_megnev LIKE '%FreshLook Dimensions%' THEN 'FreshLook Dimensions'
			WHEN i.ct_megnev LIKE '%FreshLook ONE-DAY%' THEN 'FreshLook ONE-DAY'
			WHEN i.ct_megnev LIKE '%MyDay%' THEN 'MyDay'
			WHEN i.ct_megnev LIKE '%NewDay%' THEN 'NewDay'
			WHEN i.ct_megnev LIKE '%OmniFlex SofBlue%' THEN 'OmniFlex SofBlue'
			WHEN i.ct_megnev LIKE '%Precision UV%' THEN 'Precision UV'
			WHEN i.ct_megnev LIKE '%Proclear 1 Day Multifocal%' THEN 'Proclear 1 Day Multifocal'
			WHEN i.ct_megnev LIKE '%Proclear EP%' THEN 'Proclear EP'
			WHEN i.ct_megnev LIKE '%Proclear Multifocal%' THEN 'Proclear Multifocal'
			WHEN i.ct_megnev LIKE '%Proclear RX%' THEN 'Proclear RX'
			WHEN i.ct_megnev LIKE '%Proclear 1 Day%' THEN 'Proclear 1 Day'
			WHEN i.ct_megnev LIKE '%Proclear Toric XR%' THEN 'Proclear'
			WHEN i.ct_megnev LIKE '%Proclear Toric%' THEN 'Proclear'			
			WHEN i.ct_megnev LIKE '%Proclear%' THEN 'Proclear'			
			WHEN i.ct_megnev LIKE '%PureVision 2 Multi-Focal%' THEN 'PureVision 2 Multi-Focal'
			WHEN i.ct_megnev LIKE '%PureVision 2%' THEN 'PureVision 2'
			WHEN i.ct_megnev LIKE '%PureVision Multi-Focal%' THEN 'PureVision Multi-Focal'
			WHEN i.ct_megnev LIKE '%PureVision%' THEN 'PureVision'
			WHEN i.ct_megnev LIKE '%Quantum I%' THEN 'Quantum I'
			WHEN i.ct_megnev LIKE '%Quantum II%' THEN 'Quantum II'
			WHEN i.ct_megnev LIKE '%Quantum 2%' THEN 'Quantum II'
			WHEN i.ct_megnev LIKE '%Sauflon 55 UV%' THEN 'Sauflon 55 UV'
			WHEN i.ct_megnev LIKE '%Sauflon 56 UV%' THEN 'Sauflon 56 UV'
			WHEN i.ct_megnev LIKE '%Select%' THEN 'Select'
			WHEN i.ct_megnev LIKE '%SofLens Daily Disposable%' THEN 'SofLens Daily Disposable'
			WHEN i.ct_megnev LIKE '%SofLens Multi-Focal%' THEN 'SofLens Multi-Focal'			
			WHEN i.ct_megnev LIKE '%SofLens%' THEN 'SofLens'			
			WHEN i.ct_megnev LIKE '%Surevue%' THEN 'Surevue'			
			WHEN i.ct_megnev LIKE '%Zero 6%' THEN 'Zero 6'			
			ELSE 'other'
			END AS CT3_product_short,	 
    CASE 	WHEN i.ct_megnev LIKE '%Acuvue%' THEN 'Acuvue'
			WHEN i.ct_megnev LIKE '%Air Optix%' THEN 'Air Optix'
			WHEN i.ct_megnev LIKE '%All in One Light%' THEN 'All in One Light'
			WHEN i.ct_megnev LIKE '%AoSept%' THEN 'AoSept'
			WHEN i.ct_megnev LIKE '%AQuify%' THEN 'AQuify'
			WHEN i.ct_megnev LIKE '%Avaira%' THEN 'Avaira'
			WHEN i.ct_megnev LIKE '%Béres%' THEN 'Béres'
			WHEN i.ct_megnev LIKE '%Bilutin%' THEN 'Bilutin'
			WHEN i.ct_megnev LIKE '%Bioclear%' THEN 'Bioclear'
			WHEN i.ct_megnev LIKE '%Biofinity%' THEN 'Biofinity'
			WHEN i.ct_megnev LIKE '%Biomedics%' THEN 'Biomedics'
			WHEN i.ct_megnev LIKE '%Biotrue ONEday%' THEN 'Biotrue'
			WHEN i.ct_megnev LIKE '%Biotrue%' THEN 'Biotrue solutions'
			WHEN i.ct_megnev LIKE '%Blink%' THEN 'Blink'
			WHEN i.ct_megnev LIKE '%Boston%' THEN 'Boston'
			WHEN i.ct_megnev LIKE '%Clariti%' THEN 'Clariti'
			WHEN i.ct_megnev LIKE '%Clear%' THEN 'Clear'
			WHEN i.ct_megnev LIKE '%Clens%' THEN 'Clens'
			WHEN i.ct_megnev LIKE '%ColourVUE%' THEN 'ColourVUE'
			WHEN i.ct_megnev LIKE '%Comfort%' THEN 'Comfort'
			WHEN i.ct_megnev LIKE '%ComfortVue%' THEN 'ComfortVue'
			WHEN i.ct_megnev LIKE '%Complete%' THEN 'Complete'
			WHEN i.ct_megnev LIKE '%Crazy%' THEN 'Crazy'
			WHEN i.ct_megnev LIKE '%Dailies%' THEN 'Dailies'  
			WHEN i.ct_megnev LIKE '%De Rigo Group%' THEN 'De Rigo Group'  
			WHEN i.ct_megnev LIKE '%Delta%' THEN 'Delta'
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Diesel - sole%' THEN 'Sunglasses'  
			WHEN i.ct_megnev LIKE '%Dr. Chen%' THEN 'Dr. Chen'    
			WHEN i.ct_megnev LIKE '%Expressions%' THEN 'Expressions'  
			WHEN i.ct_megnev LIKE '%EyeContact PURE%' THEN 'EyeContact PURE'  
			WHEN i.ct_megnev LIKE '%Focus%' THEN 'Focus'  
			WHEN i.ct_megnev LIKE '%Frequency%' THEN 'Frequency'  
			WHEN i.ct_megnev LIKE '%FreshLook%' THEN 'FreshLook'  
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Furla - sole%' THEN 'Sunglasses'                       
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Givenchy - sole%' THEN 'Sunglasses'    
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Oxydo - vista%' THEN 'Glasses'     
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Dolce & Gabbana - vista%' THEN 'Glasses'
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Hugo Boss - vista%' THEN 'Glasses'                         
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Giorgio Armani - vista%' THEN 'Glasses'
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Jean Paul Gaultier - vista%' THEN 'Glasses'   
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Dunhill - vista' THEN 'Glasses'
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Just Cavalli - vista%' THEN 'Glasses'     
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Roberto Cavalli - vista%' THEN 'Glasses'      
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%United Colors of Benetton - vista%' THEN 'Glasses'        
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Ray-Ban - vista%' THEN 'Glasses'      
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Vogue - vista%' THEN 'Glasses'    
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Tommy Hilfiger - vista%' THEN 'Glasses'   
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Carrera - vista%' THEN 'Glasses'  
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Police - vista%' THEN 'Glasses'   
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Givenchy - vista%' THEN 'Glasses' 
			WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Sting - vista%' THEN 'Glasses'    
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Safilo - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Carrera - vista%' THEN 'Glasses'  
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Boss Orange - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Max&Co. - vista%' THEN 'Glasses'  
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Smith Optics - vista%' THEN 'Glasses' 
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Tommy Hilfiger - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%PixelFrame - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Police - sole%' THEN 'Glasses'
       WHEN i.ct_megnev LIKE '%Herbária%' THEN 'Herbária'
       WHEN i.ct_megnev LIKE '%Isomar%' THEN 'Isomar'
       WHEN i.ct_megnev LIKE '%Lutein%' THEN 'Lutein'
       WHEN i.ct_megnev LIKE '%Max OptiFresh%' THEN 'Max OptiFresh'
       WHEN i.ct_megnev LIKE '%MyDay%' THEN 'MyDay'
       WHEN i.ct_megnev LIKE '%NewDay%' THEN 'NewDay'   
       WHEN i.ct_megnev LIKE '%Ocuvite%' THEN 'Ocuvite' 
       WHEN i.ct_megnev LIKE '%OmniFlex%' THEN 'OmniFlex'
       WHEN i.ct_megnev LIKE '%OPTI-FREE%' THEN 'OPTI-FREE'
       WHEN i.ct_megnev LIKE '%Optima%' THEN 'Optima'
       WHEN i.ct_megnev LIKE '%Options%' THEN 'Options'
       WHEN i.ct_megnev LIKE '%Optive%' THEN 'Optive'
       WHEN i.ct_megnev LIKE '%Precision UV%' THEN 'Precision UV'
       WHEN i.ct_megnev LIKE '%Proclear%' THEN 'Proclear'   
       WHEN i.ct_megnev LIKE '%PureVision%' THEN 'PureVision'   
       WHEN i.ct_megnev LIKE '%Quantum%' THEN 'Quantum' 
       WHEN i.ct_megnev LIKE '%Refresh%' THEN 'Refresh' 
       WHEN i.ct_megnev LIKE '%ReNu MultiPlus%' THEN 'ReNu MultiPlus'   
       WHEN i.ct_megnev LIKE '%Sauflon Multi%' THEN 'Sauflon solutions' 
       WHEN i.ct_megnev LIKE '%Sauflon Saline%' THEN 'Sauflon solutions'    
       WHEN i.ct_megnev LIKE '%Sauflon%' THEN 'Sauflon' 
       WHEN i.ct_megnev LIKE '%Select%' THEN 'Select'   
       WHEN i.ct_megnev LIKE '%SofLens%' THEN 'SofLens' 
       WHEN i.ct_megnev LIKE '%SOLO-Care Aqua%' THEN 'SOLO-Care Aqua'                    
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Spy+ - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Chopard - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Ray-Ban - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Vogue - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Carrera - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Tommy Hilfiger - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Marc by Marc Jacobs - Sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Polaroid - sole%' THEN 'Sunglasses'                    
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%MaxMara - Sole%' THEN 'Sunglasses'                     
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Yves Saint Laurent - Sole%' THEN 'Sunglasses'                  
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Boss Orange - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Max&Co. - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Smith Optics - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.cc_szulo = 0 THEN i.ct_megnev ELSE j.cc_megnev END LIKE '%Oxydo - sole%' THEN 'Sunglasses'
       WHEN i.ct_megnev LIKE '%Surevue%' THEN 'Surevue'
       WHEN i.ct_megnev LIKE '%Synergi%' THEN 'Synergi'
       WHEN i.ct_megnev LIKE '%Systane%' THEN 'Systane'
       WHEN i.ct_megnev LIKE '%Trizyme%' THEN 'Trizyme'
       WHEN i.ct_megnev LIKE '%Ultrasilk%' THEN 'Ultrasilk'
       WHEN i.ct_megnev LIKE '%Visine%' THEN 'Visine'
       WHEN i.ct_megnev LIKE '%Zero%' THEN 'Zero'
       ELSE 'Other'
    END AS CT4_product_brand,
    CASE 	WHEN i.ct_gyarto = 'CIBA Vision' THEN 'Alcon'
			WHEN i.ct_cikksz = 'ECPURE360' THEN 'eOptika Kft.'
			ELSE i.ct_gyarto
    END AS CT5_manufacturer,
    i.ct_csoport,
    i.ct_ean AS barcode,
    i.ct_vtsz AS goods_nomenclature_code,
    i.ct_kiszer AS packaging,
    i.ct_kiszmenny AS quantity_in_a_pack,
    i.ct_beszido AS estimated_supplier_lead_time
FROM ab_cikkto AS i LEFT JOIN ab_cikkcsto AS j
ON i.ct_csoport = j.cc_azon;




DROP TABLE IF EXISTS INVOICES_00f;
CREATE TABLE IF NOT EXISTS INVOICES_00f
SELECT DISTINCT a.*, b.*,
        CASE WHEN c.parent_id IN (4,5,6,7,77,101,124) THEN 'Contact lenses'
           WHEN c.parent_id = 2     THEN 'Solutions'
           WHEN c.parent_id = 3     THEN 'Eye drops'
           WHEN c.parent_id = 81    THEN 'Sunglasses'
           WHEN c.parent_id = 175   THEN 'Vitamins'
           ELSE 'Other'
        END AS product_group,
        CASE WHEN c.is_spheric = 1 THEN 'Spheric'
           WHEN c.is_toric = 1 THEN 'Toric'
           WHEN c.is_multifocal = 1 THEN 'Multifocal'
           ELSE 'Other'
        END AS lens_type,
        c.is_color,
        c.using_time AS wear_days,
        c.frequency AS wear_duration,
        c.qty_per_storageunit,
        c.box_width,
        c.box_height,
        c.box_depth
FROM INVOICES_00e AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
LEFT JOIN IN_product_list AS c
ON
    CASE
    WHEN c.product_cat <> 1 THEN b.CT2_pack = c.product_name
    ELSE b.ct_csoport = c.sql_id
    END
LIMIT 0;


ALTER TABLE INVOICES_00f ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `reference_id` (`reference_id`) USING BTREE;

INSERT INTO INVOICES_00f
SELECT DISTINCT a.*, b.*,
        CASE WHEN c.parent_id IN (4,5,6,7,77,101,124) THEN 'Contact lenses'
           WHEN c.parent_id = 2     THEN 'Solutions'
           WHEN c.parent_id = 3     THEN 'Eye drops'
           WHEN c.parent_id = 81    THEN 'Sunglasses'
           WHEN c.parent_id = 175   THEN 'Vitamins'
           ELSE 'Other'
        END AS product_group,
        CASE WHEN c.is_spheric = 1 THEN 'Spheric'
           WHEN c.is_toric = 1 THEN 'Toric'
           WHEN c.is_multifocal = 1 THEN 'Multifocal'
           ELSE 'Other'
        END AS lens_type,
        c.is_color,
        c.using_time AS wear_days,
        c.frequency AS wear_duration,
        c.qty_per_storageunit,
        c.box_width,
        c.box_height,
        c.box_depth
FROM INVOICES_00e AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
LEFT JOIN IN_product_list AS c
ON
    CASE 
    WHEN c.product_cat <> 1 THEN b.CT2_pack = c.product_name
    ELSE b.ct_csoport = c.sql_id
    END
;


DROP TABLE IF EXISTS INVOICES_00f2;
CREATE TABLE IF NOT EXISTS INVOICES_00f2 LIKE INVOICES_00f;
INSERT INTO INVOICES_00f2 SELECT * FROM INVOICES_00f;