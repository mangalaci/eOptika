UPDATE items SET name_hu = REPLACE(name_hu,'Alapértelmezett', '') WHERE LOWER(name_hu) LIKE '%alapértelmezett%';


UPDATE
  items AS C
  LEFT JOIN IN_frame_categories AS A 
  ON C.sku = A.sku
SET 
	C.frame_color_front = A.frame_color_front,
	C.frame_shape = A.frame_shape,
	C.frame_size_D1 = A.frame_size_D1,
	C.frame_size_D2 = A.frame_size_D2,
	C.frame_size_D3 = A.frame_size_D3,
	C.frame_size_D4 = A.frame_size_D4,
	C.frame_size_D5 = A.frame_size_D5,
	C.frame_size_D6 = A.frame_size_D6,
	C.frame_material = A.frame_material,
	C.frame_flex = A.frame_flex,
	C.frame_matt = A.frame_matt,
	C.best_seller = A.best_seller
;



DROP TABLE IF EXISTS ab_cikkto_full;
CREATE TABLE IF NOT EXISTS ab_cikkto_full
SELECT DISTINCT
    i.sku AS CT1_SKU,
    i.name_hu AS CT1_SKU_name,

	CASE 	WHEN SUBSTR(i.sku,1,2) = '17' THEN i.sku
			WHEN x.sku is not null then x.base_sku
			WHEN i.group_id in (347, 348, 358, 351, 368, 395) THEN SUBSTRING_INDEX(i.sku,'_',2)
			WHEN j.parent_id NOT IN (0) AND j.sku_eoptika_hu IS NOT NULL THEN j.sku_eoptika_hu
			WHEN j.parent_id IN (0) THEN i.sku
			WHEN j.general_name IS NULL AND i.group_id = 220 and INSTR(i.sku,"+") > 0 THEN LEFT(i.sku,INSTR(i.sku,"+")-1)
			ELSE 'Unknown'
	END AS CT2_sku,
		
    CASE 	WHEN j.parent_id IN (0) THEN i.name_hu
			WHEN x.sku is not null then x.base_sku
			WHEN i.group_id in (347, 348, 358, 351, 368, 395) THEN SUBSTRING_INDEX(i.sku,'_',2)
			WHEN j.general_name IS NOT NULL THEN j.general_name
			WHEN j.general_name IS NULL AND i.group_id = 220 and INSTR(i.sku,"+") > 0 THEN LEFT(i.sku,INSTR(i.sku,"+")-1)
			ELSE 'Unknown'
	END AS CT2_pack,
	
    CASE 	WHEN x.sku is not null then x.model
			WHEN i.group_id in (347, 348, 358, 351, 368, 395) THEN 
				case 	when RIGHT(SUBSTRING_INDEX(i.sku,'_',2), 1) in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') 
						then LEFT(SUBSTRING_INDEX(i.sku,'_',2),length(SUBSTRING_INDEX(i.sku,'_',2))-1) else SUBSTRING_INDEX(i.sku,'_',2) END
			WHEN (j.parent_id IN (8) OR i.group_id = 220) THEN i.name_hu
			WHEN INSTR(i.name_hu,"(") > 0 THEN LEFT(i.name_hu,INSTR(i.name_hu,"(")-1)
			ELSE CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.CT3_product END
    END AS CT3_product,

    CASE 	WHEN x.sku is not null then x.model
			WHEN i.group_id in (347, 348, 358, 351, 368, 395) THEN 
				case 	when RIGHT(SUBSTRING_INDEX(i.sku,'_',2), 1) in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') 
						then LEFT(SUBSTRING_INDEX(i.sku,'_',2),length(SUBSTRING_INDEX(i.sku,'_',2))-1) else SUBSTRING_INDEX(i.sku,'_',2) END	
			WHEN (j.parent_id IN (8) OR i.group_id = 220) THEN i.name_hu
			WHEN INSTR(i.name_hu,"(") > 0 THEN LEFT(i.name_hu,INSTR(i.name_hu,"(")-1)
			ELSE CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.CT3_product_short END
    END AS CT3_product_short,

	CASE 	WHEN SUBSTR(i.sku,1,2) = '17' THEN 'Service'
			/*WHEN j.parent_id IN (0, 2, 3, 4) THEN SUBSTR(i.name_hu,1,INSTR(i.name_hu," "))*/
			WHEN j.CT4_product_brand IS NOT NULL THEN j.CT4_product_brand
			WHEN j.parent_id IN (0) THEN LEFT(i.name_hu,INSTR(i.name_hu," ")-1)
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Roberto Cavalli%' THEN 'Roberto Cavalli'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Helly Hansen%' THEN 'Helly Hansen'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Bollé%' THEN 'Bollé'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Silver%' THEN 'Silver'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'BeYu%' THEN 'BeYu'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Liz Claiborne%' THEN 'Liz Claiborne'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Exté by Versace%' THEN 'Exté by Versace'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Converse%' THEN 'Converse'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Ermenegildo Zegna%' THEN 'Ermenegildo Zegna'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Pepe Jeans%' THEN 'Pepe Jeans'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Ray-Ban%' THEN 'Ray-Ban'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Police%' THEN 'Police'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Chopard%' THEN 'Chopard'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Vogue%' THEN 'Vogue'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Swarovski%' THEN 'Swarovski'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Hugo Boss%' THEN 'Boss'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Balmain%' THEN 'Balmain'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Brochelli%' THEN 'Brochelli'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Broadway%' THEN 'Broadway'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Calvin Klein%' THEN 'Calvin Klein'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Emilio Pucci%' THEN 'Emilio Pucci'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Freudenhaus%' THEN 'Freudenhaus'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Gianfranco Ferrè%' THEN 'Gianfranco Ferrè'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Hackett%' THEN 'Hackett London'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Jette %' THEN 'Jette Joop'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Karl Lagerfeld%' THEN 'Karl Lagerfeld'
			WHEN i.group_id IN (220,334,335) AND i.name_hu LIKE 'Kenzo %' THEN 'Kenzo'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Lacoste %' THEN 'Lacoste'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Mont Blanc%' THEN 'Mont Blanc'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Metzler %' THEN 'Unknown'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Osaki %' THEN 'Osaki'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Pepe Jeans%' THEN 'Pepe Jeans'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Replay%' THEN 'Replay'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Ventos%' THEN 'Ventos'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Dolce %' THEN 'Dolce & Gabbana'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Salvatore Ferragamo%' THEN 'Salvatore Ferragamo'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Ralph by Ralph Lauren%' THEN 'Ralph by Ralph Lauren'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Harley-Davidson%' THEN 'Harley-Davidson'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Candies Zola%' THEN 'Candies Zola'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Ted Baker%' THEN 'Ted Baker'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Sisley%' THEN 'Sisley'
			when i.group_id IN (220,334,335) AND i.name_hu LIKE 'Rampage%' THEN 'Rampage'
			/* szemüveglencsék */
			when j.group_eng_corrected = 'Lenses for spectacles' then			
				CASE	WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '_', '')) > 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '_', 2), ' ', -1)
						WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '_', '')) = 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '_', 1), ' ', -1)
						WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '+', '')) > 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '+', 2), ' ', -1)
						WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '+', '')) = 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '+', 1), ' ', -1)
						WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '-', '')) > 0 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '-', 1), ' ', -1)
						WHEN LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '|', '')) > 0 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '|', 1), ' ', -1)
				END
			ELSE 'Other'
	END AS CT4_product_brand,

	CASE 	WHEN i.manufacturer = 'CIBA Vision' THEN 'Alcon'
			WHEN i.manufacturer = '' AND i.group_id = 151 THEN 'Essilor'
			WHEN i.manufacturer = '' AND i.group_id = 351 THEN 'Sunoptic.com GmbH'
			WHEN i.manufacturer = '' THEN 'Unknown'
			WHEN SUBSTR(i.sku,1,2) = '17' THEN 'Service'
			ELSE i.manufacturer
    END AS CT5_manufacturer,
		
    i.group_id,
    i.barcode,
    i.goods_nomenclature_code,
    i.packaging,
    j.packaging AS quantity_in_a_pack,
    i.estimated_supplier_lead_time,
	i.net_weight_in_kg,
	
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) THEN SUBSTR(i.name_hu, LOCATE('BC: ',i.name_hu)+4, LOCATE('PWR',i.name_hu) - LOCATE('BC:',i.name_hu)- 6)
                         ELSE NULL
					END AS lens_bc,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('PWR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('PWR: ',i.name_hu)+5, 5)
						WHEN j.group_eng_corrected = 'Lenses for spectacles' THEN
						CASE 	WHEN LOCATE('PWR: ',i.name_hu) > 0 THEN REPLACE(SUBSTR(i.name_hu, LOCATE('PWR: ',i.name_hu)+5, 5),',', '')
								WHEN LOCATE('SPH: ',i.name_hu) > 0 THEN REPLACE(SUBSTR(i.name_hu, LOCATE('SPH: ',i.name_hu)+5, 5),',', '')
							ELSE 
								replace(case 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),1,6) 
								end, 'D', '')

							END
					ELSE NULL
					END AS lens_pwr,
					
					
					case 	when j.parent_id in (4,5,6,7,77,101,124) AND LOCATE('CYL: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CYL: ',i.name_hu)+5, 5)
							WHEN j.group_eng_corrected = 'Lenses for spectacles' THEN
								CASE 	WHEN LOCATE('CYL: ',i.name_hu) > 0 THEN REPLACE(SUBSTR(i.name_hu, LOCATE('CYL: ',i.name_hu)+5, 5),',', '')
										ELSE 
						replace(case 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',1),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',1),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',1),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',2),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',2),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',2),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',3),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',3),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',3),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',4),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',4),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',4),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',5),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',5),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',5),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',6),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',6),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',6),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',7),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',7),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',7),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',8),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',8),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',8),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',9),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',9),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',9),' ',-1),1,6) 
									when SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',10),' ',-1) LIKE '+%.%D%' or SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',10),' ',-1) LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(substring(name_hu,IF(COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)) < COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)), COALESCE(NULLIF(locate('0D', name_hu), 0), locate('5D', name_hu)), COALESCE(NULLIF(locate('5D', name_hu), 0), locate('0D', name_hu)))+2),' ',10),' ',-1),1,6) 
									else '0.00'
								end, 'D', '')
								END
							ELSE NULL
					END AS lens_cyl,
					
					CASE WHEN (j.parent_id IN (4,5,6,7,77,101,124) OR j.group_eng_corrected = 'Lenses for spectacles') AND LOCATE('AX: ',i.name_hu) > 0 THEN REPLACE(SUBSTR(i.name_hu, LOCATE('AX: ',i.name_hu)+4, 4), '°', '')
						 ELSE NULL
					END AS lens_ax,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('DIA: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('DIA: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_dia,

					case 	when j.parent_id in (4,5,6,7,77,101,124) AND LOCATE('ADD: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('ADD: ',i.name_hu)+5, 5)
							WHEN j.group_eng_corrected = 'Lenses for spectacles' THEN
								CASE 	WHEN LOCATE('ADD: ',i.name_hu) > 0 THEN REPLACE(SUBSTR(i.name_hu, LOCATE('ADD: ',i.name_hu)+5, 5),',', '')
										ELSE 
											case 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),1,4) 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),1,4) 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),1,4) 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),1,4) 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),1,4) 
												when SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1) LIKE '%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1) not LIKE '+%.%D%' and SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1) not LIKE '-%.%D%' then substr(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),1,4) 
											end
								END
							ELSE NULL
					END AS lens_add,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('CLR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CLR: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_clr,
					
					CASE 	WHEN SUBSTR(i.sku,1,2) = '17' THEN 'Eye tests'
							WHEN j.group_eng_corrected IS NOT NULL THEN j.group_eng_corrected
							WHEN j.group_eng_corrected IS NULL AND j.parent_id = 81 THEN 'Frames'
							WHEN j.group_eng_corrected IS NULL AND i.name_hu LIKE '%napszemüveg%' THEN 'Sunglasses'
							WHEN j.group_eng_corrected IS NULL AND i.name_hu LIKE '%parfüm%' THEN 'Others'
							ELSE 'Unidentified'
					END AS product_group,
					
					CASE 	WHEN group_eng_corrected in ('Contact lenses', 'Lenses for spectacles') AND j.is_spheric = 1 THEN 'Spheric'
							WHEN group_eng_corrected in ('Contact lenses', 'Lenses for spectacles') AND j.is_toric = 1 THEN 'Toric'
							WHEN group_eng_corrected in ('Contact lenses', 'Lenses for spectacles') AND j.is_multifocal = 1 THEN 'Multifocal'
							WHEN group_eng_corrected in ('Contact lenses', 'Lenses for spectacles') THEN 'Unidentified'
							ELSE 'Product is not Contact Lens or Lenses for spectacles'
					END AS lens_type,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.is_color
							ELSE NULL
					END AS is_color,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.using_time
							ELSE 'Product is not Contact Lens'
					END AS wear_days,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.frequency
							ELSE 'Product is not Contact Lens'
					END AS wear_duration,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.qty_per_storage_unit
							ELSE NULL
					END AS qty_per_storage_unit,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.box_width
							ELSE NULL
					END AS box_width,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.box_height
							ELSE NULL
					END AS box_height,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' THEN j.box_depth
							ELSE NULL
					END AS box_depth,

					CASE WHEN j.parent_id IN (2,4,5,6,7,77,101,124) THEN
						CASE 	WHEN LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4)) = 0
								THEN SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4)
								ELSE SUBSTR(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4), 1, LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))-1) * REPLACE(SUBSTR(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4), LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))+1, LENGTH(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))),',', '.')
						END
					ELSE NULL
					END AS pack_size,
					
                    CASE WHEN LOCATE('ml', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name))) > 0 THEN 'ml'
                    	 WHEN LOCATE('db', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name))) > 0 THEN 'db'
                         ELSE 'Not applicable'
					END AS package_unit,

	CASE 	WHEN i.name_hu LIKE '% SPH%' THEN 'yes'
			WHEN i.name_hu LIKE '% AS%' THEN 'no'
			ELSE NULL
    END AS geometry,

	CASE 	WHEN LOWER(i.name_hu) LIKE '%progress%' THEN 'Progressive'
			WHEN LOWER(i.name_hu) LIKE '%multifo%' THEN 'Multifocal'
			WHEN i.name_hu LIKE '%SV %' THEN 'Single Vision'
			ELSE NULL
    END AS focus_nr,

	CASE 	WHEN i.name_hu LIKE '%HMC+%' THEN 'HMC+'
			WHEN i.name_hu LIKE '%HMC%' THEN 'HMC'
			WHEN LOWER(i.name_hu) LIKE '%hard multicoat+%' THEN 'HMC+'
			WHEN LOWER(i.name_hu) LIKE '%hard multicoat%' THEN 'HMC'
			WHEN LOWER(i.name_hu) LIKE '%hard multi coat+%' THEN 'HMC+'			
			WHEN LOWER(i.name_hu) LIKE '%hard multi coat%' THEN 'HMC'
			WHEN i.name_hu LIKE '%HVLL%' THEN 'HVLL'
			WHEN i.name_hu LIKE '%SHV%' THEN 'SHV'
			WHEN i.name_hu LIKE '%HVA%' THEN 'HVA'
			WHEN LOWER(i.name_hu) LIKE '%hi-vision aqua%' THEN 'HVA'
			WHEN i.name_hu LIKE '%HVLL%' THEN 'HVLL'
			WHEN LOWER(i.name_hu) LIKE '%hi-vision longlife%' THEN 'HVLL'
			WHEN LOWER(i.name_hu) LIKE '%crizal forte%' THEN 'Crizal Forte'
			ELSE 'Basic'			
    END AS coating,
	
	CASE 	WHEN LOWER(i.name_hu) LIKE '%raktári%' THEN 'raktári'
			WHEN i.name_hu LIKE '%MAP %' THEN 'MAP'
			ELSE NULL
    END AS supplies,
	
	CASE 	WHEN LOCATE(' 1', i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE(' 1', i.name_hu), 4)
			ELSE NULL
    END AS refraction_index,

