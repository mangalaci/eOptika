/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   B E G I N */

UPDATE ORDERS_00 AS m
INNER JOIN IN_country_coding AS e
ON m.billing_country = e.original_country
SET m.billing_country_standardized = e.standardized_country
WHERE e.original_country IS NOT NULL
AND LENGTH(m.billing_country) > 1
;

UPDATE ORDERS_00 AS m
INNER JOIN IN_country_coding AS e
ON m.shipping_country = e.original_country
SET m.shipping_country_standardized = e.standardized_country
WHERE e.original_country IS NOT NULL
AND LENGTH(m.shipping_country) > 1
;




UPDATE ORDERS_00
SET shipping_country_standardized = billing_country_standardized
WHERE shipping_country_standardized IS NULL
;


/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D:   E N D */


/* B I L L I N G & S H I P P I N G   C I T Y   F I X I N G:   B E G I N */

UPDATE ORDERS_00
SET shipping_zip_code = case when shipping_zip_code LIKE '%Somerset%' then REPLACE(shipping_zip_code, 'Somerset', '') end,
	billing_zip_code = case when billing_zip_code LIKE '%Somerset%' then REPLACE(billing_zip_code, 'Somerset', '') end
WHERE (shipping_country_standardized = 'United Kingdom' OR billing_country_standardized = 'United Kingdom')
;


UPDATE ORDERS_00
SET shipping_zip_code =  REPLACE(LTRIM(REPLACE(shipping_zip_code,'0',' ')),' ','0'),
	billing_zip_code = REPLACE(LTRIM(REPLACE(shipping_zip_code,'0',' ')),' ','0')
WHERE ((shipping_country_standardized = 'Romania' OR shipping_city = 'Bucuresti')
OR (billing_country_standardized = 'Romania' OR billing_city = 'Bucuresti'))
;


UPDATE ORDERS_00
SET shipping_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(shipping_city, 'î', 'i'), 'â', 'a'), 'ă', 'a'), 'ţ', 't'), 'ș', 's'),
	billing_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city, 'î', 'i'), 'â', 'a'), 'ă', 'a'), 'ţ', 't'), 'ș', 's')
WHERE (shipping_country_standardized = 'Romania'
OR billing_country_standardized = 'Romania')
;


/* IN_city_coding bekódoló alapján */
UPDATE ORDERS_00 AS m
INNER JOIN IN_city_coding AS e
ON (m.shipping_city = e.original_city AND m.shipping_country_standardized = e.original_country)
SET
    m.shipping_city = e.standardized_city,
    m.shipping_country_standardized = e.standardized_country
WHERE e.original_city IS NOT NULL
;

UPDATE ORDERS_00 AS m
INNER JOIN IN_city_coding AS e
ON (m.billing_city = e.original_city AND m.billing_country_standardized = e.original_country)
SET
    m.billing_city = e.standardized_city,
    m.billing_country_standardized = e.standardized_country
WHERE e.original_city IS NOT NULL
;

/*pár kivétel*/
UPDATE ORDERS_00 AS m
INNER JOIN IN_city_coding AS e
ON (m.shipping_city = e.original_city)
SET
    m.shipping_country_standardized = e.standardized_country
WHERE m.shipping_country_standardized IS NULL
;


/* B I L L I N G & S H I P P I N G   C I T Y   F I X I N G:    E N D  */




/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D   I M P U T I N G / F I X I N G:   B E G I N */


