/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   B E G I N */

UPDATE INVOICES_00 AS m
LEFT JOIN IN_country_coding AS e1
ON m.billing_country = e1.original_country
LEFT JOIN IN_country_coding AS e2
ON m.shipping_country = e2.original_country
SET 
    m.billing_country_standardized = CASE WHEN LENGTH(m.billing_country) > 1 THEN e1.standardized_country END,
    m.shipping_country_standardized = CASE WHEN LENGTH(m.shipping_country) > 1 THEN e2.standardized_country END
;

/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   E N D */


/* B I L L I N G & S H I P P I N G   C I T Y   F I X I N G:   B E G I N */

UPDATE INVOICES_00
SET shipping_zip_code = REPLACE(shipping_zip_code, 'Somerset', '')
WHERE shipping_zip_code LIKE '%Somerset%'
AND shipping_country_standardized = 'United Kingdom'
;

UPDATE INVOICES_00
SET billing_zip_code = REPLACE(billing_zip_code, 'Somerset', '')
WHERE billing_zip_code LIKE '%Somerset%'
AND billing_country_standardized = 'United Kingdom'
;


UPDATE INVOICES_00
SET shipping_zip_code = REPLACE(LTRIM(REPLACE(shipping_zip_code,'0',' ')),' ','0')
WHERE shipping_country_standardized = 'Romania' OR shipping_city = 'Bucuresti'
;

UPDATE INVOICES_00
SET billing_zip_code = REPLACE(LTRIM(REPLACE(billing_zip_code,'0',' ')),' ','0')
WHERE billing_country_standardized = 'Romania' OR billing_city = 'Bucuresti'
;


UPDATE INVOICES_00
SET shipping_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_city, 'î', 'i'), 'â', 'a'), 'ă', 'a'), 'ţ', 't'), 'ș', 's')
WHERE shipping_country_standardized = 'Romania'
;

UPDATE INVOICES_00
SET billing_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city, 'î', 'i'), 'â', 'a'), 'ă', 'a'), 'ţ', 't'), 'ș', 's')
WHERE billing_country_standardized = 'Romania'
;


/* IN_city_coding bekódoló alapján */
UPDATE INVOICES_00 AS m
LEFT JOIN IN_city_coding AS e
ON (m.shipping_city = e.original_city AND m.shipping_country_standardized = e.original_country)
SET
    m.shipping_city = e.standardized_city,
    m.shipping_country_standardized = e.standardized_country
WHERE e.original_city IS NOT NULL
;

UPDATE INVOICES_00 AS m
LEFT JOIN IN_city_coding AS e
ON (m.billing_city = e.original_city AND m.billing_country_standardized = e.original_country)
SET
    m.billing_city = e.standardized_city,
    m.billing_country_standardized = e.standardized_country
WHERE e.original_city IS NOT NULL
;


/* B I L L I N G & S H I P P I N G   C I T Y   F I X I N G:    E N D  */




/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D   I M P U T I N G / F I X I N G:   B E G I N */

UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON  m.shipping_city = e.City
SET
    m.shipping_country_standardized = e.Country
WHERE  m.shipping_country_standardized <> e.Country
AND LENGTH(m.shipping_city) > 6
AND (m.shipping_country_standardized IN ('Hungary') OR m.shipping_country_standardized IS NULL)
;


UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON  m.shipping_city = e.City
SET
    m.shipping_country_standardized = e.Country
WHERE  m.shipping_country_standardized <> e.Country
AND LENGTH(m.shipping_city) > 6
AND (m.shipping_country_standardized IN ('Romania') OR m.shipping_country_standardized IS NULL)
;

UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON  m.billing_city = e.City
SET
    m.billing_country_standardized = e.Country
WHERE  m.billing_country_standardized <> e.Country
AND LENGTH(m.billing_city) > 6
AND (m.billing_country_standardized IN ('Hungary', 'Romania') OR m.billing_country_standardized IS NULL)
;


UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON  m.billing_city = e.City
SET
    m.billing_country_standardized = e.Country
WHERE  m.billing_country_standardized <> e.Country
AND LENGTH(m.billing_city) > 6
AND (m.billing_country_standardized IN ('Romania') OR m.billing_country_standardized IS NULL)
;

/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D   I M P U T I N G / F I X I N G:   E N D */




/* U S E R   T Y P E:   B E G I N */

