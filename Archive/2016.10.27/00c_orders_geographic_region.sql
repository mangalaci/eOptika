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

DROP TABLE IF EXISTS ORDERS_00c1;
CREATE TABLE IF NOT EXISTS ORDERS_00c1 LIKE ORDERS_00b;
ALTER TABLE ORDERS_00c1 ADD `province` VARCHAR(255) NOT NULL;
ALTER TABLE ORDERS_00c1 ADD `city_size` INT(8) NOT NULL;
ALTER TABLE ORDERS_00c1 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE ORDERS_00c1 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

INSERT INTO ORDERS_00c1
  SELECT b.*, e.megye AS province, e.meret AS city_size
  FROM ORDERS_00b AS b 
    LEFT JOIN IN_telepules_megye2 AS e
      ON e.telepules_clean = b.billing_city_clean;

DROP TABLE IF EXISTS ORDERS_00c2;
CREATE TABLE IF NOT EXISTS ORDERS_00c2 LIKE ORDERS_00c1;
ALTER TABLE `ORDERS_00c2` ADD `billing_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO ORDERS_00c2
SELECT DISTINCT b.*, 
        CASE WHEN length(b.billing_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS billing_country_standardized
FROM ORDERS_00c1 AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country;

DROP TABLE IF EXISTS ORDERS_00c3;
CREATE TABLE IF NOT EXISTS ORDERS_00c3 LIKE ORDERS_00c2;
ALTER TABLE `ORDERS_00c3` ADD `shipping_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO ORDERS_00c3
SELECT DISTINCT b.*, 
        CASE WHEN length(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS shipping_country_standardized
FROM ORDERS_00c2 AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country;


ALTER TABLE ORDERS_00c3 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;



/* S H I P P I N G   N A M E   M O D U L E:   B E G I N */
DROP TABLE IF EXISTS ORDERS_00p0;
CREATE TABLE ORDERS_00p0
SELECT 	DISTINCT
		shipping_name,
		shipping_name_trim,
		shipping_country_standardized,
	CASE 	WHEN SUBSTR(shipping_name_trim,1,1) IN ('(','/')
			THEN 
			CASE 	WHEN SUBSTR(shipping_name_trim,-1) IN ('(',')','/') THEN shipping_name_trim
					ELSE CONCAT(shipping_name_trim,'/')
			END
			ELSE CONCAT('/',
						CASE 	WHEN SUBSTR(shipping_name_trim,-1) IN ('(',')','/') THEN shipping_name_trim
								ELSE CONCAT(shipping_name_trim,'/')
						END
			)
	END AS shipping_name_aux
FROM ORDERS_00c3
;


ALTER TABLE ORDERS_00p0 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE ORDERS_00p0 DROP COLUMN shipping_name_trim;


DROP TABLE IF EXISTS ORDERS_00p1;
CREATE TABLE IF NOT EXISTS ORDERS_00p1 LIKE ORDERS_00p0;
ALTER TABLE `ORDERS_00p1` ADD `pos_1` INT(4) NOT NULL;

INSERT INTO ORDERS_00p1
SELECT 	DISTINCT
		id,
		shipping_name,
		shipping_country_standardized,
		shipping_name_aux,
	CASE
		WHEN IF(LOCATE('/',shipping_name_aux)>0,LOCATE('/',(shipping_name_aux)),999) <= IF(LOCATE('(',shipping_name_aux)>0,LOCATE('(',(shipping_name_aux)),999) AND IF(LOCATE('/',shipping_name_aux)>0,LOCATE('/',(shipping_name_aux)),999) <= IF(LOCATE(')',shipping_name_aux)>0,LOCATE(')',(shipping_name_aux)),999) THEN IF(LOCATE('/',shipping_name_aux)>0,LOCATE('/',(shipping_name_aux)),999)
		WHEN IF(LOCATE('(',shipping_name_aux)>0,LOCATE('(',(shipping_name_aux)),999) <= IF(LOCATE(')',shipping_name_aux)>0,LOCATE(')',(shipping_name_aux)),999) THEN IF(LOCATE('(',shipping_name_aux)>0,LOCATE('(',(shipping_name_aux)),999)
		ELSE IF(LOCATE(')',shipping_name_aux)>0,LOCATE(')',(shipping_name_aux)),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_1+1))),999)
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
		shipping_country_standardized,
		shipping_name_aux,
		pos_1,
		pos_2,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_2+pos_1+1))),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
		pos_2,
		pos_3,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_3+pos_2+pos_1+1))),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
	CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_4+pos_3+pos_2+pos_1+1))),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		pos_6,
		CASE
		WHEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) AND IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('/',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('/',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		WHEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) <= IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999) THEN IF(LOCATE('(',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE('(',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
		ELSE IF(LOCATE(')',SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))>0,LOCATE(')',(SUBSTR(shipping_name_aux,pos_6+pos_5+pos_4+pos_3+pos_2+pos_1+1))),999)
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
		shipping_country_standardized,		
		shipping_name_aux,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		pos_5,
		pos_6,
		pos_7,
		SUBSTR(shipping_name_aux,1+pos_1,pos_2-1) AS parse_name_1,
		SUBSTR(shipping_name_aux,1+pos_1+pos_2,pos_3-1) AS parse_name_2,
		SUBSTR(shipping_name_aux,1+pos_1+pos_2+pos_3,pos_4-1) AS parse_name_3,
		SUBSTR(shipping_name_aux,1+pos_1+pos_2+pos_3+pos_4,pos_5-1) AS parse_name_4,
		SUBSTR(shipping_name_aux,1+pos_1+pos_2+pos_3+pos_4+pos_5,pos_6-1) AS parse_name_5,
		SUBSTR(shipping_name_aux,1+pos_1+pos_2+pos_3+pos_4+pos_5+pos_6,pos_7-1) AS parse_name_6
FROM ORDERS_00p7
;


ALTER TABLE ORDERS_00p8
  DROP COLUMN shipping_name_aux,
  DROP COLUMN pos_1,
  DROP COLUMN pos_2,
  DROP COLUMN pos_3,
  DROP COLUMN pos_4,
  DROP COLUMN pos_5,
  DROP COLUMN pos_6,
  DROP COLUMN pos_7
;


ALTER TABLE ORDERS_00p8 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_1` (`parse_name_1`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_2` (`parse_name_2`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_3` (`parse_name_3`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_4` (`parse_name_4`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_5` (`parse_name_5`) USING BTREE;
ALTER TABLE ORDERS_00p8 ADD INDEX `parse_name_6` (`parse_name_6`) USING BTREE;




/* a széttagolt shipping_name mező tagjai közül itt választjuk ki, hogy melyik legyen az igazi név */


DROP TABLE IF EXISTS ORDERS_00c4;
CREATE TABLE ORDERS_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS shipping_name_clean
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


ALTER TABLE ORDERS_00c4 CHANGE `shipping_name_clean` `shipping_name_clean` VARCHAR(64);
ALTER TABLE ORDERS_00c4 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00c4 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00c4 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;



INSERT INTO ORDERS_00c4
SELECT 	DISTINCT 
		c.*,
		CASE 
			WHEN g1.first_name IS NOT NULL THEN c.parse_name_1
			WHEN g2.first_name IS NOT NULL THEN c.parse_name_2
			WHEN g3.first_name IS NOT NULL THEN c.parse_name_3
			ELSE parse_name_1
		END AS shipping_name_clean
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

/* S H I P P I N G   N A M E   M O D U L E:   E N D */



ALTER TABLE ORDERS_00c3 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00c3 DROP COLUMN shipping_name_trim;

DROP TABLE IF EXISTS ORDERS_00c5;
CREATE TABLE IF NOT EXISTS ORDERS_00c5 LIKE ORDERS_00c3;
ALTER TABLE ORDERS_00c5 ADD `shipping_name_clean`  VARCHAR(64);
ALTER TABLE ORDERS_00c5 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;

INSERT INTO ORDERS_00c5
SELECT DISTINCT c.*, d.shipping_name_clean 
FROM ORDERS_00c3 c
LEFT JOIN ORDERS_00c4 d
ON c.shipping_name = d.shipping_name
;