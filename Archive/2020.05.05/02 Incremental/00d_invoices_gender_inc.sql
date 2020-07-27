/*a tisztított név tagokra szétszedése */
DROP TABLE IF EXISTS INVOICES_00d1;
CREATE TABLE INVOICES_00d1
SELECT 	DISTINCT 
		c.sql_id,
		shipping_country_standardized,
		personal_name,
		shipping_country,
		buyer_email,
		billing_zip_code,
		billing_country,
		related_division,
		billing_name,
		shipping_name,
		pickup_name,
		business_name,
		related_webshop,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 1), ' ', -1) AS parse_name_1,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 2), ' ', -1) AS parse_name_2,
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 3), ' ', -1) AS parse_name_3,	
		SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 4), ' ', -1) AS parse_name_4		
FROM INVOICES_00_inc c
;


ALTER TABLE INVOICES_00d1 ADD PRIMARY KEY (`sql_id`) USING BTREE;


/*a feleslegesen ismétlődő tagok törlése */
UPDATE	INVOICES_00d1
		SET parse_name_2 = CASE WHEN parse_name_2 = parse_name_1 THEN '' ELSE parse_name_2 END,
			parse_name_3 = CASE WHEN parse_name_3 = parse_name_2 THEN '' ELSE parse_name_3 END,
			parse_name_4 = CASE WHEN parse_name_4 = parse_name_3 OR parse_name_4 = parse_name_2 THEN '' ELSE parse_name_4 END
;




/*
feladatok:
1. IF sorok jól kezelik-e a -nét
*/

/*a tagok megjelölése, hogy first vagy last name */
DROP TABLE IF EXISTS INVOICES_00d2;
CREATE TABLE INVOICES_00d2
SELECT 	DISTINCT c.*,

/*
 IF(c.parse_name_1 ='' , '' , IF(g1.first_name IS NULL , 'last_name', IF(c.parse_name_1 LIKE '%né', 'last_name','first_name'))) AS name_ind_1,
 IF(c.parse_name_2 ='' , '' , IF(g2.first_name IS NULL , IF(c.parse_name_2 LIKE '%né', 'first_name','last_name'), 'first_name')) AS name_ind_2,
 IF(c.parse_name_3 ='' , '' , IF(g3.first_name IS NULL , IF(c.parse_name_3 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_3,
 IF(c.parse_name_4 ='' , '' , IF(g4.first_name IS NULL , IF(c.parse_name_4 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_4,
*/ 

 IF(c.parse_name_1 ='' , '' , IF(g1.first_name IS NULL , 'last_name', IF(c.parse_name_1 LIKE '%né', 'last_name','first_name'))) AS name_ind_1,
 IF(c.parse_name_2 ='' , '' , IF(g2.first_name IS NULL , 'last_name', 'first_name')) AS name_ind_2,
 IF(c.parse_name_3 ='' , '' , IF(g3.first_name IS NULL , IF(c.parse_name_3 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_3,
 IF(c.parse_name_4 ='' , '' , IF(g4.first_name IS NULL , IF(c.parse_name_4 LIKE '%né', 'last_name','first_name'), 'first_name')) AS name_ind_4,
 
CONCAT(UCASE(LEFT(c.parse_name_1, 1)), LCASE(SUBSTRING(c.parse_name_1, 2))) AS upper_name_1,
CONCAT(UCASE(LEFT(c.parse_name_2, 1)), LCASE(SUBSTRING(c.parse_name_2, 2))) AS upper_name_2,
CONCAT(UCASE(LEFT(c.parse_name_3, 1)), LCASE(SUBSTRING(c.parse_name_3, 2))) AS upper_name_3,
CONCAT(UCASE(LEFT(c.parse_name_4, 1)), LCASE(SUBSTRING(c.parse_name_4, 2))) AS upper_name_4,

 		MIN(CASE
			WHEN LOWER(c.personal_name) LIKE '%kornélia%' THEN 'Female'
			WHEN LOWER(c.personal_name) LIKE '%kornél%' THEN 'Male'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 1), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 2), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 3), ' ', -1)) LIKE '%né' THEN 'Female'
			WHEN g1.gender = 'Female' OR g2.gender = 'Female' OR g3.gender = 'Female' THEN 'Female'
			ELSE COALESCE(g3.gender,COALESCE(g2.gender,COALESCE(g1.gender,'missing')))
		END) AS gender,
		MIN(CASE
			WHEN LOWER(c.personal_name) LIKE '%kornélia%' THEN 0
			WHEN LOWER(c.personal_name) LIKE '%kornél%' THEN 0
			WHEN LOWER(c.personal_name) LIKE '%czene%' THEN 0
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 1), ' ', -1)) LIKE '%né' THEN 1
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 2), ' ', -1)) LIKE '%né' THEN 1
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 3), ' ', -1)) LIKE '%né' THEN 1
			WHEN LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(c.personal_name, ' ', 4), ' ', -1)) LIKE '%né' THEN 1
			ELSE 0
		END) AS ne

