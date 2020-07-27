/*1. Ugyanahhoz a vevőhöz tartozó emailek egyesítése REAL_NAME_CLEAN és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_03_real_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_03_real_name_billing_zip_code_key
SELECT real_name_clean, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(real_name_clean) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY real_name_clean, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
LIMIT 0;

INSERT INTO USER_03_real_name_billing_zip_code_key
SELECT real_name_clean, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(real_name_clean) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY real_name_clean, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1;
ALTER TABLE USER_03_real_name_billing_zip_code_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_04_real_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_04_real_name_billing_zip_code_key
SELECT real_name_clean, billing_zip_code, user_id, 1 AS real_name_billing_zip_code_flg
FROM USER_03_real_name_billing_zip_code_key
LIMIT 0;

INSERT INTO USER_04_real_name_billing_zip_code_key
SELECT DISTINCT real_name_clean, billing_zip_code, (user_id*5)-2 AS user_id, 1 AS real_name_billing_zip_code_flg
FROM USER_03_real_name_billing_zip_code_key;

DROP TABLE IF EXISTS USER_05_real_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_05_real_name_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id, b.real_name_billing_zip_code_flg
FROM BASE_00j_TABLE AS a, USER_04_real_name_billing_zip_code_key AS b
WHERE a.real_name_clean = b.real_name_clean
AND a.billing_zip_code = b.billing_zip_code
LIMIT 0;
	
ALTER TABLE `USER_05_real_name_billing_zip_code_key`
  ADD INDEX `user_id` (`user_id`),
  ADD INDEX `related_email_clean` (`related_email_clean`),
  ADD INDEX `billing_zip_code` (`billing_zip_code`),
  ADD INDEX `real_name_clean` (`real_name_clean`);

INSERT INTO USER_05_real_name_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id, b.real_name_billing_zip_code_flg
FROM BASE_00j_TABLE AS a, USER_04_real_name_billing_zip_code_key AS b
WHERE a.real_name_clean = b.real_name_clean
AND a.billing_zip_code = b.billing_zip_code;

DROP TABLE IF EXISTS USER_06_real_name_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_06_real_name_billing_zip_code_key LIKE USER_05_real_name_billing_zip_code_key;
INSERT INTO USER_06_real_name_billing_zip_code_key
SELECT *
FROM USER_05_real_name_billing_zip_code_key
WHERE related_email_clean LIKE '%@%';

DROP TABLE IF EXISTS USER_07_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_07_email_deduplicated
SELECT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.user_id ELSE e.user_id END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_06_real_name_billing_zip_code_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean
LIMIT 0;
ALTER TABLE USER_07_email_deduplicated ADD PRIMARY KEY (`related_email_clean`, `crm_id`) USING BTREE;
ALTER TABLE USER_07_email_deduplicated ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_07_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;

INSERT INTO USER_07_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.user_id ELSE e.user_id END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_06_real_name_billing_zip_code_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean;




/*2. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és BILLING_ZIP_CODE alapján*/
DROP TABLE IF EXISTS USER_13_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_13_shipping_phone_billing_zip_code_key
SELECT shipping_phone, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
LIMIT 0;

INSERT INTO USER_13_shipping_phone_billing_zip_code_key
SELECT shipping_phone, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1;
ALTER TABLE USER_13_shipping_phone_billing_zip_code_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_14_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_14_shipping_phone_billing_zip_code_key
SELECT shipping_phone, billing_zip_code, user_id, 1 AS shipping_phone_billing_zip_code_flg
FROM USER_13_shipping_phone_billing_zip_code_key
LIMIT 0;

INSERT INTO USER_14_shipping_phone_billing_zip_code_key
SELECT DISTINCT shipping_phone, billing_zip_code, (user_id*5)-3 AS user_id, 1 AS shipping_phone_billing_zip_code_flg
FROM USER_13_shipping_phone_billing_zip_code_key;

DROP TABLE IF EXISTS USER_15_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_15_shipping_phone_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id, b.shipping_phone_billing_zip_code_flg
FROM BASE_00j_TABLE AS a, USER_14_shipping_phone_billing_zip_code_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.billing_zip_code = b.billing_zip_code
LIMIT 0;
	
ALTER TABLE `USER_15_shipping_phone_billing_zip_code_key`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `billing_zip_code` (`billing_zip_code`),
	ADD INDEX `shipping_phone` (`shipping_phone`);

INSERT INTO USER_15_shipping_phone_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id, b.shipping_phone_billing_zip_code_flg
FROM BASE_00j_TABLE AS a, USER_14_shipping_phone_billing_zip_code_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.billing_zip_code = b.billing_zip_code;

DROP TABLE IF EXISTS USER_16_shipping_phone_billing_zip_code_key;
CREATE TABLE IF NOT EXISTS USER_16_shipping_phone_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.billing_zip_code, a.related_email_clean, a.related_division, 
CASE WHEN (b.real_name_billing_zip_code_flg = 1) THEN b.user_id ELSE a.user_id END AS user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
FROM USER_15_shipping_phone_billing_zip_code_key a LEFT JOIN USER_05_real_name_billing_zip_code_key b
ON a.shipping_phone = b.shipping_phone
LIMIT 0;

ALTER TABLE `USER_16_shipping_phone_billing_zip_code_key`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `billing_zip_code` (`billing_zip_code`),
	ADD INDEX `shipping_phone` (`shipping_phone`);

INSERT INTO USER_16_shipping_phone_billing_zip_code_key
SELECT DISTINCT a.shipping_phone, a.billing_zip_code, a.related_email_clean, a.related_division, 
CASE WHEN (b.real_name_billing_zip_code_flg = 1) THEN b.user_id ELSE a.user_id END AS user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
FROM USER_15_shipping_phone_billing_zip_code_key a LEFT JOIN USER_05_real_name_billing_zip_code_key b
ON a.shipping_phone = b.shipping_phone;

