DROP TABLE IF EXISTS USER_03_missing_emails;

CREATE TABLE IF NOT EXISTS USER_03_missing_emails
SELECT shipping_name_clean, billing_zip_code, related_division FROM `BASE_00i_TABLE`
LIMIT 0;
ALTER TABLE USER_03_missing_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_03_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

INSERT INTO USER_03_missing_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_division
FROM `BASE_00i_TABLE`
WHERE LENGTH(related_email_clean) <= 3 /*nincs email, se más azonosító*/
AND  LENGTH(shipping_name_clean) > 3;
DROP TABLE IF EXISTS USER_04_name_zip_emails;

CREATE TABLE IF NOT EXISTS USER_04_name_zip_emails AS
SELECT shipping_name_clean, billing_zip_code, related_email_clean, related_division FROM `BASE_00i_TABLE`
LIMIT 0;
ALTER TABLE USER_04_name_zip_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_04_name_zip_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_04_name_zip_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

INSERT INTO USER_04_name_zip_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_email_clean, related_division
FROM `BASE_00i_TABLE`
WHERE  LENGTH(related_email_clean) > 3
AND  LENGTH(shipping_name_clean) > 3
GROUP BY shipping_name_clean, billing_zip_code;
DROP TABLE IF EXISTS USER_05_match_missing_emails;

CREATE TABLE IF NOT EXISTS USER_05_match_missing_emails
SELECT b.shipping_name_clean, b.billing_zip_code, e.related_email_clean, b.related_division
FROM USER_03_missing_emails AS b LEFT JOIN USER_04_name_zip_emails AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code
LIMIT 0;
ALTER TABLE USER_05_match_missing_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_05_match_missing_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_05_match_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

INSERT INTO USER_05_match_missing_emails
SELECT b.shipping_name_clean, b.billing_zip_code, e.related_email_clean, b.related_division
FROM USER_03_missing_emails AS b LEFT JOIN USER_04_name_zip_emails AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;
DROP TABLE IF EXISTS USER_06_matching_emails;
CREATE TABLE IF NOT EXISTS USER_06_matching_emails LIKE USER_05_match_missing_emails;

INSERT INTO USER_06_matching_emails
SELECT *
FROM USER_05_match_missing_emails
WHERE related_email_clean IS NOT NULL;
DROP TABLE IF EXISTS USER_07_matching_emails_plus_ID;

CREATE TABLE IF NOT EXISTS USER_07_matching_emails_plus_ID
SELECT b.shipping_name_clean, b.billing_zip_code, b.related_email_clean, b.related_division, e.user_id
FROM USER_06_matching_emails AS b LEFT JOIN USER_02_unique_emails AS e
ON b.related_email_clean = e.related_email_clean
LIMIT 0;
ALTER TABLE USER_07_matching_emails_plus_ID ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_07_matching_emails_plus_ID ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_07_matching_emails_plus_ID ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

INSERT INTO USER_07_matching_emails_plus_ID
SELECT b.shipping_name_clean, b.billing_zip_code, b.related_email_clean, b.related_division, e.user_id
FROM USER_06_matching_emails AS b LEFT JOIN USER_02_unique_emails AS e
ON b.related_email_clean = e.related_email_clean;
DROP TABLE IF EXISTS USER_08_non_matching_emails;
CREATE TABLE IF NOT EXISTS USER_08_non_matching_emails LIKE USER_05_match_missing_emails;

INSERT INTO USER_08_non_matching_emails
SELECT *
FROM USER_05_match_missing_emails
WHERE related_email_clean IS NULL;
ALTER TABLE USER_08_non_matching_emails ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;
DROP TABLE IF EXISTS USER_09_non_matching_emails;

CREATE TABLE IF NOT EXISTS USER_09_non_matching_emails
SELECT shipping_name_clean, billing_zip_code, related_division, user_id
FROM USER_08_non_matching_emails
LIMIT 0;
ALTER TABLE USER_09_non_matching_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_09_non_matching_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

INSERT INTO USER_09_non_matching_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_division, (user_id*3)-2 AS user_id
FROM USER_08_non_matching_emails;