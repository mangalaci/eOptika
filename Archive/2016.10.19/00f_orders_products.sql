DROP TABLE IF EXISTS ab_cikkto_full;
CREATE TABLE IF NOT EXISTS ab_cikkto_full
SELECT
    i.sku AS CT1_SKU,
    i.name_hu AS CT1_SKU_name,
    i.name_hu AS CT2_pack,
    i.name_hu AS CT3_product,
    i.name_hu AS CT3_product_short,
    i.name_hu AS CT4_product_brand,
	i.manufacturer AS CT5_manufacturer,
    i.group_id,
    i.barcode,
    i.goods_nomenclature_code,
    i.packaging,
    i.quantity_in_a_pack,
    i.estimated_supplier_lead_time,
	i.net_weight_in_kg
FROM items AS i LEFT JOIN zoho_item_groups AS j
ON i.group_id = j.sql_id
LIMIT 0;
ALTER TABLE ab_cikkto_full ADD PRIMARY KEY (`CT1_SKU`) USING BTREE;
ALTER TABLE ab_cikkto_full ADD INDEX `group_id` (`group_id`) USING BTREE;
ALTER TABLE `ab_cikkto_full` ADD `lens_bc` DECIMAL(6,2) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_pwr` DECIMAL(6,2) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_cyl` DECIMAL(6,2) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_ax` DECIMAL(6,2) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_dia` DECIMAL(6,2) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_add` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `ab_cikkto_full` ADD `lens_clr` VARCHAR(10) DEFAULT NULL;



INSERT INTO ab_cikkto_full
SELECT DISTINCT 
    i.sku AS CT1_SKU,
        i.name_hu AS CT1_SKU_name,
        j.general_name AS CT2_pack,
    CASE 	WHEN INSTR(i.name_hu,"(") > 0 THEN
          LEFT(i.name_hu,INSTR(i.name_hu,"(")-1)
			ELSE CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END
    END AS CT3_product,
	CASE 	
			WHEN i.name_hu LIKE '%Engedmény%' THEN 'Engedmény'
			WHEN i.name_hu LIKE '%1 Day Acuvue Moist%' THEN '1 Day Acuvue Moist'
			WHEN i.name_hu LIKE '%1 Day Acuvue TruEye%' THEN '1 Day Acuvue TruEye'
			WHEN i.name_hu LIKE '%1 Day Acuvue%' THEN '1 Day Acuvue'
			WHEN i.name_hu LIKE '%Acuvue 2%' THEN 'Acuvue 2'
			WHEN i.name_hu LIKE '%Acuvue Advance%' THEN 'Acuvue Advance'
			WHEN i.name_hu LIKE '%Acuvue Bifocal%' THEN 'Acuvue Bifocal'
			WHEN i.name_hu LIKE '%Acuvue Oasys%' THEN 'Acuvue Oasys'
			WHEN i.name_hu LIKE '%Air Optix Aqua%' THEN 'Air Optix'
			WHEN i.name_hu LIKE '%Air Optix Aqua Multifocal%' THEN 'Air Optix Aqua Multifocal'
			WHEN i.name_hu LIKE '%Air Optix Colors%' THEN 'Air Optix Colors'
			WHEN i.name_hu LIKE '%Air Optix For Astigmatism%' THEN 'Air Optix'
			WHEN i.name_hu LIKE '%Air Optix Night & Day Aqua%' THEN 'Air Optix Night & Day Aqua'
			WHEN i.name_hu LIKE '%Avaira%' THEN 'Avaira'
			WHEN i.name_hu LIKE '%Bioclear%' THEN 'Bioclear'
			WHEN i.name_hu LIKE '%Biofinity Multifocal%' THEN 'Biofinity Multifocal'
			WHEN i.name_hu LIKE '%Biofinity%' THEN 'Biofinity'
			WHEN i.name_hu LIKE '%Biomedics 1 Day%' THEN 'Biomedics 1 Day'
			WHEN i.name_hu LIKE '%Biomedics%' THEN 'Biomedics'
			WHEN i.name_hu LIKE '%Biotrue ONEday%' THEN 'Biotrue ONEday'
			WHEN i.name_hu LIKE '%Clariti 1 Day Multifocal%' THEN 'Clariti 1 Day Multifocal'		
			WHEN i.name_hu LIKE '%Clariti 1 Day%' THEN 'Clariti 1 Day'		
			WHEN i.name_hu LIKE '%Clariti Multifocal%' THEN 'Clariti Multifocal'		
			WHEN i.name_hu LIKE '%Clariti%' THEN 'Clariti'	
			WHEN i.name_hu LIKE '%Clear Comfort%' THEN 'Clear Comfort'
			WHEN i.name_hu LIKE '%ColourVUE TruBlends One-Day%' THEN 'ColourVUE TruBlends One-Day'
			WHEN i.name_hu LIKE '%ColourVUE%' THEN 'ColourVUE'
			WHEN i.name_hu LIKE '%Crazy%' THEN 'Crazy'
			WHEN i.name_hu LIKE '%Dailies AquaComfort Plus Multifocal%' THEN 'Dailies AquaComfort Plus Multifocal'
			WHEN i.name_hu LIKE '%Dailies AquaComfort Plus%' THEN 'Dailies AquaComfort Plus'
			WHEN i.name_hu LIKE '%Dailies Total 1%' THEN 'Dailies Total 1'
			WHEN i.name_hu LIKE '%Expressions Colors%' THEN 'Expressions Colors'
			WHEN i.name_hu LIKE '%Focus Dailies All Day Comfort Progressives%' THEN 'Focus Dailies All Day Comfort Progressives'
			WHEN i.name_hu LIKE '%Focus SoftColors%' THEN 'Focus SoftColors'
			WHEN i.name_hu LIKE '%Focus Dailies All Day Comfort%' THEN 'Focus Dailies All Day Comfort'	
			WHEN i.name_hu LIKE '%Frequency%' THEN 'Frequency'
			WHEN i.name_hu LIKE '%FreshLook ColorBlends%' THEN 'FreshLook ColorBlends'	
			WHEN i.name_hu LIKE '%FreshLook Colors%' THEN 'FreshLook Colors'
			WHEN i.name_hu LIKE '%FreshLook Dimensions%' THEN 'FreshLook Dimensions'
			WHEN i.name_hu LIKE '%FreshLook ONE-DAY%' THEN 'FreshLook ONE-DAY'
			WHEN i.name_hu LIKE '%MyDay%' THEN 'MyDay'
			WHEN i.name_hu LIKE '%NewDay%' THEN 'NewDay'
			WHEN i.name_hu LIKE '%OmniFlex SofBlue%' THEN 'OmniFlex SofBlue'
			WHEN i.name_hu LIKE '%Precision UV%' THEN 'Precision UV'
			WHEN i.name_hu LIKE '%Proclear 1 Day Multifocal%' THEN 'Proclear 1 Day Multifocal'
			WHEN i.name_hu LIKE '%Proclear EP%' THEN 'Proclear EP'
			WHEN i.name_hu LIKE '%Proclear Multifocal%' THEN 'Proclear Multifocal'
			WHEN i.name_hu LIKE '%Proclear RX%' THEN 'Proclear RX'
			WHEN i.name_hu LIKE '%Proclear 1 Day%' THEN 'Proclear 1 Day'
			WHEN i.name_hu LIKE '%Proclear Toric XR%' THEN 'Proclear'
			WHEN i.name_hu LIKE '%Proclear Toric%' THEN 'Proclear'			
			WHEN i.name_hu LIKE '%Proclear%' THEN 'Proclear'			
			WHEN i.name_hu LIKE '%PureVision 2 Multi-Focal%' THEN 'PureVision 2 Multi-Focal'
			WHEN i.name_hu LIKE '%PureVision 2%' THEN 'PureVision 2'
			WHEN i.name_hu LIKE '%PureVision Multi-Focal%' THEN 'PureVision Multi-Focal'
			WHEN i.name_hu LIKE '%PureVision%' THEN 'PureVision'
			WHEN i.name_hu LIKE '%Quantum I%' THEN 'Quantum I'
			WHEN i.name_hu LIKE '%Quantum II%' THEN 'Quantum II'
			WHEN i.name_hu LIKE '%Quantum 2%' THEN 'Quantum II'
			WHEN i.name_hu LIKE '%Sauflon 55 UV%' THEN 'Sauflon 55 UV'
			WHEN i.name_hu LIKE '%Sauflon 56 UV%' THEN 'Sauflon 56 UV'
			WHEN i.name_hu LIKE '%Select%' THEN 'Select'
			WHEN i.name_hu LIKE '%SofLens Daily Disposable%' THEN 'SofLens Daily Disposable'
			WHEN i.name_hu LIKE '%SofLens Multi-Focal%' THEN 'SofLens Multi-Focal'			
			WHEN i.name_hu LIKE '%SofLens%' THEN 'SofLens'			
			WHEN i.name_hu LIKE '%Surevue%' THEN 'Surevue'			
			WHEN i.name_hu LIKE '%Zero 6%' THEN 'Zero 6'			
			ELSE 'other'
			END AS CT3_product_short,
    CASE 	WHEN i.name_hu LIKE '%Acuvue%' THEN 'Acuvue'
			WHEN i.name_hu LIKE '%AquaComfort%' THEN 'Dailies'
			WHEN i.name_hu LIKE '%Dailies Total 1%' THEN 'Dailies'
			WHEN i.name_hu LIKE '%Air Optix%' THEN 'Air Optix'
			WHEN i.name_hu LIKE '%All in One Light%' THEN 'All in One Light'
			WHEN i.name_hu LIKE '%AoSept%' THEN 'AoSept'
			WHEN i.name_hu LIKE '%AQuify%' THEN 'AQuify'
			WHEN i.name_hu LIKE '%Avaira%' THEN 'Avaira'
			WHEN i.name_hu LIKE '%Béres%' THEN 'Béres'
			WHEN i.name_hu LIKE '%Bilutin%' THEN 'Bilutin'
			WHEN i.name_hu LIKE '%Bioclear%' THEN 'Bioclear'
			WHEN i.name_hu LIKE '%Biofinity%' THEN 'Biofinity'
			WHEN i.name_hu LIKE '%Biomedics%' THEN 'Biomedics'
			WHEN i.name_hu LIKE '%Biotrue ONEday%' THEN 'Biotrue'
			WHEN i.name_hu LIKE '%Biotrue%' THEN 'Biotrue'
			WHEN i.name_hu LIKE '%Blink%' THEN 'Blink'
			WHEN i.name_hu LIKE '%Boston%' THEN 'Boston'
			WHEN i.name_hu LIKE '%Clariti%' THEN 'Clariti'
			WHEN i.name_hu LIKE '%Clear Comfort%' THEN 'Clear Comfort'
			WHEN i.name_hu LIKE '%Clens%' THEN 'Clens'
			WHEN i.name_hu LIKE '%ColourVUE%' THEN 'ColourVUE'
			WHEN i.name_hu LIKE '%ComfortVue%' THEN 'ComfortVue'
			WHEN i.name_hu LIKE '%Complete%' THEN 'Complete'
			WHEN i.name_hu LIKE '%Crazy%' THEN 'Crazy'
			WHEN i.name_hu LIKE '%De Rigo Group%' THEN 'De Rigo Group'  
			WHEN i.name_hu LIKE '%Delta%' THEN 'Delta'
			WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Diesel - sole%' THEN 'Sunglasses'  
			WHEN i.name_hu LIKE '%Dr. Chen%' THEN 'Dr. Chen'    
			WHEN i.name_hu LIKE '%Expressions%' THEN 'Expressions'  
			WHEN i.name_hu LIKE '%EyeContact PURE%' THEN 'EyeContact PURE'  
			WHEN i.name_hu LIKE '%Focus%' THEN 'Focus'  
			WHEN i.name_hu LIKE '%Frequency%' THEN 'Frequency'  
       WHEN i.name_hu LIKE '%FreshLook%' THEN 'FreshLook'  
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Furla - sole%' THEN 'Sunglasses'                       
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Givenchy - sole%' THEN 'Sunglasses'    
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Oxydo - vista%' THEN 'Glasses'     
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Dolce & Gabbana - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Hugo Boss - vista%' THEN 'Glasses'                         
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Giorgio Armani - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Jean Paul Gaultier - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Dunhill - vista' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Just Cavalli - vista%' THEN 'Glasses'     
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Roberto Cavalli - vista%' THEN 'Glasses'      
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%United Colors of Benetton - vista%' THEN 'Glasses'        
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Ray-Ban - vista%' THEN 'Glasses'      
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Vogue - vista%' THEN 'Glasses'    
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Tommy Hilfiger - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Carrera - vista%' THEN 'Glasses'  
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Police - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Givenchy - vista%' THEN 'Glasses' 
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Sting - vista%' THEN 'Glasses'    
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Safilo - vista%' THEN 'Glasses'   
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Carrera - vista%' THEN 'Glasses'  
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Boss Orange - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Max&Co. - vista%' THEN 'Glasses'  
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Smith Optics - vista%' THEN 'Glasses' 
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Tommy Hilfiger - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%PixelFrame - vista%' THEN 'Glasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Gant - vista%' THEN 'Glasses'
       WHEN i.name_hu LIKE '%Herbária%' THEN 'Herbária'
       WHEN i.name_hu LIKE '%Isomar%' THEN 'Isomar'
       WHEN i.name_hu LIKE '%Lutein%' THEN 'Lutein'
       WHEN i.name_hu LIKE '%Max OptiFresh%' THEN 'Max OptiFresh'
       WHEN i.name_hu LIKE '%MyDay%' THEN 'MyDay'
       WHEN i.name_hu LIKE '%NewDay%' THEN 'NewDay'   
       WHEN i.name_hu LIKE '%Ocuvite%' THEN 'Ocuvite' 
       WHEN i.name_hu LIKE '%OmniFlex%' THEN 'OmniFlex'
       WHEN i.name_hu LIKE '%OPTI-FREE%' THEN 'Opti-free'
       WHEN i.name_hu LIKE '%Optima%' THEN 'Optima'
       WHEN i.name_hu LIKE '%Options%' THEN 'Options'
       WHEN i.name_hu LIKE '%Optive%' THEN 'Optive'
       WHEN i.name_hu LIKE '%Precision UV%' THEN 'Precision UV'
       WHEN i.name_hu LIKE '%Proclear%' THEN 'Proclear'   
       WHEN i.name_hu LIKE '%PureVision%' THEN 'PureVision'   
       WHEN i.name_hu LIKE '%Quantum%' THEN 'Quantum' 
       WHEN i.name_hu LIKE '%Refresh%' THEN 'Refresh'
       WHEN i.name_hu LIKE '%Etikett - ReNu MultiPlus%' THEN 'Anyagok - Teréz körút'
       WHEN LOWER(i.name_hu) LIKE '%termékleírás%' THEN 'Anyagok - Teréz körút'
	   WHEN LOWER(i.name_hu) LIKE '%termékcímke%' THEN 'Anyagok - Teréz körút'
       WHEN i.name_hu LIKE '%ReNu MultiPlus%' THEN 'ReNu'
       WHEN i.name_hu LIKE '%ReNu MPS%' THEN 'ReNu'	   
       WHEN i.name_hu LIKE '%Sauflon Multi%' THEN 'Sauflon solutions'
       WHEN i.name_hu LIKE '%Sauflon Saline%' THEN 'Sauflon solutions'
       WHEN i.name_hu LIKE '%Sauflon%' THEN 'Sauflon'
       WHEN i.name_hu LIKE '%Select%' THEN 'Select'
       WHEN i.name_hu LIKE '%SofLens%' THEN 'SofLens'
       WHEN i.name_hu LIKE '%SOLO-Care Aqua%' THEN 'SOLO-Care Aqua'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Spy+ - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Chopard - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Ray-Ban - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Vogue - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Carrera - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Tommy Hilfiger - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Marc by Marc Jacobs - Sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Polaroid - sole%' THEN 'Sunglasses'                    
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%MaxMara - Sole%' THEN 'Sunglasses'                     
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Yves Saint Laurent - Sole%' THEN 'Sunglasses'                  
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Boss Orange - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Max&Co. - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Smith Optics - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Oxydo - sole%' THEN 'Sunglasses'
       WHEN CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.general_name END LIKE '%Police - sole%' THEN 'Sunglasses'	   
       WHEN i.name_hu LIKE '%Surevue%' THEN 'Surevue'
       WHEN i.name_hu LIKE '%Synergi%' THEN 'Synergi'
       WHEN i.name_hu LIKE '%Systane%' THEN 'Systane'
       WHEN i.name_hu LIKE '%Trizyme%' THEN 'Trizyme'
       WHEN i.name_hu LIKE '%Ultrasilk%' THEN 'Ultrasilk'
       WHEN i.name_hu LIKE '%Visine%' THEN 'Visine'
       WHEN i.name_hu LIKE '%Zero%' THEN 'Zero'
	   WHEN i.name_hu LIKE '%Szemüveglencse%' THEN 'Lenses'
	   WHEN i.name_hu LIKE '% lencse%' THEN 'Lenses'
	   WHEN LOWER(i.name_hu) LIKE '%törlőkendő%' THEN 'Napkins'
	   WHEN i.name_hu LIKE '%LG 22MP55HQ-P monitor%' THEN 'Tárgyi eszközök - Teréz körút'
	   WHEN i.name_hu LIKE '%Police Pure DNA%' THEN 'Parfümök'
	   WHEN i.name_hu LIKE '%Police Dark EDT%' THEN 'Parfümök'
	   WHEN i.name_hu LIKE '%Police Caribbean EDT%' THEN 'Parfümök'
	   WHEN i.name_hu LIKE '%Eyeye%' THEN 'Other solutions'
	   WHEN i.name_hu LIKE '%EasySept Hydro+%' THEN 'Other solutions'	   
	   WHEN i.name_hu LIKE '%EasySept Hydro+%' THEN 'Other eyedrops'
	   WHEN i.name_hu LIKE '%Sensitive Eyes%' THEN 'Other eyedrops'
	   WHEN i.name_hu LIKE '%Comfort Drops%' THEN 'Other eyedrops'
	   WHEN i.name_hu LIKE '% szár%' THEN 'Sides of spectacles'	   
	   WHEN i.name_hu LIKE '% papucs%' THEN 'Slippers'
	   WHEN i.name_hu LIKE '% táska%' THEN 'Bags'
	   WHEN i.name_hu LIKE '%Tok%' THEN 'Lense case'
	   WHEN i.name_hu LIKE '%tároló tok%' THEN 'Lense case'
	   WHEN i.name_hu LIKE '%fülhallgató%' THEN 'Headset'
	   WHEN i.name_hu LIKE '%Szemüvegtok%' THEN 'Spectacle-case'
       ELSE 'Other'
    END AS CT4_product_brand,
	    CASE 	WHEN j.item_manufacturer_name = 'CIBA Vision' THEN 'Alcon'
				ELSE j.item_manufacturer_name
    END AS CT5_manufacturer,
    i.group_id,
    i.barcode,
    i.goods_nomenclature_code,
    i.packaging,
    i.quantity_in_a_pack,
    i.estimated_supplier_lead_time,
	i.net_weight_in_kg,
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) THEN SUBSTR(i.name_hu, LOCATE('BC: ',i.name_hu)+4, LOCATE('PWR',i.name_hu) - LOCATE('BC:',i.name_hu)- 6)
                         ELSE NULL
					END AS lens_bc,
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('PWR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('PWR: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_pwr,
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('CYL: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CYL: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_cyl,					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('AX: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('AX: ',i.name_hu)+4, 4)
                         ELSE NULL
					END AS lens_ax,
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('DIA: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('DIA: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_dia,	
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('ADD: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('ADD: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_add,					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('CLR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CLR: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_clr
FROM items AS i LEFT JOIN zoho_item_groups AS j
ON i.group_id = j.sql_id
WHERE i.name_hu NOT IN ('Engedmények, kuponok', 'Teszt', 'ajandek', 'Súly korrekció', 'Egyedi súly korrekció', 'Színes', 'Engedmények, kuponok', 'KUPONKOD', 'Kellékek', 'SZEPSZEMEK kuponkód', 'Szállítási díjak', 'Szállítási díj', 'SZEPSZEMEK kuponkód')
AND i.name_hu NOT LIKE '%ajándékutalvány%'
AND i.name_hu NOT LIKE '%kuponkód%'
AND i.name_hu NOT LIKE 'kuponok'
;


DROP TABLE IF EXISTS ORDERS_00f;
CREATE TABLE IF NOT EXISTS ORDERS_00f
SELECT DISTINCT a.*, b.*,
        c.group_eng_corrected AS product_group,
        CASE WHEN c.is_spheric = 1 THEN 'Spheric'
           WHEN c.is_toric = 1 THEN 'Toric'
           WHEN c.is_multifocal = 1 THEN 'Multifocal'
           ELSE 'Other'
        END AS lens_type,
        c.is_color,
        c.using_time AS wear_days,
        c.frequency AS wear_duration,
        c.qty_per_storage_unit,
        c.box_width,
        c.box_height,
        c.box_depth
FROM ORDERS_00e AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
LEFT JOIN zoho_item_groups AS c
ON
    CASE
    WHEN c.is_item_group = 1 THEN b.CT2_pack = c.general_name
    ELSE b.group_id = c.sql_id
    END
LIMIT 0;



ALTER TABLE ORDERS_00f ADD `pack_size` FLOAT(10,2) DEFAULT NULL;
ALTER TABLE ORDERS_00f ADD `package_unit` VARCHAR(32) DEFAULT NULL;
ALTER TABLE ORDERS_00f ADD `lens_material` VARCHAR(64) DEFAULT NULL;
ALTER TABLE ORDERS_00f ADD `product_introduction_dt` DATE DEFAULT NULL;
ALTER TABLE ORDERS_00f ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00f ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE ORDERS_00f ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00f ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE ORDERS_00f ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE ORDERS_00f ADD INDEX `reference_id` (`reference_id`) USING BTREE;

INSERT INTO ORDERS_00f
SELECT DISTINCT a.*, b.*,
        c.group_eng_corrected AS product_group,
        CASE WHEN c.is_spheric = 1 THEN 'Spheric'
           WHEN c.is_toric = 1 THEN 'Toric'
           WHEN c.is_multifocal = 1 THEN 'Multifocal'
           ELSE 'Other'
        END AS lens_type,
        c.is_color,
        c.using_time AS wear_days,
        c.frequency AS wear_duration,
        c.qty_per_storage_unit,
        c.box_width,
        c.box_height,
        c.box_depth,
		c.pack_size,
		c.package_unit,
		'SiHi' AS lens_material,
		NULL AS product_introduction_dt
FROM ORDERS_00e AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
LEFT JOIN (SELECT *, 
					CASE WHEN LOCATE('x', SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4)) = 0
						 THEN SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4)
						 ELSE SUBSTR(SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4), 1, LOCATE('x', SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4))-1) * REPLACE(SUBSTR(SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4), LOCATE('x', SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4))+1, LENGTH(SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name)-4))),',', '.')
					END AS pack_size,
                    CASE WHEN LOCATE('ml', SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name))) > 0 THEN 'ml'
                    	 WHEN LOCATE('db', SUBSTR(general_name, LOCATE('(',general_name)+1, LOCATE(')',general_name)-LOCATE('(',general_name))) > 0 THEN 'db'
                         ELSE 'other'
					END AS package_unit
			FROM zoho_item_groups) AS c
ON
    CASE 
    WHEN c.is_item_group = 1 THEN b.CT2_pack = c.general_name
    ELSE b.group_id = c.sql_id
    END
;

UPDATE
  ORDERS_00f AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM ORDERS_00f GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;



DROP TABLE IF EXISTS ORDERS_00f2;
CREATE TABLE IF NOT EXISTS ORDERS_00f2 LIKE ORDERS_00f;
INSERT INTO ORDERS_00f2 SELECT * FROM ORDERS_00f;