FROM INVOICES_00d1 c
LEFT JOIN IN_gender g1
ON (c.parse_name_1 = g1.first_name AND c.shipping_country_standardized = g1.country)
LEFT JOIN IN_gender g2
ON (c.parse_name_2 = g2.first_name AND c.shipping_country_standardized = g2.country)
LEFT JOIN IN_gender g3
ON (c.parse_name_3 = g3.first_name AND c.shipping_country_standardized = g3.country)
LEFT JOIN IN_gender g4
ON (c.parse_name_4 = g4.first_name AND c.shipping_country_standardized = g4.country)
GROUP BY c.sql_id
;


ALTER TABLE INVOICES_00d2 ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `shipping_country_standardized` (`shipping_country_standardized`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `related_webshop` (`related_webshop`) USING BTREE;
ALTER TABLE INVOICES_00d2 ADD INDEX `gender` (`gender`) USING BTREE;


/*

https://www.precisionb2b.com/contact-data/personalization/business-greeting/salutations-list.shtm
innen vettem a megszólításokat

*/

/*név tagok és megszólítás összetétele */
DROP TABLE IF EXISTS INVOICES_00d3;
CREATE TABLE INVOICES_00d3
SELECT DISTINCT a.*,
		CASE 
			WHEN c.webshop is null AND shipping_country_standardized = 'Hungary' THEN 'Kedves'
			WHEN c.webshop is null AND shipping_country_standardized <> 'Hungary' THEN 'Dear'
			ELSE c.prefix
		END AS salutation,
		CASE WHEN shipping_country_standardized = 'Hungary' THEN
			CASE 
				WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name' /*amikor semmilyen keresztnév nincs a névben: céges név*/
					THEN CONCAT(personal_name) 
				WHEN name_ind_1 = 'last_name' AND name_ind_2 = 'last_name' AND name_ind_3 = 'first_name' /*pl.: Pappné G. Anita*/ 
					THEN CONCAT(upper_name_1, ' ', upper_name_2)
				WHEN name_ind_1 = 'last_name' AND name_ind_2 = 'first_name' AND name_ind_3 = 'first_name' AND ne = 1 /*pl.: Ráczné Dávid Katalin*/ 
					THEN CONCAT(upper_name_1, ' ', upper_name_2)
					WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = '' /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/ 
					THEN upper_name_1 
				WHEN name_ind_1 = 'last_name' 
					THEN upper_name_1
				ELSE upper_name_2
			END
		ELSE
			upper_name_2
		END	AS last_name,

		CASE WHEN shipping_country_standardized = 'Hungary' THEN
			CASE 
				WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name'
					THEN '' /*amikor semmilyen keresztnév nincs a névben: céges név*/
				WHEN name_ind_1 = 'last_name' AND name_ind_2 = 'last_name' AND name_ind_3 = 'first_name' 
					THEN CONCAT(upper_name_3) /*pl.: Pappné G. Anita*/
				WHEN name_ind_1 = 'last_name' AND name_ind_2 = 'first_name' AND name_ind_3 = 'first_name' AND ne = 1
					THEN CONCAT(upper_name_3) /*pl.: Ráczné Dávid Katalin*/
				WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = '' 
					THEN CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4) /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/
				WHEN name_ind_1 = 'last_name'
					THEN CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4)
				ELSE CONCAT(upper_name_1,' ',upper_name_3, ' ', upper_name_4)
			END
		ELSE
						upper_name_1
		END	AS first_name,
		
		CASE WHEN shipping_country_standardized = 'Hungary' THEN
			CASE 
			WHEN name_ind_1 <> 'first_name' AND name_ind_2 <> 'first_name' AND name_ind_3 <> 'first_name' AND name_ind_4 <> 'first_name' THEN
						CONCAT(personal_name) /*amikor semmilyen keresztnév nincs a névben: céges név*/
			WHEN name_ind_1 = 'first_name' AND name_ind_2 = 'first_name' AND name_ind_3 = '' AND name_ind_4 = '' THEN
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4)) /*amikor a vezetéknév egy keresztnév: pl. Imre Alexandra*/

			WHEN name_ind_1 = 'last_name' THEN
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4))

						ELSE 	CONCAT(upper_name_2, ' ', CONCAT(upper_name_1,' ',upper_name_3, ' ', upper_name_4))
			END
		ELSE
						CONCAT(upper_name_1, ' ', CONCAT(upper_name_2,' ',upper_name_3, ' ', upper_name_4))
		END	AS full_name_raw
		
FROM INVOICES_00d2 AS a
LEFT JOIN IN_megszolitasi_formak c
ON (a.gender = c.gender AND a.related_webshop = c.webshop AND a.shipping_country_standardized = c.country)
;


ALTER TABLE INVOICES_00d3 ADD PRIMARY KEY (`sql_id`) USING BTREE;



UPDATE INVOICES_00_inc AS m
        LEFT JOIN
    INVOICES_00d3 AS s ON m.sql_id = s.sql_id
SET
    m.full_name = REPLACE(REPLACE(REPLACE(REPLACE(full_name_raw,'/',''),'Dr ','Dr. '),'  !','!'),' !','!'),
    m.first_name = s.first_name,
    m.last_name = s.last_name,
    m.gender = s.gender,
    m.salutation = CONCAT(s.salutation,' ', if(trim(s.first_name)= '',trim(s.last_name),trim(s.first_name)), ',')
;
