DROP TABLE USER_01_unique_emails;
CREATE TABLE USER_01_unique_emails AS
SELECT DISTINCT related_email_clean, MIN(related_division) AS related_division /*25 esetben két országban is regisztrált. Default = HU */
FROM `BASE_00h_TABLE`
WHERE LENGTH(related_email_clean) > 3 /*email vagy valami egyedi, ami egyedi a related_email_clean mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
GROUP BY related_email_clean
ORDER By 1;

ALTER TABLE USER_01_unique_emails
ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

DROP TABLE USER_02_unique_emails;
CREATE TABLE USER_02_unique_emails AS
SELECT DISTINCT related_email_clean, related_division, (user_id*3)-1 AS user_id
FROM USER_01_unique_emails;

ALTER TABLE USER_02_unique_emails ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `related_division` (`related_division`) USING BTREE;