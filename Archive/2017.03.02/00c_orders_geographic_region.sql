/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   B E G I N */

DROP TABLE IF EXISTS ORDERS_00c1;
CREATE TABLE IF NOT EXISTS ORDERS_00c1 LIKE ORDERS_00b;
ALTER TABLE `ORDERS_00c1` ADD `billing_country_standardized` VARCHAR(255) NOT NULL;

ALTER TABLE ORDERS_00c1 ADD INDEX `billing_country` (`billing_country`) USING BTREE;

INSERT INTO ORDERS_00c1
SELECT DISTINCT b.*,
        CASE WHEN LENGTH(b.billing_country) > 1 THEN e.standardized_country
                ELSE 'Other'
                END AS billing_country_standardized
FROM ORDERS_00b AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country;

DROP TABLE IF EXISTS ORDERS_00c2;
CREATE TABLE IF NOT EXISTS ORDERS_00c2 LIKE ORDERS_00c1;
ALTER TABLE `ORDERS_00c2` ADD `shipping_country_standardized` VARCHAR(255) NOT NULL;

ALTER TABLE ORDERS_00c1 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

INSERT INTO ORDERS_00c2
SELECT DISTINCT b.*, 
        CASE WHEN LENGTH(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE b.billing_country_standardized
                END AS shipping_country_standardized
FROM ORDERS_00c1 AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country;

	  
/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   E N D */




/* R E A L   &   P I C K U P   I N F O   M O D U L E:   B E G I N */

DROP TABLE IF EXISTS AGGR_USER_REAL_ADDRESS;
CREATE TABLE IF NOT EXISTS AGGR_USER_REAL_ADDRESS
SELECT DISTINCT
sql_id,
shipping_name,
shipping_country_standardized,
shipping_method,

CASE 	WHEN billing_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		THEN
			CASE	WHEN shipping_name REGEXP '/TOF|PPP|/ PM|/EP'
					OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
					THEN NULL
					ELSE shipping_name_trim
			END
		ELSE billing_name_trim
END AS real_name,

CASE 	WHEN billing_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		OR billing_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		THEN
		CASE 	WHEN shipping_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
		OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
					OR shipping_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
					OR LOWER(shipping_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj|váci utca 38'
					THEN NULL
				ELSE shipping_address
			END 
		ELSE billing_address
END AS real_address,
CASE 	WHEN billing_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		OR billing_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
		OR LOWER(billing_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		THEN
			CASE	WHEN shipping_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
					OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
					OR shipping_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
					OR LOWER(shipping_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj|váci utca 38'
					THEN NULL
				ELSE shipping_zip_code
			END
		ELSE billing_zip_code
END AS real_zip_code,

CASE	WHEN billing_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
		OR LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		OR billing_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
		OR LOWER(billing_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
		THEN
			CASE	WHEN shipping_name REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP'
					OR LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj'
					OR shipping_address REGEXP 'Egészségpénztár|Egészség-|/TOF|PPP|/ PM|/EP|MÁV'
					OR LOWER(shipping_address) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedió|irodai átvétel|alulj|váci utca 38'
					THEN NULL
				ELSE shipping_city
			END 
		ELSE billing_city
END AS real_city
FROM ORDERS_00c2
GROUP BY shipping_name
ORDER BY shipping_name
;


ALTER TABLE AGGR_USER_REAL_ADDRESS ADD INDEX `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE AGGR_USER_REAL_ADDRESS ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;


DROP TABLE IF EXISTS AGGR_USER_PICKUP_ADDRESS;
CREATE TABLE IF NOT EXISTS AGGR_USER_PICKUP_ADDRESS
SELECT DISTINCT 
sql_id,
shipping_name,
shipping_country_standardized,
shipping_method,
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'					
		OR billing_name LIKE '%/EP%'					
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		OR LOWER(billing_name) LIKE '%inmedio%'
		THEN billing_name
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'					
					OR shipping_name LIKE '%/EP%'					
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR LOWER(shipping_name) LIKE '%inmedio%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')
					THEN shipping_name_trim
				ELSE billing_name_trim
			END
END AS pickup_name,

CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN 'Teréz krt. 41.' ELSE
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'					
		OR billing_name LIKE '%/EP%'					
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_address
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'					
					OR shipping_name LIKE '%/EP%'					
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')			
				THEN shipping_address
				ELSE billing_address
			END
END
END AS pickup_address,
CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN '1067' 
	ELSE
	CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'
		OR LOWER(billing_name) LIKE '%omv%'
		OR LOWER(billing_name) LIKE '%mol %'
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_zip_code
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'	
					OR LOWER(shipping_name) LIKE '%omv%'				
					OR LOWER(shipping_name) LIKE '%mol %'			
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')	
				THEN shipping_zip_code
				ELSE billing_zip_code
			END
	END
END AS pickup_zip_code,
CASE WHEN shipping_method IN ('Pickup in person') AND shipping_country_standardized = 'Hungary' THEN 'Budapest' ELSE
CASE WHEN LOWER(shipping_name) LIKE '%egészség%'
		OR billing_name LIKE '%/TOF%'
		OR billing_name LIKE '%PPP%'
		OR billing_name LIKE '%/ PM%'
		OR billing_name LIKE '%/EP%'
		OR LOWER(billing_name) LIKE '%sprinter%'
		OR LOWER(billing_name) LIKE '%exon 2000%'	
		OR LOWER(billing_name) LIKE '%omv%'				
		OR LOWER(billing_name) LIKE '%mol %'			
		OR LOWER(billing_name) LIKE '%nemzeti dohánybolt%'
		OR LOWER(billing_name) LIKE '%relay%'
		OR LOWER(billing_name) LIKE '%inmedió%'
		THEN billing_city
		ELSE
			CASE WHEN LOWER(billing_name) LIKE '%egészség%'
					OR shipping_name LIKE '%/TOF%'
					OR shipping_name LIKE '%PPP%'
					OR shipping_name LIKE '%/ PM%'
					OR shipping_name LIKE '%/EP%'
					OR LOWER(shipping_name) LIKE '%sprinter%'
					OR LOWER(shipping_name) LIKE '%exon 2000%'
					OR LOWER(shipping_name) LIKE '%omv%'
					OR LOWER(shipping_name) LIKE '%mol %'
					OR LOWER(shipping_name) LIKE '%nemzeti dohánybolt%'
					OR LOWER(shipping_name) LIKE '%relay%'
					OR LOWER(shipping_name) LIKE '%inmedió%'
					OR shipping_method IN ('MPL', 'Foxpost', 'Pick-Pack')
			THEN shipping_city
			ELSE billing_city
			END
END
END AS pickup_city
FROM ORDERS_00c2
GROUP BY shipping_name
ORDER BY shipping_name
;

ALTER TABLE AGGR_USER_PICKUP_ADDRESS ADD INDEX `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE AGGR_USER_PICKUP_ADDRESS ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;


DROP TABLE IF EXISTS ORDERS_00c3;
CREATE TABLE IF NOT EXISTS ORDERS_00c3 LIKE ORDERS_00c2;
ALTER TABLE ORDERS_00c3 ADD real_name VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD real_address VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD real_zip_code VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD real_city_trim VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD pickup_name VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD pickup_address VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD pickup_zip_code VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c3 ADD pickup_city_trim VARCHAR(255) NOT NULL;



INSERT INTO ORDERS_00c3
SELECT 	DISTINCT u.*,
		r.real_name,
		r.real_address,
		r.real_zip_code,
		/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.real_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS real_city_trim,
		p.pickup_name,
		p.pickup_address,
		p.pickup_zip_code,
		/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p.pickup_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS pickup_city_trim
FROM ORDERS_00c2 u
LEFT JOIN AGGR_USER_REAL_ADDRESS r
ON u.shipping_name = r.shipping_name
LEFT JOIN AGGR_USER_PICKUP_ADDRESS p
ON u.shipping_name = p.shipping_name
;


/* R E A L   &   P I C K U P   I N F O   M O D U L E:   E N D */



/* S H I P P I N G   P H O N E   M O D U L E:   B E G I N */

ALTER TABLE ORDERS_00c3 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00c3 ADD INDEX `shipping_phone` (`shipping_phone`) USING BTREE;
ALTER TABLE ORDERS_00c3 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_shipping_phone_aux;
CREATE TABLE IF NOT EXISTS BASE_TABLE_shipping_phone_aux
SELECT DISTINCT 
		shipping_country_standardized, 
		shipping_phone,
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_phone,'T: ',''), ' ', ''), '/', ''), '-', ''), ')', ''), '(', '') AS shipping_phone_aux 
FROM ORDERS_00c3
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



