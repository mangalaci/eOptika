/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   B E G I N */

DROP TABLE IF EXISTS INVOICES_00c1;
CREATE TABLE IF NOT EXISTS INVOICES_00c1 LIKE INVOICES_00b;
ALTER TABLE `INVOICES_00c1` ADD `billing_country_standardized` VARCHAR(255) NOT NULL;

ALTER TABLE INVOICES_00c1 ADD INDEX `billing_country` (`billing_country`) USING BTREE;

INSERT INTO INVOICES_00c1
SELECT DISTINCT b.*,
        CASE WHEN LENGTH(b.billing_country) > 1 THEN e.standardized_country
                ELSE 'Other'
                END AS billing_country_standardized
FROM INVOICES_00b AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country;

DROP TABLE IF EXISTS INVOICES_00c2;
CREATE TABLE IF NOT EXISTS INVOICES_00c2 LIKE INVOICES_00c1;
ALTER TABLE `INVOICES_00c2` ADD `shipping_country_standardized` VARCHAR(255) NOT NULL;

ALTER TABLE INVOICES_00c1 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

INSERT INTO INVOICES_00c2
SELECT DISTINCT b.*, 
        CASE WHEN LENGTH(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE b.billing_country_standardized
                END AS shipping_country_standardized
FROM INVOICES_00c1 AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country;

ALTER TABLE INVOICES_00c2 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;


/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   E N D */




/* R E A L   &   P I C K U P   I N F O   M O D U L E:   B E G I N */

DROP TABLE IF EXISTS real_pickup_discrimination_01;
CREATE TABLE IF NOT EXISTS real_pickup_discrimination_01
SELECT DISTINCT
sql_id,
shipping_name,
billing_name,
shipping_name_trim,
billing_name_trim,
shipping_address,
billing_address,
shipping_zip_code,
billing_zip_code,
shipping_city,
billing_city,
CASE 	WHEN shipping_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj'
		THEN 'pickup'
		WHEN LOWER(shipping_name) REGEXP 'bt.|kft|zrt|nyrt|iroda'
		THEN 'billing'
		ELSE 'real'
END AS shipping_name_flg,

CASE 	WHEN billing_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj'
		THEN 'pickup'
		WHEN LOWER(billing_name) REGEXP 'bt.|kft|zrt|nyrt|iroda'
		THEN 'billing'
		ELSE 'real'
END AS billing_name_flg

FROM INVOICES_00c2
GROUP BY shipping_name
ORDER BY shipping_name
;

ALTER TABLE real_pickup_discrimination_01 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE real_pickup_discrimination_01 ADD INDEX `shipping_name_flg` (`shipping_name_flg`) USING BTREE;
ALTER TABLE real_pickup_discrimination_01 ADD INDEX `billing_name_flg` (`billing_name_flg`) USING BTREE;



DROP TABLE IF EXISTS real_pickup_discrimination_02;
CREATE TABLE IF NOT EXISTS real_pickup_discrimination_02
SELECT
sql_id,
shipping_name,
billing_name,
shipping_address,
billing_address,
shipping_zip_code,
billing_zip_code,
shipping_city,
billing_city,
CASE
	WHEN shipping_name_flg = 'real' THEN shipping_name_trim
	WHEN billing_name_flg = 'real' THEN billing_name_trim
END AS real_name,

CASE 
	WHEN shipping_name_flg = 'billing' THEN shipping_name_trim
	WHEN billing_name_flg = 'billing' THEN billing_name_trim 
END AS business_name,

CASE 
	WHEN shipping_name_flg = 'pickup' THEN shipping_name_trim
	WHEN billing_name_flg = 'pickup' THEN billing_name_trim 
END AS pickup_name,

CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell a COALESCE, hogy ha üres a shipping_address */
	WHEN billing_name_flg = 'real' THEN IF(billing_address = '', shipping_address, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_address */
END AS real_address,

CASE 
	WHEN shipping_name_flg = 'billing' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell a COALESCE, hogy ha üres a shipping_address */
	WHEN billing_name_flg = 'billing' THEN IF(billing_address = '', shipping_address, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_address */ 
END AS business_address,

CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell a COALESCE, hogy ha üres a shipping_address */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_address = '', shipping_address, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_address */ 
END AS pickup_address,

CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'real' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */
END AS real_zip_code,

CASE 
	WHEN shipping_name_flg = 'billing' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'billing' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */ 
END AS business_zip_code,

CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */ 
END AS pickup_zip_code,

CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_city = '', billing_city, shipping_city) /* azért kell a COALESCE, hogy ha üres a shipping_city */ 
	WHEN billing_name_flg = 'real' THEN IF(billing_city = '', shipping_city, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_city */
END AS real_city,

CASE 
	WHEN shipping_name_flg = 'billing' THEN IF(shipping_city = '', billing_city, shipping_city) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'billing' THEN IF(billing_city = '', shipping_city, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_city */ 
END AS business_city,

CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_city = '', billing_city, shipping_city) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_city = '', shipping_city, billing_city) /* azért kell a COALESCE, hogy ha üres a billing_city */ 
END AS pickup_city

FROM real_pickup_discrimination_01 r
;

ALTER TABLE real_pickup_discrimination_02 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `real_name` (`real_name`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `business_name` (`business_name`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `pickup_name` (`pickup_name`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `real_address` (`real_address`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `business_address` (`business_address`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `pickup_address` (`pickup_address`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `real_zip_code` (`real_zip_code`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `business_zip_code` (`business_zip_code`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `pickup_zip_code` (`pickup_zip_code`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `real_city` (`real_city`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `business_city` (`business_city`) USING BTREE;
ALTER TABLE real_pickup_discrimination_02 ADD INDEX `pickup_city` (`pickup_city`) USING BTREE;



DROP TABLE IF EXISTS INVOICES_00c3;
CREATE TABLE IF NOT EXISTS INVOICES_00c3 LIKE INVOICES_00c2;
ALTER TABLE INVOICES_00c3 ADD real_name VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD real_address VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD real_zip_code VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD real_city_trim VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD business_name VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD business_address VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD business_zip_code VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD business_city_trim VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD pickup_name VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD pickup_address VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD pickup_zip_code VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c3 ADD pickup_city_trim VARCHAR(255) NOT NULL;



INSERT INTO INVOICES_00c3
SELECT 	DISTINCT u.*,
		r.real_name,
		r.real_address,
		r.real_zip_code,
		/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.real_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS real_city_trim,
		r.business_name,
		r.business_address,
		r.business_zip_code,
		/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.real_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS business_city_trim,
		r.pickup_name,
		r.pickup_address,
		r.pickup_zip_code,
		/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.real_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS pickup_city_trim
FROM INVOICES_00c2 u
LEFT JOIN real_pickup_discrimination_02 r
ON u.shipping_name = r.shipping_name
;


/* R E A L   &   P I C K U P   I N F O   M O D U L E:   E N D */



/* S H I P P I N G   P H O N E   M O D U L E:   B E G I N */

ALTER TABLE INVOICES_00c3 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00c3 ADD INDEX `shipping_phone` (`shipping_phone`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_shipping_phone_aux;
CREATE TABLE IF NOT EXISTS BASE_TABLE_shipping_phone_aux
SELECT DISTINCT 
		shipping_country_standardized, 
		shipping_phone,
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') AS shipping_phone_aux 
FROM INVOICES_00c3
;


DROP TABLE IF EXISTS BASE_TABLE_shipping_phone;
CREATE TABLE IF NOT EXISTS BASE_TABLE_shipping_phone
SELECT DISTINCT 
		shipping_country_standardized, 
		shipping_phone,
		shipping_phone_aux,
        CASE 
			WHEN shipping_country_standardized = 'Hungary' THEN 
        	CASE 
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+36' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '036' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0036' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,5,12))
								
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3670' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3630' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3620' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0670' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0630' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0620' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
		
				WHEN SUBSTR(shipping_phone_aux,1,2) = '70' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,2) = '30' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,2) = '20' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+70' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+30' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+20' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0670' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,6,14))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0630' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,6,14))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0620' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,6,14))
								
				/*budapesti*/
				WHEN LENGTH(shipping_phone_aux) = 7 THEN CONCAT('+36 1', shipping_phone_aux)
				/*vidéki*/
				WHEN SUBSTR(shipping_phone_aux,1,2) = '06' AND SUBSTR(shipping_phone_aux,3,2) NOT IN ('20','30','70') THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,2) = '06' AND SUBSTR(shipping_phone_aux,3,2) NOT IN ('20','30','70') THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN LENGTH(shipping_phone_aux) = 8 THEN CONCAT('+36 ', shipping_phone_aux)
				/*szlovén*/
				WHEN SUBSTR(shipping_phone_aux,1,3) = '386' THEN CONCAT('+386 ', SUBSTR(shipping_phone_aux,4,12))				
				WHEN SUBSTR(shipping_phone_aux,1,4) = '+386' THEN CONCAT('+386 ', SUBSTR(shipping_phone_aux,5,12))				
			END
		WHEN shipping_country_standardized = 'Romania' THEN 
			CASE 
				WHEN SUBSTR(shipping_phone_aux,1,7) = '+40+400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,8,9))
				WHEN SUBSTR(shipping_phone_aux,1,7) = '+400000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,8,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40010' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+4000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,6,9))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '+400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,5,9))
				ELSE CONCAT('+40 ', SUBSTR(shipping_phone_aux,4,9))
			END
		
        ELSE shipping_phone_aux
        END AS shipping_phone_clean
FROM BASE_TABLE_shipping_phone_aux
;

ALTER TABLE BASE_TABLE_shipping_phone ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE BASE_TABLE_shipping_phone ADD INDEX `shipping_phone` (`shipping_phone`) USING BTREE;



DROP TABLE IF EXISTS INVOICES_00n1;
CREATE TABLE IF NOT EXISTS INVOICES_00n1 LIKE INVOICES_00c3;
ALTER TABLE INVOICES_00n1 ADD `shipping_phone_clean` VARCHAR(100) NOT NULL;

INSERT INTO INVOICES_00n1
SELECT DISTINCT b.*, e.shipping_phone_clean
FROM INVOICES_00c3 AS b LEFT JOIN BASE_TABLE_shipping_phone AS e
ON (b.shipping_country_standardized = e.shipping_country_standardized AND b.shipping_phone = e.shipping_phone)
;

ALTER TABLE INVOICES_00n1 ADD INDEX `shipping_phone_clean` (`shipping_phone_clean`) USING BTREE;



/* S H I P P I N G   P H O N E   M O D U L E:   E N D */



/* S H I P P I N G   N A M E   M O D U L E:   B E G I N */

/* ez a module szétválasztja a perjelek és a zárójelek közé írt tagokat,
 és megállapítja, hogy melyik a personal name és melyik a céges név (melyikben van keresztnév) */
DROP TABLE IF EXISTS INVOICES_00p0;
CREATE TABLE INVOICES_00p0
SELECT 	DISTINCT
		shipping_name,
		real_name,
		shipping_country_standardized,
	CASE 	WHEN SUBSTR(real_name,1,1) IN ('(','/')
			THEN 
			CASE 	WHEN SUBSTR(real_name,-1) IN ('(',')','/') THEN real_name
					ELSE CONCAT(real_name,'/')
			END
			ELSE CONCAT('/',
						CASE 	WHEN SUBSTR(real_name,-1) IN ('(',')','/') THEN real_name
								ELSE CONCAT(real_name,'/')
						END
			)
	END AS real_name_aux
FROM INVOICES_00n1
;


ALTER TABLE INVOICES_00p0 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


DROP TABLE IF EXISTS INVOICES_00p1;
CREATE TABLE IF NOT EXISTS INVOICES_00p1 LIKE INVOICES_00p0;
ALTER TABLE `INVOICES_00p1` ADD `pos_1` INT(4) NOT NULL;

INSERT INTO INVOICES_00p1
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,
		real_name_aux,
	CASE
		WHEN IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999) <= IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999) AND IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999) <= IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999) THEN IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999)
		WHEN IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999) <= IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999) THEN IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999)
		ELSE IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999)
	END AS	pos_1
