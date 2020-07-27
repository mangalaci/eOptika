DROP TABLE IF EXISTS ORDERS_00e;
CREATE TABLE IF NOT EXISTS ORDERS_00e LIKE ORDERS_00d5;
ALTER TABLE `ORDERS_00e` ADD `reminder_day_dt` VARCHAR(10) NOT NULL;
ALTER TABLE `ORDERS_00e` ADD `reminder_day_flg` VARCHAR(20) NOT NULL;

INSERT INTO ORDERS_00e
SELECT DISTINCT a.*, 
				CASE WHEN max(nap) IS NOT NULL THEN max(nap) ELSE '9999-12-31' END reminder_day_dt,
				CASE WHEN max(nap) IS NOT NULL THEN 'received' ELSE 'never received' END reminder_day_flg
FROM ORDERS_00d5 AS a LEFT JOIN IN_vasarlas_emlekezteto AS b
ON a.related_email_clean = b.email
AND left(a.item_sku,12) = left(b.cikkek,12)
AND DATE(nap) < DATE(created)
GROUP BY a.sql_id;

ALTER TABLE ORDERS_00e ADD INDEX `item_sku` (`item_sku`) USING BTREE;