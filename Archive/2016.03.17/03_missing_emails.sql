DROP TABLE IF EXISTS USER_33_missing_emails;
CREATE TABLE USER_33_missing_emails AS
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_division
FROM `BASE_00h_TABLE`
WHERE LENGTH(related_email_clean) <= 3 /*nincs email, se más azonosító*/
AND  LENGTH(shipping_name_clean) > 3 /*van viszont név*/
ORDER By 1;

ALTER TABLE USER_33_missing_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_33_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

/*minden shipping_name_clean és billing_zip_code kulcshoz tartozó related_email_clean*/
DROP TABLE IF EXISTS USER_34_name_zip_emails;
CREATE TABLE USER_34_name_zip_emails AS
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_email_clean, related_division
FROM `BASE_00h_TABLE`
WHERE  LENGTH(related_email_clean) > 3
AND  LENGTH(shipping_name_clean) > 3
GROUP BY shipping_name_clean, billing_zip_code
ORDER By 1;


ALTER TABLE USER_34_name_zip_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_34_name_zip_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_34_name_zip_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

DROP TABLE IF EXISTS USER_35_match_missing_emails;
CREATE TABLE USER_35_match_missing_emails
SELECT b.shipping_name_clean, b.billing_zip_code, e.related_email_clean, b.related_division
FROM USER_33_missing_emails AS b LEFT JOIN USER_34_name_zip_emails AS e
ON b.shipping_name_clean = e.shipping_name_clean
AND b.billing_zip_code = e.billing_zip_code;

ALTER TABLE USER_35_match_missing_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_35_match_missing_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_35_match_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

--ELÁGAZTATÁS
/*A: a hiányzó email cím mellé van másik sor u.a. névvel és irányító számmal*/
DROP TABLE IF EXISTS USER_36_matching_emails;
CREATE TABLE USER_36_matching_emails
SELECT *
FROM USER_35_match_missing_emails
WHERE related_email_clean IS NOT NULL;

DROP TABLE IF EXISTS USER_37_matching_emails_plus_ID;
CREATE TABLE USER_37_matching_emails_plus_ID
SELECT b.shipping_name_clean, b.billing_zip_code, b.related_email_clean, b.related_division, e.crm_id
FROM USER_36_matching_emails AS b LEFT JOIN USER_27_email_deduplicated AS e
ON b.related_email_clean = e.related_email_clean;

ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

/*B: a hiányzó email cím mellé nincs másik sor u.a. névvel és irányító számmal*/
DROP TABLE IF EXISTS USER_38_non_matching_emails;
CREATE TABLE USER_38_non_matching_emails
SELECT *
FROM USER_35_match_missing_emails
WHERE related_email_clean IS NULL;

ALTER TABLE USER_38_non_matching_emails
ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_39_non_matching_emails;
CREATE TABLE USER_39_non_matching_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, related_division, (user_id*5) AS user_id
FROM USER_38_non_matching_emails;

ALTER TABLE USER_39_non_matching_emails ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE USER_39_non_matching_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
