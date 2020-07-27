/*
1. városok letöltése innen: https://www.maxmind.com/en/free-world-cities-database:
(https://www.aggdata.com/free/spain-postal-codes)
https://raw.githubusercontent.com/Gibbs/uk-postcodes/d750a34a6401007434bed962278bf000fde925f9/postcodes.csv

2. mivel túl nagy a tábla, ezért le kell szűkíteni az európai országokra. 
   a. worldcitiespop.txt-t be kell tölteni ACCESS-be.
   b. a "Database2.accdb" nevü MS ACCESS adatbázisba kell elmenteni.
   c. ott ki kell törölni a nem-európai országok városait.
   d. a szűkített táblát el kell menteni EUcitiespop.txt néven.


3. be kell tölteni a "EUcitiespop.txt" táblát mysql-be. Ott az alábbi lekérdezés segítségével a több soron szereplő városok közül csak a legnagyobb népességgel szereplőket kell venni:
*/

ALTER TABLE world_cities ADD INDEX (`Country`) USING BTREE;
ALTER TABLE world_cities ADD INDEX (`AccentCity`) USING BTREE;
ALTER TABLE world_cities ADD INDEX (`City`) USING BTREE;
ALTER TABLE IN_postcodes ADD INDEX (`town`) USING BTREE;
ALTER TABLE IN_postcodes ADD INDEX (`postcode`) USING BTREE;
ALTER TABLE IN_postcodes ADD INDEX (`country`) USING BTREE;



UPDATE world_cities
SET City = REPLACE(City, 'bucharest', 'bucuresti'),
	AccentCity = REPLACE(AccentCity, 'Bucharest', 'Bucuresti')
where City = 'bucharest'
;

UPDATE IN_postcodes
SET town = CASE WHEN town LIKE '%București%' THEN 'Bucuresti' ELSE town END
WHERE town LIKE '%București%'
AND country = 'RO'
;


DROP TABLE IF EXISTS IN_eu_cities;
CREATE TABLE IN_eu_cities
SELECT 
	w.Country, 
	w.City,
	w.AccentCity,
	i.region,
	i.postcode AS zip_code,
	MAX(w.Population) AS Population
FROM world_cities w
LEFT JOIN IN_postcodes i
ON (w.Country = i.country AND w.AccentCity = i.town)
GROUP BY w.Country, w.City, w.AccentCity, i.postcode, i.town
;

ALTER TABLE IN_eu_cities ADD fulltext INDEX(City);
ALTER TABLE IN_eu_cities ADD INDEX (`City`) USING BTREE;
ALTER TABLE IN_eu_cities ADD INDEX (`Country`) USING BTREE;
ALTER TABLE IN_eu_cities ADD INDEX (`zip_code`) USING BTREE;



/*
3. át kell nevezni a 2-betűs ország kódokat a KPI rendszerben használt standardized_country formátumra:
*/
UPDATE IN_eu_cities
    SET Country = CASE
        WHEN Country  = 'at' THEN 'Austria'
        WHEN Country  = 'be' THEN 'Belgium'
        WHEN Country  = 'bg' THEN 'Bulgaria'
        WHEN Country  = 'by' THEN 'Belarus'
        WHEN Country  = 'ch' THEN 'Switzerland'
        WHEN Country  = 'cy' THEN 'Cyprus'
        WHEN Country  = 'cz' THEN 'Czech Republic'
        WHEN Country  = 'de' THEN 'Germany'
        WHEN Country  = 'dk' THEN 'Denmark'
        WHEN Country  = 'es' THEN 'Spain'
        WHEN Country  = 'fi' THEN 'Finland'
        WHEN Country  = 'fr' THEN 'France'
        WHEN Country  = 'gb' THEN 'United Kingdom'
        WHEN Country  = 'gr' THEN 'Greece'
        WHEN Country  = 'hr' THEN 'Croatia'
        WHEN Country  = 'hu' THEN 'Hungary'
        WHEN Country  = 'ie' THEN 'Ireland'
        WHEN Country  = 'il' THEN 'Israel'
        WHEN Country  = 'it' THEN 'Italy'
        WHEN Country  = 'lt' THEN 'Lithuania'
        WHEN Country  = 'lv' THEN 'Latvia'
        WHEN Country  = 'md' THEN 'Moldova'
        WHEN Country  = 'nl' THEN 'Netherlands'
        WHEN Country  = 'no' THEN 'Norway'
        WHEN Country  = 'pl' THEN 'Poland'
        WHEN Country  = 'pt' THEN 'Portugal'
        WHEN Country  = 'ro' THEN 'Romania'
        WHEN Country  = 'rs' THEN 'Serbia'
        WHEN Country  = 'ru' THEN 'Russia'
        WHEN Country  = 'se' THEN 'Sweden'
        WHEN Country  = 'si' THEN 'Slovenia'
        WHEN Country  = 'sk' THEN 'Slovakia'
        WHEN Country  = 'ua' THEN 'Ukrain'
	ELSE Country
    END
