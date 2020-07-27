ALTER TABLE IN_vasarlas_emlekezteto ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE IN_vasarlas_emlekezteto ADD INDEX `email` (`email`) USING BTREE;
ALTER TABLE IN_vasarlas_emlekezteto ADD INDEX `nap` (`nap`) USING BTREE;



DROP TABLE IF EXISTS IN_vasarlas_emlekezteto2;
CREATE TABLE IN_vasarlas_emlekezteto2
SELECT  a.sql_id, CASE WHEN MAX(b.nap) IS NOT NULL THEN MAX(b.nap) ELSE '9999-12-31' END reminder_day
FROM BASE_005_TABLE AS a, IN_vasarlas_emlekezteto AS b
WHERE a.related_email_clean = b.email
AND LEFT(a.item_sku,12) = LEFT(b.cikkek,12)
AND DATE(b.nap) < DATE(a.created)
GROUP BY a.sql_id
;

ALTER TABLE IN_vasarlas_emlekezteto2 ADD PRIMARY KEY (`sql_id`) USING BTREE;


DROP TABLE IF EXISTS BASE_006_TABLE;
CREATE TABLE BASE_006_TABLE
SELECT  a.*, b.reminder_day
FROM BASE_005_TABLE AS a LEFT JOIN IN_vasarlas_emlekezteto2 AS b
ON a.sql_id = b.sql_id
;



ALTER TABLE BASE_006_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_006_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_006_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_006_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_006_TABLE ADD INDEX `item_sku` (`item_sku`) USING BTREE;