FROM INVOICES_00p0
;


DROP TABLE IF EXISTS INVOICES_00p2;
CREATE TABLE IF NOT EXISTS INVOICES_00p2 LIKE INVOICES_00p1;
ALTER TABLE `INVOICES_00p2` ADD `pos_2` INT(4) NOT NULL;

INSERT INTO INVOICES_00p2
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_1+1))),999)
	END AS	pos_2
FROM INVOICES_00p1
;


DROP TABLE IF EXISTS INVOICES_00p3;
CREATE TABLE IF NOT EXISTS INVOICES_00p3 LIKE INVOICES_00p2;
ALTER TABLE `INVOICES_00p3` ADD `pos_3` INT(4) NOT NULL;

INSERT INTO INVOICES_00p3
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,
		real_name_aux,
		pos_1,
		pos_2,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_2+pos_1+1))),999)
	END AS	pos_3
FROM INVOICES_00p2
;


DROP TABLE IF EXISTS INVOICES_00p4;
CREATE TABLE IF NOT EXISTS INVOICES_00p4 LIKE INVOICES_00p3;
ALTER TABLE `INVOICES_00p4` ADD `pos_4` INT(4) NOT NULL;

INSERT INTO INVOICES_00p4
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
		pos_2,
		pos_3,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_3+pos_2+pos_1+1))),999)
	END AS	pos_4
