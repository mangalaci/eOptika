DROP TABLE USER_10_multiple_emails;
CREATE TABLE USER_10_multiple_emails
SELECT shipping_name_clean, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00h_TABLE`
WHERE LENGTH(shipping_name_clean) > 3 /*üres nevek kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_name_clean, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
ORDER BY 1,2;


-------
DROP TABLE USER_10_multiple_emails;
CREATE TABLE USER_10_multiple_emails
SELECT shipping_phone, billing_zip_code, COUNT(DISTINCT related_email_clean) AS num_of_emails
FROM `BASE_00h_TABLE`
WHERE LENGTH(shipping_phone) > 3 /*üres telefonszámok kizárva*/
AND LENGTH(related_email_clean) > 3 /*üres emailek kizárva*/
GROUP BY shipping_phone, billing_zip_code
HAVING COUNT(DISTINCT related_email_clean) > 1
ORDER BY 1,2;

---------



ALTER TABLE USER_10_multiple_emails
add user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE USER_11_multiple_emails;
CREATE TABLE USER_11_multiple_emails
SELECT DISTINCT shipping_name_clean, billing_zip_code, user_id*3 AS user_id
FROM USER_10_multiple_emails;

DROP TABLE USER_12_multiple_emails;
CREATE TABLE USER_12_multiple_emails
SELECT DISTINCT a.shipping_name_clean, a.billing_zip_code, a.related_email_clean, a.related_division, b.user_id
FROM BASE_00h_TABLE AS a, USER_11_multiple_emails AS b
WHERE a.shipping_name_clean = b.shipping_name_clean
AND a.billing_zip_code = b.billing_zip_code;
	
ALTER TABLE `USER_12_multiple_emails`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `billing_zip_code` (`billing_zip_code`),
	ADD INDEX `shipping_name_clean` (`shipping_name_clean`);

DROP TABLE USER_13_multiple_emails;
CREATE TABLE USER_13_multiple_emails
SELECT *
FROM USER_12_multiple_emails
WHERE related_email_clean LIKE '%@%'; /*üres email sorok nem kellenek*/

ALTER TABLE `USER_13_multiple_emails`
	ADD INDEX `user_id` (`user_id`),
	ADD INDEX `related_email_clean` (`related_email_clean`),
	ADD INDEX `billing_zip_code` (`billing_zip_code`),
	ADD INDEX `shipping_name_clean` (`shipping_name_clean`);


DROP TABLE USER_14_email_deduplicated;
CREATE TABLE USER_14_email_deduplicated
SELECT DISTINCT b.related_email_clean,
MAX(CASE WHEN e.related_email_clean IS NULL THEN b.user_id ELSE e.user_id END) AS crm_id
FROM USER_02_unique_emails AS b LEFT JOIN USER_13_multiple_emails AS e
ON b.related_email_clean = e.related_email_clean
GROUP BY  b.related_email_clean;


ALTER TABLE USER_14_email_deduplicated ADD PRIMARY KEY (`related_email_clean`, `crm_id`) USING BTREE;
ALTER TABLE USER_14_email_deduplicated ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_14_email_deduplicated ADD INDEX `crm_id` (`crm_id`) USING BTREE;

