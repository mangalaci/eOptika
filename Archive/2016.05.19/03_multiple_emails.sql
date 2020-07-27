DROP TABLE IF EXISTS USER_10_multiple_emails;

CREATE TABLE IF NOT EXISTS USER_10_multiple_emails
SELECT shipping_name_clean, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00i_TABLE`
WHERE LENGTH(shipping_name_clean) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_name_clean, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
LIMIT 0;

INSERT INTO USER_10_multiple_emails
SELECT shipping_name_clean, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00i_TABLE`
WHERE LENGTH(shipping_name_clean) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_name_clean, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1;
ALTER TABLE USER_10_multiple_emails ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;
DROP TABLE IF EXISTS USER_11_multiple_emails;

CREATE TABLE IF NOT EXISTS USER_11_multiple_emails
SELECT shipping_name_clean, billing_zip_code, user_id
FROM USER_10_multiple_emails
LIMIT 0;

INSERT INTO USER_11_multiple_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, user_id*3 AS user_id
FROM USER_10_multiple_emails;
DROP TABLE IF EXISTS USER_12_multiple_emails;

CREATE TABLE IF NOT EXISTS USER_12_multiple_emails
SELECT a.shipping_name_clean, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id
FROM BASE_00i_TABLE AS a, USER_11_multiple_emails AS b
WHERE a.shipping_name_clean = b.shipping_name_clean
AND a.billing_zip_code = b.billing_zip_code
LIMIT 0;

ALTER TABLE `USER_12_multiple_emails`
  ADD INDEX `user_id` (`user_id`),
  ADD INDEX `related_email_clean` (`related_email_clean`),
  ADD INDEX `billing_zip_code` (`billing_zip_code`),
  ADD INDEX `shipping_name_clean` (`shipping_name_clean`);

INSERT INTO USER_12_multiple_emails
SELECT DISTINCT a.shipping_name_clean, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id
FROM BASE_00i_TABLE AS a, USER_11_multiple_emails AS b
WHERE a.shipping_name_clean = b.shipping_name_clean
AND a.billing_zip_code = b.billing_zip_code;
DROP TABLE IF EXISTS USER_13_multiple_emails;
CREATE TABLE IF NOT EXISTS USER_13_multiple_emails LIKE USER_12_multiple_emails;

INSERT INTO USER_13_multiple_emails
SELECT *
FROM USER_12_multiple_emails
WHERE related_email_clean LIKE '%@%';
DROP TABLE IF EXISTS USER_14_email_deduplicated;

CREATE TABLE IF NOT EXISTS USER_14_email_deduplicated
SELECT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.user_id ELSE e.user_id END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_13_multiple_emails AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean
LIMIT 0;
ALTER TABLE USER_14_email_deduplicated ADD PRIMARY KEY (`related_email_clean`, `crm_id`) USING BTREE;
ALTER TABLE USER_14_email_deduplicated ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_14_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;

INSERT INTO USER_14_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.user_id ELSE e.user_id END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_13_multiple_emails AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean;
