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

DROP TABLE IF EXISTS INVOICES_00c1;
CREATE TABLE IF NOT EXISTS INVOICES_00c1 LIKE INVOICES_00b;
ALTER TABLE INVOICES_00c1 ADD `province` VARCHAR(255) NOT NULL;
ALTER TABLE INVOICES_00c1 ADD `city_size` INT(8) NOT NULL;
ALTER TABLE INVOICES_00c1 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE INVOICES_00c1 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

INSERT INTO INVOICES_00c1
  SELECT b.*, e.megye AS province, e.meret AS city_size
  FROM INVOICES_00b AS b 
    LEFT JOIN IN_telepules_megye2 AS e
      ON e.telepules_clean = b.billing_city_clean;

DROP TABLE IF EXISTS INVOICES_00c2;
CREATE TABLE IF NOT EXISTS INVOICES_00c2 LIKE INVOICES_00c1;
ALTER TABLE `INVOICES_00c2` ADD `billing_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00c2
SELECT DISTINCT b.*, 
        CASE WHEN length(b.billing_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS billing_country_standardized
FROM INVOICES_00c1 AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country;

DROP TABLE IF EXISTS INVOICES_00c3;
CREATE TABLE IF NOT EXISTS INVOICES_00c3 LIKE INVOICES_00c2;
ALTER TABLE `INVOICES_00c3` ADD `shipping_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO INVOICES_00c3
SELECT DISTINCT b.*, 
        CASE WHEN length(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS shipping_country_standardized
FROM INVOICES_00c2 AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country;

ALTER TABLE INVOICES_00c3 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;


__________________________________________
DROP TABLE IF EXISTS INVOICES_00p1;
CREATE TABLE INVOICES_00p1
SELECT 	DISTINCT
		shipping_name,
		shipping_name_trim,
		CASE 	WHEN LOCATE('/',shipping_name_trim) > 0 AND LOCATE('(',shipping_name_trim) = 0 THEN LOCATE('/',shipping_name_trim)
				WHEN LOCATE('/',shipping_name_trim) = 0 AND LOCATE('(',shipping_name_trim) > 0 THEN LOCATE('(',shipping_name_trim)
				ELSE IF(LOCATE('/',shipping_name_trim)>LOCATE('(',shipping_name_trim),LOCATE('(',shipping_name_trim),LOCATE('/',shipping_name_trim)) 
		END AS pos_1
FROM INVOICES_00a
WHERE shipping_name LIKE '%/%'
AND shipping_name LIKE '%(%'
;

ALTER TABLE `INVOICES_00p1` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



DROP TABLE IF EXISTS INVOICES_00p2;
CREATE TABLE IF NOT EXISTS INVOICES_00p2 LIKE INVOICES_00p1;
ALTER TABLE `INVOICES_00p2` ADD `pos_2` INT(4) NOT NULL;

INSERT INTO INVOICES_00p2
SELECT 	DISTINCT
		id,
		shipping_name,
		shipping_name_trim,
		pos_1,
		CASE 	WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) > 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) = 0 THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) = 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) > 0 THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) = 0 AND LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1)) > 0 THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+1))

				END AS pos_2
FROM INVOICES_00p1
;



DROP TABLE IF EXISTS INVOICES_00p3;
CREATE TABLE IF NOT EXISTS INVOICES_00p3 LIKE INVOICES_00p2;
ALTER TABLE `INVOICES_00p3` ADD `pos_3` INT(4) NOT NULL;

INSERT INTO INVOICES_00p3
SELECT 	DISTINCT
		id,
		shipping_name,
		shipping_name_trim,
		pos_1,
		pos_2,
		CASE 	WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) > 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) = 0 THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) = 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) > 0 THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) = 0 AND LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) > 0 THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+1))
				END AS pos_3
FROM INVOICES_00p2
;





DROP TABLE IF EXISTS INVOICES_00p4;
CREATE TABLE IF NOT EXISTS INVOICES_00p4 LIKE INVOICES_00p3;
ALTER TABLE `INVOICES_00p4` ADD `pos_4` INT(4) NOT NULL;

INSERT INTO INVOICES_00p4
SELECT 	DISTINCT
		id,
		shipping_name,
		shipping_name_trim,
		pos_1,
		pos_2,
		pos_3,
		CASE 	WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) > 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) = 0 THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) = 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) > 0 THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) = 0 AND LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) > 0 THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+1))
	END AS pos_4
