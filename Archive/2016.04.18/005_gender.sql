
ALTER TABLE IN_gender ADD INDEX `nev` (`nev`) USING BTREE;
ALTER TABLE IN_gender ADD INDEX `nem` (`nem`) USING BTREE;


DROP TABLE IF EXISTS BASE_005_TABLE;
CREATE TABLE BASE_005_TABLE
SELECT a.*, gender
FROM BASE_004c_TABLE AS a LEFT JOIN
(SELECT a.billing_name, a.shipping_name_clean, MAX(b.nev) AS keresztnev, MAX(b.nem) AS gender
  FROM BASE_004c_TABLE AS a LEFT JOIN IN_gender AS b ON 
	CASE WHEN LOCATE(b.nev, a.shipping_name_clean) > 0 THEN  shipping_name_clean LIKE CONCAT('%', b.nev, '%')
		 WHEN LOCATE(b.nev, a.billing_name) > 0 THEN a.billing_name LIKE CONCAT('%', b.nev, '%')
		ELSE a.shipping_name LIKE CONCAT('%', b.nev, '%')
	END
  WHERE related_division = 'Optika - HU'
  GROUP BY shipping_name_clean) AS b
ON a.shipping_name_clean = b.shipping_name_clean
LIMIT 0;



 /*né-ket kezelni kellene Pumival*/



INSERT INTO BASE_005_TABLE
SELECT a.*, gender
FROM BASE_004c_TABLE AS a LEFT JOIN
(SELECT a.billing_name, a.shipping_name_clean, MAX(b.nev) AS keresztnev, MAX(b.nem) AS gender
  FROM BASE_004c_TABLE AS a LEFT JOIN IN_gender AS b ON 
	CASE WHEN LOCATE(b.nev, a.shipping_name_clean) > 0 THEN  shipping_name_clean LIKE CONCAT('%', b.nev, '%')
		 WHEN LOCATE(b.nev, a.billing_name) > 0 THEN a.billing_name LIKE CONCAT('%', b.nev, '%')
		ELSE a.shipping_name LIKE CONCAT('%', b.nev, '%')
	END
  WHERE related_division = 'Optika - HU'
  GROUP BY shipping_name_clean) AS b
ON a.shipping_name_clean = b.shipping_name_clean
;


ALTER TABLE BASE_005_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `billing_country` (`billing_country`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `shipping_country` (`shipping_country`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `related_division` (`related_division`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `shipping_name` (`shipping_name`) USING BTREE;
ALTER TABLE BASE_005_TABLE ADD INDEX `billing_name` (`billing_name`) USING BTREE;
