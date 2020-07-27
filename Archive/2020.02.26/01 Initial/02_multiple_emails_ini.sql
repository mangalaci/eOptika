/*1. Ugyanahhoz a vevőhöz tartozó emailek egyesítése REAL_NAME és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_03_personal_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_03_personal_name_billing_zip_code_key
SELECT 	personal_name, 
		billing_zip_code, 
		COUNT(DISTINCT buyer_email) AS num_of_emails
FROM `BASE_00i_TABLE`
WHERE LENGTH(personal_name) > 3 /*üres nevek kizárva*/
AND LENGTH(buyer_email) > 3 /*üres emailek kizárva*/
GROUP BY personal_name, billing_zip_code
HAVING COUNT(DISTINCT buyer_email) > 1
;

ALTER TABLE USER_03_personal_name_billing_zip_code_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_04_personal_name_billing_zip_code_key;
SET @cnt = 0;
CREATE TABLE IF NOT EXISTS USER_04_personal_name_billing_zip_code_key
SELECT DISTINCT personal_name, 
				billing_zip_code, 
				((@cnt :=@cnt + 1)*5)-2 AS user_id, 
				1 AS personal_name_billing_zip_code_flg
FROM USER_03_personal_name_billing_zip_code_key
;

ALTER TABLE USER_04_personal_name_billing_zip_code_key ADD PRIMARY KEY (`personal_name`, `billing_zip_code`) USING BTREE;
ALTER TABLE USER_04_personal_name_billing_zip_code_key ADD INDEX `user_id` (`user_id`);
ALTER TABLE BASE_00i_TABLE ADD INDEX (`personal_name`, `billing_zip_code`) USING BTREE;


DROP TABLE IF EXISTS USER_05_personal_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_05_personal_name_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, 
				a.personal_name, 
				a.billing_zip_code, 
				a.buyer_email, 
				a.related_division, 
				b.user_id, 
				b.personal_name_billing_zip_code_flg
FROM BASE_00i_TABLE AS a, USER_04_personal_name_billing_zip_code_key AS b
WHERE a.personal_name = b.personal_name
AND a.billing_zip_code = b.billing_zip_code
AND a.buyer_email LIKE '%@%'
;

ALTER TABLE USER_05_personal_name_billing_zip_code_key ADD PRIMARY KEY (`buyer_email`, `shipping_phone`, `personal_name`, `billing_zip_code`, `related_division`) USING BTREE;
ALTER TABLE USER_05_personal_name_billing_zip_code_key
  ADD INDEX `buyer_email` (`buyer_email`),
  ADD INDEX `personal_name` (`personal_name`),
  ADD INDEX `shipping_phone` (`shipping_phone`);