DROP TABLE IF EXISTS INVOICES_00u;
CREATE TABLE IF NOT EXISTS INVOICES_00u
SELECT m.erp_id,
			MAX(CASE 		WHEN s.user_type = 'Private insurance' THEN 'Private insurance'
							WHEN s.user_type = 'B2B2C' THEN 'B2B2C'
							WHEN s.user_type = 'B2C' THEN 'B2C'
							WHEN s.user_type = 'B2B' THEN 'B2B'
							WHEN s.user_type IS NULL THEN 'B2C'		
							ELSE s.user_type
			END) AS user_type
FROM INVOICES_00 m LEFT JOIN IN_user_type s
ON (m.shipping_country_standardized = s.country OR m.billing_country_standardized = s.country) 
AND ((LOWER(m.billing_name) LIKE CONCAT('%', s.search_string, '%') AND LOWER(m.billing_name) NOT LIKE '%eoptika kft.%') 
OR (LOWER(m.shipping_name) LIKE CONCAT('%', s.search_string, '%') AND LOWER(m.shipping_name) NOT LIKE '%eoptika kft.%'))
GROUP BY m.erp_id
;

ALTER TABLE INVOICES_00u ADD PRIMARY KEY (`erp_id`) USING BTREE;


UPDATE INVOICES_00 AS m 
SET m.user_type = 
(SELECT s.user_type FROM INVOICES_00u AS s WHERE m.erp_id = s.erp_id)
;

/* U S E R   T Y P E:   E N D */



/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   B E G I N */


/* 1. tökéletes ország és város egyezés */

UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_city = e.City AND m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE e.Country IS NOT NULL
;


UPDATE INVOICES_00 AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_city = e.City AND m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE e.Country IS NOT NULL
;



DROP TABLE IF EXISTS shipping_city_nonmatch;
CREATE TABLE IF NOT EXISTS shipping_city_nonmatch
SELECT DISTINCT
		m.shipping_city_standardized, 
		m.shipping_country_standardized, 
		m.shipping_city,
		m.shipping_zip_code
FROM INVOICES_00 AS m
WHERE m.shipping_city_standardized IS NULL
;

ALTER TABLE shipping_city_nonmatch ADD fulltext INDEX(shipping_city);
ALTER TABLE shipping_city_nonmatch ADD INDEX (`shipping_country_standardized`) USING BTREE;
ALTER TABLE shipping_city_nonmatch ADD INDEX (`shipping_zip_code`) USING BTREE;



DROP TABLE IF EXISTS billing_city_nonmatch;
CREATE TABLE IF NOT EXISTS billing_city_nonmatch
SELECT DISTINCT
		m.billing_city_standardized, 
		m.billing_country_standardized, 
		m.billing_city,
		m.billing_zip_code
FROM INVOICES_00 AS m
WHERE m.billing_city_standardized IS NULL
;

ALTER TABLE billing_city_nonmatch ADD fulltext INDEX(billing_city);
ALTER TABLE billing_city_nonmatch ADD INDEX (`billing_country_standardized`) USING BTREE;
ALTER TABLE billing_city_nonmatch ADD INDEX (`billing_zip_code`) USING BTREE;


/* 2. tökéletes ország egyezés, utána a megadott városban benne van a városlista egyik eleme: Alsónémedi É-i V.ter. -> Alsónémedi */

/* ahol a shipping_city elég hosszú, hogy ne legyen téves találat, és ahol az irányítószám első száma egyezik 
ott meg keresi hivatalos város nevet a saját listában 
*/
UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE LENGTH(e.City) > 7
AND SUBSTR(e.zip_code,1,1) = SUBSTR(m.shipping_zip_code,1,1)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE LENGTH(e.City) > 7
AND SUBSTR(e.zip_code,1,1) = SUBSTR(m.billing_zip_code,1,1)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;


/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;



/* 
3. tökéletes ország egyezés, utána a megadott város benne van a városlistában: Nyiregy -> Nyíregyháza
*/

UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND e.City LIKE CONCAT('%',m.shipping_city,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE LENGTH(m.shipping_city) > 5
AND SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.shipping_city <> 'England'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND e.City LIKE CONCAT('%',m.billing_city,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE LENGTH(m.billing_city) > 5
AND SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.billing_city <> 'England'
;


/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;





/* 
4. tökéletes ország egyezés, utána a megadott város átkódolása: BP -> Budapest
*/

UPDATE shipping_city_nonmatch AS m
SET
    m.shipping_city_standardized = 'Budapest'
WHERE m.shipping_city IN ('BP', 'Bp.', 'Bu', 'Buda', 'Budapes')
AND m.shipping_country_standardized = 'Hungary'
;

UPDATE billing_city_nonmatch AS m
SET
    m.billing_city_standardized = 'Budapest'
WHERE m.billing_city IN ('BP', 'Bp.', 'Bu', 'Buda', 'Budapes')
AND m.billing_country_standardized = 'Hungary'
;

/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;



/*
4. egy-két betűs eltérés: Debrcen -> Debrecen
*/
UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND SOUNDEX(m.shipping_city) LIKE SOUNDEX(e.City))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND SOUNDEX(m.billing_city) LIKE SOUNDEX(e.City))
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;




/*
5. városnév kiigazítás zip_code egyezés alapján
*/
UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,4) = SUBSTR(m.shipping_zip_code,1,4)
AND LENGTH(m.shipping_zip_code) = 4
AND m.shipping_country_standardized = 'Hungary'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,4) = SUBSTR(m.billing_zip_code,1,4)
AND LENGTH(m.billing_zip_code) = 4
AND m.billing_country_standardized = 'Hungary'
;


UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE m.shipping_zip_code LIKE CONCAT(e.zip_code,'%')
AND m.shipping_country_standardized = 'United Kingdom'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE m.billing_zip_code LIKE CONCAT(e.zip_code,'%')
AND m.billing_country_standardized = 'United Kingdom'
;


UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Italy'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Italy'
;

UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Spain'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Spain'
;


UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Romania'
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Romania'
;


/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;




/* 
6. tökéletes ország egyezés, utána a megadott városban benne van a városlista egyik eleme, de most már városnév hossz megkötés nélkül 
*/

UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;


/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;




/*
7. tökéletes ország egyezés, utána a megadott városban benne van a városlista egyik eleme, de most már városnévhossz és zip_code egyezés nélkül

https://androidaddicted.wordpress.com/2010/06/01/jaro-winkler-sql-code/
http://dannykopping.com/blog/fuzzy-text-search-mysql-jaro-winkler
http://sjhannah.com/blog/2014/11/03/using-soundex-and-mysql-full-text-search-for-fuzzy-matching/
https://dba.stackexchange.com/questions/15214/why-is-like-more-than-4x-faster-than-match-against-on-a-fulltext-index-in-mysq

*/

UPDATE shipping_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
LEFT JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

/* a megtalált városneveket update-eljük az INVOICES_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;


/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   E N D */



DROP TABLE IF EXISTS SHIPPING_FEES_001;
CREATE TABLE IF NOT EXISTS SHIPPING_FEES_001 LIKE INVOICES_00;
INSERT INTO SHIPPING_FEES_001
SELECT * 
FROM INVOICES_00
WHERE item_group_name = 'Szállítási díjak'
;




/* R E A L   &   P I C K U P   I N F O   M O D U L E:   B E G I N */

