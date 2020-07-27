DROP TABLE IF EXISTS CANCELLED_ORDERS_00d1;
CREATE TABLE CANCELLED_ORDERS_00d1
SELECT 	DISTINCT c.shipping_name_clean,
		MIN(CASE
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g.nem IS NULL THEN c.user_type
			ELSE g.nem
		END) AS nem
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g
ON
CASE 	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g.nev
		THEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g.nev
		WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g.nev
		THEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g.nev
		ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g.nev
		END
WHERE shipping_name_clean NOT IN ('', 'teszt teszt', 'teszt elek', 'vezetéknév keresztné', 'teszt vezetékné teszt keresztnév', 'vezetéknév keresztnév')
		GROUP BY c.sql_id
ORDER BY c.sql_id
;

ALTER TABLE CANCELLED_ORDERS_00d1 ADD PRIMARY KEY (`shipping_name_clean`) USING BTREE;





DROP TABLE IF EXISTS CANCELLED_ORDERS_00d;
CREATE TABLE CANCELLED_ORDERS_00d
SELECT a.*, nem AS gender
FROM CANCELLED_ORDERS_00c3 AS a LEFT JOIN
(
SELECT 	c.shipping_name_clean,
		MIN(CASE
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g.nem IS NULL THEN c.user_type
			ELSE g.nem
		END) AS nem
FROM CANCELLED_ORDERS_00c3 c
LEFT JOIN IN_gender g
ON
CASE 	WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g.nev
		THEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 2), ' ', -1) = g.nev
		WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g.nev
		THEN SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 1), ' ', -1) = g.nev
		ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(c.shipping_name_clean, ' ', 3), ' ', -1) = g.nev
		END
GROUP BY c.sql_id
ORDER BY c.sql_id
) AS b
ON a.shipping_name_clean = b.shipping_name_clean
LIMIT 0;








ALTER TABLE CANCELLED_ORDERS_00d ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00d ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