/*	https://stackoverflow.com/questions/2742650/what-is-the-equivalent-of-regexp-substr-in-mysql */
	
	CASE 	WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),1,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),1,2)
			ELSE NULL
	END AS diameter,
	
	CASE 	WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',8),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',9),' ',-1),3,2)
			WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1)) = 4 AND SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),1,1) IN ('5','6','7') THEN SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',10),' ',-1),3,2)
			ELSE NULL
	END AS decentralized_diameter,

	CASE 	WHEN i.name_hu LIKE '%11mm%' THEN '11mm'
			WHEN i.name_hu LIKE '%15mm%' THEN '15mm'
			ELSE NULL
    END AS channel_width,
	
	CASE 	WHEN i.name_hu LIKE '%BlueControl%' THEN 'Yes'
			ELSE 'No'
    END AS blue_control,

	CASE 	WHEN i.name_hu LIKE '%UV Control%' THEN 'Yes'
			ELSE 'No'
    END AS uv_control,
	
	CASE 	WHEN i.name_hu LIKE '%Transitions%' THEN 'Transitions'
			WHEN i.name_hu LIKE '%Sensitive%' THEN 'Sensitive'
			ELSE NULL
    END AS photo_chrome,
		
	CASE 	WHEN i.name_hu LIKE '%szürke%' THEN 'szürke'
			WHEN i.name_hu LIKE '%American Grey%' THEN 'American Grey'
			ELSE NULL
    END AS color,
	
	NULL AS color_percentage,
	NULL AS color_gradient,
	NULL AS prism,
	
	CASE 	WHEN i.name_hu LIKE '%polarized%' THEN 'Yes'
			ELSE NULL
    END AS polarized,
	
    CASE 	WHEN j.general_name LIKE '%Szemüveglencsék%' AND LOWER(i.name_hu) LIKE '%pnx%' THEN 'PNX'
			WHEN j.general_name LIKE '%Szemüveglencsék%' AND LOWER(i.name_hu) LIKE '%poly%' THEN 'Polycarbonate'
			WHEN j.general_name LIKE '%Szemüveglencsék%' THEN 'Glass'
       ELSE j.material_type
    END AS material_type,

	j.material_name,
	j.water_content,
	i.frame_color_front,
	i.frame_shape,
	i.frame_size_D1,
	i.frame_size_D2,
	i.frame_size_D3,
	i.frame_size_D4,
	i.frame_size_D5,
	i.frame_size_D6,
	i.frame_material,
	i.frame_flex,
	i.frame_matt,
	i.best_seller,
	s.color as bonus_rate,
	case when p.SKU is null then 0 else 1 end as private_label_product,
    case 
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 36/%' or i.name_hu LIKE '% 36-%') THEN 36
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 37/%' or i.name_hu LIKE '% 37-%') THEN 37
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 38/%' or i.name_hu LIKE '% 38-%') THEN 38
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 39/%' or i.name_hu LIKE '% 39-%') THEN 39
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 40/%' or i.name_hu LIKE '% 40-%') THEN 40
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 41/%' or i.name_hu LIKE '% 41-%') THEN 41
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 42/%' or i.name_hu LIKE '% 42-%') THEN 42
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 43/%' or i.name_hu LIKE '% 43-%') THEN 43
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 44/%' or i.name_hu LIKE '% 44-%') THEN 44
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 45/%' or i.name_hu LIKE '% 45-%') THEN 45
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 46/%' or i.name_hu LIKE '% 46-%') THEN 46
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 47/%' or i.name_hu LIKE '% 47-%') THEN 47
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 48/%' or i.name_hu LIKE '% 48-%') THEN 48
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 49/%' or i.name_hu LIKE '% 49-%') THEN 49
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 50/%' or i.name_hu LIKE '% 50-%') THEN 50
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 51/%' or i.name_hu LIKE '% 51-%') THEN 51
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 52/%' or i.name_hu LIKE '% 52-%') THEN 52
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 53/%' or i.name_hu LIKE '% 53-%') THEN 53
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 54/%' or i.name_hu LIKE '% 54-%') THEN 54
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 55/%' or i.name_hu LIKE '% 55-%') THEN 55
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 56/%' or i.name_hu LIKE '% 56-%') THEN 56
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 57/%' or i.name_hu LIKE '% 57-%') THEN 57
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 58/%' or i.name_hu LIKE '% 58-%') THEN 58
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 59/%' or i.name_hu LIKE '% 59-%') THEN 59
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 60/%' or i.name_hu LIKE '% 60-%') THEN 60
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 61/%' or i.name_hu LIKE '% 61-%') THEN 61
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 62/%' or i.name_hu LIKE '% 62-%') THEN 62
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and (i.name_hu LIKE '% 63/%' or i.name_hu LIKE '% 63-%') THEN 63
    end as lens_width,

    case 
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/12' THEN 12
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%12/%' THEN 12
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-12/' THEN 12
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/13' THEN 13
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%13/%' THEN 13
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-13/' THEN 13		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/14' THEN 14
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%14/%' THEN 14
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-14/' THEN 14		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/15' THEN 15
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%15/%' THEN 15
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-15/' THEN 15		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/16' THEN 16
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%16/%' THEN 16
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-16/' THEN 16		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/16' THEN 16		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/17' THEN 17
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%17/%' THEN 17
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-17/' THEN 17		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/17' THEN 17		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/18' THEN 18
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%18/%' THEN 18
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-18/' THEN 18		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/19' THEN 19
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%19/%' THEN 19
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-19/' THEN 19		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/20' THEN 20
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%20/%' THEN 20
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-20/' THEN 20		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/21' THEN 21
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%21/%' THEN 21
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-21/' THEN 21		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/22' THEN 22
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%22/%' THEN 22
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-22/' THEN 22		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/23' THEN 23
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%23/%' THEN 23
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-23/' THEN 23		
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%/24' THEN 24
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/%24/%' THEN 24
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%-24/' THEN 24		
    end as bridge_width,

    case 
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/100' THEN 100
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/105' THEN 105
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/110' THEN 110
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/115' THEN 115
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/120' THEN 120
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/125' THEN 125
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/130' THEN 130
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/135' THEN 135
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/138' THEN 138
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/140' THEN 140
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/142' THEN 142
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/143' THEN 143
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/145' THEN 145
    	when (j.group_eng_corrected = 'Frames' OR j.group_eng_corrected = 'Sunglasses') and i.name_hu LIKE '%/150' THEN 150
    end as temple_length
	