UPDATE INVOICES_00 AS u /*az egészségpénztári  tagság külön mezőben való tárolása*/
SET
    u.health_insurance =
		CASE
			WHEN UPPER(shipping_name) LIKE '%MKB EGÉSZSÉGPÉNZTÁR%' OR UPPER(billing_name) LIKE '%MKB EGÉSZSÉGPÉNZTÁR%' THEN 'MKB EGÉSZSÉGPÉNZTÁR' 
			WHEN UPPER(shipping_name) LIKE '%MKB E%' OR UPPER(billing_name) LIKE '%MKB E%' THEN 'MKB EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%MKB-PANNÓNIA%' OR UPPER(billing_name) LIKE '%MKB-PANNÓNIA%' THEN 'MKB-PANNÓNIA EGÉSZSÉG- ÉS ÖNSEGÉLYEZŐ PÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%MKB PANNÓNIA%' OR UPPER(billing_name) LIKE '%MKB PANNÓNIA%' THEN 'MKB-PANNÓNIA EGÉSZSÉG- ÉS ÖNSEGÉLYEZŐ PÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%MEDICINA E%' OR UPPER(billing_name) LIKE '%MEDICINA E%' THEN 'MEDICINA EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%POSTÁS E%' OR UPPER(billing_name) LIKE '%POSTÁS E%' THEN 'POSTÁS EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%OTP ORSZÁGOS E%' OR UPPER(billing_name) LIKE '%OTP ORSZÁGOS E%' THEN 'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%OTP E%'OR UPPER(billing_name) LIKE '%OTP E%' THEN 'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%PATIKA E%' OR UPPER(billing_name) LIKE '%PATIKA E%' THEN 'PATIKA EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%ARANYKOR E%' OR UPPER(billing_name) LIKE '%ARANYKOR E%' THEN 'ARANYKOR EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%TEMPO E%' OR UPPER(billing_name) LIKE '%TEMPO E%' THEN 'TEMPO EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%AXA E%' OR UPPER(billing_name) LIKE '%AXA E%' THEN 'AXA EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%PRÉMIUM E%' OR UPPER(billing_name) LIKE '%PRÉMIUM E%' THEN 'PRÉMIUM EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%VITAMIN E%' OR UPPER(billing_name) LIKE '%VITAMIN E%' THEN 'VITAMIN EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%ÉLETERÖ E%' OR UPPER(billing_name) LIKE '%ÉLETERÖ E%' THEN 'ÉLETERÖ EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%ÉLETÚT E%' OR UPPER(billing_name) LIKE '%ÉLETÚT E%' THEN 'ÉLETÚT EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%GENERALI E%' OR UPPER(billing_name) LIKE '%GENERALI E%' THEN 'GENERALI EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%HONVÉD E%' OR UPPER(billing_name) LIKE '%HONVÉD E%' THEN 'HONVÉD EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%NAVOSZ E%' OR UPPER(billing_name) LIKE '%NAVOSZ E%' THEN 'NAVOSZ EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%QAESTOR E%' OR UPPER(billing_name) LIKE '%QAESTOR E%' THEN 'QAESTOR EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%ADOSZT E%' OR UPPER(billing_name) LIKE '%ADOSZT E%' THEN 'ADOSZT EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%ÚJ PILLÉR E%'OR UPPER(billing_name) LIKE '%ÚJ PILLÉR E%' THEN 'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%PILLÉR E%' OR UPPER(billing_name) LIKE '%PILLÉR E%' THEN 'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%HONVÉD E%' OR UPPER(billing_name) LIKE '%HONVÉD E%' THEN 'HONVÉD EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%PROVITA E%' OR UPPER(billing_name) LIKE '%PROVITA E%' THEN 'PROVITA EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%EGÉSZSÉGÉRT E%' OR UPPER(billing_name) LIKE '%EGÉSZSÉGÉRT E%' THEN 'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%KARDIREX E%'OR UPPER(billing_name) LIKE '%KARDIREX E%' THEN 'KARDIREX EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%VASUTAS E%' OR UPPER(billing_name) LIKE '%VASUTAS E%' THEN 'VASUTAS EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%TICKET WELLNESS E%' OR UPPER(billing_name) LIKE '%TICKET WELLNESS E%' THEN 'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%K&H%' OR UPPER(billing_name) LIKE '%K&H%' THEN 'K&H MEDICINA EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%DIMENZIÓ E%' OR UPPER(billing_name) LIKE '%DIMENZIÓ E%' THEN 'DIMENZIÓ EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%DIMENZIO E%' OR UPPER(billing_name) LIKE '%DIMENZIO E%' THEN 'DIMENZIÓ EGÉSZSÉGPÉNZTÁR'
			WHEN UPPER(shipping_name) LIKE '%DANUBIUS E%' OR UPPER(billing_name) LIKE '%DANUBIUS E%' THEN 'DANUBIUS EGÉSZSÉGPÉNZTÁR'
			END
;

