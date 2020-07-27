/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   B E G I N */
/*
ALTER TABLE ORDERS_00 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
*/

ALTER TABLE ORDERS_00 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE ORDERS_00 ADD INDEX `billing_country` (`billing_country`) USING BTREE;


DROP TABLE IF EXISTS ORDERS_00c1;
CREATE TABLE IF NOT EXISTS ORDERS_00c1
SELECT DISTINCT b.sql_id,
        CASE WHEN LENGTH(b.billing_country) > 1 THEN e.standardized_country
        END AS billing_country_standardized
FROM ORDERS_00 AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country
;

ALTER TABLE ORDERS_00c1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00c1 ADD INDEX `billing_country_standardized` (`billing_country_standardized`) USING BTREE;

DROP TABLE IF EXISTS ORDERS_00c2;
CREATE TABLE IF NOT EXISTS ORDERS_00c2
SELECT DISTINCT 
		s.sql_id,
        CASE WHEN LENGTH(s.shipping_country) > 1 THEN e.standardized_country
                END AS shipping_country_standardized
FROM ORDERS_00 AS s 
LEFT JOIN IN_country_coding AS e
ON s.shipping_country = e.original_country
;

ALTER TABLE ORDERS_00c2 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00c2 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
 
UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c1 AS s ON m.sql_id = s.sql_id
SET
    m.billing_country_standardized = s.billing_country_standardized
;

UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c2 AS s ON m.sql_id = s.sql_id
SET
    m.shipping_country_standardized = s.shipping_country_standardized
;

UPDATE ORDERS_00
SET
    shipping_country_standardized = billing_country_standardized
WHERE shipping_country_standardized IS NULL
;


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
CASE 	WHEN shipping_name REGEXP '/TOF|PPP|/ PM|/EP'
		OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj'
		THEN 'pickup'
		WHEN LOWER(shipping_name) REGEXP 'Egészségpénztár|Egészség-|bt.|kft|zrt|nyrt|iroda'
		THEN 'billing'
		ELSE 'real'
END AS shipping_name_flg,

CASE 	WHEN billing_name REGEXP '/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj'
		THEN 'pickup'
		WHEN LOWER(billing_name) REGEXP 'Egészségpénztár|Egészség-|bt.|kft|zrt|nyrt|iroda'
		THEN 'billing'
		ELSE 'real'
END AS billing_name_flg

FROM ORDERS_00
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
	ELSE shipping_name_trim /* ha se a shipping_name_flg, se a billing_name_flg nem real, akkor default=shipping_name_trim, mert kell hogy legyen real_name */
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



UPDATE ORDERS_00 AS u
LEFT JOIN real_pickup_discrimination_02 r
ON u.shipping_name = r.shipping_name
LEFT JOIN IN_iranyitoszamok i
ON u.pickup_zip_code = i.irsz
SET
    u.real_name = COALESCE(r.real_name,COALESCE(r.business_name, r.pickup_name)),
    u.real_address = COALESCE(r.real_address,COALESCE(r.business_address, r.pickup_address)),
    u.real_zip_code = COALESCE(r.real_zip_code,COALESCE(r.business_zip_code, r.pickup_zip_code)),
    u.real_city_trim = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(r.real_city,COALESCE(r.business_city, r.pickup_city)),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü'),
    u.pickup_name = COALESCE(r.pickup_name, r.real_name),
    u.pickup_address = CASE WHEN u.shipping_method = 'Pickup in person' THEN 'Terez krt 50.' ELSE COALESCE(r.pickup_address, r.real_address) END,
    u.pickup_zip_code = CASE WHEN u.shipping_method = 'Pickup in person' THEN '1067' ELSE COALESCE(r.pickup_zip_code, r.real_zip_code) END,
	u.pickup_city_trim = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(r.pickup_city,COALESCE(r.real_city, r.business_city)),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü'),
	u.business_name = COALESCE(r.business_name, r.real_name),
	u.business_address = COALESCE(r.business_address, r.real_address),
	u.business_zip_code = COALESCE(r.business_zip_code, r.real_zip_code),
	u.business_city_trim = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(r.business_city, r.real_city),'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü'),
	u.catchment_area = CASE WHEN u.shipping_method = 'Pickup in person' OR i.Megye IN ('Budapest', 'Pest') THEN 'Budapest, Terez krt 50.' ELSE 'other' END
;


/* R E A L   &   P I C K U P   I N F O   M O D U L E:   E N D */



/* S H I P P I N G   P H O N E   M O D U L E:   B E G I N */

