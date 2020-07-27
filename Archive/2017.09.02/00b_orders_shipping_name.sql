DROP TABLE IF EXISTS ORDERS_00b;
CREATE TABLE IF NOT EXISTS ORDERS_00b LIKE ORDERS_00a3;
ALTER TABLE `ORDERS_00b` ADD `billing_city_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00b` ADD `shipping_method2` VARCHAR(100) NOT NULL;
ALTER TABLE `ORDERS_00b` ADD `item_sku2` VARCHAR(30) NOT NULL;
ALTER TABLE `ORDERS_00b` ADD `related_division2` VARCHAR(100);


INSERT INTO ORDERS_00b
SELECT
		 *,
/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS billing_city_clean,
			
CASE 
		WHEN shipping_method = 'GPSe' AND shipping_country = 'HUN' THEN 'Pickup in person'
		WHEN shipping_method = 'Személyes átvétel' AND shipping_country = 'ITA' THEN 'GLS'
		WHEN shipping_method = 'Személyes átvétel' THEN 'Pickup in person'
		ELSE shipping_method
END AS shipping_method2,

CASE WHEN item_sku = 'AO_MIRR' THEN 'AOA_MIRR'
	 ELSE item_sku
END AS item_sku2,

CASE 	
		WHEN related_webshop = 'LenteContatto.it' THEN 'Optika - IT'
		WHEN related_webshop = 'netOptica.ro' THEN 'Optika - RO'
		ELSE related_division
END AS related_division2

FROM  ORDERS_00a3
;


ALTER TABLE ORDERS_00b
  DROP COLUMN shipping_method,
  DROP COLUMN item_sku,
  DROP COLUMN related_division
;


ALTER TABLE ORDERS_00b CHANGE `shipping_method2` `shipping_method` VARCHAR(100);
ALTER TABLE ORDERS_00b CHANGE `item_sku2` `item_sku` VARCHAR(30);
ALTER TABLE ORDERS_00b CHANGE `related_division2` `related_division` VARCHAR(100);
ALTER TABLE ORDERS_00b ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;



DROP TABLE IF EXISTS orig_created_table;
CREATE TABLE IF NOT EXISTS orig_created_table
SELECT DISTINCT t1.erp_id,
t1.created,
CASE WHEN TIME(t2.created) = '00:00:00' THEN t2.processed ELSE t2.created END AS orig_created
FROM incoming_orders t1
LEFT JOIN incoming_orders t2
ON SUBSTRING_INDEX(t1.erp_id, '/', 2) = t2.erp_id
;

UPDATE ORDERS_00b AS m
        INNER JOIN
    orig_created_table AS s ON m.erp_id = s.erp_id
SET 
    m.created = s.orig_created
;
