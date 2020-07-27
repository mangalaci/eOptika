DROP TABLE IF EXISTS BASE_00a_TABLE;
CREATE TABLE BASE_00a_TABLE
SELECT
		 *,
/*related_email @ utáni részének a tisztítása*/
			trim(replace(replace((case
				 when related_email  LIKE '%freeemail.hu' THEN REPLACE(related_email, 'freeemail.hu', 'freemail.hu')
				 
				 when related_email  LIKE '%gmai.com' THEN REPLACE(related_email, 'gmai.com', 'gmail.com')
				 when related_email  LIKE '%gmal.com' THEN REPLACE(related_email, 'gmal.com', 'gmail.com')				 
				 when related_email  LIKE '%gamil.com' THEN REPLACE(related_email, 'gamil.com', 'gmail.com')
				 when related_email  LIKE '%gnail.com' THEN REPLACE(related_email, 'gnail.com', 'gmail.com')
				 when related_email  LIKE '%gmaikl.com' THEN REPLACE(related_email, 'gmaikl.com', 'gmail.com')
				 when related_email  LIKE '%mail.com' THEN REPLACE(related_email, 'g-mail.com', 'gmail.com')
				 when related_email  LIKE '%g.mail.com' THEN REPLACE(related_email, 'g.mail.com', 'gmail.com')
				 when related_email  LIKE '%gail.com' THEN REPLACE(related_email, 'gail.com', 'gmail.com')
				 when related_email  LIKE '%gmsil.com' THEN REPLACE(related_email, 'gmsil.com', 'gmail.com')
				 when related_email  LIKE '%gmali.com' THEN REPLACE(related_email, 'gmali.com', 'gmail.com')
				 when related_email  LIKE '%gmil.com' THEN REPLACE(related_email, 'gmil.com', 'gmail.com')

				 when related_email  LIKE '%gmai.hu' THEN REPLACE(related_email, 'gmai.hu', 'gmail.hu')
				 when related_email  LIKE '%gmal.hu' THEN REPLACE(related_email, 'gmal.hu', 'gmail.hu')				 
				 when related_email  LIKE '%gamil.hu' THEN REPLACE(related_email, 'gamil.hu', 'gmail.hu')
				 when related_email  LIKE '%gnail.hu' THEN REPLACE(related_email, 'gnail.hu', 'gmail.hu')
				 when related_email  LIKE '%gmaikl.hu' THEN REPLACE(related_email, 'gmaikl.hu', 'gmail.hu')
				 when related_email  LIKE '%mail.hu' THEN REPLACE(related_email, 'g-mail.hu', 'gmail.hu')
				 when related_email  LIKE '%g.mail.hu' THEN REPLACE(related_email, 'g.mail.hu', 'gmail.hu')
				 when related_email  LIKE '%gail.hu' THEN REPLACE(related_email, 'gail.hu', 'gmail.hu')
				 when related_email  LIKE '%gmsil.hu' THEN REPLACE(related_email, 'gmsil.hu', 'gmail.hu')
				 when related_email  LIKE '%gmali.hu' THEN REPLACE(related_email, 'gmali.hu', 'gmail.hu')
				 when related_email  LIKE '%gmil.hu' THEN REPLACE(related_email, 'gmil.hu', 'gmail.hu')
				 
				 when related_email  LIKE '%cirtomail.com' THEN REPLACE(related_email, 'cirtomail.com', 'citromail.com')
				 
				 when related_email  LIKE '%undefined' THEN REPLACE(related_email, 'undefined', '')				 
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu')) as related_email_clean,

/*shipping_name előtisztítása*/
			TRIM(REPLACE
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
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')				
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')	
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')				
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'EXON 2000','')
			,'OMV','')
			,'MOL ','')
			,'NEMZETI DOHÁNYBOLT','')		
			,'MOL ','')
			,'OMW','')
			,'RELAY','')
			,'INMEDIO','')
			,'ALLEGROUP.HU KFT.','')
			,'OTP BANK NYRT','')
			,'/ PPP','')
			,'/PPP','')
			,'PPPP','')
			,'/ PM','')
			,'/EP','')
			,'/ TOF','')
			,'/ SPRINTER','')
			, 'PP', '')
			, 'UNDEFINED', '')			
			, '0', '')
			, '1', '')			
			, '2', '')			
			, '3', '')			
			, '4', '')			
			, '5', '')
			, '6', '')
			, '7', '')
			, '8', '')
			, '9', '')
			, '()', '')
			) AS shipping_name_trim,

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
				 WHEN lower(billing_name)  LIKE '%egészség%' OR	lower(shipping_name)  LIKE '%egészség%' THEN 'Private insurance'
				 WHEN lower(billing_name)  LIKE '%kft%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%bt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%zrt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%nyrt%' THEN 'B2B'
				 WHEN lower(billing_name)  LIKE '%kkt%' THEN 'B2B'
				 ELSE 'B2C'
			 END AS user_type
