/*a tisztított név tagokra szétszedése */
DROP TABLE IF EXISTS ORDERS_00d1;
CREATE TABLE ORDERS_00d1
SELECT 	DISTINCT c.*,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) AS parse_name_1,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) AS parse_name_2,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) AS parse_name_3,	
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 4), ' ', -1) AS parse_name_4		
FROM ORDERS_00c5 c
;


ALTER TABLE ORDERS_00d1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00d1 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00d1 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;


/*a feleslegesen ismétlődő tagok törlése */
DROP TABLE IF EXISTS ORDERS_00d2;
CREATE TABLE ORDERS_00d2
SELECT 	DISTINCT c.*,
		parse_name_1 AS name_1,
		CASE WHEN parse_name_2 = parse_name_1 THEN ''	ELSE parse_name_2 END AS name_2,
		CASE WHEN parse_name_3 = parse_name_2 THEN ''	ELSE parse_name_3 END AS name_3,
		CASE WHEN parse_name_4 = parse_name_3 THEN ''	ELSE parse_name_4 END AS name_4
FROM ORDERS_00d1 c
;

ALTER TABLE ORDERS_00d2 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE ORDERS_00d2 ADD INDEX `billing_name` (`billing_name`) USING BTREE;



/*a tagok megjelölése, hogy first vagy last name */
DROP TABLE IF EXISTS ORDERS_00d3;
CREATE TABLE ORDERS_00d3
SELECT 	DISTINCT c.*,

 IF(c.name_1 ='' , '' , IF(g1.first_name IS NULL , 'last_name', IF(c.name_1 LIKE '%né', 'last_name','first_name'))) AS name_ind_1,
 IF(c.name_2 ='' , '' , IF(g2.first_name IS NULL , IF(c.name_2 LIKE '%né', 'first_name','last_name'), 'first_name')) AS name_ind_2,
 IF(c.name_3 ='' , '' , IF(g3.first_name IS NULL , IF(c.name_3 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_3,
 IF(c.name_4 ='' , '' , IF(g4.first_name IS NULL , IF(c.name_4 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_4,
 

CONCAT(UCASE(LEFT(c.name_1, 1)), LCASE(SUBSTRING(c.name_1, 2))) AS upper_name_1,
CONCAT(UCASE(LEFT(c.name_2, 1)), LCASE(SUBSTRING(c.name_2, 2))) AS upper_name_2,
CONCAT(UCASE(LEFT(c.name_3, 1)), LCASE(SUBSTRING(c.name_3, 2))) AS upper_name_3,
CONCAT(UCASE(LEFT(c.name_4, 1)), LCASE(SUBSTRING(c.name_4, 2))) AS upper_name_4,

 		MIN(CASE
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornélia%' THEN 'Female'
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.gender = 'Female' OR g2.gender = 'Female' OR g3.gender = 'Female' THEN 'Female'
			ELSE COALESCE(g3.gender,COALESCE(g2.gender,COALESCE(g1.gender,'missing')))
		END) AS gender
FROM ORDERS_00d2 c
LEFT JOIN IN_gender g1
ON (c.name_1 = g1.first_name AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (c.name_2 = g2.first_name AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (c.name_3 = g3.first_name AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (c.name_4 = g4.first_name AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
;

ALTER TABLE ORDERS_00d3 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00d3 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00d3 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00d3 ADD INDEX `gender` (`gender`) USING BTREE;


/*név tagok és megszólítás összetétele */
DROP TABLE IF EXISTS ORDERS_00d4;
CREATE TABLE ORDERS_00d4
SELECT DISTINCT a.*,
		CASE 
			WHEN c.webshop IS NULL AND shipping_country_standardized = 'Hungary' THEN 'Kedves'
			WHEN c.webshop IS NULL AND shipping_country_standardized <> 'Hungary' THEN 'Dear'
			ELSE c.prefix
		END AS salutation,
		CASE WHEN shipping_country_standardized = 'Hungary' THEN
				CASE 
				WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name'
					THEN CONCAT(shipping_name) /*amikor semmilyen keresztnév nincs a névben: céges név*/
				WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = ''
					THEN upper_name_1 /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/
				WHEN name_ind_1 = 'last_name' 
					THEN upper_name_1
				ELSE upper_name_2
			END
		ELSE
				upper_name_2
		END	AS last_name,

		CASE WHEN shipping_country_standardized = 'Hungary' THEN
			CASE 
				WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name' 
					THEN '' /*amikor semmilyen keresztnév nincs a névben: céges név*/
			WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = '' THEN
						CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4) /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/

			WHEN name_ind_1 = 'last_name' THEN
						CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4)
						ELSE 	CONCAT(upper_name_1,' ',upper_name_3, ' ', upper_name_4)
			END
		ELSE
						upper_name_1
		END	AS first_name,
		
		CASE WHEN shipping_country_standardized = 'Hungary' THEN
			CASE 
			WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name' THEN
						CONCAT(shipping_name) /*amikor semmilyen keresztnév nincs a névben: céges név*/
			WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = '' THEN
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4)) /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/

			WHEN name_ind_1 = 'last_name' THEN
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4))

						ELSE 	CONCAT(upper_name_2, ' ', CONCAT(upper_name_1,' ',upper_name_3, ' ', upper_name_4))
			END
		ELSE
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4))
		END	AS full_name_raw
		
FROM ORDERS_00d3 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.related_webshop = c.webshop)
;


ALTER TABLE ORDERS_00d4 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00d4 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00d4 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00d4 ADD INDEX `gender` (`gender`) USING BTREE;



DROP TABLE IF EXISTS ORDERS_00d5;
CREATE TABLE ORDERS_00d5
SELECT DISTINCT a.*,
		REPLACE(REPLACE(REPLACE(REPLACE(full_name_raw,'/',''),'Dr ','Dr. '),'  !','!'),' !','!') AS full_name
FROM ORDERS_00d4 a
;


ALTER TABLE ORDERS_00d5
  DROP COLUMN parse_name_1,
  DROP COLUMN parse_name_2,
  DROP COLUMN parse_name_3,
  DROP COLUMN parse_name_4,
  DROP COLUMN name_1,
  DROP COLUMN name_2,
  DROP COLUMN name_3,
  DROP COLUMN name_4,
  DROP COLUMN name_ind_1,
  DROP COLUMN name_ind_2,
  DROP COLUMN name_ind_3,
  DROP COLUMN name_ind_4,
  DROP COLUMN upper_name_1,
  DROP COLUMN upper_name_2,
  DROP COLUMN upper_name_3,
  DROP COLUMN upper_name_4,
  DROP COLUMN full_name_raw
;


ALTER TABLE ORDERS_00d5 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00d5 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE ORDERS_00d5 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00d5 ADD INDEX `gender` (`gender`) USING BTREE;