DROP TABLE IF EXISTS ORDERS_00c4;
CREATE TABLE IF NOT EXISTS ORDERS_00c4
SELECT DISTINCT 
		sql_id,
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
FROM ORDERS_00
;

ALTER TABLE ORDERS_00c4 ADD PRIMARY KEY (`sql_id`) USING BTREE;

UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c4 AS s ON m.sql_id = s.sql_id
SET
    m.shipping_phone_clean = s.shipping_phone_clean
;


/* S H I P P I N G   P H O N E   M O D U L E:   E N D */



/* S H I P P I N G   N A M E   M O D U L E:   B E G I N */

/* ez a module szétválasztja a perjelek és a zárójelek közé írt tagokat,
 és megállapítja, hogy melyik a personal name és melyik a céges név (melyikben van keresztnév) */
DROP TABLE IF EXISTS ORDERS_00p0;
CREATE TABLE ORDERS_00p0
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00
;

ALTER TABLE ORDERS_00p0 ADD PRIMARY KEY (`sql_id`) USING BTREE;



DROP TABLE IF EXISTS ORDERS_00p1;
CREATE TABLE IF NOT EXISTS ORDERS_00p1 LIKE ORDERS_00p0;
ALTER TABLE `ORDERS_00p1` ADD `pos_1` INT(4) NOT NULL;

INSERT INTO ORDERS_00p1
SELECT 	DISTINCT
		sql_id,
		shipping_name,
		real_name,
		shipping_country_standardized,
		real_name_aux,
	CASE
		WHEN IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999) <= IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999) AND IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999) <= IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999) THEN IF(LOCATE('/',real_name_aux)>0,LOCATE('/',(real_name_aux)),999)
		WHEN IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999) <= IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999) THEN IF(LOCATE('(',real_name_aux)>0,LOCATE('(',(real_name_aux)),999)
		ELSE IF(LOCATE(')',real_name_aux)>0,LOCATE(')',(real_name_aux)),999)
	END AS	pos_1
FROM ORDERS_00p0
;


DROP TABLE IF EXISTS ORDERS_00p2;
CREATE TABLE IF NOT EXISTS ORDERS_00p2 LIKE ORDERS_00p1;
ALTER TABLE `ORDERS_00p2` ADD `pos_2` INT(4) NOT NULL;

INSERT INTO ORDERS_00p2
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p1
;


DROP TABLE IF EXISTS ORDERS_00p3;
CREATE TABLE IF NOT EXISTS ORDERS_00p3 LIKE ORDERS_00p2;
ALTER TABLE `ORDERS_00p3` ADD `pos_3` INT(4) NOT NULL;

INSERT INTO ORDERS_00p3
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p2
;


DROP TABLE IF EXISTS ORDERS_00p4;
CREATE TABLE IF NOT EXISTS ORDERS_00p4 LIKE ORDERS_00p3;
ALTER TABLE `ORDERS_00p4` ADD `pos_4` INT(4) NOT NULL;

INSERT INTO ORDERS_00p4
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p3
;


DROP TABLE IF EXISTS ORDERS_00p5;
CREATE TABLE IF NOT EXISTS ORDERS_00p5 LIKE ORDERS_00p4;
ALTER TABLE `ORDERS_00p5` ADD `pos_5` INT(4) NOT NULL;

INSERT INTO ORDERS_00p5
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p4
;


DROP TABLE IF EXISTS ORDERS_00p6;
CREATE TABLE IF NOT EXISTS ORDERS_00p6 LIKE ORDERS_00p5;
ALTER TABLE `ORDERS_00p6` ADD `pos_6` INT(4) NOT NULL;

INSERT INTO ORDERS_00p6
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p5
;


DROP TABLE IF EXISTS ORDERS_00p7;
CREATE TABLE IF NOT EXISTS ORDERS_00p7 LIKE ORDERS_00p6;
ALTER TABLE `ORDERS_00p7` ADD `pos_7` INT(4) NOT NULL;

INSERT INTO ORDERS_00p7
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p6
;


DROP TABLE IF EXISTS ORDERS_00p8;
CREATE TABLE IF NOT EXISTS ORDERS_00p8 LIKE ORDERS_00p7;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_1` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_2` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_3` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_4` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_5` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00p8` ADD `parse_name_6` VARCHAR(255) NOT NULL;


INSERT INTO ORDERS_00p8
SELECT 	DISTINCT
		sql_id,
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
FROM ORDERS_00p7
;


