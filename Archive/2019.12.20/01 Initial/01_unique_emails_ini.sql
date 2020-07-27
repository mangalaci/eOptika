DROP TABLE IF EXISTS USER_01_unique_emails;
CREATE TABLE IF NOT EXISTS USER_01_unique_emails
SELECT DISTINCT buyer_email, MIN(related_division) AS related_division /*25 esetben két országban is regisztrált. Default = HU */
FROM `BASE_00i_TABLE`
WHERE LENGTH(buyer_email) > 3 /*email vagy valami egyedi, ami egyedi a buyer_email mezőben, nem feltétlenül kukacot tartalmazó bejegyzés*/
GROUP BY buyer_email;

ALTER TABLE USER_01_unique_emails ADD user_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;


DROP TABLE IF EXISTS USER_02_unique_emails;
CREATE TABLE IF NOT EXISTS USER_02_unique_emails
SELECT DISTINCT buyer_email, related_division, (user_id*5)-1 AS user_id
FROM USER_01_unique_emails;

ALTER TABLE USER_02_unique_emails ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `buyer_email` (`buyer_email`) USING BTREE;
ALTER TABLE USER_02_unique_emails ADD INDEX `related_division` (`related_division`) USING BTREE;
