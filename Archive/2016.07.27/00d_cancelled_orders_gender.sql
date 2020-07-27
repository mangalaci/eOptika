SELECT * FROM `CANCELLED_ORDERS_00d`
GROUP BY sql_id
HAVING COUNT(*) > 1

/*
hibalista:
abacus art de-ko kft
ágnes lázár
dr furka andrea
takács györgyi
rados tamás/
csizmadia célia
*/


DROP TABLE IF EXISTS CANCELLED_ORDERS_00d;
CREATE TABLE CANCELLED_ORDERS_00d
SELECT DISTINCT a.*, b.gender, b.first_name, c.prefix AS solutation
FROM CANCELLED_ORDERS_00c3 AS a LEFT JOIN
(
SELECT 	DISTINCT
		c.shipping_name_clean,
		c.shipping_country_standardized,
		MIN(CASE
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.nem = 'Female' OR g2.nem = 'Female' OR g3.nem = 'Female' THEN 'Female'
			ELSE COALESCE(g2.nem,COALESCE(g1.nem,NULL))
		END) AS gender,
		COALESCE(g2.nev,COALESCE(g1.nev,COALESCE(g3.nev,NULL))) AS first_name
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.nev AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.nev AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.nev AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.nev AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
) AS b
ON a.shipping_name_clean = b.shipping_name_clean
LEFT JOIN IN_megszolitasi_formak c
ON (b.gender = c.gender AND b.shipping_country_standardized = c.country)
LIMIT 0;


ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `gender` (`gender`) USING BTREE;


INSERT INTO CANCELLED_ORDERS_00d
SELECT DISTINCT a.*, b.gender, b.first_name, c.prefix AS solutation
FROM CANCELLED_ORDERS_00c3 AS a LEFT JOIN
(
SELECT 	c.sql_id,
		c.shipping_name_clean,
		c.shipping_country_standardized,
		MIN(CASE
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.nem = 'Female' OR g2.nem = 'Female' OR g3.nem = 'Female' THEN 'Female'
			ELSE COALESCE(g2.nem,COALESCE(g1.nem,NULL))
		END) AS gender,
		LOWER(COALESCE(g2.nev,COALESCE(g1.nev,COALESCE(g3.nev,NULL)))) AS first_name
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g1
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g1.nev AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g2.nev AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g3.nev AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g4.nev AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
) AS b
ON a.sql_id = b.sql_id
LEFT JOIN IN_megszolitasi_formak c
ON (b.gender = c.gender AND b.shipping_country_standardized = c.country)
;



ALTER TABLE CANCELLED_ORDERS_00d ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
