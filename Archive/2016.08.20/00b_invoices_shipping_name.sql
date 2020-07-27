DROP TABLE IF EXISTS INVOICES_00b;
CREATE TABLE IF NOT EXISTS INVOICES_00b LIKE INVOICES_00a;
ALTER TABLE `INVOICES_00b` ADD `shipping_name_clean` VARCHAR(100) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `billing_city_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `shipping_method2` VARCHAR(100) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `payment_method` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00b
SELECT
		 *,
/*név kinyerése shipping_name-ből*/
			TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(CASE
/*case 5: keep after 2nd bracket*/	WHEN shipping_name_trim LIKE '%(%)%(%)%' THEN SUBSTR(shipping_name_trim, LOCATE(')',shipping_name_trim)+1, (CHAR_LENGTH(shipping_name_trim) - LOCATE(')',REVERSE(shipping_name_trim)) - LOCATE('(',shipping_name_trim)))
/*case 4: keep after 2nd slash*/	WHEN shipping_name_trim LIKE '%/%/%' THEN SUBSTR(shipping_name_trim, LOCATE('/',shipping_name_trim)+1, (CHAR_LENGTH(shipping_name_trim) - LOCATE('/',REVERSE(shipping_name_trim)) - LOCATE('/',shipping_name_trim)))
/*case 3: contains only bracket*/	WHEN LOCATE('(', shipping_name_trim) > 0 AND LOCATE('/', shipping_name_trim) = 0 THEN SUBSTR(shipping_name_trim, LOCATE('(', shipping_name_trim) + 1)
/*case 2: contains only slash*/		WHEN LOCATE('(', shipping_name_trim) = 0 AND LOCATE('/', shipping_name_trim) > 0 THEN SUBSTR(shipping_name_trim, LOCATE('/', shipping_name_trim) + 1)
/*case 1: leave as is*/			ELSE shipping_name_trim
			 END), '(', ''), '  ', ' '), '.', ''), ')', ''), ',', ''), 'â', 'á')) AS shipping_name_clean,
/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
			 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS billing_city_clean,
			
CASE WHEN shipping_method = 'Személyes átvétel' THEN 'Pickup in person'	
	 ELSE shipping_method
END AS shipping_method2,

CASE WHEN billing_method = 'Utánvét' THEN 'Cash on delivery'
	 WHEN billing_method = 'Készpénz' THEN 'Cash'
	 WHEN billing_method = 'Bankkártya' THEN 'Bank card (POS)'
	 WHEN billing_method = 'PayPal' THEN 'PayPal'
	 WHEN billing_method = 'Átutalás' THEN 'Bank transfer'
	 WHEN billing_method = 'Online fizetés' THEN 'Online payment'
	 WHEN billing_method = 'Kupon' THEN 'Coupon'
	 WHEN billing_method = 'Bankkártya POS' THEN 'Bank card (POS)'
	 ELSE billing_method
END AS payment_method
FROM  INVOICES_00a
;



/*Pár esetben nincs email cím és a tisztított shipping name is üres vagy túl rövid. Ilyenkor az eredeti shipping name lesz a tisztított helyén, hogy elkerüljük a NULL user_id-t.*/
UPDATE
  INVOICES_00b AS C
  inner join (
      SELECT  
		sql_id,
		shipping_name
FROM
INVOICES_00b
WHERE LENGTH(shipping_name_clean) < 4 
AND LENGTH(related_email) < 4
  ) AS A ON C.sql_id = A.sql_id
set C.shipping_name_clean = A.shipping_name
;


ALTER TABLE INVOICES_00b
  DROP COLUMN shipping_name_trim,
  DROP COLUMN shipping_method,
  DROP COLUMN billing_method
;


ALTER TABLE INVOICES_00b CHANGE `shipping_method2` `shipping_method` VARCHAR(100);
ALTER TABLE INVOICES_00b ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00b ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;