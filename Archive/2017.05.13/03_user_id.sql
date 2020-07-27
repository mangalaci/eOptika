DROP TABLE IF EXISTS BASE_01_TABLE;
CREATE TABLE IF NOT EXISTS BASE_01_TABLE LIKE BASE_00j_TABLE;
ALTER TABLE `BASE_01_TABLE` ADD `crm_id` BIGINT(20) NULL DEFAULT NULL;

/*crm_id is loaded back to base table*/
INSERT INTO BASE_01_TABLE
SELECT DISTINCT b.*, e.crm_id /*multiple -> unique*/
FROM BASE_00j_TABLE AS b LEFT JOIN USER_27_email_deduplicated AS e
ON b.related_email_clean = e.related_email_clean;

DROP TABLE IF EXISTS BASE_02_TABLE;
CREATE TABLE IF NOT EXISTS BASE_02_TABLE LIKE BASE_01_TABLE;
ALTER TABLE `BASE_02_TABLE` ADD `crm_id_2` BIGINT(20) NULL DEFAULT NULL;

INSERT INTO BASE_02_TABLE
SELECT DISTINCT b.*, e.crm_id as crm_id_2 /*matching missing*/
FROM BASE_01_TABLE AS b LEFT JOIN USER_37_matching_emails_plus_ID AS e
ON b.real_name_clean = e.real_name_clean
AND b.billing_zip_code = e.billing_zip_code;

DROP TABLE IF EXISTS BASE_03_TABLE;
CREATE TABLE IF NOT EXISTS BASE_03_TABLE LIKE BASE_02_TABLE;
ALTER TABLE `BASE_03_TABLE` ADD `crm_id_3` BIGINT(20) NULL DEFAULT NULL;
ALTER TABLE `BASE_03_TABLE` ADD `user_id` BIGINT(20);

INSERT INTO BASE_03_TABLE
SELECT DISTINCT b.*, e.user_id as crm_id_3, /*non-matching missing*/
		COALESCE(b.crm_id,COALESCE(b.crm_id_2,COALESCE(e.user_id,'N/A'))) as user_id
FROM BASE_02_TABLE AS b LEFT JOIN USER_39_non_matching_emails AS e
ON b.real_name_clean = e.real_name_clean
AND b.billing_zip_code = e.billing_zip_code;

ALTER TABLE BASE_03_TABLE DROP crm_id;
ALTER TABLE BASE_03_TABLE DROP crm_id_2;
ALTER TABLE BASE_03_TABLE DROP crm_id_3;