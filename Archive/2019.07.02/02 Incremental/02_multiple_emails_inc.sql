/*1. Ugyanahhoz a vevőhöz tartozó emailek egyesítése REAL_NAME és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_03_new_plus_old;
CREATE TABLE IF NOT EXISTS USER_03_new_plus_old
SELECT DISTINCT
real_name,
shipping_phone,
billing_zip_code,
related_email_clean,
user_id,
'new' AS origin
FROM USER_02_new_emails
UNION ALL
SELECT DISTINCT
personal_name as real_name,
shipping_phone,
billing_zip_code,
buyer_email AS related_email_clean,
user_id,
'old' AS origin
FROM BASE_03_TABLE
;

ALTER TABLE USER_03_new_plus_old ADD INDEX `real_name` (`real_name`);
ALTER TABLE USER_03_new_plus_old ADD INDEX `billing_zip_code` (`billing_zip_code`);
ALTER TABLE USER_03_new_plus_old ADD INDEX `related_email_clean` (`related_email_clean`);
ALTER TABLE USER_03_new_plus_old ADD INDEX `user_id` (`user_id`);



DROP TABLE IF EXISTS USER_04_real_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_04_real_name_billing_zip_code_key
SELECT 	real_name,
		billing_zip_code,
		MAX(user_id) AS user_id, /* a MAX függvény a NULL user_id mellőzése miatt kell */
		COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM USER_03_new_plus_old
WHERE LENGTH(real_name) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY real_name, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
;


UPDATE USER_02_new_emails AS m
        LEFT JOIN
    USER_04_real_name_billing_zip_code_key AS s ON (m.real_name = s.real_name AND m.billing_zip_code = s.billing_zip_code)
SET
    m.user_id = s.user_id,
	m.real_name_billing_zip_code_flg = s.user_id/s.user_id
;



/*2. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_06_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_06_shipping_phone_billing_zip_code_key
SELECT 	shipping_phone, 
		billing_zip_code,
		MAX(user_id) AS user_id, /* a MAX függvény a NULL user_id mellőzése miatt kell */
		COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM USER_03_new_plus_old
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, billing_zip_code
HAVING (COUNT(DISTINCT related_email_clean) > 1 AND COUNT(DISTINCT real_name) > 1)
;

UPDATE USER_02_new_emails AS m
        LEFT JOIN
    USER_06_shipping_phone_billing_zip_code_key AS s ON (m.shipping_phone = s.shipping_phone AND m.billing_zip_code = s.billing_zip_code)
SET
    m.user_id = s.user_id,
	m.shipping_phone_billing_zip_code_flg = s.user_id/s.user_id
WHERE m.real_name_billing_zip_code_flg IS NULL
;



/*3. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és REAL_NAME alapján*/
DROP TABLE IF EXISTS USER_07_shipping_phone_real_name_clean_key;
CREATE TABLE IF NOT EXISTS USER_07_shipping_phone_real_name_clean_key
SELECT 	shipping_phone, 
		real_name,
		MAX(user_id) AS user_id, /* a MAX függvény a NULL user_id mellőzése miatt kell */
		COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM USER_03_new_plus_old
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, real_name
HAVING COUNT(DISTINCT related_email_clean) > 1
;


UPDATE USER_02_new_emails AS m
        LEFT JOIN
    USER_07_shipping_phone_real_name_clean_key AS s ON (m.shipping_phone = s.shipping_phone AND m.real_name = s.real_name)
SET
    m.user_id = s.user_id
WHERE m.real_name_billing_zip_code_flg IS NULL
AND m.shipping_phone_billing_zip_code_flg IS NULL
;

ALTER TABLE USER_02_new_emails ADD id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

UPDATE USER_02_new_emails AS m
SET    m.user_id = (SELECT MAX(user_id) FROM BASE_03_TABLE) + id /* a belső SELECT azért kell, mert csak a már létező user_id-knál nagyobb id-t oszthatunk ki*/
WHERE m.user_id IS NULL
;