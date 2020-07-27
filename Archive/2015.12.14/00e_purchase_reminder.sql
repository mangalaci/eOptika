DROP TABLE BASE_00e_TABLE;
CREATE TABLE BASE_00e_TABLE
SELECT DISTINCT a.*, CASE WHEN max(nap) IS NOT NULL THEN max(nap) ELSE '9999-12-31' END reminder_day
FROM BASE_00d_TABLE AS a LEFT JOIN IN_vasarlas_emlekezteto AS b
ON a.related_email_clean = b.email
AND left(a.item_sku,12) = left(b.cikkek,12)
AND DATE(nap) < DATE(created)
GROUP BY a.sql_id
;



ALTER TABLE BASE_00e_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00e_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00e_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00e_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00e_TABLE ADD INDEX `item_sku` (`item_sku`) USING BTREE;

