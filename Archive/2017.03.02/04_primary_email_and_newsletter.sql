DROP TABLE IF EXISTS user_by_email;
CREATE TABLE IF NOT EXISTS user_by_email
SELECT user_id, related_email_clean, MAX(created) AS last_email_usage, COUNT(DISTINCT erp_id) AS num_of_email_usage
FROM `BASE_03_TABLE`
WHERE user_id IN
(
SELECT user_id
FROM `BASE_03_TABLE`
GROUP BY user_id
HAVING COUNT(DISTINCT related_email_clean) > 1
)
AND related_email_clean LIKE '%@%'
GROUP BY user_id, related_email_clean
ORDER BY user_id
;

ALTER TABLE user_by_email ADD PRIMARY KEY (`related_email_clean`) USING BTREE;
ALTER TABLE user_by_email ADD INDEX (`user_id`) USING BTREE;

SET @prev := null;
SET @cnt := 1;

DROP TABLE IF EXISTS user_by_email_rank;
CREATE TABLE IF NOT EXISTS user_by_email_rank
SELECT t.user_id, t.related_email_clean, t.last_email_usage, num_of_email_usage, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS email_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, related_email_clean, last_email_usage, num_of_email_usage FROM user_by_email ORDER BY user_id) as t
ORDER BY t.user_id, t.last_email_usage
;

DROP TABLE IF EXISTS user_by_email_tab;
CREATE TABLE IF NOT EXISTS user_by_email_tab
SELECT 	user_id, 
		CASE WHEN email_rank = 1 THEN related_email_clean END AS buyer_email_1, 
		CASE WHEN email_rank = 2 THEN related_email_clean END AS buyer_email_2,
		CASE WHEN email_rank = 3 THEN related_email_clean END AS buyer_email_3,
		CASE WHEN email_rank = 4 THEN related_email_clean END AS buyer_email_4,
		CASE WHEN email_rank = 5 THEN related_email_clean END AS buyer_email_5,
		CASE WHEN email_rank = 6 THEN related_email_clean END AS buyer_email_6,
		CASE WHEN email_rank = 7 THEN related_email_clean END AS buyer_email_7,
		CASE WHEN email_rank = 8 THEN related_email_clean END AS buyer_email_8,
		CASE WHEN email_rank = 8 THEN related_email_clean END AS buyer_email_9,

		CASE WHEN email_rank = 1 THEN last_email_usage END AS last_email_usage_1, 
		CASE WHEN email_rank = 2 THEN last_email_usage END AS last_email_usage_2,
		CASE WHEN email_rank = 3 THEN last_email_usage END AS last_email_usage_3,
		CASE WHEN email_rank = 4 THEN last_email_usage END AS last_email_usage_4,
		CASE WHEN email_rank = 5 THEN last_email_usage END AS last_email_usage_5,
		CASE WHEN email_rank = 6 THEN last_email_usage END AS last_email_usage_6,
		CASE WHEN email_rank = 7 THEN last_email_usage END AS last_email_usage_7,
		CASE WHEN email_rank = 8 THEN last_email_usage END AS last_email_usage_8,
		CASE WHEN email_rank = 8 THEN last_email_usage END AS last_email_usage_9,

		CASE WHEN email_rank = 1 THEN num_of_email_usage END AS num_of_email_usage_1, 
		CASE WHEN email_rank = 2 THEN num_of_email_usage END AS num_of_email_usage_2,
		CASE WHEN email_rank = 3 THEN num_of_email_usage END AS num_of_email_usage_3,
		CASE WHEN email_rank = 4 THEN num_of_email_usage END AS num_of_email_usage_4,
		CASE WHEN email_rank = 5 THEN num_of_email_usage END AS num_of_email_usage_5,
		CASE WHEN email_rank = 6 THEN num_of_email_usage END AS num_of_email_usage_6,
		CASE WHEN email_rank = 7 THEN num_of_email_usage END AS num_of_email_usage_7,
		CASE WHEN email_rank = 8 THEN num_of_email_usage END AS num_of_email_usage_8,
		CASE WHEN email_rank = 8 THEN num_of_email_usage END AS num_of_email_usage_9
		
FROM user_by_email_rank
;



ALTER TABLE user_by_email_tab ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


