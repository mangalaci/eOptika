UPDATE items
SET name_hu = REPLACE(name_hu,'Alapértelmezett', '')
WHERE LOWER(name_hu) LIKE '%alapértelmezett%'
;

DROP TABLE IF EXISTS ab_cikkto_full;
CREATE TABLE IF NOT EXISTS ab_cikkto_full
SELECT DISTINCT 
    i.sku AS CT1_SKU,
	
        i.name_hu AS CT1_SKU_name,
		
    CASE 	WHEN j.general_name LIKE '% sole%' OR j.general_name LIKE '% vista%' OR i.group_id IN (82, 84, 85, 86, 88, 90, 92, 93, 97, 98, 99, 100, 119, 120, 121, 122, 126, 132, 133, 134, 135, 212, 220, 358) THEN i.sku
			WHEN j.general_name IS NOT NULL THEN j.general_name
			ELSE 'Unidentified'
	END AS CT2_pack,
	
    CASE 	WHEN (j.general_name LIKE '% sole%' OR j.general_name LIKE '% vista%' OR i.group_id IN (82, 84, 85, 86, 88, 90, 92, 93, 97, 98, 99, 100, 119, 120, 121, 122, 126, 132, 133, 134, 135, 212, 220, 358)) AND LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '_', '')) > 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '_', 2), ' ', -1)
			WHEN (j.general_name LIKE '% sole%' OR j.general_name LIKE '% vista%' OR i.group_id IN (82, 84, 85, 86, 88, 90, 92, 93, 97, 98, 99, 100, 119, 120, 121, 122, 126, 132, 133, 134, 135, 212, 220, 358)) AND LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '_', '')) = 1 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '_', 1), ' ', -1)
			WHEN (j.general_name LIKE '% sole%' OR j.general_name LIKE '% vista%' OR i.group_id IN (82, 84, 85, 86, 88, 90, 92, 93, 97, 98, 99, 100, 119, 120, 121, 122, 126, 132, 133, 134, 135, 212, 220, 358)) AND LENGTH(i.sku) - LENGTH(REPLACE(i.sku, '-', '')) > 0 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '-', 1), ' ', -1)
			WHEN INSTR(i.name_hu,"(") > 0 THEN LEFT(i.name_hu,INSTR(i.name_hu,"(")-1)
			ELSE CASE WHEN j.parent_id = 0 THEN i.name_hu ELSE j.CT3_product END
    END AS CT3_product,

    CASE 	WHEN i.group_id = 220 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.sku, '_', 1), ' ', -1)
			ELSE j.CT3_product_short
    END AS CT3_product_short,
	
    CASE 	WHEN i.group_id = 220 THEN SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu, ' ', 1), ' ', -1)
			ELSE j.CT4_product_brand
    END AS CT4_product_brand,
	
	CASE 	WHEN i.manufacturer = 'CIBA Vision' THEN 'Alcon'
				ELSE i.manufacturer
    END AS CT5_manufacturer,
		
    i.group_id,
    i.barcode,
    i.goods_nomenclature_code,
    i.packaging,
    i.quantity_in_a_pack,
    i.estimated_supplier_lead_time,
	i.net_weight_in_kg,
	
    CASE 	WHEN i.group_id = 220 THEN i.sku
			ELSE sku_eoptika_hu
	END AS CT2_sku,
	
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) THEN SUBSTR(i.name_hu, LOCATE('BC: ',i.name_hu)+4, LOCATE('PWR',i.name_hu) - LOCATE('BC:',i.name_hu)- 6)
                         ELSE NULL
					END AS lens_bc,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('PWR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('PWR: ',i.name_hu)+5, 5)
						WHEN j.general_name = 'Szemüveglencsék' THEN 
							CASE 	WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',1),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',2),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',3),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',4),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',5),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',6),' ',-1),5)
									WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1) LIKE '%.%D' THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',7),' ',-1),5)
									WHEN LOCATE('PWR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('PWR: ',i.name_hu)+5, 5)
							ELSE NULL
							END
					ELSE NULL
					END AS lens_pwr,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('CYL: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CYL: ',i.name_hu)+5, 5)
						WHEN j.general_name = 'Szemüveglencsék' THEN 
						CASE 	WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-2),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-2),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-2),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-3),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-2),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-3),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-3),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-4),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-3),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-4),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-4),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-5),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-4),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-5),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-5),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-6),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-5),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-6),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-6),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-7),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-6),' ',1),5)
								WHEN LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-7),' ',1)) = 6 AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-7),' ',1) LIKE '%.%D' AND SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-1),' ',1) <> SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-8),' ',1) THEN LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(i.name_hu,' ',-7),' ',1),5)
								WHEN LOCATE('CYL: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CYL: ',i.name_hu)+5, 5)
								ELSE NULL
						END
					ELSE NULL
					END AS lens_cyl,					
					
					CASE WHEN (j.parent_id IN (4,5,6,7,77,101,124) OR j.general_name = 'Szemüveglencsék') AND LOCATE('AX: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('AX: ',i.name_hu)+4, 4)
						 ELSE NULL
					END AS lens_ax,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('DIA: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('DIA: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_dia,
					
					CASE WHEN (j.parent_id IN (4,5,6,7,77,101,124) OR j.general_name = 'Szemüveglencsék') AND LOCATE('ADD: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('ADD: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_add,
					
					CASE WHEN j.parent_id IN (4,5,6,7,77,101,124) AND LOCATE('CLR: ',i.name_hu) > 0 THEN SUBSTR(i.name_hu, LOCATE('CLR: ',i.name_hu)+5, 5)
                         ELSE NULL
					END AS lens_clr,
					
					CASE 	WHEN SUBSTR(i.sku,1,2) = '17' THEN 'Eye tests'
							WHEN j.group_eng_corrected IS NOT NULL THEN j.group_eng_corrected
							ELSE 'Unidentified'
					END AS product_group,
					CASE 	WHEN group_eng_corrected = 'Contact lenses' AND j.is_spheric = 1 THEN 'Spheric'
							WHEN group_eng_corrected = 'Contact lenses' AND j.is_toric = 1 THEN 'Toric'
							WHEN group_eng_corrected = 'Contact lenses' AND j.is_multifocal = 1 THEN 'Multifocal'
							WHEN group_eng_corrected = 'Contact lenses' THEN 'Unidentified'
							ELSE 'Product is not Contact Lens'
					END AS lens_type,
					j.is_color,
					j.using_time AS wear_days,
					j.frequency AS wear_duration,
					j.qty_per_storage_unit,
					j.box_width,
					j.box_height,
					j.box_depth,
					CASE WHEN LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4)) = 0
						 THEN SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4)
						 ELSE SUBSTR(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4), 1, LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))-1) * REPLACE(SUBSTR(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4), LOCATE('x', SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))+1, LENGTH(SUBSTR(j.general_name, LOCATE('(',j.general_name)+1, LOCATE(')',j.general_name)-LOCATE('(',j.general_name)-4))),',', '.')
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
	
    CASE 	WHEN j.general_name = 'Szemüveglencsék' AND LOWER(i.name_hu) LIKE '%pnx%' THEN 'PNX'
			WHEN j.general_name = 'Szemüveglencsék' AND LOWER(i.name_hu) LIKE '%poly%' THEN 'Polycarbonate'
			WHEN j.general_name = 'Szemüveglencsék' THEN 'Glass'
       ELSE j.material_type
    END AS material_type,

	j.material_name,
	j.water_content
	