ALTER TABLE ORDERS_00p8
  DROP COLUMN real_name_aux,
  DROP COLUMN pos_1,
  DROP COLUMN pos_2,
  DROP COLUMN pos_3,
  DROP COLUMN pos_4,
  DROP COLUMN pos_5,
  DROP COLUMN pos_6,
  DROP COLUMN pos_7
;


ALTER TABLE ORDERS_00p8 ADD INDEX `real_name` (`real_name`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_1` (`parse_name_1`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_2` (`parse_name_2`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_3` (`parse_name_3`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_4` (`parse_name_4`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_5` (`parse_name_5`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_6` (`parse_name_6`) USING BTREE;




/* a széttagolt real_name mező tagjai közül itt választjuk ki, hogy melyik legyen az igazi név */
UPDATE IN_gender
SET first_name = UPPER(first_name);
 
  
DROP TABLE IF EXISTS ORDERS_00c5;
CREATE TABLE ORDERS_00c5
SELECT 	DISTINCT 
		c.sql_id,
		COALESCE(c.parse_name_1,c.parse_name_2,c.parse_Name_3,c.parse_name_4,c.parse_name_5,c.parse_name_6) real_name_clean
		FROM ORDERS_00p8 c
LEFT JOIN IN_gender g1
ON ((LOCATE(LOWER(g1.first_name), LOWER(c.parse_name_1)) > 0 
    OR LOCATE(g1.first_name, c.parse_name_2) > 0 
	OR LOCATE(g1.first_name, c.parse_name_3) > 0 
	OR LOCATE(g1.first_name, c.parse_name_4) > 0 
	OR LOCATE(g1.first_name, c.parse_name_5) > 0 
	OR LOCATE(g1.first_name, c.parse_name_6) > 0 
   ) AND c.shipping_country_standardized = g1.country)
;

ALTER TABLE ORDERS_00c5 ADD PRIMARY KEY (`sql_id`) USING BTREE;

UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c5 AS s ON m.sql_id = s.sql_id
SET
    m.real_name_clean = s.real_name_clean
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


ALTER TABLE ORDERS_00 ADD INDEX `real_city_trim` (`real_city_trim`) USING BTREE;

DROP TABLE IF EXISTS ORDERS_00c6;
CREATE TABLE IF NOT EXISTS ORDERS_00c6
SELECT 	b.sql_id, 
		e.megye AS real_province, 
		e.meret AS real_city_size, 
		telepules_clean AS real_city
FROM ORDERS_00 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.real_city_trim
;

ALTER TABLE ORDERS_00c6 ADD PRIMARY KEY (`sql_id`) USING BTREE;


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c6 AS s ON m.sql_id = s.sql_id
SET
    m.real_province = s.real_province,
    m.real_city_size = s.real_city_size,
    m.real_city = s.real_city
;


UPDATE ORDERS_00 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.real_zip_code = s.irsz
SET
    m.real_city = s.Telepules
WHERE m.real_city = ''
;



ALTER TABLE ORDERS_00 ADD INDEX `pickup_city_trim` (`pickup_city_trim`) USING BTREE;

DROP TABLE IF EXISTS ORDERS_00c7;
CREATE TABLE IF NOT EXISTS ORDERS_00c7
SELECT 	b.sql_id, 
		e.megye AS pickup_province, 
		e.meret AS pickup_city_size, 
		telepules_clean AS pickup_city
FROM ORDERS_00 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.pickup_city_trim
;

ALTER TABLE ORDERS_00c7 ADD PRIMARY KEY (`sql_id`) USING BTREE;


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c7 AS s ON m.sql_id = s.sql_id
SET
    m.pickup_province = s.pickup_province,
    m.pickup_city_size = s.pickup_city_size,
    m.pickup_city = s.pickup_city
;



ALTER TABLE ORDERS_00 ADD INDEX `business_city_trim` (`business_city_trim`) USING BTREE;

DROP TABLE IF EXISTS ORDERS_00c8;
CREATE TABLE IF NOT EXISTS ORDERS_00c8
SELECT 	b.sql_id, 
		e.megye AS business_province, 
		e.meret AS business_city_size, 
		telepules_clean AS business_city
FROM ORDERS_00 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.business_city_trim
;

ALTER TABLE ORDERS_00c8 ADD PRIMARY KEY (`sql_id`) USING BTREE;


UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00c8 AS s ON m.sql_id = s.sql_id
SET
    m.business_province = s.business_province,
    m.business_city_size = s.business_city_size,
    m.business_city = s.business_city
;

/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   E N D */

