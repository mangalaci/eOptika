DROP TABLE IF EXISTS CANCELLED_ORDERS_00e;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00e LIKE CANCELLED_ORDERS_00d2;
ALTER TABLE `CANCELLED_ORDERS_00e` ADD `reminder_day_dt` VARCHAR(10) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00e` ADD `reminder_day_flg` VARCHAR(20) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00e
SELECT DISTINCT a.*, 
				CASE WHEN max(nap) IS NOT NULL THEN max(nap) ELSE '9999-12-31' END reminder_day_dt,
				CASE WHEN max(nap) IS NOT NULL THEN 'received' ELSE 'never received' END reminder_day_flg
FROM CANCELLED_ORDERS_00d2 AS a LEFT JOIN IN_vasarlas_emlekezteto AS b
ON a.related_email_clean = b.email
AND left(a.item_sku,12) = left(b.cikkek,12)
AND DATE(nap) < DATE(created)
GROUP BY a.sql_id;

ALTER TABLE CANCELLED_ORDERS_00e ADD INDEX `item_sku` (`item_sku`) USING BTREE;