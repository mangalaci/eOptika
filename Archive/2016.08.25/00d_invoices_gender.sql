DROP TABLE IF EXISTS INVOICES_00d1;
CREATE TABLE INVOICES_00d1
SELECT 	DISTINCT c.*,
		MIN(CASE
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.nem = 'Female' OR g2.nem = 'Female' OR g3.nem = 'Female' THEN 'Female'
			ELSE COALESCE(g2.nem,COALESCE(g1.nem,'missing'))
		END) AS gender,
		COALESCE(g2.nev,COALESCE(g1.nev,COALESCE(g3.nev,NULL))) AS first_name
FROM INVOICES_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.nev AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.nev AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.nev AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.nev AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
LIMIT 0;


ALTER TABLE INVOICES_00d1 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00d1 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00d1 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00d1 ADD INDEX `gender` (`gender`) USING BTREE;


INSERT INTO INVOICES_00d1
SELECT 	DISTINCT c.*,
		MIN(CASE
			WHEN LOWER(c.shipping_name_clean) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.nem = 'Female' OR g2.nem = 'Female' OR g3.nem = 'Female' THEN 'Female'
			ELSE COALESCE(g2.nem,COALESCE(g1.nem,'missing'))
		END) AS gender,
		COALESCE(g2.nev,COALESCE(g1.nev,COALESCE(g3.nev,NULL))) AS first_name
FROM INVOICES_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.nev AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.nev AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.nev AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.nev AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
;


DROP TABLE IF EXISTS INVOICES_00d2;
CREATE TABLE INVOICES_00d2
SELECT DISTINCT a.*, c.prefix AS salutation
FROM INVOICES_00d1 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.shipping_country_standardized = c.country)
LIMIT 0;


ALTER TABLE INVOICES_00d2 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `gender` (`gender`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `billing_name` (`billing_name`) USING BTREE;



INSERT INTO INVOICES_00d2
SELECT DISTINCT a.*, c.prefix AS solutation
FROM INVOICES_00d1 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.shipping_country_standardized = c.country)
;