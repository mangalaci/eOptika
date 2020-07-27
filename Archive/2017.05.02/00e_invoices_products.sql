DROP TABLE IF EXISTS INVOICES_00e;
CREATE TABLE IF NOT EXISTS INVOICES_00e
SELECT DISTINCT a.*, b.*
FROM INVOICES_00d5 AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amik nincsenek benne a cikktörzsben*/
LIMIT 0;



ALTER TABLE INVOICES_00e ADD `lens_material` VARCHAR(64) DEFAULT NULL;
ALTER TABLE INVOICES_00e ADD `product_introduction_dt` DATE DEFAULT NULL;
ALTER TABLE INVOICES_00e ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00e ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE INVOICES_00e ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00e ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE INVOICES_00e ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE INVOICES_00e ADD INDEX `reference_id` (`reference_id`) USING BTREE;


INSERT INTO INVOICES_00e
SELECT DISTINCT a.*, b.*,
		'SiHi' AS lens_material,
		NULL AS product_introduction_dt
FROM INVOICES_00d5 AS a 
LEFT JOIN ab_cikkto_full AS b
ON a.item_sku = b.CT1_SKU
WHERE b.CT1_SKU IS NOT NULL	/*kiszűrjük azokat az sku-kat, amik nincsenek benne a cikktörzsben*/
;


UPDATE
  INVOICES_00e AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00e GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;


DROP TABLE IF EXISTS INVOICES_00e2;
CREATE TABLE IF NOT EXISTS INVOICES_00e2 LIKE INVOICES_00e;
INSERT INTO INVOICES_00e2 SELECT * FROM INVOICES_00e;