FROM INVOICES_00p3
;




DROP TABLE IF EXISTS INVOICES_00p5;
CREATE TABLE IF NOT EXISTS INVOICES_00p5 LIKE INVOICES_00p4;
ALTER TABLE `INVOICES_00p5` ADD `pos_5` INT(4) NOT NULL;

INSERT INTO INVOICES_00p5
SELECT 	DISTINCT
		id,
		shipping_name,
		shipping_name_trim,
		pos_1,
		pos_2,
		pos_3,
		pos_4,
		CASE 	WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) > 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) = 0 THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) = 0 AND LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) > 0 THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) = 0 AND LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) > 0 THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE('/',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))
				WHEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) < LOCATE('(',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1)) THEN LOCATE(')',SUBSTR(shipping_name_trim,pos_1+pos_2+pos_3+pos_4+1))				
		END AS pos_5
FROM INVOICES_00p4
;


DROP TABLE IF EXISTS INVOICES_00c4;
CREATE TABLE INVOICES_00c4 
SELECT 	DISTINCT shipping_name,
		shipping_name_trim,
		related_email_clean,
		shipping_country_standardized,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 1), '/', -1), '(', 1), '(', -1), ' ', 1), ' ', -1) AS parse_name_1a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 1), '/', -1), '(', 1), '(', -1), ' ', 2), ' ', -1) AS parse_name_1b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 1), '/', -1), '(', 1), '(', -1), ' ', 3), ' ', -1) AS parse_name_1c,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 2), '/', -1), '(', 2), '(', -1), ' ', 1), ' ', -1) AS parse_name_2a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 2), '/', -1), '(', 2), '(', -1), ' ', 2), ' ', -1) AS parse_name_2b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 2), '/', -1), '(', 2), '(', -1), ' ', 3), ' ', -1) AS parse_name_2c,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 3), '/', -1), '(', 3), '(', -1), ' ', 1), ' ', -1) AS parse_name_3a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 3), '/', -1), '(', 3), '(', -1), ' ', 2), ' ', -1) AS parse_name_3b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 4), '/', -1), '(', 4), '(', -1), ' ', 1), ' ', -1) AS parse_name_4a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '/', 4), '/', -1), '(', 4), '(', -1), ' ', 2), ' ', -1) AS parse_name_4b,
		
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 1), '(', -1), '/', 1), '/', -1) AS parse_name_1,		
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 2), '(', -1), '/', 2), '/', -1) AS parse_name_2,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 3), '(', -1), '/', 3), '/', -1) AS parse_name_3,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 4), '(', -1), '/', 4), '/', -1) AS parse_name_4
FROM INVOICES_00c3 c
LIMIT 0;


INSERT INTO INVOICES_00c4
SELECT 	DISTINCT shipping_name,
		shipping_name_trim,
		related_email_clean,
		shipping_country_standardized,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 1), '(', -1), '/', 1), '/', -1), ' ', 1), ' ', -1) AS parse_name_1a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 1), '(', -1), '/', 1), '/', -1), ' ', 2), ' ', -1) AS parse_name_1b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 1), '(', -1), '/', 1), '/', -1), ' ', 3), ' ', -1) AS parse_name_1c,		
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 2), '(', -1), '/', 2), '/', -1), ' ', 1), ' ', -1) AS parse_name_2a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 2), '(', -1), '/', 2), '/', -1), ' ', 2), ' ', -1) AS parse_name_2b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 2), '(', -1), '/', 2), '/', -1), ' ', 3), ' ', -1) AS parse_name_2c,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 3), '(', -1), '/', 3), '/', -1), ' ', 1), ' ', -1) AS parse_name_3a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 3), '(', -1), '/', 3), '/', -1), ' ', 2), ' ', -1) AS parse_name_3b,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 4), '(', -1), '/', 4), '/', -1), ' ', 1), ' ', -1) AS parse_name_4a,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_trim, '(', 4), '(', -1), '/', 4), '/', -1), ' ', 2), ' ', -1) AS parse_name_4b,
		
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 1), '(', -1), '/', 1), '/', -1) AS parse_name_1,		
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 2), '(', -1), '/', 2), '/', -1) AS parse_name_2,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 3), '(', -1), '/', 3), '/', -1) AS parse_name_3,
		SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name, '(', 4), '(', -1), '/', 4), '/', -1) AS parse_name_4
FROM INVOICES_00c3 c
;