DROP TABLE IF EXISTS ORDERS_00_std;
CREATE TABLE IF NOT EXISTS ORDERS_00_std
SELECT DISTINCT
erp_id,
shipping_city,
shipping_country,
shipping_country_standardized,
billing_city,
billing_country,
billing_country_standardized,
shipping_address,
billing_address,
shipping_zip_code,
billing_zip_code,
shipping_city_standardized,
billing_city_standardized,
catchment_area,
shipping_method,
LENGTH(shipping_country) as shipping_country_length,
LENGTH(billing_country) as billing_country_length,
LENGTH(shipping_city) as shipping_city_length,
LENGTH(billing_city) as billing_city_length,
IF(shipping_country_standardized = 'Hungary',1,IF(ISNULL(shipping_country_standardized),1,0)) as hungary_shipping_flag,
IF(billing_country_standardized = 'Hungary',1,IF(ISNULL(billing_country_standardized),1,0)) as hungary_billing_flag,
IF(shipping_country_standardized = 'Romania',1,IF(ISNULL(shipping_country_standardized),1,0)) as romania_shipping_flag,
IF(billing_country_standardized = 'Romania',1,IF(ISNULL(billing_country_standardized),1,0)) as romania_billing_flag,

/*az egészségpénztári tagság külön mezőben való tárolása*/
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
			END as health_insurance,


