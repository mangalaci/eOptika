DROP TABLE IF EXISTS USER_01_returning_emails;

CREATE TABLE IF NOT EXISTS USER_01_returning_emails
SELECT DISTINCT 
		u.related_email_clean, 
		u.related_division,
		CASE WHEN u.related_email_clean = b.buyer_email THEN b.user_id
		ELSE NULL
		END AS user_id
FROM BASE_00i_TABLE u
LEFT JOIN BASE_03_TABLE b
ON (u.related_email_clean = b.buyer_email AND u.related_division = b.related_division)
WHERE LENGTH(u.related_email_clean) > 3 /*email vagy valami egyedi, ami egyedi a related_email_clean mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
AND b.buyer_email IS NOT NULL
;

ALTER TABLE USER_01_returning_emails ADD PRIMARY KEY (`related_email_clean`) USING BTREE;


DROP TABLE IF EXISTS USER_02_new_emails;
CREATE TABLE IF NOT EXISTS USER_02_new_emails
SELECT DISTINCT
		u.real_name,
		u.billing_zip_code,
		u.shipping_phone,
		u.related_email_clean, 
		u.related_division,
		CASE WHEN u.related_email_clean = b.buyer_email THEN b.user_id
		ELSE NULL
		END AS user_id
FROM BASE_00i_TABLE u
LEFT JOIN BASE_03_TABLE b
ON (u.related_email_clean = b.buyer_email AND u.related_division = b.related_division)
WHERE LENGTH(u.related_email_clean) > 3 /*email vagy valami egyedi, ami egyedi a related_email_clean mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
AND b.buyer_email IS NULL
;

ALTER TABLE USER_02_new_emails ADD real_name_billing_zip_code_flg INT(10);
ALTER TABLE USER_02_new_emails ADD shipping_phone_billing_zip_code_flg INT(10);
ALTER TABLE USER_02_new_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;