FROM  `outgoing_bills`
WHERE	 lower(is_canceled) in ('no', 'élő')
/*removing test user*/
 AND	item_SKU  NOT IN ( 'GLS'  , 'GPS'  , 'PP'  , 'PPP'  , 'SPRINTER'  , 'Sprinter'  , 'TOF'  , 'WEIGHT_CORRECTION'  , 'szallitas'  , 'Személyes átvétel'  )
 AND	related_email NOT IN ('cristianotozzi@gmail.com', 'baross@tobias.hu', 'kontaktlencserendeles@tobias.hu', 'richard@tobias.hu', 'levente.fabian@gmail.com', 'levente.f@eoptika.hu', 'szabolcs@valner.com'  , 'szabolcs.valner@alumni.insead.edu'  , 'valner_sabie@yahoo.com'  , 'egyforintosaukcio@gmail.com'  , 'szabolcs@eoptika.hu'  , 'contact@digitalfactory.vc'  , 'info@lentecontatto.it'  , 'cristiano@eottica.it'  , 'kapcsolat@eoptika.hu'  , 'peter@eoptika.hu'  , 'mail@teszt.elek.hu'  , 'mail@elek.teszt.hu'  , 'elek@teszt.hu'  , 'teszt@elek.hu'  , 'lakospeter@gmail.com'  , 'administrator@eoptika.hu'  , 'kapcsolat@eoptika.hu' , 'zsolt.eder@eoptika.hu', 'lpmorpheus@citromail.hu'  , 'lpmorpheus@gmail.com')
 AND	lower(billing_name)  NOT IN ('tóbiás optik kft.', 'test_user'  , 'asasas', 'cristiano tozzi', 'eoptika kft'  , 'pálfi gábor - unas teszt'  , 'szabolcs valner'  , 'szeker zsolt'  , 'tamás tóth'  , 'test
test béla', 'test testina', 'test', 'teszt tamás', 'teszt unas', 'unas', 'zsolt teszt')
/*removing Előleg records*/
AND item_name_eng NOT IN ('Előleg')
;


ALTER TABLE BASE_00a_TABLE
  DROP COLUMN related_department,
  DROP COLUMN related_customer_group,
  DROP COLUMN lot_number,
  DROP COLUMN unknown,
  DROP COLUMN packaging_weight_in_kg,
  DROP COLUMN item_group_name,
  DROP COLUMN item_net_registered_price_in_base_currency,
  DROP COLUMN item_net_clearing_price_in_base_currency
;

ALTER TABLE BASE_00a_TABLE CHANGE `related_email_clean` `related_email_clean` VARCHAR(255);  
  
  
  
ALTER TABLE BASE_00a_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00a_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00a_TABLE ADD INDEX `shipping_name_trim` (`shipping_name_trim`) USING BTREE;
ALTER TABLE BASE_00a_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;