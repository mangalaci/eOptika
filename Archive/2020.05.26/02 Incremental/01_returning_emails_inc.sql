DROP TABLE IF EXISTS USER_01_returning_emails;

CREATE TABLE IF NOT EXISTS USER_01_returning_emails
SELECT DISTINCT
		u.buyer_email,
		u.related_division,
		CASE WHEN u.buyer_email = b.buyer_email THEN b.user_id
		ELSE NULL
		END AS user_id
FROM BASE_00i_TABLE_inc u
LEFT JOIN BASE_03_TABLE b
ON (u.buyer_email = b.buyer_email AND u.related_division = b.related_division)
WHERE LENGTH(u.buyer_email) > 3 /*email vagy valami egyedi, ami egyedi a buyer_email mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
AND b.buyer_email IS NOT NULL
;

ALTER TABLE USER_01_returning_emails ADD INDEX (`buyer_email`) USING BTREE;


DROP TABLE IF EXISTS USER_02_new_emails;
CREATE TABLE IF NOT EXISTS USER_02_new_emails
SELECT DISTINCT
		u.personal_name,
		u.billing_zip_code,
		u.shipping_phone,
		u.buyer_email, 
		u.related_division,
		CASE WHEN u.buyer_email = b.buyer_email THEN b.user_id
		ELSE NULL
		END AS user_id
FROM BASE_00i_TABLE_inc u
LEFT JOIN BASE_03_TABLE b
ON (u.buyer_email = b.buyer_email AND u.related_division = b.related_division)
WHERE LENGTH(u.buyer_email) > 3 /*email vagy valami egyedi, ami egyedi a buyer_email mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
AND b.buyer_email IS NULL
;

ALTER TABLE USER_02_new_emails ADD personal_name_billing_zip_code_flg INT(10);
ALTER TABLE USER_02_new_emails ADD shipping_phone_billing_zip_code_flg INT(10);
ALTER TABLE USER_02_new_emails ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;