DROP TABLE IN_telepules_megye2;
CREATE TABLE IN_telepules_megye2
SELECT DISTINCT telepules,
				MAX(megye) AS megye,
				MAX(meret) AS meret,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(telepules,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS telepules_clean
FROM IN_telepules_megye
GROUP BY telepules
;

ALTER TABLE IN_telepules_megye2 ADD PRIMARY KEY (`telepules_clean`) USING BTREE;


DROP TABLE BASE_00c1_TABLE;
CREATE TABLE BASE_00c1_TABLE
SELECT DISTINCT b.*, e.megye AS province, e.meret AS city_size
FROM BASE_00b_TABLE AS b LEFT JOIN IN_telepules_megye2 AS e
ON e.telepules_clean = b.billing_city_clean
;

ALTER TABLE BASE_00c1_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00c1_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00c1_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00c1_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00c1_TABLE ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE BASE_00c1_TABLE ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

DROP INDEX original_country ON IN_country_coding;
ALTER TABLE IN_country_coding ADD INDEX `original_country` (`original_country`) USING BTREE;

DROP TABLE BASE_00c2_TABLE;
CREATE TABLE BASE_00c2_TABLE
SELECT DISTINCT b.*, 
				CASE WHEN length(b.billing_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS billing_country_standardized
FROM BASE_00c1_TABLE AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country
;


ALTER TABLE BASE_00c2_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00c2_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00c2_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00c2_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00c2_TABLE ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE BASE_00c2_TABLE ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;


DROP TABLE BASE_00c3_TABLE;
CREATE TABLE BASE_00c3_TABLE
SELECT DISTINCT b.*, 
				CASE WHEN length(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS shipping_country_standardized
FROM BASE_00c2_TABLE AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country
;


ALTER TABLE BASE_00c3_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE BASE_00c3_TABLE ADD INDEX `billing_name` (`billing_name`) USING BTREE;