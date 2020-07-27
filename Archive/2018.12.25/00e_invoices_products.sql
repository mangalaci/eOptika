DROP TABLE IF EXISTS INVOICES_00e;
CREATE TABLE IF NOT EXISTS INVOICES_00e
SELECT DISTINCT a.sql_id, a.item_sku, a.created, b.*
FROM INVOICES_00 AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amit nincsenek benne a cikktörzsben*/
LIMIT 0;



ALTER TABLE INVOICES_00e ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00e ADD `lens_material` VARCHAR(64) DEFAULT NULL;
ALTER TABLE INVOICES_00e ADD `product_introduction_dt` DATE DEFAULT NULL;


INSERT INTO INVOICES_00e
SELECT DISTINCT a.sql_id, a.item_sku, a.created, b.*,
		'SiHi' AS lens_material,
		NULL AS product_introduction_dt
FROM INVOICES_00 AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amit nincsenek benne a cikktörzsben*/
;


UPDATE
  INVOICES_00e AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00e GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;


UPDATE INVOICES_00 AS m
        LEFT JOIN
    INVOICES_00e AS s ON m.sql_id = s.sql_id
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



DROP TABLE IF EXISTS INVOICES_002;
CREATE TABLE IF NOT EXISTS INVOICES_002 LIKE INVOICES_00;
INSERT INTO INVOICES_002 SELECT * FROM INVOICES_00;



ALTER TABLE INVOICES_00 ADD INDEX (`related_comment`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX (`item_comment`) USING BTREE;




/* kuponkódok leválogatása ERP_ID szerint */
DROP TABLE IF EXISTS INVOICES_trx_coupon_codes;
CREATE TABLE IF NOT EXISTS INVOICES_trx_coupon_codes
SELECT
			e.erp_id,
			e.related_comment, 
			e.item_comment, 
			k.trunk,
			k.product_group,
			CASE 
				WHEN k.product_group <> 'Basket' THEN CONCAT(e.CT1_SKU, '_', k.coupon)
				ELSE e.CT1_SKU
			END AS CT1_SKU,
			MAX(k.coupon) AS trx_coupon_code
FROM (SELECT erp_id, related_comment, item_comment, CT1_SKU, related_division FROM INVOICES_00 WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */) e
LEFT JOIN (SELECT * FROM IN_kupon_codes WHERE LENGTH(coupon) > 4) k
ON (LOWER(e.related_comment) LIKE CONCAT('%',LOWER(k.coupon),'%') OR LOWER(e.item_comment) LIKE CONCAT('%',LOWER(k.coupon),'%'))
AND e.related_division = k.related_division
GROUP BY e.erp_id
;



ALTER TABLE INVOICES_trx_coupon_codes ADD INDEX (`erp_id`) USING BTREE;
ALTER TABLE INVOICES_trx_coupon_codes ADD INDEX (`trx_coupon_code`) USING BTREE;
ALTER TABLE INVOICES_trx_coupon_codes ADD INDEX (`product_group`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX (`trx_coupon_code`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX (`product_group`) USING BTREE;


UPDATE INVOICES_00 AS m
LEFT JOIN INVOICES_trx_coupon_codes AS s 
ON m.erp_id = s.erp_id
SET
    m.trx_coupon_code = s.trx_coupon_code
;

DELETE FROM INVOICES_trx_coupon_codes
WHERE trx_coupon_code = ''
OR product_group = ''
;

/* azon számlák besorolása, ahol NEM 'Basket' a termékcsoport neve */
UPDATE INVOICES_00 AS m
LEFT JOIN INVOICES_trx_coupon_codes AS s 
ON (m.erp_id = s.erp_id AND m.trx_coupon_code = s.trx_coupon_code AND m.product_group = s.product_group)
SET  m.coupon_code = s.trx_coupon_code
WHERE s.product_group <> 'Basket'
;

/* azon számlák besorolása, ahol 'Basket' a termékcsoport neve */
UPDATE INVOICES_00 AS m
LEFT JOIN INVOICES_trx_coupon_codes AS s 
ON (m.erp_id = s.erp_id AND m.trx_coupon_code = s.trx_coupon_code)
SET  m.coupon_code = s.trx_coupon_code
WHERE s.product_group = 'Basket'
;

