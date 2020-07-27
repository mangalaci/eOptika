

DROP TABLE IF EXISTS CANCELLED_ORDERS_00d;
CREATE TABLE CANCELLED_ORDERS_00d
SELECT a.*, gender
FROM CANCELLED_ORDERS_00c3 AS a LEFT JOIN
(SELECT a.billing_name, a.shipping_name_clean, MAX(b.nev) AS keresztnev, MAX(b.nem) AS gender
  FROM CANCELLED_ORDERS_00c3 AS a LEFT JOIN IN_gender AS b ON 
	CASE WHEN LOCATE(b.nev, a.shipping_name_clean) > 0 THEN  shipping_name_clean LIKE CONCAT('%', b.nev, '%')
		 WHEN LOCATE(b.nev, a.billing_name) > 0 THEN a.billing_name LIKE CONCAT('%', b.nev, '%')
		ELSE a.shipping_name LIKE CONCAT('%', b.nev, '%')
	END
  WHERE billing_country = 'HUN'
  GROUP BY shipping_name_clean) AS b
ON a.shipping_name_clean = b.shipping_name_clean
;



 /*né-ket kezelni kellene Pumival*/


ALTER TABLE CANCELLED_ORDERS_00d ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
