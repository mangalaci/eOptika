
/*crm_id is loaded back to base table*/
DROP TABLE BASE_01_TABLE;
CREATE TABLE BASE_01_TABLE
SELECT DISTINCT b.*, e.crm_id
FROM BASE_00h_TABLE AS b LEFT JOIN USER_14_email_deduplicated AS e
ON b.related_email_clean = e.related_email_clean;


ALTER TABLE BASE_01_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_01_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_01_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_01_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

DROP TABLE BASE_02_TABLE;
CREATE TABLE BASE_02_TABLE
SELECT b.*, e.user_id as crm_id_2
FROM BASE_01_TABLE AS b LEFT JOIN USER_07_matching_emails_plus_ID AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;


ALTER TABLE BASE_02_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_02_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_02_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_02_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

DROP TABLE BASE_03_TABLE;
CREATE TABLE BASE_03_TABLE
SELECT b.*, e.user_id as crm_id_3, COALESCE(b.crm_id,COALESCE(b.crm_id_2,e.user_id)) as user_id
FROM BASE_02_TABLE AS b LEFT JOIN USER_09_non_matching_emails AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;

ALTER TABLE BASE_03_TABLE DROP crm_id;
ALTER TABLE BASE_03_TABLE DROP crm_id_2;
ALTER TABLE BASE_03_TABLE DROP crm_id_3;


ALTER TABLE BASE_03_TABLE ADD PRIMARY KEY `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
___________________________________________


CREATE TABLE USER_LIST
SELECT DISTINCT billing_name, shipping_name, shipping_name_clean, related_email_clean, billing_zip_code, related_division, user_id
FROM `BASE_03_TABLE`
ORDER BY 2



/*54165*/
SELECT count(DISTINCT related_email_clean)
FROM `BASE_01_TABLE`;

/*48563*/
SELECT count(DISTINCT crm_id)
FROM `BASE_01_TABLE`;


SELECT shipping_name, shipping_name_clean, billing_zip_code, related_email, related_email_clean, crm_id
FROM `BASE_01_TABLE`
GROUP BY shipping_name, shipping_name_clean, billing_zip_code, related_email, related_email_clean
ORDER BY 2;

