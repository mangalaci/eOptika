


/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   START */

DROP TABLE IF EXISTS missing_gender;
CREATE TABLE IF NOT EXISTS `missing_gender`
SELECT DISTINCT buyer_email 
FROM BASE_03_TABLE 
WHERE gender = 'missing'
;



ALTER TABLE missing_gender ADD PRIMARY KEY (`buyer_email`) USING BTREE;


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
;



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   END */