DROP TABLE IF EXISTS ORDERS_00n1;
CREATE TABLE IF NOT EXISTS ORDERS_00n1 LIKE ORDERS_00c3;
ALTER TABLE ORDERS_00n1 ADD `shipping_phone_clean` VARCHAR(100) NOT NULL;

INSERT INTO ORDERS_00n1
SELECT DISTINCT b.*, e.shipping_phone_clean
FROM ORDERS_00c3 AS b LEFT JOIN BASE_TABLE_shipping_phone AS e
ON (b.shipping_country_standardized = e.shipping_country_standardized AND b.shipping_phone = e.shipping_phone)
;

ALTER TABLE ORDERS_00n1 ADD INDEX `shipping_phone_clean` (`shipping_phone_clean`) USING BTREE;



/* S H I P P I N G   P H O N E   M O D U L E:   E N D */



/* S H I P P I N G   N A M E   M O D U L E:   B E G I N */

/* ez a module szétválasztja a perjelek és a zárójelek közé írt tagokat,
 és megállapítja, hogy melyik a personal name és melyik a céges név (melyikben van keresztnév) */
DROP TABLE IF EXISTS ORDERS_00p0;
CREATE TABLE ORDERS_00p0
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
FROM ORDERS_00n1
;


ALTER TABLE ORDERS_00p0 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


DROP TABLE IF EXISTS ORDERS_00p1;
CREATE TABLE IF NOT EXISTS ORDERS_00p1 LIKE ORDERS_00p0;
ALTER TABLE `ORDERS_00p1` ADD `pos_1` INT(4) NOT NULL;

