
/*crm_id is loaded back to base table*/
DROP TABLE IF EXISTS BASE_010_TABLE;
CREATE TABLE BASE_010_TABLE
SELECT DISTINCT b.*, e.crm_id /*multiple -> unique*/
FROM BASE_009_TABLE AS b LEFT JOIN USER_27_email_deduplicated AS e
ON b.related_email_clean = e.related_email_clean;


ALTER TABLE BASE_010_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_010_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_010_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_010_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

DROP TABLE IF EXISTS BASE_011_TABLE;
CREATE TABLE BASE_011_TABLE
SELECT DISTINCT b.*, e.crm_id as crm_id_2 /*matching missing*/
FROM BASE_010_TABLE AS b LEFT JOIN USER_37_matching_emails_plus_ID AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;


ALTER TABLE BASE_011_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_011_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_011_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_011_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

DROP TABLE IF EXISTS BASE_012_TABLE;
CREATE TABLE BASE_012_TABLE
SELECT DISTINCT b.*, e.user_id as crm_id_3, /*non-matching missing*/
		COALESCE(b.crm_id,COALESCE(b.crm_id_2,e.user_id)) as user_id
FROM BASE_011_TABLE AS b LEFT JOIN USER_39_non_matching_emails AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;




ALTER TABLE BASE_012_TABLE DROP crm_id;
ALTER TABLE BASE_012_TABLE DROP crm_id_2;
ALTER TABLE BASE_012_TABLE DROP crm_id_3;


ALTER TABLE BASE_012_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_012_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_012_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_012_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_012_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