/*az egészségpénztári tagság tisztítása a shipping_name és a billing_name mezőből*/

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
			)) as shipping_name_trim,
			
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
			)) as billing_name_trim,

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
			)) as shipping_name_trim_wo_pickup,

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
			)) as billing_name_trim_wo_pickup,

		CASE 
			WHEN LOWER(shipping_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|iroda' THEN 'business'
			WHEN LOWER(shipping_name) REGEXP '/tof|/ tof|ppp|/ pm|/pm|/pp|/ pp|sprinter|exon 2000| omv|omv |mol benzinkút|mol töltőállomás|nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN 'pickup'
			ELSE 'real'
		END as shipping_name_flg,

		CASE 
			WHEN LOWER(billing_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|iroda' THEN 'business'
			WHEN LOWER(billing_name) REGEXP '/tof|/ tof|ppp|/ pm|/pm|/pp|/ pp|sprinter|exon 2000| omv|omv |mol benzinkút|mol töltőállomás|nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN 'pickup'
			ELSE 'real'
		END as billing_name_flg,

		CASE
			WHEN LOWER(shipping_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN shipping_name_trim
			END as shipping_name_pickup,

		CASE
			WHEN LOWER(billing_name) REGEXP 'sprinter|exon 2000|omv|mol |nemzeti dohánybolt|relay|inmedio|inmedió|irodai átvétel|alulj' THEN billing_name_trim
			END as billing_name_pickup,
			
		CASE
			WHEN LOWER(shipping_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|egyesület|iroda' THEN shipping_name_trim
		END as shipping_name_business,
			
		CASE
			WHEN LOWER(billing_name) REGEXP 'bt.| bt |kft|zrt|nyrt|takarékszövetkezet|egyesület|iroda' THEN billing_name_trim
		END as billing_name_business,
		
		personal_name,
		pickup_name,
		business_name,
		personal_address,
		pickup_address,
		business_address,
		personal_zip_code,
		pickup_zip_code,
		business_zip_code,
		personal_city,
		pickup_city,
		business_city,
		personal_country,
		pickup_country,
		business_country,

        CASE
			when shipping_phone =  buyer_email then buyer_email	
			when buyer_email LIKE ('+3%') or buyer_email LIKE ('+4%') then buyer_email 
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

FROM ORDERS_00
;




ALTER TABLE ORDERS_00_std ADD PRIMARY KEY (`erp_id`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`shipping_city`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`shipping_country`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`shipping_country_standardized`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`billing_city`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`billing_country`) USING BTREE;
ALTER TABLE ORDERS_00_std ADD INDEX (`billing_country_standardized`) USING BTREE;




/*a város külföldi, viszont országnak Magyarország van beírva*/
UPDATE ORDERS_00 AS a
INNER JOIN
(
SELECT m.erp_id, m.shipping_country_standardized, m.shipping_city, e.Country
FROM 
(
SELECT erp_id, shipping_city, shipping_country_standardized
FROM ORDERS_00_std
WHERE shipping_city_length > 6
AND hungary_shipping_flag = 1
) m
 INNER JOIN IN_eu_cities AS e
ON  m.shipping_city = e.City
WHERE  m.shipping_country_standardized <> e.Country
) b
ON a.erp_id = b.erp_id
SET
    a.shipping_country_standardized = b.Country
;


UPDATE ORDERS_00 AS a
INNER JOIN
(
SELECT m.erp_id, m.billing_country_standardized, m.billing_city, e.Country
FROM 
(
SELECT erp_id, billing_city, billing_country_standardized
FROM ORDERS_00_std
WHERE billing_city_length > 6
AND hungary_billing_flag = 1
) m
 INNER JOIN IN_eu_cities AS e
ON  m.billing_city = e.City
WHERE  m.billing_country_standardized <> e.Country
) b
ON a.erp_id = b.erp_id
SET
    a.billing_country_standardized = b.Country
;


/*a város magyar, viszont országnak Románia van beírva*/
UPDATE ORDERS_00 AS a
INNER JOIN
(
SELECT m.erp_id, m.shipping_country_standardized, m.shipping_city, e.Country
FROM 
(
SELECT erp_id, shipping_city, shipping_country_standardized
FROM ORDERS_00_std
WHERE shipping_city_length > 6
AND romania_shipping_flag = 1
) m
 INNER JOIN IN_eu_cities AS e
ON  m.shipping_city = e.City
WHERE  m.shipping_country_standardized <> e.Country
) b
ON a.erp_id = b.erp_id
SET
    a.shipping_country_standardized = b.Country
;


UPDATE ORDERS_00 AS a
INNER JOIN
(
SELECT m.erp_id, m.billing_country_standardized, m.billing_city, e.Country
FROM 
(
SELECT erp_id, billing_city, billing_country_standardized
FROM ORDERS_00_std
WHERE billing_city_length > 6
AND romania_billing_flag = 1
) m
 INNER JOIN IN_eu_cities AS e
ON  m.billing_city = e.City
WHERE  m.billing_country_standardized <> e.Country
) b
ON a.erp_id = b.erp_id
SET
    a.billing_country_standardized = b.Country
;



UPDATE ORDERS_00 AS a
INNER JOIN
(
SELECT m.erp_id, m.billing_country_standardized, m.billing_city, e.Country
FROM 
(
SELECT erp_id, billing_city, billing_country_standardized
FROM ORDERS_00_std
WHERE billing_city_length > 6
AND (hungary_billing_flag = 1 or romania_billing_flag = 1)
) m
 INNER JOIN IN_eu_cities AS e
ON  m.billing_city = e.City
WHERE  m.billing_country_standardized <> e.Country
) b
ON a.erp_id = b.erp_id
SET
    a.billing_country_standardized = b.Country
;




/* B I L L I N G & S H I P P I N G   C O U N T R Y   S T A N D A R D I Z E D   I M P U T I N G / F I X I N G:   E N D */




/* U S E R   T Y P E:   B E G I N */

/* ezt a 06_aggr_user_ini-be kellene rakni talán, ha NINCS FÜGGŐSÉG (fel van-e használva a 05 létrejötte előtt?)*/


DROP TABLE IF EXISTS ORDERS_00u;
CREATE TABLE IF NOT EXISTS ORDERS_00u
SELECT m.erp_id,
			MAX(CASE 		WHEN s.user_type = 'B2B2C Optician' THEN 'B2B2C Optician'
							WHEN s.user_type = 'B2B2C Pharmacist' THEN 'B2B2C Pharmacist'
							WHEN s.user_type = 'B2B2B2C Wholesaler' THEN 'B2B2B2C Wholesaler'							
							WHEN s.user_type = 'B2B2C' THEN 'B2B2C'
							WHEN s.user_type = 'B2C' THEN 'B2C'
							WHEN s.user_type = 'B2B' THEN 'B2B'
							WHEN s.user_type IS NULL THEN 'B2C'
							ELSE s.user_type
			END) AS user_type
FROM ORDERS_00 m 
LEFT JOIN IN_user_type s
ON m.related_email = s.email 
GROUP BY m.erp_id
;

ALTER TABLE ORDERS_00u ADD PRIMARY KEY (`erp_id`) USING BTREE;


UPDATE ORDERS_00 AS m
LEFT JOIN ORDERS_00u s
ON m.erp_id = s.erp_id 
SET m.user_type = s.user_type
WHERE s.user_type <> 'B2C'
;



/* U S E R   T Y P E:   E N D */



/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   B E G I N */


/* 1. tökéletes ország és város egyezés */

UPDATE ORDERS_00_std AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_city = e.City AND m.shipping_country_standardized = e.Country)
SET    m.shipping_city_standardized = e.AccentCity
WHERE e.Country IS NOT NULL
;


UPDATE ORDERS_00_std AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_city = e.City AND m.billing_country_standardized = e.Country)
SET m.billing_city_standardized = e.AccentCity
WHERE e.Country IS NOT NULL
;



DROP TABLE IF EXISTS shipping_city_nonmatch;
CREATE TABLE IF NOT EXISTS shipping_city_nonmatch
SELECT DISTINCT
		m.shipping_city_standardized, 
		m.shipping_country_standardized, 
		m.shipping_city,
		m.shipping_zip_code
FROM ORDERS_00_std AS m
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
FROM ORDERS_00_std AS m
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
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE LENGTH(e.City) > 7
AND SUBSTR(e.zip_code,1,1) = SUBSTR(m.shipping_zip_code,1,1)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.shipping_city_standardized <> e.AccentCity
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE LENGTH(e.City) > 7
AND SUBSTR(e.zip_code,1,1) = SUBSTR(m.billing_zip_code,1,1)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.billing_city_standardized <> e.AccentCity;



/* a megtalált városneveket update-eljük az ORDERS_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;



/* 
3. tökéletes ország egyezés, utána a megadott város benne van a városlistában: Nyiregy -> Nyíregyháza
*/

UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND e.City LIKE CONCAT('%',m.shipping_city,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE LENGTH(m.shipping_city) > 5
AND SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.shipping_city <> 'England'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND e.City LIKE CONCAT('%',m.billing_city,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE LENGTH(m.billing_city) > 5
AND SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
AND m.billing_city <> 'England'
;


/* a megtalált városneveket update-eljük az ORDERS_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

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

/* a megtalált városneveket update-eljük az ORDERS_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;



/*
4. egy-két betűs eltérés: Debrcen -> Debrecen
*/
UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND SOUNDEX(m.shipping_city) LIKE SOUNDEX(e.City))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND SOUNDEX(m.billing_city) LIKE SOUNDEX(e.City))
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

/* a megtalált városneveket update-eljük az ORDERS_00 alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;




/*
5. városnév kiigazítás zip_code egyezés alapján
*/
UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,4) = SUBSTR(m.shipping_zip_code,1,4)
AND LENGTH(m.shipping_zip_code) = 4
AND m.shipping_country_standardized = 'Hungary'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,4) = SUBSTR(m.billing_zip_code,1,4)
AND LENGTH(m.billing_zip_code) = 4
AND m.billing_country_standardized = 'Hungary'
;


UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE m.shipping_zip_code LIKE CONCAT(e.zip_code,'%')
AND m.shipping_country_standardized = 'United Kingdom'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE m.billing_zip_code LIKE CONCAT(e.zip_code,'%')
AND m.billing_country_standardized = 'United Kingdom'
;


UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Italy'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Italy'
;

UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Spain'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Spain'
;


UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country)
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.shipping_zip_code,1,5)
AND LENGTH(m.shipping_zip_code) = 5
AND m.shipping_country_standardized = 'Romania'
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country)
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,5) = SUBSTR(m.billing_zip_code,1,5)
AND LENGTH(m.billing_zip_code) = 5
AND m.billing_country_standardized = 'Romania'
;


/* a megtalált városneveket update-eljük az ORDERS_00_std alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;




/* 
6. tökéletes ország egyezés, utána a megadott városban benne van a városlista egyik eleme, de most már városnév hossz megkötés nélkül 
*/

UPDATE shipping_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.shipping_zip_code,1,2)
AND m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE SUBSTR(e.zip_code,1,2) = SUBSTR(m.billing_zip_code,1,2)
AND m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;


/* a megtalált városneveket update-eljük az ORDERS_00_std alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

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
INNER JOIN IN_eu_cities AS e
ON (m.shipping_country_standardized = e.Country AND m.shipping_city LIKE CONCAT('%',e.City,'%'))
SET
    m.shipping_city_standardized = e.AccentCity
WHERE m.shipping_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

UPDATE billing_city_nonmatch AS m
INNER JOIN IN_eu_cities AS e
ON (m.billing_country_standardized = e.Country AND m.billing_city LIKE CONCAT('%',e.City,'%'))
SET
    m.billing_city_standardized = e.AccentCity
WHERE m.billing_country_standardized IN ('Hungary', 'United Kingdom', 'Italy', 'Spain', 'Romania')
;

/* a megtalált városneveket update-eljük az ORDERS_00_std alaptáblában */
CALL CityUpdate('shipping_city_nonmatch', 'ORDERS_00_std', 'shipping');
CALL CityUpdate('billing_city_nonmatch', 'ORDERS_00_std', 'billing');

