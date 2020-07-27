DROP TABLE IF EXISTS Userlist_newsletter;
CREATE TABLE Userlist_newsletter
SELECT a.user_id, max(CASE WHEN b.email IS NOT NULL THEN 'subscribed' ELSE 'never subscribed' END) newsletter
FROM BASE_03_TABLE AS a LEFT JOIN IN_subscribe AS b
ON a.related_email_clean = b.email
GROUP BY user_id
;

ALTER TABLE Userlist_newsletter ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;

DROP TABLE IF EXISTS BASE_04_TABLE;
CREATE TABLE BASE_04_TABLE
SELECT DISTINCT a.*, b.newsletter
FROM BASE_03_TABLE AS a LEFT JOIN Userlist_newsletter AS b
ON a.user_id = b.user_id
;

ALTER TABLE BASE_04_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_04_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_04_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_04_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_04_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;