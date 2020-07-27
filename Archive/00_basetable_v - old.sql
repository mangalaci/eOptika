CREATE VIEW BASE_00_TABLE_v AS
SELECT
		 *,
		 
/*related_email @ utáni részének a tisztítása*/
			trim(replace(replace((case
				 when related_email  LIKE '%freeemail.hu' THEN REPLACE(related_email, 'freeemail.hu', 'freemail.hu')
				 when related_email  LIKE '%gmai.com' THEN REPLACE(related_email, 'gmai.com', 'gmail.com')
				 when related_email  LIKE '%gmil.com' THEN REPLACE(related_email, 'gmil.com', 'gmail.com')
				 when related_email  LIKE '%cirtomail.com' THEN REPLACE(related_email, 'cirtomail.com', 'citromail.com')
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu')) as related_email_clean,

/*név kinyerése shipping_name-ből*/
			TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(CASE
/*case 4: keep after 2nd slash*/	WHEN shipping_name_trim like '%/%/%' THEN SUBSTRING(shipping_name_trim, LOCATE('/', shipping_name_trim, LOCATE('/', shipping_name_trim) + 1) + 1) 
/*case 6: keep after 1st bracket*/	WHEN shipping_name_trim like '%/%(%/%)%' THEN SUBSTRING(shipping_name_trim, LOCATE('(', shipping_name_trim) + 1)
				 WHEN LOCATE('(omv)', LOWER(shipping_name))  > 0 THEN SUBSTRING(REPLACE(LOWER(shipping_name), 'omv', ''), LOCATE('(', REPLACE(LOWER(shipping_name), 'omv', '')) + 1) /*case 5: keep after 2nd bracket*/
				 WHEN shipping_name like '%/%(%/%)%' THEN SUBSTRING(billing_name, LOCATE('(', billing_name) + 1) /*case 6: keep after 1st bracket*/
				 WHEN LENGTH(shipping_name) - LENGTH(REPLACE(shipping_name, '/', ''))  > 1 THEN SUBSTRING(shipping_name, LOCATE('/', shipping_name, LOCATE('/', shipping_name) + 1) + 1) /*case 4: keep after 2nd slash*/
				 WHEN LOCATE('(', shipping_name)  > LOCATE('/', shipping_name) THEN SUBSTRING(shipping_name, LOCATE('(', shipping_name) + 1) /*case 3: keep after 1st bracket*/
				 WHEN LOCATE('(', shipping_name)  = 0 AND	LOCATE('/', shipping_name)  = 0 THEN shipping_name /*case 1: leave as is*/
				 ELSE SUBSTRING(shipping_name, LOCATE('(', shipping_name) + 1, LOCATE('/', shipping_name) -LOCATE('(', shipping_name) -1) /*case 2: keep before slash*/
			 END), '(', ''), '  ', ' '), '.', ''), ')', ''), ',', '')) AS shipping_name_clean,
			 
			CASE
				 WHEN lower(billing_name)  LIKE '%optika%' OR	lower(shipping_name)  LIKE '%optika%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%optik%' OR	lower(shipping_name)  LIKE '%optik%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%optic%' OR	lower(shipping_name)  LIKE '%optic%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%optica%' OR	lower(shipping_name)  LIKE '%optica%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%iris%' OR	lower(shipping_name)  LIKE '%iris%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%wellness%' OR	lower(shipping_name)  LIKE '%wellness%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%arnus bt%' OR	lower(shipping_name)  LIKE '%arnus bt%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%demeter imre%' OR	lower(shipping_name)  LIKE '%demeter imre%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%etele ernő%' OR	lower(shipping_name)  LIKE '%etele ernő%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%gajdóczy annamária%' OR	lower(shipping_name)  LIKE '%gajdóczy annamária%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%laurentes%' OR	lower(shipping_name)  LIKE '%laurentes%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%pályi zoltán%' OR	lower(shipping_name)  LIKE '%pályi zoltán%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%pro visus%' OR	lower(shipping_name)  LIKE '%pro visus%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%vidákovics enikő%' OR	lower(shipping_name)  LIKE '%vidákovics enikő%' THEN 'B2B2C'
				 WHEN lower(billing_name)  LIKE '%egészség%' OR	lower(shipping_name)  LIKE '%egészség%' THEN 'Egészségpénztár'
				 WHEN lower(billing_name)  LIKE '%kft%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%bt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%zrt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%nyrt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%kkt%' THEN 'B2B'
				 ELSE 'B2C'
			 END as user_type
FROM  `outgoing_bills`
WHERE	 lower(is_canceled)  in ('no', 'élő')
/*removing test user*/
 AND	item_SKU  NOT IN ( 'GLS'  , 'GPS'  , 'PP'  , 'PPP'  , 'SPRINTER'  , 'Sprinter'  , 'TOF'  , 'WEIGHT_CORRECTION'  , 'szallitas'  , 'Személyes átvétel'  )
 AND	related_email  NOT IN ('levente.fabian@gmail.com', 'levente.f@eoptika.hu', 'szabolcs@valner.com'  , 'szabolcs.valner@alumni.insead.edu'  , 'valner_sabie@yahoo.com'  , 'egyforintosaukcio@gmail.com'  , 'szabolcs@eoptika.hu'  , 'contact@digitalfactory.vc'  , 'info@lentecontatto.it'  , 'cristiano@eottica.it'  , 'kapcsolat@eoptika.hu'  , 'peter@eoptika.hu'  , 'mail@teszt.elek.hu'  , 'mail@elek.teszt.hu'  , 'elek@teszt.hu'  , 'teszt@elek.hu'  , 'lakospeter@gmail.com'  , 'administrator@eoptika.hu'  , 'kapcsolat@eoptika.hu'  , 'lpmorpheus@citromail.hu'  , 'lpmorpheus@gmail.com'  )
 AND	lower(billing_name)  NOT IN ( 'test_user'  , 'asasas'  , 'cristiano tozzi'  , 'eoptika kft'  , 'pálfi gábor - unas teszt'  , 'szabolcs valner'  , 'szeker zsolt'  , 'tamás tóth'  , 'test
test béla'  , 'test testina'  , 'test'  , 'teszt tamás'  , 'teszt unas'  , 'unas'  , 'zsolt teszt');


ALTER TABLE BASE_00_TABLE ADD PRIMARY KEY (`__ZDBID`) USING BTREE;
ALTER TABLE BASE_00_TABLE ADD UNIQUE `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_00_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;