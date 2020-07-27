DROP TABLE IF EXISTS CANCELLED_ORDERS_00d1;
CREATE TABLE CANCELLED_ORDERS_00d1
SELECT 	DISTINCT c.*,
		MIN(CASE
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.gender = 'Female' OR g2.gender = 'Female' OR g3.gender = 'Female' THEN 'Female'
			ELSE COALESCE(g2.gender,COALESCE(g1.gender,'missing'))
		END) AS gender,

		TRIM(CONCAT(UCASE(LEFT(g1.first_name, 1)), LCASE(SUBSTRING(g1.first_name, 2)))) AS first_name_1,
	/*case when azért kell, mert ha több keresztnév is van akkor azok nem egyezhetnek meg*/
		CASE WHEN IFNULL(g1.first_name,'') = g2.first_name THEN ''	ELSE g2.first_name END AS first_name_2,
		CASE WHEN IFNULL(g2.first_name,'') = g3.first_name THEN ''	ELSE g3.first_name END AS first_name_3
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.first_name AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.first_name AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.first_name AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.first_name AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
LIMIT 0;


ALTER TABLE CANCELLED_ORDERS_00d1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d1 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d1 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d1 ADD INDEX `gender` (`gender`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d1 ADD last_name VARCHAR(255);



INSERT INTO CANCELLED_ORDERS_00d1
SELECT 	DISTINCT c.*,
		MIN(CASE
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.gender = 'Female' OR g2.gender = 'Female' OR g3.gender = 'Female' THEN 'Female'
			ELSE COALESCE(g2.gender,COALESCE(g1.gender,'missing'))
		END) AS gender,
		TRIM(CONCAT(UCASE(LEFT(g1.first_name, 1)), LCASE(SUBSTRING(g1.first_name, 2)))) AS first_name_1,
/*case when azért kell, mert ha több keresztnév is van akkor azok nem egyezhetnek meg*/
		CASE WHEN IFNULL(g1.first_name,'') = g2.first_name THEN ''	ELSE g2.first_name END AS first_name_2,
		CASE WHEN IFNULL(g2.first_name,'') = g3.first_name THEN ''	ELSE g3.first_name END AS first_name_3,
/*a last_name-ből ki kell venni az összes keresztnevet (ha több van)*/		
		REPLACE(REPLACE(shipping_name_clean, LOWER(g2.first_name),''), LOWER(g3.first_name),'') AS last_name
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.first_name AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.first_name AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.first_name AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.first_name AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id;


DROP TABLE IF EXISTS CANCELLED_ORDERS_00d2;
CREATE TABLE CANCELLED_ORDERS_00d2
SELECT DISTINCT a.*,
		CASE WHEN shipping_country_standardized = 'Hungary' THEN
						CONCAT(c.prefix,' ', last_name, ' ', CONCAT(first_name_2,' ',first_name_3), c.suffix)
		ELSE
						CONCAT(c.prefix,' ',CONCAT(first_name_1,' ',first_name_2), ' ', last_name ,c.suffix) 
		END	AS salutation
FROM CANCELLED_ORDERS_00d1 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.shipping_country_standardized = c.country)
LIMIT 0;


ALTER TABLE CANCELLED_ORDERS_00d2 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `gender` (`gender`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d2 ADD INDEX `billing_name` (`billing_name`) USING BTREE;



INSERT INTO CANCELLED_ORDERS_00d2
SELECT DISTINCT a.*, c.prefix AS salutation
FROM CANCELLED_ORDERS_00d1 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.shipping_country_standardized = c.country)
;


