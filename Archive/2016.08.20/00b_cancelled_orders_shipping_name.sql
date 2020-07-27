DROP TABLE IF EXISTS CANCELLED_ORDERS_00b;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00b LIKE CANCELLED_ORDERS_00a;
ALTER TABLE `CANCELLED_ORDERS_00b` ADD `shipping_name_clean` VARCHAR(100) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00b` ADD `billing_city_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00b` ADD `shipping_method2` VARCHAR(100) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00b
SELECT
		 *,
/*név kinyerése shipping_name-ből*/
			TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(CASE
/*case 5: keep after 2nd bracket*/	WHEN shipping_name_trim LIKE '%(%)%(%)%' THEN SUBSTR(shipping_name_trim, LOCATE(')',shipping_name_trim)+1, (CHAR_LENGTH(shipping_name_trim) - LOCATE(')',REVERSE(shipping_name_trim)) - LOCATE('(',shipping_name_trim)))
/*case 4: keep after 2nd slash*/	WHEN shipping_name_trim LIKE '%/%/%' THEN SUBSTR(shipping_name_trim, LOCATE('/',shipping_name_trim)+1, (CHAR_LENGTH(shipping_name_trim) - LOCATE('/',REVERSE(shipping_name_trim)) - LOCATE('/',shipping_name_trim)))
/*case 3: contains only bracket*/	WHEN LOCATE('(', shipping_name_trim) > 0 AND LOCATE('/', shipping_name_trim) = 0 THEN SUBSTR(shipping_name_trim, LOCATE('(', shipping_name_trim) + 1)
/*case 2: contains only slash*/		WHEN LOCATE('(', shipping_name_trim) = 0 AND LOCATE('/', shipping_name_trim) > 0 THEN SUBSTR(shipping_name_trim, LOCATE('/', shipping_name_trim) + 1)
/*case 1: leave as is*/			ELSE shipping_name_trim
			 END), '(', ''), '  ', ' '), 'dr.', ''), ')', ''), ',', ''), 'â', 'á'), '.', '')) AS shipping_name_clean,

			 /*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS billing_city_clean,
			
CASE WHEN shipping_method = 'Személyes átvétel' THEN 'Pickup in person'	
	 ELSE shipping_method
END AS shipping_method2
FROM  CANCELLED_ORDERS_00a
;



/*Pár esetben hiányzik az email cím vagy a tisztított shipping name lesz üres vagy túl rövid. Ilyenkor az eredeti shipping name lesz a tisztított helyén, hogy elkerüljük a NULL user_id-t.*/
UPDATE
  CANCELLED_ORDERS_00b AS C
  INNER JOIN (
      SELECT  
		sql_id,
		shipping_name
FROM
CANCELLED_ORDERS_00b
WHERE LENGTH(shipping_name_clean) < 4 
AND LENGTH(related_email) < 4
  ) AS A ON C.sql_id = A.sql_id
set C.shipping_name_clean = A.shipping_name
;


ALTER TABLE CANCELLED_ORDERS_00b
  DROP COLUMN shipping_name_trim,
  DROP COLUMN shipping_method
;

  
ALTER TABLE CANCELLED_ORDERS_00b CHANGE `shipping_method2` `shipping_method` VARCHAR(100);
ALTER TABLE CANCELLED_ORDERS_00b ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00b ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;