FROM INVOICES_00p3
;


DROP TABLE IF EXISTS INVOICES_00p5;
CREATE TABLE IF NOT EXISTS INVOICES_00p5 LIKE INVOICES_00p4;
ALTER TABLE `INVOICES_00p5` ADD `pos_5` INT(4) NOT NULL;

INSERT INTO INVOICES_00p5
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
	END AS	pos_5
FROM INVOICES_00p4
;


DROP TABLE IF EXISTS INVOICES_00p6;
CREATE TABLE IF NOT EXISTS INVOICES_00p6 LIKE INVOICES_00p5;
ALTER TABLE `INVOICES_00p6` ADD `pos_6` INT(4) NOT NULL;

INSERT INTO INVOICES_00p6
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
	END AS	pos_6
FROM INVOICES_00p5
;


DROP TABLE IF EXISTS INVOICES_00p7;
CREATE TABLE IF NOT EXISTS INVOICES_00p7 LIKE INVOICES_00p6;
ALTER TABLE `INVOICES_00p7` ADD `pos_7` INT(4) NOT NULL;

INSERT INTO INVOICES_00p7
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		pos_6,
		CASE
		WHEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(real_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
	END AS	pos_7
FROM INVOICES_00p6
;


DROP TABLE IF EXISTS INVOICES_00p8;
CREATE TABLE IF NOT EXISTS INVOICES_00p8 LIKE INVOICES_00p7;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_1` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_2` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_3` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_4` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_5` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00p8` ADD `parse_name_6` VARCHAR(255) NOT NULL;


INSERT INTO INVOICES_00p8
SELECT 	DISTINCT
		id,
		shipping_name,
		real_name,
		shipping_country_standardized,		
		real_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		pos_6,
		pos_7,
		SUBSTR(real_name_aux,1+pos_1,pos_2-1) AS parse_name_1,
		SUBSTR(real_name_aux,1+pos_1+pos_2,pos_3-1) AS parse_name_2,
		SUBSTR(real_name_aux,1+pos_1+pos_2+pos_3,pos_4-1) AS parse_name_3,
		SUBSTR(real_name_aux,1+pos_1+pos_2+pos_3+pos_4,pos_5-1) AS parse_name_4,
		SUBSTR(real_name_aux,1+pos_1+pos_2+pos_3+pos_4+pos_5,pos_6-1) AS parse_name_5,
		SUBSTR(real_name_aux,1+pos_1+pos_2+pos_3+pos_4+pos_5+pos_6,pos_7-1) AS parse_name_6
FROM INVOICES_00p7
;


ALTER TABLE INVOICES_00p8
  DROP COLUMN real_name_aux,
  DROP COLUMN pos_1,
  DROP COLUMN pos_2,
  DROP COLUMN pos_3,
  DROP COLUMN pos_4,
  DROP COLUMN pos_5,
  DROP COLUMN pos_6,
  DROP COLUMN pos_7
;


ALTER TABLE INVOICES_00p8 ADD INDEX `real_name` (`real_name`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_1` (`parse_name_1`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_2` (`parse_name_2`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_3` (`parse_name_3`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_4` (`parse_name_4`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_5` (`parse_name_5`) USING BTREE;
ALTER TABLE INVOICES_00p8 ADD INDEX `parse_name_6` (`parse_name_6`) USING BTREE;




/* a széttagolt real_name mező tagjai közül itt választjuk ki, hogy melyik legyen az igazi név */


DROP TABLE IF EXISTS INVOICES_00c4;
CREATE TABLE INVOICES_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS real_name_clean
FROM INVOICES_00p8 c
LEFT JOIN IN_gender g1
ON (LOWER(c.parse_name_1) LIKE CONCAT('%',LOWER(g1.first_name),'%') AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (LOWER(c.parse_name_2) LIKE CONCAT('%',LOWER(g2.first_name),'%') AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (LOWER(c.parse_name_3) LIKE CONCAT('%',LOWER(g3.first_name),'%') AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (LOWER(c.parse_name_4) LIKE CONCAT('%',LOWER(g4.first_name),'%') AND c.shipping_country_standardized = g4.country)
LEFT JOIN IN_gender g5
ON (LOWER(c.parse_name_5) LIKE CONCAT('%',LOWER(g5.first_name),'%') AND c.shipping_country_standardized = g5.country)
LEFT JOIN IN_gender g6
ON (LOWER(c.parse_name_6) LIKE CONCAT('%',LOWER(g6.first_name),'%') AND c.shipping_country_standardized = g6.country)
LIMIT 0;


ALTER TABLE INVOICES_00c4 CHANGE `real_name_clean` `real_name_clean` VARCHAR(64);
ALTER TABLE INVOICES_00c4 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;



INSERT INTO INVOICES_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS real_name_clean
FROM INVOICES_00p8 c
LEFT JOIN IN_gender g1
ON (LOWER(c.parse_name_1) LIKE CONCAT('%',LOWER(g1.first_name),'%') AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (LOWER(c.parse_name_2) LIKE CONCAT('%',LOWER(g2.first_name),'%') AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (LOWER(c.parse_name_3) LIKE CONCAT('%',LOWER(g3.first_name),'%') AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (LOWER(c.parse_name_4) LIKE CONCAT('%',LOWER(g4.first_name),'%') AND c.shipping_country_standardized = g4.country)
LEFT JOIN IN_gender g5
ON (LOWER(c.parse_name_5) LIKE CONCAT('%',LOWER(g5.first_name),'%') AND c.shipping_country_standardized = g5.country)
LEFT JOIN IN_gender g6
ON (LOWER(c.parse_name_6) LIKE CONCAT('%',LOWER(g6.first_name),'%') AND c.shipping_country_standardized = g6.country)
;



ALTER TABLE INVOICES_00n1 ADD INDEX `real_name` (`real_name`) USING BTREE;

DROP TABLE IF EXISTS INVOICES_00c5;
CREATE TABLE IF NOT EXISTS INVOICES_00c5 LIKE INVOICES_00n1;
ALTER TABLE INVOICES_00c5 ADD `real_name_clean`  VARCHAR(64);
ALTER TABLE INVOICES_00c5 ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00c5 ADD INDEX `real_city_trim` (`real_city_trim`) USING BTREE;
ALTER TABLE INVOICES_00c5 ADD INDEX `pickup_city_trim` (`pickup_city_trim`) USING BTREE;
ALTER TABLE INVOICES_00c5 ADD INDEX `business_city_trim` (`business_city_trim`) USING BTREE;


INSERT INTO INVOICES_00c5
SELECT DISTINCT c.*, d.real_name_clean 
FROM INVOICES_00n1 c
LEFT JOIN INVOICES_00c4 d
ON c.shipping_name = d.shipping_name
;

	
/* S H I P P I N G   N A M E   M O D U L E:   E N D */



/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   B E G I N */

DROP TABLE IF EXISTS IN_telepules_megye2;

CREATE TABLE IF NOT EXISTS IN_telepules_megye2
SELECT telepules, megye, meret, telepules AS telepules_clean
FROM IN_telepules_megye
LIMIT 0;

ALTER TABLE IN_telepules_megye2 ADD PRIMARY KEY (`telepules_clean`) USING BTREE;

INSERT INTO IN_telepules_megye2
SELECT DISTINCT telepules,
        MAX(megye) AS megye,
        MAX(meret) AS meret,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(telepules,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS telepules_clean
FROM IN_telepules_megye
GROUP BY telepules;

DROP TABLE IF EXISTS INVOICES_00c6;
CREATE TABLE IF NOT EXISTS INVOICES_00c6 LIKE INVOICES_00c5;
ALTER TABLE INVOICES_00c6 ADD `real_province` VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c6 ADD `real_city_size` INT(8) NOT NULL;
ALTER TABLE INVOICES_00c6 ADD `real_city` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00c6
SELECT b.*, e.megye AS real_province, e.meret AS real_city_size, telepules_clean AS real_city
FROM INVOICES_00c5 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.real_city_trim
;

UPDATE INVOICES_00c6 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.real_zip_code = s.irsz
SET
    m.real_city = s.Telepules
WHERE m.real_city = ''
;



DROP TABLE IF EXISTS INVOICES_00c7;
CREATE TABLE IF NOT EXISTS INVOICES_00c7 LIKE INVOICES_00c6;
ALTER TABLE INVOICES_00c7 ADD `pickup_province` VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c7 ADD `pickup_city_size` INT(8) NOT NULL;
ALTER TABLE INVOICES_00c7 ADD `pickup_city` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00c7
SELECT b.*, e.megye AS pickup_province, e.meret AS pickup_city_size, telepules_clean AS pickup_city
FROM INVOICES_00c6 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.pickup_city_trim
;

UPDATE INVOICES_00c7 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.pickup_zip_code = s.irsz
SET
    m.pickup_city = s.Telepules
WHERE m.pickup_city = ''
;


DROP TABLE IF EXISTS INVOICES_00c8;
CREATE TABLE IF NOT EXISTS INVOICES_00c8 LIKE INVOICES_00c7;
ALTER TABLE INVOICES_00c8 ADD `business_province` VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c8 ADD `business_city_size` INT(8) NOT NULL;
ALTER TABLE INVOICES_00c8 ADD `business_city` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00c8
SELECT b.*, e.megye AS business_province, e.meret AS business_city_size, telepules_clean AS business_city
FROM INVOICES_00c7 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.business_city_trim
;

UPDATE INVOICES_00c8 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.business_zip_code = s.irsz
SET
    m.business_city = s.Telepules
WHERE m.business_city = ''
;




/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   E N D */
	  

	  


/*
budapest bank / reményi zsolt reményi zsolt
veszprémi közgazdasági szakközépiskola/ dobó dóra dobó dóra
77 Elektronika Kft.
Ariella  / Gyöngyi Hegedűs
*/



/*

Mit kellene még:
- keresztnév a cég nevében
- tagolni a shipping_name-t ','-re is

*/