;

UPDATE IN_eu_cities
SET 
	City = CASE WHEN City  = 'tahitofalu' THEN 'tahitotfalu' ELSE City END,
	AccentCity = CASE WHEN AccentCity = 'Tahitófalu' THEN 'Tahitótfalu' ELSE AccentCity END
;

UPDATE IN_eu_cities
SET zip_code = REPLACE(LTRIM(REPLACE(zip_code,'0',' ')),' ','0')
WHERE country = 'Romania'
;



SELECT DISTINCT Country  FROM `IN_eu_cities` WHERE 1


DELETE FROM IN_eu_cities
WHERE Country  IN ('et', 'ly')
;


/*
Törölni kell a listából azokat a MAGYAR város neveket, amik léteznek máshol is a világban!
*/
CREATE TABLE duplicate_cities_hu
SELECT DISTINCT City
FROM IN_eu_cities
WHERE City IN
(
SELECT DISTINCT City
FROM IN_eu_cities
WHERE Country = 'Hungary'    
)
GROUP BY City
HAVING COUNT(*) > 1
;

ALTER TABLE duplicate_cities_hu ADD INDEX (`City`) USING BTREE;


DELETE FROM IN_eu_cities
WHERE Country <> 'Hungary'
AND City IN 
(
SELECT DISTINCT City
FROM duplicate_cities_hu
)
; 



/*
Törölni kell a listából azokat a ROMÁN város neveket, amik léteznek máshol is a világban!
*/
CREATE TABLE duplicate_cities_ro
SELECT DISTINCT City
FROM IN_eu_cities
WHERE City IN
(
SELECT DISTINCT City
FROM IN_eu_cities
WHERE Country = 'Romania'
)
GROUP BY City
HAVING COUNT(*) > 1
;

ALTER TABLE duplicate_cities_ro ADD INDEX (`City`) USING BTREE;


DELETE FROM IN_eu_cities
WHERE Country <> 'Romania'
AND City IN 
(
SELECT DISTINCT City
FROM duplicate_cities_ro
)
; 

/* INNENTŐL LEFELÉ NEM KELL */

/*
4. Lelistázása az összes városnak, ahonnan valaha vásároltak
*/
DROP TABLE IF EXISTS unique_shipping_city_from_items_sold;
CREATE TABLE unique_shipping_city_from_items_sold
SELECT DISTINCT 
		shipping_city, 
		shipping_country_standardized
FROM BASE_03_TABLE
;

ALTER TABLE unique_shipping_city_from_items_sold ADD INDEX (`shipping_city`) USING BTREE;
ALTER TABLE unique_shipping_city_from_items_sold ADD INDEX (`shipping_country_standardized`) USING BTREE;

ALTER TABLE INVOICES_00 ADD INDEX (`shipping_city_standardized`) USING BTREE;




/*
5. Városnév-hibajavító bekódoló tábla: azon ERP-ból jövö városok listája, ahol a város nem található meg a hivatalos városlistában:
*/
DROP TABLE IF EXISTS missing_standardized_city;
CREATE TABLE missing_standardized_city
SELECT DISTINCT  	u.shipping_city AS original_city, 
			t.shipping_city_standardized,
			u.shipping_country_standardized AS standardized_country
FROM unique_shipping_city_from_items_sold u
LEFT JOIN INVOICES_00 t
ON (u.shipping_city = t.shipping_city_standardized AND u.shipping_country_standardized = t.shipping_country_standardized)
WHERE t.shipping_city_standardized IS NULL
;

ALTER TABLE missing_standardized_city ADD INDEX (`original_city`) USING BTREE;
ALTER TABLE missing_standardized_city ADD INDEX (`standardized_country`) USING BTREE;




/*
7.
A "missing_standardized_city" tábla kiexportálása és a kapott csv betöltése az "KPI segedtabla - city_coding" bekódoló táblába. 


8. A "KPI segedtabla - city_coding" bekódoló tábla tartalma szinkronizálódik a 'IN_city_coding' KPI táblával.

9. Végül a bekódolóban javított városnév megjelenik a base table-ben. 
*/
SELECT DISTINCT shipping_city, personal_city 
FROM `BASE_03_TABLE`
WHERE shipping_city IN ('Derecen-Nagymacs', 'Nyíregy', 'Tiszaföldvár-Homok')
;

/*
cél: 
minden megadott városhoz megtalálni a hivatalos városnevet
módszertan:
1. a hivatalos város listával nem meccselö városnevekhez a karbantartó személy manuálisan rendeli hozzá a megfeleló hivatalos várost
lépések:
1. az összes ország (nemzetközi és magyar) hivatalos városlistájának az egyesítése a "KPI segedtabla - telepules_megye" bekódoló táblában,
2. a rosszul megadott városnevek javtására szolgáló hibajavító bekódoló tábla létrehozása az alábbi script alapján:



