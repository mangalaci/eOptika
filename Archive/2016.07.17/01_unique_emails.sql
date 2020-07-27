DROP TABLE IF EXISTS USER_01_unique_emails;

CREATE TABLE IF NOT EXISTS USER_01_unique_emails
SELECT related_email_clean, related_division /*25 esetben két országban is regisztrált. Default = HU */
FROM `BASE_00i_TABLE`
LIMIT 0;

INSERT INTO USER_01_unique_emails
SELECT DISTINCT related_email_clean, MIN(related_division) AS related_division /*25 esetben két országban is regisztrált. Default = HU */
FROM `BASE_00i_TABLE`
WHERE LENGTH(related_email_clean) > 3 /*email vagy valami egyedi, ami egyedi a related_email_clean mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
GROUP BY related_email_clean;
ALTER TABLE USER_01_unique_emails ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;
DROP TABLE USER_02_unique_emails;

CREATE TABLE IF NOT EXISTS USER_02_unique_emails
SELECT related_email_clean, related_division, user_id
FROM USER_01_unique_emails
LIMIT 0;
ALTER TABLE USER_02_unique_emails ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `related_division` (`related_division`) USING BTREE;

INSERT INTO USER_02_unique_emails
SELECT DISTINCT related_email_clean, related_division, (user_id*5)-1 AS user_id
FROM USER_01_unique_emails;