DROP TABLE IF EXISTS USER_17_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_17_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_07_email_deduplicated AS b LEFT JOIN USER_16_shipping_phone_billing_zip_code_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean
LIMIT 0;
ALTER TABLE USER_17_email_deduplicated ADD PRIMARY KEY (`related_email_clean`, `crm_id`) USING BTREE;
ALTER TABLE USER_17_email_deduplicated ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_17_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;

INSERT INTO USER_17_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_07_email_deduplicated AS b LEFT JOIN USER_16_shipping_phone_billing_zip_code_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean;


/*3. Ugyanahhoz a vevőhöz tartozó emailek egyesítése SHIPPING_PHONE és real_name_clean alapján*/
DROP TABLE IF EXISTS USER_23_shipping_phone_real_name_clean_key;
CREATE TABLE IF NOT EXISTS USER_23_shipping_phone_real_name_clean_key
SELECT shipping_phone, real_name_clean, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, real_name_clean
HAVING COUNT(DISTINCT related_email_clean) > 1
LIMIT 0;

INSERT INTO USER_23_shipping_phone_real_name_clean_key
SELECT shipping_phone, real_name_clean, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00j_TABLE`
WHERE LENGTH(shipping_phone) > 7 /*nem teljes telefonszámok kizárva*/
AND shipping_phone NOT LIKE '%--%' /*hamis telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, real_name_clean
HAVING COUNT(DISTINCT related_email_clean) > 1;
ALTER TABLE USER_23_shipping_phone_real_name_clean_key ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE IF EXISTS USER_24_shipping_phone_real_name_clean_key;
CREATE TABLE IF NOT EXISTS USER_24_shipping_phone_real_name_clean_key
SELECT shipping_phone, real_name_clean, user_id
FROM USER_23_shipping_phone_real_name_clean_key
LIMIT 0;

INSERT INTO USER_24_shipping_phone_real_name_clean_key
SELECT DISTINCT shipping_phone, real_name_clean, (user_id*5)-4 AS user_id
FROM USER_23_shipping_phone_real_name_clean_key;

DROP TABLE IF EXISTS USER_25_shipping_phone_real_name_clean_key;
CREATE TABLE IF NOT EXISTS USER_25_shipping_phone_real_name_clean_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.related_email_clean, a.related_division, b.user_id
FROM BASE_00j_TABLE AS a, USER_24_shipping_phone_real_name_clean_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.real_name_clean = b.real_name_clean
LIMIT 0;
	
ALTER TABLE `USER_25_shipping_phone_real_name_clean_key`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `real_name_clean` (`real_name_clean`),
	ADD INDEX `shipping_phone` (`shipping_phone`);

INSERT INTO USER_25_shipping_phone_real_name_clean_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.related_email_clean, a.related_division, b.user_id
FROM BASE_00j_TABLE AS a, USER_24_shipping_phone_real_name_clean_key AS b
WHERE a.shipping_phone = b.shipping_phone
AND a.real_name_clean = b.real_name_clean;

DROP TABLE IF EXISTS USER_26_shipping_phone_real_name_clean_key;
CREATE TABLE IF NOT EXISTS USER_26_shipping_phone_real_name_clean_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.related_email_clean, a.related_division,
CASE 
	WHEN c.shipping_phone_billing_zip_code_flg = 1 THEN c.user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
	WHEN b.real_name_billing_zip_code_flg = 1 THEN b.user_id 
	ELSE a.user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
	END AS user_id 
FROM USER_25_shipping_phone_real_name_clean_key a LEFT JOIN USER_05_real_name_billing_zip_code_key b
ON a.real_name_clean = b.real_name_clean
LEFT JOIN USER_15_shipping_phone_billing_zip_code_key c
ON a.shipping_phone = c.shipping_phone
LIMIT 0;

ALTER TABLE `USER_26_shipping_phone_real_name_clean_key`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_division` (`related_division`),	
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `real_name_clean` (`real_name_clean`),
	ADD INDEX `shipping_phone` (`shipping_phone`);

INSERT INTO USER_26_shipping_phone_real_name_clean_key
SELECT DISTINCT a.shipping_phone, a.real_name_clean, a.related_email_clean, a.related_division,
CASE 
	WHEN c.shipping_phone_billing_zip_code_flg = 1 THEN c.user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
	WHEN b.real_name_billing_zip_code_flg = 1 THEN b.user_id 
	ELSE a.user_id /*ha már volt real_name + billing_zip_code egyesítés, akkor az maradjon meg*/
	END AS user_id 
FROM USER_25_shipping_phone_real_name_clean_key a LEFT JOIN USER_05_real_name_billing_zip_code_key b
ON a.real_name_clean = b.real_name_clean
LEFT JOIN USER_15_shipping_phone_billing_zip_code_key c
ON a.shipping_phone = c.shipping_phone;

DROP TABLE IF EXISTS USER_27_email_deduplicated;
CREATE TABLE IF NOT EXISTS USER_27_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_17_email_deduplicated AS b LEFT JOIN USER_26_shipping_phone_real_name_clean_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean
LIMIT 0;
ALTER TABLE USER_27_email_deduplicated ADD PRIMARY KEY (`related_email_clean`, `crm_id`) USING BTREE;
ALTER TABLE USER_27_email_deduplicated ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_27_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;

INSERT INTO USER_27_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.crm_id ELSE e.user_id END) AS crm_id
FROM USER_17_email_deduplicated AS b LEFT JOIN USER_26_shipping_phone_real_name_clean_key AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean;

