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

DROP TABLE IF EXISTS CANCELLED_ORDERS_00c1;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00c1 LIKE CANCELLED_ORDERS_00b;
ALTER TABLE CANCELLED_ORDERS_00c1 ADD `province` VARCHAR(255) NOT NULL;
ALTER TABLE CANCELLED_ORDERS_00c1 ADD `city_size` INT(8) NOT NULL;
ALTER TABLE CANCELLED_ORDERS_00c1 ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00c1 ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;

INSERT INTO CANCELLED_ORDERS_00c1
  SELECT b.*, e.megye AS province, e.meret AS city_size
  FROM CANCELLED_ORDERS_00b AS b 
    LEFT JOIN IN_telepules_megye2 AS e
      ON e.telepules_clean = b.billing_city_clean;

DROP TABLE IF EXISTS CANCELLED_ORDERS_00c2;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00c2 LIKE CANCELLED_ORDERS_00c1;
ALTER TABLE `CANCELLED_ORDERS_00c2` ADD `billing_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00c2
SELECT DISTINCT b.*, 
        CASE WHEN length(b.billing_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS billing_country_standardized
FROM CANCELLED_ORDERS_00c1 AS b LEFT JOIN IN_country_coding AS e
ON b.billing_country = e.original_country;

DROP TABLE IF EXISTS CANCELLED_ORDERS_00c3;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00c3 LIKE CANCELLED_ORDERS_00c2;
ALTER TABLE `CANCELLED_ORDERS_00c3` ADD `shipping_country_standardized` VARCHAR(255) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00c3
SELECT DISTINCT b.*, 
        CASE WHEN length(b.shipping_country) > 1 THEN e.standardized_country  
                ELSE 'Other' 
                END AS shipping_country_standardized
FROM CANCELLED_ORDERS_00c2 AS b LEFT JOIN IN_country_coding AS e
ON b.shipping_country = e.original_country;
