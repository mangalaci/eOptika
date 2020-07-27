DROP TABLE IF EXISTS INVOICES_00e;
CREATE TABLE IF NOT EXISTS INVOICES_00e LIKE INVOICES_00d;
ALTER TABLE `INVOICES_00e` ADD `reminder_day` VARCHAR(10) NOT NULL;

INSERT INTO INVOICES_00e
SELECT DISTINCT a.*, CASE WHEN max(nap) IS NOT NULL THEN max(nap) ELSE '9999-12-31' END reminder_day
FROM INVOICES_00d AS a LEFT JOIN IN_vasarlas_emlekezteto AS b
ON a.related_email_clean = b.email
AND left(a.item_sku,12) = left(b.cikkek,12)
AND DATE(nap) < DATE(created)
GROUP BY a.sql_id;

ALTER TABLE INVOICES_00e ADD INDEX `item_sku` (`item_sku`) USING BTREE;