DROP TABLE IF EXISTS user_by_email;
CREATE TABLE IF NOT EXISTS user_by_email
SELECT user_id, buyer_email, MAX(created) AS last_email_usage, COUNT(DISTINCT erp_invoice_id) AS num_of_email_usage
FROM `BASE_03_TABLE`
WHERE user_id IN
(
SELECT user_id
FROM `BASE_03_TABLE`
GROUP BY user_id
HAVING COUNT(DISTINCT buyer_email) > 1
)
AND buyer_email LIKE '%@%'
GROUP BY user_id, buyer_email
;

ALTER TABLE user_by_email ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE user_by_email ADD INDEX (`user_id`) USING BTREE;

SET @prev := null;
SET @cnt := 1;

DROP TABLE IF EXISTS user_by_email_rank;
CREATE TABLE IF NOT EXISTS user_by_email_rank
SELECT t.user_id, t.buyer_email, t.last_email_usage, num_of_email_usage, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS email_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, buyer_email, last_email_usage, num_of_email_usage FROM user_by_email ORDER BY user_id) as t
ORDER BY t.user_id, t.last_email_usage DESC
;

ALTER TABLE user_by_email_rank ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE user_by_email_rank ADD INDEX (`user_id`) USING BTREE;

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

ALTER TABLE user_by_email_01 ADD PRIMARY KEY (`user_id`) USING BTREE;

DROP TABLE IF EXISTS user_by_email_02;
CREATE TABLE IF NOT EXISTS user_by_email_02
SELECT 	a.*,
		IF(DATEDIFF(last_email_usage_1,last_email_usage_2)>180, buyer_email_1, IF(num_of_email_usage_2>num_of_email_usage_1, buyer_email_2, buyer_email_1)) AS primary_email
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
IF(b.primary_email <> '', b.primary_email, a.buyer_email) 
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
ON c.user_id = g.user_id
SET
c.primary_email = /* keresztnev.csaladnev@eoptikafiktiv.hu email cím hozzátétele, ha nincs email cím megadva */
  IF(LENGTH(g.primary_email) - LENGTH(REPLACE(g.primary_email, '@', '')) = 0, CONCAT(LOWER(TRIM(c.first_name)), '.', LOWER(TRIM(c.last_name)), '@eoptikafiktiv.hu'), g.primary_email)
, c.secondary_email = g.secondary_email
WHERE c.primary_email is null
;



/*   N E W S L E T T E R   */
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



/*   NÉV ÉS EMAIL NÉLKÜLIEK erp_invoice_id SZERINTI USER_ID KIOSZTÁSA   START */
UPDATE
BASE_03_TABLE
SET user_id = id*5
WHERE shipping_name = 'EOPTIKA KFT.'
AND new_entry = 1
;
/*   NÉV ÉS EMAIL NÉLKÜLIEK erp_invoice_id SZERINTI USER_ID KIOSZTÁSA   END */



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   START */

DROP TABLE IF EXISTS missing_gender;
CREATE TABLE IF NOT EXISTS `missing_gender`
SELECT DISTINCT buyer_email 
FROM BASE_03_TABLE 
WHERE gender = 'missing'
AND new_entry = 1
;


/*first_name*/
DROP TABLE IF EXISTS best_first_name;
CREATE TABLE IF NOT EXISTS best_first_name
SELECT j.buyer_email, j.first_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT buyer_email, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT buyer_email, first_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) t
GROUP BY buyer_email
) i,

(

SELECT a.*
FROM
(
SELECT buyer_email, first_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) a,

(
SELECT buyer_email, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email
) b
WHERE (a.buyer_email = b.buyer_email AND a.gender = b.gender)

) j
WHERE (i.buyer_email = j.buyer_email AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_first_name ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE best_first_name CHANGE `first_name` `first_name` VARCHAR(100);
ALTER TABLE best_first_name ADD INDEX `first_name` (`first_name`) USING BTREE;



UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_first_name AS n ON b.buyer_email = n.buyer_email
SET
b.first_name = n.first_name
WHERE n.buyer_email IS NOT NULL
AND b.new_entry = 1
;



/*full_name*/
DROP TABLE IF EXISTS best_full_name;
CREATE TABLE IF NOT EXISTS best_full_name
SELECT j.buyer_email, j.full_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT buyer_email, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT buyer_email, full_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) t
GROUP BY buyer_email
) i,

(

SELECT a.*
FROM
(
SELECT buyer_email, full_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) a,

(
SELECT buyer_email, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email
) b
WHERE (a.buyer_email = b.buyer_email AND a.gender = b.gender)

) j
WHERE (i.buyer_email = j.buyer_email AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_full_name ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE best_full_name CHANGE `full_name` `full_name` VARCHAR(100);
ALTER TABLE best_full_name ADD INDEX `full_name` (`full_name`) USING BTREE;


UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_full_name AS n ON b.buyer_email = n.buyer_email
SET
b.full_name = n.full_name
WHERE n.buyer_email IS NOT NULL
;

/*gender*/

UPDATE
BASE_03_TABLE AS c
LEFT JOIN IN_gender AS g 
ON g.first_name = c.first_name
SET
c.gender = g.gender
WHERE g.first_name IS NOT NULL
AND c.new_entry = 1
;



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   END */