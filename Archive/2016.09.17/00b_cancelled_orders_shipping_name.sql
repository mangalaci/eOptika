DROP TABLE IF EXISTS CANCELLED_ORDERS_00b;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00b LIKE CANCELLED_ORDERS_00a;
ALTER TABLE `CANCELLED_ORDERS_00b` ADD `billing_city_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00b` ADD `shipping_method2` VARCHAR(100) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00b
SELECT
		 *,
/*név kinyerése shipping_name-ből*/
/*			TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(shipping_name_trim), '(', ''), '  ', ' '), 'dr.', ''), ')', ''), ',', ''), 'â', 'á'), '.', '')) AS shipping_name_clean, */
/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS billing_city_clean,
			
CASE WHEN shipping_method = 'Személyes átvétel' THEN 'Pickup in person'	
	 ELSE shipping_method
END AS shipping_method2
FROM  CANCELLED_ORDERS_00a
;




ALTER TABLE CANCELLED_ORDERS_00b
  DROP COLUMN shipping_method
;

  
ALTER TABLE CANCELLED_ORDERS_00b CHANGE `shipping_method2` `shipping_method` VARCHAR(100);
ALTER TABLE CANCELLED_ORDERS_00b ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;