FROM items i
LEFT JOIN zoho_item_groups j
ON 
CASE 	WHEN i.group_id IN (2,3,5, 220) THEN IF(j.sku_eoptika_hu <> '', i.sku = j.sku_eoptika_hu, i.sku = j.sku_base_erp)
		ELSE i.group_id = j.sql_id
		END
;

ALTER TABLE ab_cikkto_full ADD PRIMARY KEY (`CT1_SKU`) USING BTREE;
ALTER TABLE ab_cikkto_full ADD INDEX `group_id` (`group_id`) USING BTREE;



DROP TABLE IF EXISTS ORDERS_00e;
CREATE TABLE IF NOT EXISTS ORDERS_00e
SELECT DISTINCT a.sql_id, a.item_sku, b.*
FROM ORDERS_00 AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amit nincsenek benne a cikktörzsben*/
LIMIT 0;


ALTER TABLE ORDERS_00e ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00e ADD `product_introduction_dt` DATE DEFAULT NULL;


INSERT INTO ORDERS_00e
SELECT DISTINCT 
		a.sql_id, 
		a.item_sku, 
		b.*,
		NULL AS product_introduction_dt
FROM ORDERS_00 AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amit nincsenek benne a cikktörzsben*/
;


UPDATE
  ORDERS_00e AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00 GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;



UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00e AS s ON m.sql_id = s.sql_id
SET
    m.product_introduction_dt = s.product_introduction_dt,
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
	m.water_content = s.water_content
;



DROP TABLE IF EXISTS ORDERS_002;
CREATE TABLE IF NOT EXISTS ORDERS_002 LIKE ORDERS_00;
INSERT INTO ORDERS_002 SELECT * FROM ORDERS_00;