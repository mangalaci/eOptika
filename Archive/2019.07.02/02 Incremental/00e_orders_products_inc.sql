
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
	m.water_content = s.water_content
WHERE m.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


ALTER TABLE ORDERS_00 ADD INDEX (`CT2_pack`) USING BTREE;

UPDATE
  ORDERS_00 AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM ORDERS_002 GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
WHERE C.new_entry = 1 /*csak az uj sorokat update-eljük*/
;



INSERT INTO ORDERS_002 
SELECT * 
FROM ORDERS_00
WHERE new_entry = 1 /*csak az uj sorokat update-eljük*/
;