DROP TABLE IF EXISTS user_by_email_01;
CREATE TABLE IF NOT EXISTS user_by_email_01
SELECT 	user_id, 
		CASE WHEN id = 1 THEN MAX(buyer_email_2) ELSE MAX(buyer_email_1) END AS buyer_email_1,
		CASE WHEN id = 1 THEN MAX(buyer_email_3) ELSE MAX(buyer_email_2) END AS buyer_email_2,
		CASE WHEN id = 1 THEN MAX(buyer_email_4) ELSE MAX(buyer_email_3) END AS buyer_email_3,
		MAX(buyer_email_4) AS buyer_email_4,
		MAX(buyer_email_5) AS buyer_email_5,
		MAX(buyer_email_6) AS buyer_email_6,
		MAX(buyer_email_7) AS buyer_email_7,
		MAX(buyer_email_8) AS buyer_email_8,
		MAX(buyer_email_9) AS buyer_email_9,

		CASE WHEN id = 1 THEN MAX(last_email_usage_2) ELSE MAX(last_email_usage_1) END AS last_email_usage_1,
		CASE WHEN id = 1 THEN MAX(last_email_usage_3) ELSE MAX(last_email_usage_2) END AS last_email_usage_2,
		CASE WHEN id = 1 THEN MAX(last_email_usage_4) ELSE MAX(last_email_usage_3) END AS last_email_usage_3,
		MAX(last_email_usage_4) AS last_email_usage_4,
		MAX(last_email_usage_5) AS last_email_usage_5,
		MAX(last_email_usage_6) AS last_email_usage_6,
		MAX(last_email_usage_7) AS last_email_usage_7,
		MAX(last_email_usage_8) AS last_email_usage_8,
		MAX(last_email_usage_9) AS last_email_usage_9,

		CASE WHEN id = 1 THEN MAX(num_of_email_usage_2) ELSE MAX(num_of_email_usage_1) END AS num_of_email_usage_1,
		CASE WHEN id = 1 THEN MAX(num_of_email_usage_3) ELSE MAX(num_of_email_usage_2) END AS num_of_email_usage_2,
		CASE WHEN id = 1 THEN MAX(num_of_email_usage_4) ELSE MAX(num_of_email_usage_3) END AS num_of_email_usage_3,
		MAX(num_of_email_usage_4) AS num_of_email_usage_4,
		MAX(num_of_email_usage_5) AS num_of_email_usage_5,
		MAX(num_of_email_usage_6) AS num_of_email_usage_6,
		MAX(num_of_email_usage_7) AS num_of_email_usage_7,
		MAX(num_of_email_usage_8) AS num_of_email_usage_8,
		MAX(num_of_email_usage_9) AS num_of_email_usage_9		
		
FROM user_by_email_tab
GROUP BY user_id
;


DROP TABLE IF EXISTS user_by_email_02;
CREATE TABLE IF NOT EXISTS user_by_email_02
SELECT 	a.*,
		IF(DATEDIFF(last_email_usage_2,last_email_usage_1)>180 ,buyer_email_2,IF(num_of_email_usage_2>num_of_email_usage_1,buyer_email_2,buyer_email_1)) AS primary_email
FROM user_by_email_01 a
;


DROP TABLE IF EXISTS user_by_email_03;
CREATE TABLE IF NOT EXISTS user_by_email_03
SELECT 	a.*,
		IF(buyer_email_2 = primary_email, buyer_email_1, buyer_email_2) AS secondary_email
FROM user_by_email_02 a
;

ALTER TABLE user_by_email_03 ADD PRIMARY KEY (`user_id`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX (`user_id`) USING BTREE;


DROP TABLE IF EXISTS `BASE_04a_TABLE`;
CREATE TABLE IF NOT EXISTS `BASE_04a_TABLE` LIKE `BASE_03_TABLE`;

ALTER TABLE `BASE_04a_TABLE` ADD `primary_email` VARCHAR(255) NOT NULL;
ALTER TABLE `BASE_04a_TABLE` ADD `secondary_email` VARCHAR(255) NOT NULL;

INSERT INTO `BASE_04a_TABLE`
  SELECT a.*, b.primary_email, b.secondary_email
  FROM `BASE_03_TABLE` AS a 
  LEFT JOIN user_by_email_03 AS b
  ON a.user_id = b.user_id;
  
ALTER TABLE BASE_04a_TABLE ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE BASE_04a_TABLE ADD INDEX (`secondary_email`) USING BTREE;


DROP TABLE IF EXISTS `BASE_04b_TABLE`;
CREATE TABLE IF NOT EXISTS `BASE_04b_TABLE` LIKE `BASE_04a_TABLE`;

ALTER TABLE `BASE_04b_TABLE` ADD `primary_newsletter_flg` VARCHAR(255) NOT NULL;

INSERT INTO `BASE_04b_TABLE`
SELECT DISTINCT a.*, CASE WHEN b.email IS NOT NULL THEN 'subscribed' ELSE 'never subscribed' END AS primary_newsletter_flg
FROM BASE_04a_TABLE AS a LEFT JOIN IN_subscribe AS b
ON a.primary_email = b.email
;

DROP TABLE IF EXISTS `BASE_04c_TABLE`;
CREATE TABLE IF NOT EXISTS `BASE_04c_TABLE` LIKE `BASE_04b_TABLE`;

ALTER TABLE `BASE_04c_TABLE` ADD `secondary_newsletter_flg` VARCHAR(255) NOT NULL;

INSERT INTO `BASE_04c_TABLE`
SELECT DISTINCT a.*, CASE WHEN b.email IS NOT NULL THEN 'subscribed' ELSE 'never subscribed' END secondary_newsletter_flg
FROM BASE_04b_TABLE AS a LEFT JOIN IN_subscribe AS b
ON a.secondary_email = b.email
;