DROP TABLE IF EXISTS USER_07_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_07_email_deduplicated
SELECT DISTINCT 
				b.buyer_email,
				MAX(CASE 	WHEN e.buyer_email IS NULL 
							THEN b.user_id 
							ELSE e.user_id 
					END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_05_personal_name_billing_zip_code_key AS e
ON b.buyer_email = e.buyer_email
GROUP BY  b.buyer_email;
;

ALTER TABLE USER_07_email_deduplicated ADD PRIMARY KEY (`buyer_email`, `crm_id`) USING BTREE;
ALTER TABLE USER_07_email_deduplicated ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_07_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;



/*2. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_13_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_13_shipping_phone_billing_zip_code_key
SELECT shipping_phone, billing_zip_code, COUNT(DISTINCT buyer_email) AS num_of_emails
FROM `BASE_00i_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(buyer_email) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, billing_zip_code
HAVING (COUNT(DISTINCT buyer_email) > 1 AND COUNT(DISTINCT personal_name) > 1)
;

/*
https://stackoverflow.com/questions/35545281/mysql-longest-common-substring
*/

ALTER TABLE USER_13_shipping_phone_billing_zip_code_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_14_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_14_shipping_phone_billing_zip_code_key
SELECT DISTINCT shipping_phone, billing_zip_code, (user_id*5)-3 AS user_id, 1 AS shipping_phone_billing_zip_code_flg
FROM USER_13_shipping_phone_billing_zip_code_key
;

ALTER TABLE USER_14_shipping_phone_billing_zip_code_key ADD PRIMARY KEY (`shipping_phone`, `billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`shipping_phone`, `billing_zip_code`) USING BTREE;


DROP TABLE IF EXISTS USER_15_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_15_shipping_phone_billing_zip_code_key
SELECT DISTINCT 
				a.shipping_phone, 
				a.billing_zip_code, 
				a.buyer_email, 
				a.related_division, 
				b.user_id, 
				b.shipping_phone_billing_zip_code_flg
FROM BASE_00i_TABLE AS a, 
USER_14_shipping_phone_billing_zip_code_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.billing_zip_code = b.billing_zip_code
;

ALTER TABLE `USER_15_shipping_phone_billing_zip_code_key`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `buyer_email` (`buyer_email`),
	ADD INDEX `billing_zip_code` (`billing_zip_code`),
	ADD INDEX `shipping_phone` (`shipping_phone`);



DROP TABLE IF EXISTS USER_16_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_16_shipping_phone_billing_zip_code_key
SELECT DISTINCT 
				a.shipping_phone, 
				a.billing_zip_code, 
				a.buyer_email, 
				a.related_division, 
				CASE 	WHEN (b.personal_name_billing_zip_code_flg = 1) 
						THEN b.user_id 
						ELSE a.user_id 
				END AS user_id /*ha már volt personal_name + billing_zip_code egyesítés, akkor az maradjon meg*/
FROM USER_15_shipping_phone_billing_zip_code_key a 
LEFT JOIN 
USER_05_personal_name_billing_zip_code_key b
ON a.shipping_phone = b.shipping_phone
;

ALTER TABLE `USER_16_shipping_phone_billing_zip_code_key` ADD INDEX (`buyer_email`)  USING BTREE;

DROP TABLE IF EXISTS USER_17_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_17_email_deduplicated
SELECT DISTINCT b.buyer_email,
MAX(CASE WHEN e.buyer_email IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_07_email_deduplicated AS b LEFT JOIN USER_16_shipping_phone_billing_zip_code_key AS e
ON b.buyer_email = e.buyer_email
GROUP BY  b.buyer_email
;

ALTER TABLE USER_17_email_deduplicated ADD PRIMARY KEY (`buyer_email`, `crm_id`) USING BTREE;
ALTER TABLE USER_17_email_deduplicated ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_17_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;




/*3. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és personal_name alapján*/
DROP TABLE IF EXISTS USER_23_shipping_phone_personal_name_key;
CREATE TABLE IF NOT EXISTS USER_23_shipping_phone_personal_name_key
SELECT shipping_phone, personal_name, COUNT(DISTINCT buyer_email) AS num_of_emails
FROM `BASE_00i_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(buyer_email) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, personal_name
HAVING COUNT(DISTINCT buyer_email) > 1
;


ALTER TABLE USER_23_shipping_phone_personal_name_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_24_shipping_phone_personal_name_key;
CREATE TABLE IF NOT EXISTS USER_24_shipping_phone_personal_name_key
SELECT DISTINCT shipping_phone, personal_name, (user_id*5)-4 AS user_id
FROM USER_23_shipping_phone_personal_name_key
;

ALTER TABLE USER_24_shipping_phone_personal_name_key ADD PRIMARY KEY (`shipping_phone`, `personal_name`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`shipping_phone`, `personal_name`) USING BTREE;


DROP TABLE IF EXISTS USER_25_shipping_phone_personal_name_key;
CREATE TABLE IF NOT EXISTS USER_25_shipping_phone_personal_name_key
SELECT DISTINCT a.shipping_phone, a.personal_name, a.buyer_email, a.related_division, b.user_id
FROM BASE_00i_TABLE AS a, USER_24_shipping_phone_personal_name_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.personal_name = b.personal_name
;

	
ALTER TABLE `USER_25_shipping_phone_personal_name_key`
	ADD INDEX `buyer_email` (`buyer_email`),
	ADD INDEX `personal_name` (`personal_name`),
	ADD INDEX `shipping_phone` (`shipping_phone`);




DROP TABLE IF EXISTS USER_26_shipping_phone_personal_name_key;
CREATE TABLE IF NOT EXISTS USER_26_shipping_phone_personal_name_key
SELECT DISTINCT a.shipping_phone, a.personal_name, a.buyer_email, a.related_division,
CASE 
	WHEN b.personal_name_billing_zip_code_flg = 1 AND c.shipping_phone_billing_zip_code_flg = 1 THEN b.user_id /*speciális eset: ha már volt shipping_phone + billing_zip_code és personal_name + billing_zip_code egyesítés, akkor az előző (personal_name + billing_zip_code) maradjon meg*/
	WHEN c.shipping_phone_billing_zip_code_flg = 1 THEN c.user_id /*ha már volt shipping_phone + billing_zip_code egyesítés, akkor az maradjon meg*/
	WHEN b.personal_name_billing_zip_code_flg = 1 THEN b.user_id 
	ELSE a.user_id /*ha már volt personal_name + billing_zip_code egyesítés, akkor az maradjon meg*/
	END AS user_id 
FROM USER_25_shipping_phone_personal_name_key a 
LEFT JOIN USER_05_personal_name_billing_zip_code_key b
ON a.personal_name = b.personal_name
LEFT JOIN USER_15_shipping_phone_billing_zip_code_key c
ON a.shipping_phone = c.shipping_phone
;


ALTER TABLE `USER_26_shipping_phone_personal_name_key` ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;




DROP TABLE IF EXISTS USER_27_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_27_email_deduplicated
SELECT DISTINCT b.buyer_email,
MAX(CASE WHEN e.buyer_email IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_17_email_deduplicated AS b LEFT JOIN USER_26_shipping_phone_personal_name_key AS e
ON b.buyer_email = e.buyer_email
GROUP BY  b.buyer_email
;


ALTER TABLE USER_27_email_deduplicated ADD PRIMARY KEY (`buyer_email`) USING BTREE;