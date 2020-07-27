DROP TABLE IF EXISTS INVOICES_00f;
CREATE TABLE IF NOT EXISTS INVOICES_00f
SELECT DISTINCT a.*, b.*
FROM INVOICES_00d5 AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
LIMIT 0;



ALTER TABLE INVOICES_00f ADD `lens_material` VARCHAR(64) DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD `product_introduction_dt` DATE DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `reference_id` (`reference_id`) USING BTREE;


INSERT INTO INVOICES_00f
SELECT DISTINCT a.*, b.*,
		'SiHi' AS lens_material,
		NULL AS product_introduction_dt
FROM INVOICES_00d5 AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amik nincsenek benne a cikktörzsben*/
;


UPDATE
  INVOICES_00f AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00f GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;


DROP TABLE IF EXISTS INVOICES_00f2;
CREATE TABLE IF NOT EXISTS INVOICES_00f2 LIKE INVOICES_00f;
INSERT INTO INVOICES_00f2 SELECT * FROM INVOICES_00f;