UPDATE INVOICES_00 AS u /*az egészségpénztári tagság tisztítása a shipping_name és a billing_name mezőből*/
SET
    u.shipping_name_trim =
			TRIM(numerical_code_replace
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(shipping_name)
			,'MKB EGÉSZSÉGPÉNZTÁR','')
			,'MKB-PANNÓNIA EGÉSZSÉG- ÉS ÖNSEGÉLYEZŐ PÉNZTÁR','')
			,'MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'POSTÁS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSPÉNZTÁR','')
			,'OTP EGÉSZSÉGPÉNZTÁR','')
			,'PATIKA EGÉSZSÉGPÉNZTÁR','')
			,'ARANYKOR EGÉSZSÉGPÉNZTÁR','')
			,'TEMPO EGÉSZSÉGPÉNZTÁR','')			
			,'AXA EGÉSZSÉGPÉNZTÁR','')	
			,'PRÉMIUM EGÉSZSÉGPÉNZTÁR','')	
			,'VITAMIN EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETERÖ EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETÚT EGÉSZSÉGPÉNZTÁR','')
			,'GENERALI EGÉSZSÉGPÉNZTÁR','')	
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')
			,'NAVOSZ EGÉSZSÉGPÉNZTÁR','')
			,'QAESTOR EGÉSZSÉGPÉNZTÁR','')
			,'ADOSZT EGÉSZSÉGPÉNZTÁR','')
			,'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR','')
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')
			,'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR','')
			,'KARDIREX EGÉSZSÉGPÉNZTÁR','')
			,'VASUTAS EGÉSZSÉGPÉNZTÁR','')
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EP.','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'DANUBIUS EGÉSZSÉGPÉNZTÁR','')
			,'UNDEFINED', '')
			,'/', '')
			,'(', '')
			,')', '')	
			)),
			
    u.billing_name_trim =
			TRIM(numerical_code_replace
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(billing_name)
			,'MKB EGÉSZSÉGPÉNZTÁR','')
			,'MKB-PANNÓNIA EGÉSZSÉG- ÉS ÖNSEGÉLYEZŐ PÉNZTÁR','')
			,'MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'POSTÁS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSÉGPÉNZTÁR','')
			,'OTP ORSZÁGOS EGÉSZSPÉNZTÁR','')
			,'OTP EGÉSZSÉGPÉNZTÁR','')
			,'PATIKA EGÉSZSÉGPÉNZTÁR','')
			,'ARANYKOR EGÉSZSÉGPÉNZTÁR','')
			,'TEMPO EGÉSZSÉGPÉNZTÁR','')			
			,'AXA EGÉSZSÉGPÉNZTÁR','')	
			,'PRÉMIUM EGÉSZSÉGPÉNZTÁR','')	
			,'VITAMIN EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETERÖ EGÉSZSÉGPÉNZTÁR','')
			,'ÉLETÚT EGÉSZSÉGPÉNZTÁR','')
			,'GENERALI EGÉSZSÉGPÉNZTÁR','')	
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')
			,'NAVOSZ EGÉSZSÉGPÉNZTÁR','')
			,'QAESTOR EGÉSZSÉGPÉNZTÁR','')
			,'ADOSZT EGÉSZSÉGPÉNZTÁR','')
			,'ÚJ PILLÉR EGÉSZSÉGPÉNZTÁR','')
			,'HONVÉD EGÉSZSÉGPÉNZTÁR','')	
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')
			,'EGÉSZSÉGÉRT EGÉSZSÉGPÉNZTÁR','')
			,'KARDIREX EGÉSZSÉGPÉNZTÁR','')
			,'VASUTAS EGÉSZSÉGPÉNZTÁR','')
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EP.','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'DANUBIUS EGÉSZSÉGPÉNZTÁR','')
			,'UNDEFINED', '')
			,'/', '')
			,'(', '')
			,')', '')			
			)),

	u.shipping_name_trim_wo_pickup =
			TRIM(numerical_code_replace
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(shipping_name_trim)
			,'EXON 2000','')
			,'OMV','')
			,'MOL ','')
			,'NEMZETI DOHÁNYBOLT','')
			,'MOL ','')
			,'OMW','')
			,'RELAY','')
			,'INMEDIO','')
			,'INMEDIÓ','')
			,'ALLEGROUP.HU KFT.','')
			,'OTP BANK NYRT','')
			,'/ PPP','')
			,'/PPP','')
			,'PPPP','')
			,'/ PM','')
			,'/EP','')
			,'/ TOF','')
			,'/ SPRINTER','')
			,' PP', '')
			,'/PP', '')
			,' / ', ' /')
			)),

	u.billing_name_trim_wo_pickup =
			TRIM(numerical_code_replace
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(REPLACE
			(UPPER
			(billing_name_trim)
			,'EXON 2000','')
			,'OMV','')
			,'MOL ','')
			,'NEMZETI DOHÁNYBOLT','')
			,'MOL ','')
			,'OMW','')
			,'RELAY','')
			,'INMEDIO','')
			,'INMEDIÓ','')
			,'ALLEGROUP.HU KFT.','')
			,'OTP BANK NYRT','')
			,'/ PPP','')
			,'/PPP','')
			,'PPPP','')
			,'/ PM','')
			,'/EP','')
			,'/ TOF','')
			,'/ SPRINTER','')
			,' PP', '')
			,'/PP', '')
			,'/', '')
			,'(', '')
			,')', '')
			))
