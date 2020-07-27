DROP TABLE IF EXISTS user_by_email;
CREATE TABLE IF NOT EXISTS user_by_email
SELECT user_id, buyer_email, MAX(created) AS last_email_usage, COUNT(DISTINCT erp_invoice_id) AS num_of_email_usage
FROM `BASE_09_TABLE`
WHERE user_id IN
(
SELECT user_id
FROM `BASE_09_TABLE`
GROUP BY user_id
HAVING COUNT(DISTINCT buyer_email) > 1
)
AND buyer_email LIKE '%@%'
GROUP BY user_id, buyer_email
ORDER BY user_id
;

ALTER TABLE user_by_email ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE user_by_email ADD INDEX (`user_id`) USING BTREE;




SET @prev := null;
SET @cnt := 1;

DROP TABLE IF EXISTS user_by_email_rank;
CREATE TABLE IF NOT EXISTS user_by_email_rank
SELECT t.user_id, t.buyer_email, t.last_email_usage, num_of_email_usage, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS email_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, buyer_email, last_email_usage, num_of_email_usage FROM user_by_email ORDER BY user_id) as t
ORDER BY t.user_id, t.last_email_usage




DROP TABLE IF EXISTS user_by_email_tab;
CREATE TABLE IF NOT EXISTS user_by_email_tab
SELECT 	user_id, 
		CASE WHEN email_rank = 1 THEN buyer_email END AS buyer_email_1, 
		CASE WHEN email_rank = 2 THEN buyer_email END AS buyer_email_2,
		CASE WHEN email_rank = 3 THEN buyer_email END AS buyer_email_3,
		CASE WHEN email_rank = 4 THEN buyer_email END AS buyer_email_4,
		CASE WHEN email_rank = 5 THEN buyer_email END AS buyer_email_5,
		CASE WHEN email_rank = 6 THEN buyer_email END AS buyer_email_6,
		CASE WHEN email_rank = 7 THEN buyer_email END AS buyer_email_7,
		CASE WHEN email_rank = 8 THEN buyer_email END AS buyer_email_8,
		CASE WHEN email_rank = 8 THEN buyer_email END AS buyer_email_9,

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

