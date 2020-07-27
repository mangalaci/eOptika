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
    m.lens_material = s.lens_material,
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
	m.package_unit = s.package_unit
;


DROP TABLE IF EXISTS INVOICES_002;
CREATE TABLE IF NOT EXISTS INVOICES_002 LIKE INVOICES_00;
INSERT INTO INVOICES_002 SELECT * FROM INVOICES_00;




/* kuponkódok leválogatása ERP_ID szerint: majd BASE_06_TABLE-hez lesz csatolva */
DROP TABLE IF EXISTS INVOICES_coupon_codes;
CREATE TABLE IF NOT EXISTS INVOICES_coupon_codes
SELECT DISTINCT
			e.erp_id,
			MAX(COALESCE(k.coupon,e.related_comment)) AS coupon_code
FROM INVOICES_00 e
LEFT JOIN IN_kupon_codes k
ON LOWER(e.related_comment) LIKE CONCAT('%',LOWER(k.coupon),'%')
WHERE e.related_comment LIKE '%:%'
AND e.item_sku IN ('KUPON', 'RABAT')
AND length(k.coupon) > 3
GROUP BY e.erp_id
;

ALTER TABLE INVOICES_coupon_codes ADD PRIMARY KEY (`erp_id`) USING BTREE;