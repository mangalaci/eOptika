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

ALTER TABLE user_by_email_rank ADD PRIMARY KEY (`related_email_clean`) USING BTREE;
ALTER TABLE user_by_email_rank ADD INDEX (`user_id`) USING BTREE;

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

ALTER TABLE user_by_email_01 ADD PRIMARY KEY (`user_id`) USING BTREE;

DROP TABLE IF EXISTS user_by_email_02;
CREATE TABLE IF NOT EXISTS user_by_email_02
SELECT 	a.*,
		IF(DATEDIFF(last_email_usage_2,last_email_usage_1)>180 ,buyer_email_2,IF(num_of_email_usage_2>num_of_email_usage_1,buyer_email_2,buyer_email_1)) AS primary_email
FROM user_by_email_01 a
;

ALTER TABLE user_by_email_02 ADD PRIMARY KEY (`user_id`) USING BTREE;


DROP TABLE IF EXISTS user_by_email_03;
CREATE TABLE IF NOT EXISTS user_by_email_03
SELECT 	a.*,
		IF(buyer_email_2 = primary_email, buyer_email_1, buyer_email_2) AS secondary_email
FROM user_by_email_02 a
;


ALTER TABLE user_by_email_03 ADD PRIMARY KEY (`user_id`) USING BTREE;


DROP TABLE IF EXISTS user_by_email_04;
CREATE TABLE IF NOT EXISTS user_by_email_04
SELECT DISTINCT a.user_id,
IF(b.primary_email <> '', b.primary_email, a.related_email_clean) 
	AS primary_email,
	b.secondary_email
FROM `BASE_03_TABLE` AS a 
LEFT JOIN user_by_email_03 AS b
ON a.user_id = b.user_id
;



ALTER TABLE user_by_email_04 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE user_by_email_04 ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE user_by_email_04 ADD INDEX (`secondary_email`) USING BTREE;
ALTER TABLE user_by_email_04 ADD INDEX (`user_id`) USING BTREE;


UPDATE
BASE_03_TABLE AS c
LEFT JOIN user_by_email_04 AS g 
ON g.user_id = c.user_id
SET
c.primary_email = /* keresztnev.csaladnev@eoptikafiktiv.hu email cím hozzátétele, ha nincs email cím megadva */
  IF(g.primary_email = '', CONCAT(LOWER(TRIM(c.first_name)), '.', LOWER(TRIM(c.last_name)), '@eoptikafiktiv.hu'), g.primary_email)
, c.secondary_email = g.secondary_email
;



/*   N E W S L E T T E R   */
ALTER TABLE BASE_03_TABLE ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE BASE_03_TABLE ADD INDEX (`secondary_email`) USING BTREE;


UPDATE
BASE_03_TABLE AS c
LEFT JOIN IN_subscribe AS g 
ON g.email = c.primary_email
SET
c.primary_newsletter_flg =
  IF(g.email IS NOT NULL, 'subscribed', 'never subscribed')
;


UPDATE
BASE_03_TABLE AS c
LEFT JOIN IN_subscribe AS g 
ON g.email = c.secondary_email
SET
c.secondary_newsletter_flg =
  IF(g.email IS NOT NULL, 'subscribed', 'never subscribed')
;



/*   NÉV ÉS EMAIL NÉLKÜLIEK ERP_ID SZERINTI USER_ID KIOSZTÁSA   START */
UPDATE
BASE_03_TABLE
SET user_id = id*5
WHERE shipping_name = 'EOPTIKA KFT.'
;
/*   NÉV ÉS EMAIL NÉLKÜLIEK ERP_ID SZERINTI USER_ID KIOSZTÁSA   END */



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   START */

DROP TABLE IF EXISTS missing_gender;
CREATE TABLE IF NOT EXISTS `missing_gender`
SELECT DISTINCT related_email_clean 
FROM BASE_03_TABLE 
WHERE gender = 'missing'
;



ALTER TABLE missing_gender ADD PRIMARY KEY (`related_email_clean`) USING BTREE;


/*first_name*/
DROP TABLE IF EXISTS best_first_name;
CREATE TABLE IF NOT EXISTS best_first_name
SELECT j.related_email_clean, j.first_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT related_email_clean, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT related_email_clean, first_name, gender, COUNT(DISTINCT erp_id) AS name_occurance
FROM BASE_03_TABLE
WHERE related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean, gender
) t
GROUP BY related_email_clean
) i,

(

SELECT a.*
FROM
(
SELECT related_email_clean, first_name, gender, COUNT(DISTINCT erp_id) AS name_occurance
FROM BASE_03_TABLE
WHERE related_email_clean <> ''
AND related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean, gender
) a,

(
SELECT related_email_clean, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE related_email_clean <> ''
AND related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean
) b
WHERE (a.related_email_clean = b.related_email_clean AND a.gender = b.gender)

) j
WHERE (i.related_email_clean = j.related_email_clean AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_first_name ADD PRIMARY KEY (`related_email_clean`) USING BTREE;
ALTER TABLE best_first_name CHANGE `first_name` `first_name` VARCHAR(100);
ALTER TABLE best_first_name ADD INDEX `first_name` (`first_name`) USING BTREE;



UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_first_name AS n ON b.related_email_clean = n.related_email_clean
SET
b.first_name = n.first_name
WHERE n.related_email_clean IS NOT NULL
;



/*full_name*/
DROP TABLE IF EXISTS best_full_name;
CREATE TABLE IF NOT EXISTS best_full_name
SELECT j.related_email_clean, j.full_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT related_email_clean, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT related_email_clean, full_name, gender, COUNT(DISTINCT erp_id) AS name_occurance
FROM BASE_03_TABLE
WHERE related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean, gender
) t
GROUP BY related_email_clean
) i,

(

SELECT a.*
FROM
(
SELECT related_email_clean, full_name, gender, COUNT(DISTINCT erp_id) AS name_occurance
FROM BASE_03_TABLE
WHERE related_email_clean <> ''
AND related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean, gender
) a,

(
SELECT related_email_clean, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE related_email_clean <> ''
AND related_email_clean IN
(
SELECT DISTINCT related_email_clean 
FROM missing_gender
)
GROUP BY related_email_clean
) b
WHERE (a.related_email_clean = b.related_email_clean AND a.gender = b.gender)

) j
WHERE (i.related_email_clean = j.related_email_clean AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_full_name ADD PRIMARY KEY (`related_email_clean`) USING BTREE;
ALTER TABLE best_full_name CHANGE `full_name` `full_name` VARCHAR(100);
ALTER TABLE best_full_name ADD INDEX `full_name` (`full_name`) USING BTREE;


UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_full_name AS n ON b.related_email_clean = n.related_email_clean
SET
b.full_name = n.full_name
WHERE n.related_email_clean IS NOT NULL
;

/*gender*/

UPDATE
BASE_03_TABLE AS c
LEFT JOIN IN_gender AS g 
ON g.first_name = c.first_name
SET
c.gender = g.gender
WHERE g.first_name IS NOT NULL
;



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   END */