/* a már update-elt városnevek törlése a  hibalistából */
DELETE FROM shipping_city_nonmatch WHERE shipping_city_standardized IS NOT NULL;
DELETE FROM billing_city_nonmatch WHERE billing_city_standardized IS NOT NULL
;


/* B I L L I N G & S H I P P I N G   C I T Y   S T A N D A R D I Z E D:   E N D */





/* R E A L   &   P I C K U P   I N F O   M O D U L E:   B E G I N */



UPDATE ORDERS_00_std AS u
SET
    u.personal_name = 
	CASE
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'real' AND LOCATE(billing_name_trim, shipping_name_trim) > 0 AND LENGTH(billing_name_trim) > 3 THEN billing_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'real' THEN shipping_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'pickup' THEN shipping_name_trim
		WHEN shipping_name_flg = 'real' AND billing_name_flg = 'business' THEN shipping_name_trim
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'real' THEN billing_name_trim
		WHEN shipping_name_flg = 'pickup' AND billing_name_flg = 'pickup' THEN shipping_name_trim_wo_pickup
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



    u.personal_address =
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



    u.personal_zip_code =
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



    u.personal_city =
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



    u.personal_country =
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




ALTER TABLE ORDERS_00_std ADD unified_zip_code VARCHAR(10);
ALTER TABLE ORDERS_00_std ADD index (`unified_zip_code`) USING BTREE;

UPDATE ORDERS_00_std AS u
SET
    u.unified_zip_code = COALESCE(u.pickup_zip_code,COALESCE(u.personal_zip_code, u.business_zip_code)) 
;


