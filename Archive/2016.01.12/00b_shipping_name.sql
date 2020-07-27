DROP TABLE BASE_00b_TABLE;
CREATE TABLE BASE_00b_TABLE AS
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

FROM  BASE_00a_TABLE
;



/*Pár esetben nincs email cím és a tisztított shipping name is üres vagy túl rövid. Ilyenkor az eredeti shipping name lesz a tisztított helyén, hogy elkerüljük a NULL user_id-t.*/
UPDATE
  BASE_00b_TABLE as C
  inner join (
      SELECT  
		sql_id,
		shipping_name
FROM
BASE_00b_TABLE
WHERE length(shipping_name_clean) < 4 
AND length(related_email) < 4
  ) as A on C.sql_id = A.sql_id
set C.shipping_name_clean = A.shipping_name
;


ALTER TABLE BASE_00b_TABLE
  DROP COLUMN shipping_name_trim,
  DROP COLUMN shipping_method,
  DROP COLUMN billing_method
;

ALTER TABLE BASE_00b_TABLE CHANGE `shipping_name_clean` `shipping_name_clean` VARCHAR(100);  
ALTER TABLE BASE_00b_TABLE CHANGE `shipping_method2` `shipping_method` VARCHAR(100);

  
ALTER TABLE BASE_00b_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00b_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00b_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00b_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00b_TABLE ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;