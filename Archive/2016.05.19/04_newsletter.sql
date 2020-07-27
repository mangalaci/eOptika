DROP TABLE IF EXISTS Userlist_newsletter;

CREATE TABLE IF NOT EXISTS Userlist_newsletter
SELECT DISTINCT a.user_id, max(CASE WHEN b.email IS NOT NULL THEN 'subscribed' ELSE 'never subscribed' END) newsletter
FROM BASE_03_TABLE AS a LEFT JOIN IN_subscribe AS b
ON a.related_email_clean = b.email
GROUP BY user_id
LIMIT 0;
ALTER TABLE Userlist_newsletter ADD PRIMARY KEY (`user_id`) USING BTREE;

INSERT INTO Userlist_newsletter
SELECT DISTINCT a.user_id, max(CASE WHEN b.email IS NOT NULL THEN 'subscribed' ELSE 'never subscribed' END) newsletter
FROM BASE_03_TABLE AS a LEFT JOIN IN_subscribe AS b
ON a.related_email_clean = b.email
GROUP BY user_id;
DROP TABLE `BASE_04_TABLE`;
CREATE TABLE IF NOT EXISTS `BASE_04_TABLE` LIKE `BASE_03_TABLE`;
ALTER TABLE `BASE_04_TABLE` ADD `newsletter` VARCHAR(16) NOT NULL AFTER `user_id`;

INSERT INTO `BASE_04_TABLE`
  SELECT a.*, b.newsletter
  FROM `BASE_03_TABLE` AS a 
  LEFT JOIN Userlist_newsletter AS b
  ON a.user_id = b.user_id;