ALTER TABLE INVOICES_00c4 CHANGE `shipping_name` `shipping_name` VARCHAR(120);
ALTER TABLE INVOICES_00c4 CHANGE `shipping_name_trim` `shipping_name_trim` VARCHAR(120);
ALTER TABLE INVOICES_00c4 CHANGE `related_email_clean` `related_email_clean` VARCHAR(80);
ALTER TABLE INVOICES_00c4 CHANGE `shipping_country_standardized` `shipping_country_standardized` VARCHAR(20);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_1a` `parse_name_1a` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_1b` `parse_name_1b` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_1c` `parse_name_1c` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_2a` `parse_name_2a` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_2b` `parse_name_2b` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_3a` `parse_name_3a` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_3b` `parse_name_3b` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_4a` `parse_name_4a` VARCHAR(40);
ALTER TABLE INVOICES_00c4 CHANGE `parse_name_4b` `parse_name_4b` VARCHAR(40);

ALTER TABLE INVOICES_00c4 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `shipping_name_trim` (`shipping_name_trim`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_1a` (`parse_name_1a`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_1b` (`parse_name_1b`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_1c` (`parse_name_1c`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_2a` (`parse_name_2a`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_2b` (`parse_name_2b`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_3a` (`parse_name_3a`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_3b` (`parse_name_3b`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_4a` (`parse_name_4a`) USING BTREE;
ALTER TABLE INVOICES_00c4 ADD INDEX `parse_name_4b` (`parse_name_4b`) USING BTREE;



DROP TABLE IF EXISTS INVOICES_00c5;
CREATE TABLE INVOICES_00c5
SELECT 	DISTINCT 
		c.shipping_name,
		c.related_email_clean,
		c.shipping_country_standardized,
		CASE 	WHEN ((LOWER(c.parse_name_1a) = LOWER(g1a.first_name) AND c.shipping_country_standardized = g1a.country) OR (LOWER(c.parse_name_1b) = LOWER(g1b.first_name) AND c.shipping_country_standardized = g1b.country) OR (LOWER(c.parse_name_1c) = LOWER(g1c.first_name) AND c.shipping_country_standardized = g1c.country)) THEN parse_name_1
				WHEN ((LOWER(c.parse_name_2a) = LOWER(g2a.first_name) AND c.shipping_country_standardized = g2a.country) OR (LOWER(c.parse_name_2b) = LOWER(g2b.first_name) AND c.shipping_country_standardized = g2b.country) OR (LOWER(c.parse_name_2c) = LOWER(g2c.first_name) AND c.shipping_country_standardized = g2c.country)) THEN parse_name_2
				WHEN ((LOWER(c.parse_name_3a) = LOWER(g3a.first_name) AND c.shipping_country_standardized = g3a.country) OR (LOWER(c.parse_name_3b) = LOWER(g3b.first_name) AND c.shipping_country_standardized = g3b.country)) THEN parse_name_3
				WHEN ((LOWER(c.parse_name_4a) = LOWER(g4a.first_name) AND c.shipping_country_standardized = g4a.country) OR (LOWER(c.parse_name_4b) = LOWER(g4b.first_name) AND c.shipping_country_standardized = g4b.country)) THEN parse_name_4
				ELSE shipping_name
		END AS shipping_name_clean
FROM INVOICES_00c4 c
LEFT JOIN IN_gender g1a
ON (LOWER(c.parse_name_1a) = LOWER(g1a.first_name) AND c.shipping_country_standardized = g1a.country)
LEFT JOIN IN_gender g1b
ON (LOWER(c.parse_name_1b) = LOWER(g1b.first_name) AND c.shipping_country_standardized = g1b.country)
LEFT JOIN IN_gender g1c
ON (LOWER(c.parse_name_1c) = LOWER(g1c.first_name) AND c.shipping_country_standardized = g1c.country)
LEFT JOIN IN_gender g2a
ON (LOWER(c.parse_name_2a) = LOWER(g2a.first_name) AND c.shipping_country_standardized = g2a.country)
LEFT JOIN IN_gender g2b
ON (LOWER(c.parse_name_2b) = LOWER(g2b.first_name) AND c.shipping_country_standardized = g2b.country)
LEFT JOIN IN_gender g2c
ON (LOWER(c.parse_name_2c) = LOWER(g2c.first_name) AND c.shipping_country_standardized = g2c.country)
LEFT JOIN IN_gender g3a
ON (LOWER(c.parse_name_3a) = LOWER(g3a.first_name) AND c.shipping_country_standardized = g3a.country)
LEFT JOIN IN_gender g3b
ON (LOWER(c.parse_name_3b) = LOWER(g3b.first_name) AND c.shipping_country_standardized = g3b.country)
LEFT JOIN IN_gender g4a
ON (LOWER(c.parse_name_4a) = LOWER(g4a.first_name) AND c.shipping_country_standardized = g4a.country)
LEFT JOIN IN_gender g4b
ON (LOWER(c.parse_name_4b) = LOWER(g4b.first_name) AND c.shipping_country_standardized = g4b.country)
LIMIT 0;


ALTER TABLE INVOICES_00c5 CHANGE `shipping_name_clean` `shipping_name_clean` VARCHAR(64);

ALTER TABLE INVOICES_00c5 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00c5 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE INVOICES_00c5 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;



INSERT INTO INVOICES_00c5
SELECT 	DISTINCT
		c.shipping_name,
		c.related_email_clean,
		c.shipping_country_standardized,
		CASE 	WHEN ((LOWER(c.parse_name_1a) = LOWER(g1a.first_name) AND c.shipping_country_standardized = g1a.country) OR (LOWER(c.parse_name_1b) = LOWER(g1b.first_name) AND c.shipping_country_standardized = g1b.country) OR (LOWER(c.parse_name_1c) = LOWER(g1c.first_name) AND c.shipping_country_standardized = g1c.country)) THEN parse_name_1
				WHEN ((LOWER(c.parse_name_2a) = LOWER(g2a.first_name) AND c.shipping_country_standardized = g2a.country) OR (LOWER(c.parse_name_2b) = LOWER(g2b.first_name) AND c.shipping_country_standardized = g2b.country) OR (LOWER(c.parse_name_2c) = LOWER(g2c.first_name) AND c.shipping_country_standardized = g2c.country)) THEN parse_name_2
				WHEN ((LOWER(c.parse_name_3a) = LOWER(g3a.first_name) AND c.shipping_country_standardized = g3a.country) OR (LOWER(c.parse_name_3b) = LOWER(g3b.first_name) AND c.shipping_country_standardized = g3b.country)) THEN parse_name_3
				WHEN ((LOWER(c.parse_name_4a) = LOWER(g4a.first_name) AND c.shipping_country_standardized = g4a.country) OR (LOWER(c.parse_name_4b) = LOWER(g4b.first_name) AND c.shipping_country_standardized = g4b.country)) THEN parse_name_4
				ELSE shipping_name
		END AS shipping_name_clean
FROM INVOICES_00c4 c
LEFT JOIN IN_gender g1a
ON (LOWER(c.parse_name_1a) = LOWER(g1a.first_name) AND c.shipping_country_standardized = g1a.country)
LEFT JOIN IN_gender g1b
ON (LOWER(c.parse_name_1b) = LOWER(g1b.first_name) AND c.shipping_country_standardized = g1b.country)
LEFT JOIN IN_gender g1c
ON (LOWER(c.parse_name_1c) = LOWER(g1c.first_name) AND c.shipping_country_standardized = g1c.country)
LEFT JOIN IN_gender g2a
ON (LOWER(c.parse_name_2a) = LOWER(g2a.first_name) AND c.shipping_country_standardized = g2a.country)
LEFT JOIN IN_gender g2b
ON (LOWER(c.parse_name_2b) = LOWER(g2b.first_name) AND c.shipping_country_standardized = g2b.country)
LEFT JOIN IN_gender g2c
ON (LOWER(c.parse_name_2c) = LOWER(g2c.first_name) AND c.shipping_country_standardized = g2c.country)
LEFT JOIN IN_gender g3a
ON (LOWER(c.parse_name_3a) = LOWER(g3a.first_name) AND c.shipping_country_standardized = g3a.country)
LEFT JOIN IN_gender g3b
ON (LOWER(c.parse_name_3b) = LOWER(g3b.first_name) AND c.shipping_country_standardized = g3b.country)
LEFT JOIN IN_gender g4a
ON (LOWER(c.parse_name_4a) = LOWER(g4a.first_name) AND c.shipping_country_standardized = g4a.country)
LEFT JOIN IN_gender g4b
ON (LOWER(c.parse_name_4b) = LOWER(g4b.first_name) AND c.shipping_country_standardized = g4b.country)
LIMIT 5000
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


ALTER TABLE INVOICES_00b ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;