;





UPDATE INVOICES_00 AS u
SET
    u.shipping_name_flg =
		CASE 
			WHEN LOWER(shipping_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|iroda' THEN 'business'
			WHEN LOWER(shipping_name) REGEXP '/tof|/ tof|ppp|/ pm|/pm|/pp|/ pp|sprinter|exon 2000| omv|omv |mol benzinkút|mol töltőállomás|nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN 'pickup'
			ELSE 'real'
		END,

    u.billing_name_flg =
		CASE 
			WHEN LOWER(billing_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|iroda' THEN 'business'
			WHEN LOWER(billing_name) REGEXP '/tof|/ tof|ppp|/ pm|/pm|/pp|/ pp|sprinter|exon 2000| omv|omv |mol benzinkút|mol töltőállomás|nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN 'pickup'
			ELSE 'real'
		END,

    u.shipping_name_pickup =
		CASE
			WHEN LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN shipping_name_trim
			END,

    u.billing_name_pickup =
		CASE
			WHEN LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN billing_name_trim
			END,
			
    u.shipping_name_business =
		CASE
			WHEN LOWER(shipping_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|egyesület|iroda' THEN shipping_name_trim
		END,
			
    u.billing_name_business =
		CASE
			WHEN LOWER(billing_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|egyesület|iroda' THEN billing_name_trim
		END
;



UPDATE INVOICES_00 AS u
SET
    u.real_name = 
	CASE
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'real' AND LOCATE(billing_name_trim, shipping_name_trim) > 0 AND LENGTH(billing_name_trim) > 3 THEN billing_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'real' THEN shipping_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'pickup' THEN shipping_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'business' THEN shipping_name_trim
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'real' THEN billing_name_trim
		WHEN shipping_name_flg = 'business' AND billing_name_flg = 'real' THEN billing_name_trim
		WHEN shipping_name_flg = 'business' AND billing_name_flg = 'business' AND LOCATE(shipping_name_trim, billing_name_trim) = 0 THEN REPLACE(shipping_name_trim, billing_name_trim,'')
		END,

    u.pickup_name =	
	CASE
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'real' THEN REPLACE(shipping_name_trim, billing_name_trim,'')
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'pickup' THEN billing_name_trim
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'business' THEN REPLACE(shipping_name_trim, shipping_name_trim_wo_pickup,'')
	END,
	
    u.business_name =
	CASE
		WHEN shipping_name_flg = 'business' AND billing_name_flg = 'real' THEN REPLACE(shipping_name_trim, billing_name_trim_wo_pickup,'')
		WHEN shipping_name_flg = 'business' AND billing_name_flg = 'business' THEN billing_name_trim
	END,



    u.real_address =
CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell az IF, amikor üres a shipping_address */
	WHEN billing_name_flg = 'real' THEN IF(billing_address = '', shipping_address, billing_address) /* azért kell az IF, amikor üres a billing_address */
END,

    u.pickup_address =
CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell a COALESCE, hogy ha üres a shipping_address */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_address = '', shipping_address, billing_address) /* azért kell a COALESCE, hogy ha üres a billing_address */ 
END,

    u.business_address =
CASE 
	WHEN shipping_name_flg = 'business' THEN IF(shipping_address = '', billing_address, shipping_address) /* azért kell a COALESCE, hogy ha üres a shipping_address */
	WHEN billing_name_flg = 'business' THEN IF(billing_address = '', shipping_address, billing_address) /* azért kell a COALESCE, hogy ha üres a billing_address */ 
END,



    u.real_zip_code =
CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'real' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */
END,

    u.pickup_zip_code =
CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */ 
END,

    u.business_zip_code =
CASE
	WHEN shipping_name_flg = 'business' THEN IF(shipping_zip_code = '', billing_zip_code, shipping_zip_code) /* azért kell a COALESCE, hogy ha üres a shipping_zip_code */
	WHEN billing_name_flg = 'business' THEN IF(billing_zip_code = '', shipping_zip_code, billing_zip_code) /* azért kell a COALESCE, hogy ha üres a billing_zip_code */ 
END,



    u.real_city =
CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_city_standardized IS NULL, billing_city_standardized, shipping_city_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */ 
	WHEN billing_name_flg = 'real' THEN IF(billing_city_standardized IS NULL, shipping_city_standardized, billing_city_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */
END,

    u.pickup_city =
CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_city_standardized IS NULL, billing_city_standardized, shipping_city_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_city_standardized IS NULL, shipping_city_standardized, billing_city_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */ 
END,

    u.business_city =
CASE 
	WHEN shipping_name_flg = 'business' THEN IF(shipping_city_standardized IS NULL, billing_city_standardized, shipping_city_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'business' THEN IF(billing_city_standardized IS NULL, shipping_city_standardized, billing_city_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */
END,




    u.real_country =
CASE
	WHEN shipping_name_flg = 'real' THEN IF(shipping_country_standardized IS NULL, billing_country_standardized, shipping_country_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */ 
	WHEN billing_name_flg = 'real' THEN IF(billing_country_standardized IS NULL, shipping_country_standardized, billing_country_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */
END,

    u.pickup_country =
CASE 
	WHEN shipping_name_flg = 'pickup' THEN IF(shipping_country_standardized IS NULL, billing_country_standardized, shipping_country_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'pickup' THEN IF(billing_country_standardized IS NULL, shipping_country_standardized, billing_country_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */ 
END,

    u.business_country =
CASE 
	WHEN shipping_name_flg = 'business' THEN IF(shipping_country_standardized IS NULL, billing_country_standardized, shipping_country_standardized) /* azért kell a COALESCE, hogy ha üres a shipping_city */
	WHEN billing_name_flg = 'business' THEN IF(billing_country_standardized IS NULL, shipping_country_standardized, billing_country_standardized) /* azért kell a COALESCE, hogy ha üres a billing_city */
END
;


UPDATE INVOICES_00 AS u
LEFT JOIN IN_postcodes i
ON u.pickup_zip_code = i.postcode
SET
    u.real_name = COALESCE(u.real_name,COALESCE(u.business_name, u.pickup_name)),
    u.real_address = COALESCE(u.real_address,COALESCE(u.business_address, u.pickup_address)),
    u.real_zip_code = COALESCE(u.real_zip_code,COALESCE(u.business_zip_code, u.pickup_zip_code)),
    u.real_city = special_char_replace(COALESCE(u.real_city,COALESCE(u.business_city, u.pickup_city))),
    u.real_country = COALESCE(u.real_country,COALESCE(u.business_country, u.pickup_country)),	
    u.pickup_name = COALESCE(u.pickup_name, u.real_name),
    u.pickup_address = CASE WHEN u.shipping_method = 'Pickup in person' THEN 'Terez krt 50.' ELSE COALESCE(u.pickup_address, u.real_address) END,
    u.pickup_zip_code = CASE WHEN u.shipping_method = 'Pickup in person' THEN '1067' ELSE COALESCE(u.pickup_zip_code, u.real_zip_code) END,
	u.pickup_city = special_char_replace(COALESCE(u.pickup_city,COALESCE(u.real_city, u.business_city))),
    u.pickup_country = CASE WHEN u.shipping_method = 'Pickup in person' THEN 'Hungary' ELSE COALESCE(u.pickup_country, u.real_country) END,
	u.business_name = COALESCE(u.business_name, u.real_name),
	u.business_address = COALESCE(u.business_address, u.real_address),
	u.business_zip_code = COALESCE(u.business_zip_code, u.real_zip_code),
	u.business_city = special_char_replace(COALESCE(u.business_city, u.real_city)),
    u.business_country = COALESCE(u.business_country, u.real_country),
	u.catchment_area = CASE WHEN u.shipping_method = 'Pickup in person' OR i.region IN ('Budapest', 'Pest') THEN 'Budapest, Terez krt 50.' ELSE 'other' END
;


/* R E A L   &   P I C K U P   I N F O   M O D U L E:   E N D */





/* P R O V I N C E  &  C I T Y_S I Z E:   B E G I N */

UPDATE INVOICES_00 AS m
        LEFT JOIN IN_eu_cities AS s 
	ON (m.real_city = s.City AND m.real_country = s.Country)
SET
    m.real_city_size = s.Population,
    m.real_province = s.region
;


UPDATE INVOICES_00 AS m
        LEFT JOIN IN_eu_cities AS s 
	ON (m.pickup_city = s.City AND m.pickup_country = s.Country)
SET
    m.pickup_city_size = s.Population,
    m.pickup_province = s.region
;


UPDATE INVOICES_00 AS m
        LEFT JOIN IN_eu_cities AS s 
	ON (m.business_city = s.City AND m.business_country = s.Country)
SET
    m.business_city_size = s.Population
    m.business_province = s.region
;

/* P R O V I N C E  &  C I T Y_S I Z E:   E N D */




/* S H I P P I N G   P H O N E   M O D U L E:   B E G I N */

DROP TABLE IF EXISTS INVOICES_00c4;
CREATE TABLE IF NOT EXISTS INVOICES_00c4
SELECT DISTINCT 
		sql_id,
        CASE 
			WHEN shipping_country_standardized = 'Hungary' THEN 
        	CASE 
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+36' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '036' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0036' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,5,12))
								
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3670' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3630' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '3620' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0670' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0630' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '0620' THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
		
				WHEN SUBSTR(shipping_phone_aux,1,2) = '70' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,2) = '30' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,2) = '20' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,3,12)) 
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+70' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+30' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,3) = '+20' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,4,12))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0670' THEN CONCAT('+36 70', SUBSTR(shipping_phone_aux,6,14))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0630' THEN CONCAT('+36 30', SUBSTR(shipping_phone_aux,6,14))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+0620' THEN CONCAT('+36 20', SUBSTR(shipping_phone_aux,6,14))
								
				/*budapesti*/
				WHEN LENGTH(shipping_phone_aux) = 7 THEN CONCAT('+36 1', shipping_phone_aux)
				/*vidéki*/
				WHEN SUBSTR(shipping_phone_aux,1,2) = '06' AND SUBSTR(shipping_phone_aux,3,2) NOT IN ('20','30','70') THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN SUBSTR(shipping_phone_aux,1,2) = '06' AND SUBSTR(shipping_phone_aux,3,2) NOT IN ('20','30','70') THEN CONCAT('+36 ', SUBSTR(shipping_phone_aux,3,12))
				WHEN LENGTH(shipping_phone_aux) = 8 THEN CONCAT('+36 ', shipping_phone_aux)
				/*szlovén*/
				WHEN SUBSTR(shipping_phone_aux,1,3) = '386' THEN CONCAT('+386 ', SUBSTR(shipping_phone_aux,4,12))				
				WHEN SUBSTR(shipping_phone_aux,1,4) = '+386' THEN CONCAT('+386 ', SUBSTR(shipping_phone_aux,5,12))				
			END
		WHEN shipping_country_standardized = 'Romania' THEN 
			CASE 
				WHEN SUBSTR(shipping_phone_aux,1,7) = '+40+400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,8,9))
				WHEN SUBSTR(shipping_phone_aux,1,7) = '+400000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,8,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,6) = '+40010' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,7,9))
				WHEN SUBSTR(shipping_phone_aux,1,5) = '+4000' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,6,9))
				WHEN SUBSTR(shipping_phone_aux,1,4) = '+400' THEN CONCAT('+40 ', SUBSTR(shipping_phone_aux,5,9))
				ELSE CONCAT('+40 ', SUBSTR(shipping_phone_aux,4,9))
			END
		
        ELSE shipping_phone_aux
        END AS shipping_phone_clean
FROM INVOICES_00
;

ALTER TABLE INVOICES_00c4 ADD PRIMARY KEY (`sql_id`) USING BTREE;

UPDATE INVOICES_00 AS m
        LEFT JOIN
    INVOICES_00c4 AS s ON m.sql_id = s.sql_id
SET
    m.shipping_phone_clean = s.shipping_phone_clean
;


/* S H I P P I N G   P H O N E   M O D U L E:   E N D */

ALTER TABLE INVOICES_00 ADD INDEX (`pickup_city`) USING BTREE;
ALTER TABLE INVOICES_00 ADD INDEX (`personal_city`) USING BTREE;

UPDATE INVOICES_00 AS m
LEFT JOIN IN_city_agglomeration AS s 
ON m.pickup_city = s.city
SET m.pickup_location_catchment_area = s.agglomeration
;

UPDATE INVOICES_00 AS m
LEFT JOIN IN_city_agglomeration AS s 
ON m.real_city = s.city
SET m.personal_location_catchment_area = s.agglomeration
;