INSERT INTO ORDERS_00p1
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
FROM ORDERS_00p0
;


DROP TABLE IF EXISTS ORDERS_00p2;
CREATE TABLE IF NOT EXISTS ORDERS_00p2 LIKE ORDERS_00p1;
ALTER TABLE `ORDERS_00p2` ADD `pos_2` INT(4) NOT NULL;

INSERT INTO ORDERS_00p2
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
FROM ORDERS_00p1
;


DROP TABLE IF EXISTS ORDERS_00p3;
CREATE TABLE IF NOT EXISTS ORDERS_00p3 LIKE ORDERS_00p2;
ALTER TABLE `ORDERS_00p3` ADD `pos_3` INT(4) NOT NULL;

INSERT INTO ORDERS_00p3
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
FROM ORDERS_00p2
;


DROP TABLE IF EXISTS ORDERS_00p4;
CREATE TABLE IF NOT EXISTS ORDERS_00p4 LIKE ORDERS_00p3;
ALTER TABLE `ORDERS_00p4` ADD `pos_4` INT(4) NOT NULL;

INSERT INTO ORDERS_00p4
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
FROM ORDERS_00p3
;


DROP TABLE IF EXISTS ORDERS_00p5;
CREATE TABLE IF NOT EXISTS ORDERS_00p5 LIKE ORDERS_00p4;
ALTER TABLE `ORDERS_00p5` ADD `pos_5` INT(4) NOT NULL;

INSERT INTO ORDERS_00p5
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
FROM ORDERS_00p4
;


DROP TABLE IF EXISTS ORDERS_00p6;
CREATE TABLE IF NOT EXISTS ORDERS_00p6 LIKE ORDERS_00p5;
ALTER TABLE `ORDERS_00p6` ADD `pos_6` INT(4) NOT NULL;

INSERT INTO ORDERS_00p6
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
FROM ORDERS_00p5
;


DROP TABLE IF EXISTS ORDERS_00p7;
CREATE TABLE IF NOT EXISTS ORDERS_00p7 LIKE ORDERS_00p6;
ALTER TABLE `ORDERS_00p7` ADD `pos_7` INT(4) NOT NULL;

INSERT INTO ORDERS_00p7
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


DROP TABLE IF EXISTS ORDERS_00c4;
CREATE TABLE ORDERS_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS real_name_clean
FROM ORDERS_00p8 c
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


ALTER TABLE ORDERS_00c4 CHANGE `real_name_clean` `real_name_clean` VARCHAR(64);
ALTER TABLE ORDERS_00c4 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00c4 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00c4 ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;



INSERT INTO ORDERS_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS real_name_clean
FROM ORDERS_00p8 c
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



ALTER TABLE ORDERS_00n1 ADD INDEX `real_name` (`real_name`) USING BTREE;

DROP TABLE IF EXISTS ORDERS_00c5;
CREATE TABLE IF NOT EXISTS ORDERS_00c5 LIKE ORDERS_00n1;
ALTER TABLE ORDERS_00c5 ADD `real_name_clean`  VARCHAR(64);
ALTER TABLE ORDERS_00c5 ADD INDEX `real_name_clean` (`real_name_clean`) USING BTREE;

INSERT INTO ORDERS_00c5
SELECT DISTINCT c.*, d.real_name_clean 
FROM ORDERS_00n1 c
LEFT JOIN ORDERS_00c4 d
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

DROP TABLE IF EXISTS ORDERS_00c6;
CREATE TABLE IF NOT EXISTS ORDERS_00c6 LIKE ORDERS_00c5;
ALTER TABLE ORDERS_00c6 ADD `real_province` VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c6 ADD `real_city_size` INT(8) NOT NULL;
ALTER TABLE ORDERS_00c6 ADD `real_city` VARCHAR(255) NOT NULL;

INSERT INTO ORDERS_00c6
SELECT b.*, e.megye AS real_province, e.meret AS real_city_size, telepules_clean AS real_city
FROM ORDERS_00c5 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.real_city_trim
;

UPDATE ORDERS_00c6 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.real_zip_code = s.irsz
SET
    m.real_city = s.Telepules
WHERE m.real_city = ''
;




DROP TABLE IF EXISTS ORDERS_00c7;
CREATE TABLE IF NOT EXISTS ORDERS_00c7 LIKE ORDERS_00c6;
ALTER TABLE ORDERS_00c7 ADD `pickup_province` VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c7 ADD `pickup_city_size` INT(8) NOT NULL;
ALTER TABLE ORDERS_00c7 ADD `pickup_city` VARCHAR(255) NOT NULL;

INSERT INTO ORDERS_00c7
SELECT b.*, e.megye AS pickup_province, e.meret AS pickup_city_size, telepules_clean AS pickup_city
FROM ORDERS_00c6 AS b 
LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.pickup_city_trim
;

UPDATE ORDERS_00c7 AS m
        INNER JOIN
    IN_iranyitoszamok AS s ON m.pickup_zip_code = s.irsz
SET
    m.pickup_city = s.Telepules
WHERE m.pickup_city = ''
;



/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   E N D */
	  
