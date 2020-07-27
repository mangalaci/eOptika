DROP TABLE IF EXISTS USER_33_missing_emails;
CREATE TABLE IF NOT EXISTS USER_33_missing_emails
SELECT DISTINCT personal_name, billing_zip_code
FROM `BASE_00i_TABLE`
WHERE LENGTH(buyer_email) <= 3 /* nincs email, se más azonosító */
AND  LENGTH(personal_name) > 3 /* viszont van név */
;

ALTER TABLE USER_33_missing_emails ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE USER_33_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;



/*minden personal_name és billing_zip_code kulcshoz tartozó buyer_email*/
DROP TABLE IF EXISTS USER_34_name_zip_emails;
CREATE TABLE IF NOT EXISTS USER_34_name_zip_emails
SELECT DISTINCT personal_name, billing_zip_code, buyer_email
FROM `BASE_00i_TABLE`
WHERE  LENGTH(buyer_email) > 3 /* van email */
AND  LENGTH(personal_name) > 3 /* van név */
GROUP BY personal_name, billing_zip_code;

ALTER TABLE USER_34_name_zip_emails ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_34_name_zip_emails ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE USER_34_name_zip_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;



DROP TABLE IF EXISTS USER_35_match_missing_emails;
CREATE TABLE IF NOT EXISTS USER_35_match_missing_emails
SELECT b.personal_name, b.billing_zip_code, e.buyer_email
FROM USER_33_missing_emails AS b LEFT JOIN USER_34_name_zip_emails AS e
ON b.personal_name = e.personal_name
AND b.billing_zip_code = e.billing_zip_code;

ALTER TABLE USER_35_match_missing_emails ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_35_match_missing_emails ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE USER_35_match_missing_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;



/*ELÁGAZTATÁS*/
/*A: a hiányzó email cím mellé van másik sor u.a. névvel és irányító számmal*/
DROP TABLE IF EXISTS USER_36_matching_emails;
CREATE TABLE IF NOT EXISTS USER_36_matching_emails LIKE USER_35_match_missing_emails;

INSERT INTO USER_36_matching_emails
SELECT *
FROM USER_35_match_missing_emails
WHERE buyer_email IS NOT NULL;

DROP TABLE IF EXISTS USER_37_matching_emails_plus_ID;
CREATE TABLE IF NOT EXISTS USER_37_matching_emails_plus_ID
SELECT b.personal_name, b.billing_zip_code, b.buyer_email, e.user_id
FROM USER_36_matching_emails AS b LEFT JOIN USER_01_returning_emails AS e
ON b.buyer_email = e.buyer_email;

ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE USER_37_matching_emails_plus_ID ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;



/*B: a hiányzó email cím mellé nincs másik sor u.a. névvel és irányító számmal*/
DROP TABLE IF EXISTS USER_38_non_matching_emails;
CREATE TABLE IF NOT EXISTS USER_38_non_matching_emails LIKE USER_35_match_missing_emails;
INSERT INTO USER_38_non_matching_emails
SELECT *
FROM USER_35_match_missing_emails
WHERE buyer_email IS NULL;

ALTER TABLE USER_38_non_matching_emails ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;


DROP TABLE IF EXISTS USER_39_non_matching_emails;
CREATE TABLE IF NOT EXISTS USER_39_non_matching_emails
SELECT DISTINCT personal_name, billing_zip_code, (((SELECT MAX(user_id) FROM BASE_03_TABLE)+user_id)*5) AS user_id /* a belső SELECT azért kell, mert csak a már létező user_id-knál nagyobb id-t oszthatunk ki*/
FROM USER_38_non_matching_emails;

ALTER TABLE USER_39_non_matching_emails ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE USER_39_non_matching_emails ADD INDEX `personal_name` (`personal_name`) USING BTREE;
ALTER TABLE USER_39_non_matching_emails ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