FROM items i
LEFT JOIN zoho_item_groups j
ON 
CASE 	when i.group_id IN (2,3,5, 220) then IF(j.sku_eoptika_hu <> '', i.sku = j.sku_eoptika_hu, i.sku = j.sku_base_erp)
		ELSE i.group_id = j.sql_id
		END
LEFT JOIN IN_sales_performance s
on
case 	when (j.parent_id IN (81, 332, 357, 367) OR i.group_id = 220) then i.sku = s.CT2_pack
		else j.general_name = s.CT2_pack
end
left join IN_sajat_markas_termek p
ON  i.sku = p.SKU
LEFT JOIN (select min(name) as name, sku, base_sku, sku_ext, brand_code, min(model) as model from prc_products_kpi group by sku, base_sku, sku_ext, brand_code) x
on i.sku = x.sku
;


ALTER TABLE ab_cikkto_full ADD INDEX (`CT1_SKU`) USING BTREE;
ALTER TABLE ab_cikkto_full ADD INDEX `group_id` (`group_id`) USING BTREE;



UPDATE
  ORDERS_00 AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00 GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ab_cikkto_full AS s ON m.item_sku = s.CT1_SKU
SET
	m.CT1_SKU = s.CT1_SKU,
	m.CT1_SKU_name = s.CT1_SKU_name,
	m.CT2_pack = s.CT2_pack,
	m.CT3_product = s.CT3_product,
	m.CT3_product_short = s.CT3_product_short,
	m.CT4_product_brand = s.CT4_product_brand,
	m.CT5_manufacturer = s.CT5_manufacturer,
	m.group_id = s.group_id,
	m.barcode = s.barcode,
	m.goods_nomenclature_code = s.goods_nomenclature_code,
	m.packaging = s.packaging,
	m.quantity_in_a_pack = s.quantity_in_a_pack,
	m.estimated_supplier_lead_time = s.estimated_supplier_lead_time,
	m.net_weight_in_kg = s.net_weight_in_kg,
	m.CT2_sku = s.CT2_sku,
	m.lens_bc = s.lens_bc,
	m.lens_pwr = s.lens_pwr,
	m.lens_cyl = s.lens_cyl,
	m.lens_ax = s.lens_ax,
	m.lens_dia = s.lens_dia,
	m.lens_add = s.lens_add,
	m.lens_clr = s.lens_clr,
	m.product_group = s.product_group,
	m.lens_type = s.lens_type,
	m.is_color = s.is_color,
	m.wear_days = s.wear_days,
	m.wear_duration = s.wear_duration,
	m.qty_per_storage_unit = s.qty_per_storage_unit,
	m.box_width = s.box_width,
	m.box_height = s.box_height,
	m.box_depth = s.box_depth,
	m.pack_size = s.pack_size,
	m.package_unit = s.package_unit,
	m.geometry = s.geometry,
	m.focus_nr = s.focus_nr,
	m.coating = s.coating,
	m.supplies = s.supplies,
	m.refraction_index = s.refraction_index,
	m.diameter = s.diameter,
	m.decentralized_diameter = s.decentralized_diameter,
	m.channel_width = s.channel_width,
	m.blue_control = s.blue_control,
	m.uv_control = s.uv_control,
	m.photo_chrome = s.photo_chrome,
	m.color = s.color,
	m.color_percentage = s.color_percentage,
	m.color_gradient = s.color_gradient,
	m.prism = s.prism,
	m.polarized = s.polarized,
	m.material_type = s.material_type,
	m.material_name = s.material_name,
	m.water_content = s.water_content,
	m.frame_color_front = s.frame_color_front,
	m.frame_shape = s.frame_shape,
	m.frame_size_D1 = s.frame_size_D1,
	m.frame_size_D2 = s.frame_size_D2,
	m.frame_size_D3 = s.frame_size_D3,
	m.frame_size_D4 = s.frame_size_D4,
	m.frame_size_D5 = s.frame_size_D5,
	m.frame_size_D6 = s.frame_size_D6,
	m.frame_material = s.frame_material,
	m.frame_flex = s.frame_flex,
	m.frame_matt = s.frame_matt,
	m.best_seller = s.best_seller,
	m.private_label_product = s.private_label_product
;



DROP TABLE IF EXISTS ORDERS_002;
CREATE TABLE IF NOT EXISTS ORDERS_002 LIKE ORDERS_00;
INSERT INTO ORDERS_002 SELECT * FROM ORDERS_00;