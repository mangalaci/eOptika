DROP TABLE IF EXISTS INVOICES_00f;
CREATE TABLE IF NOT EXISTS INVOICES_00f
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
FROM INVOICES_00e AS a
LEFT JOIN ab_cikkto_full AS b
  ON a.item_sku = b.CT1_SKU
LEFT JOIN zoho_item_groups AS c
ON
    CASE 
    WHEN c.is_item_group = 1 THEN b.CT2_pack = c.general_name
    ELSE b.group_id = c.sql_id
    END
LIMIT 0;



ALTER TABLE INVOICES_00f ADD `pack_size` FLOAT(10,2) DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD `package_unit` VARCHAR(32) DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD `lens_material` VARCHAR(64) DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD `product_introduction_dt` DATE DEFAULT NULL;
ALTER TABLE INVOICES_00f ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE INVOICES_00f ADD INDEX `reference_id` (`reference_id`) USING BTREE;

INSERT INTO INVOICES_00f
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
FROM INVOICES_00e AS a 
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
  INVOICES_00f AS C
  INNER JOIN (
SELECT CT2_pack, MIN(created) AS product_introduction_dt FROM INVOICES_00f GROUP by CT2_pack
) AS A ON C.CT2_pack = A.CT2_pack
SET C.product_introduction_dt = A.product_introduction_dt
;


DROP TABLE IF EXISTS INVOICES_00f2;
CREATE TABLE IF NOT EXISTS INVOICES_00f2 LIKE INVOICES_00f;
INSERT INTO INVOICES_00f2 SELECT * FROM INVOICES_00f;