UPDATE ORDERS_00_std AS u
LEFT JOIN IN_postcodes i
ON u.unified_zip_code = i.postcode
SET
    u.personal_name = COALESCE(CAP_FIRST(u.personal_name),COALESCE(CAP_FIRST(u.business_name), CAP_FIRST(u.pickup_name))),
    u.personal_address = COALESCE(u.personal_address,COALESCE(u.business_address, u.pickup_address)),
    u.personal_zip_code = COALESCE(u.personal_zip_code,COALESCE(u.business_zip_code, u.pickup_zip_code)),
    u.personal_city = special_char_replace(COALESCE(u.personal_city,COALESCE(u.business_city, u.pickup_city))),
    u.personal_country = COALESCE(u.personal_country,COALESCE(u.business_country, u.pickup_country)),	
    u.pickup_name = COALESCE(CAP_FIRST(u.pickup_name), CAP_FIRST(u.personal_name)),
    u.pickup_address = CASE WHEN u.shipping_method = 'Pickup in person' THEN 'Terez krt 50.' ELSE COALESCE(u.pickup_address, u.personal_address) END,
    u.pickup_zip_code = CASE WHEN u.shipping_method = 'Pickup in person' THEN '1067' ELSE COALESCE(u.pickup_zip_code, u.personal_zip_code) END,
	u.pickup_city = special_char_replace(COALESCE(u.pickup_city,COALESCE(u.personal_city, u.business_city))),
    u.pickup_country = CASE WHEN u.shipping_method = 'Pickup in person' THEN 'Hungary' ELSE COALESCE(u.pickup_country, u.personal_country) END,
	u.business_name = COALESCE(CAP_FIRST(u.business_name), CAP_FIRST(u.personal_name)),
	u.business_address = COALESCE(u.business_address, u.personal_address),
	u.business_zip_code = COALESCE(u.business_zip_code, u.personal_zip_code),
	u.business_city = special_char_replace(COALESCE(u.business_city, u.personal_city)),
    u.business_country = COALESCE(u.business_country, u.personal_country),
	u.catchment_area = 	CASE 
							WHEN u.shipping_method = 'Pickup in person' OR i.region IN ('Budapest', 'Pest') OR u.shipping_city_standardized IN ('Budapest') THEN 'Budapest, Terez krt 41.'
							WHEN i.country = 'HU' AND i.region NOT IN ('Budapest', 'Pest') THEN 'Other HU'
							WHEN u.shipping_country_standardized <> 'Hungary' THEN 'Other Intl'
							ELSE 'missing'
						END
;



UPDATE ORDERS_00 AS m
        INNER JOIN
    ORDERS_00_std AS s ON m.erp_id = s.erp_id
SET
    m.personal_name = s.personal_name,
    m.personal_address = s.personal_address,
    m.personal_zip_code = s.personal_zip_code,
    m.personal_city = s.personal_city,
    m.personal_country = s.personal_country,
    m.pickup_name = s.pickup_name,
    m.pickup_address = s.pickup_address,
    m.pickup_zip_code = s.pickup_zip_code,
    m.pickup_city = s.pickup_city,
    m.pickup_country = s.pickup_country,
    m.business_name = s.business_name,
    m.business_address = s.business_address,
    m.business_zip_code = s.business_zip_code,
    m.business_city = s.business_city,
    m.business_country = s.business_country,
    m.catchment_area = s.catchment_area,
	m.shipping_phone_clean = s.shipping_phone_clean
WHERE new_entry = 1 /*csak az uj sorokat update-eljük*/	
;



/* R E A L   &   P I C K U P   I N F O   M O D U L E:   E N D */





/* P R O V I N C E  &  C I T Y_S I Z E:   B E G I N */

UPDATE ORDERS_00 AS m
        INNER JOIN IN_eu_cities AS s 
	ON (m.personal_city = s.City AND m.personal_country = s.Country)
SET
    m.personal_city_size = s.Population,
    m.personal_province = s.region
;


UPDATE ORDERS_00 AS m
        INNER JOIN IN_eu_cities AS s 
	ON (m.pickup_city = s.City AND m.pickup_country = s.Country)
SET
    m.pickup_city_size = s.Population,
    m.pickup_province = s.region
;


UPDATE ORDERS_00 AS m
        INNER JOIN IN_eu_cities AS s 
	ON (m.business_city = s.City AND m.business_country = s.Country)
SET
    m.business_city_size = s.Population,
    m.business_province = s.region
;

/* P R O V I N C E  &  C I T Y_S I Z E:   E N D */



UPDATE ORDERS_00 AS m
INNER JOIN IN_city_agglomeration AS s 
ON m.pickup_city = s.city
SET m.pickup_location_catchment_area = s.agglomeration
;

UPDATE ORDERS_00 AS m
INNER JOIN IN_city_agglomeration AS s 
ON m.personal_city = s.city
SET m.personal_location_catchment_area = s.agglomeration
;
