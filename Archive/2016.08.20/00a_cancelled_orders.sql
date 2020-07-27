DROP TABLE IF EXISTS CANCELLED_ORDERS_00a;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00a LIKE incoming_orders;
ALTER TABLE `CANCELLED_ORDERS_00a` ADD `related_email_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00a` ADD `shipping_name_trim` VARCHAR(255) NOT NULL;
ALTER TABLE `CANCELLED_ORDERS_00a` ADD `user_type` VARCHAR(17) NOT NULL;

INSERT INTO CANCELLED_ORDERS_00a
SELECT DISTINCT
		 i.*,
			TRIM(REPLACE(REPLACE((case
				 WHEN related_email  LIKE '%freeemail.hu' THEN REPLACE(related_email, 'freeemail.hu', 'freemail.hu')
				 WHEN related_email  LIKE '%gmai.com' THEN REPLACE(related_email, 'gmai.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmal.com' THEN REPLACE(related_email, 'gmal.com', 'gmail.com')				 
				 WHEN related_email  LIKE '%gamil.com' THEN REPLACE(related_email, 'gamil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gnail.com' THEN REPLACE(related_email, 'gnail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmaikl.com' THEN REPLACE(related_email, 'gmaikl.com', 'gmail.com')
				 WHEN related_email  LIKE '%mail.com' THEN REPLACE(related_email, 'g-mail.com', 'gmail.com')
				 WHEN related_email  LIKE '%g.mail.com' THEN REPLACE(related_email, 'g.mail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gail.com' THEN REPLACE(related_email, 'gail.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmsil.com' THEN REPLACE(related_email, 'gmsil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmali.com' THEN REPLACE(related_email, 'gmali.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmil.com' THEN REPLACE(related_email, 'gmil.com', 'gmail.com')
				 WHEN related_email  LIKE '%gmai.hu' THEN REPLACE(related_email, 'gmai.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmal.hu' THEN REPLACE(related_email, 'gmal.hu', 'gmail.hu')				 
				 WHEN related_email  LIKE '%gamil.hu' THEN REPLACE(related_email, 'gamil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gnail.hu' THEN REPLACE(related_email, 'gnail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmaikl.hu' THEN REPLACE(related_email, 'gmaikl.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%mail.hu' THEN REPLACE(related_email, 'g-mail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%g.mail.hu' THEN REPLACE(related_email, 'g.mail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gail.hu' THEN REPLACE(related_email, 'gail.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmsil.hu' THEN REPLACE(related_email, 'gmsil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmali.hu' THEN REPLACE(related_email, 'gmali.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%gmil.hu' THEN REPLACE(related_email, 'gmil.hu', 'gmail.hu')
				 WHEN related_email  LIKE '%cirtomail.com' THEN REPLACE(related_email, 'cirtomail.com', 'citromail.com')
				 WHEN related_email  LIKE '%undefined' THEN REPLACE(related_email, 'undefined', '')				 
				 ELSE related_email
			 END), '  ', ' '), ',hu', '.hu')) as related_email_clean,
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
			,'DANuBIUS EGÉSZSÉGPÉNZTÁR','')				
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
			,' PP', '')
			,'/PP', '')
			,'UNDEFINED', '')
			,'0', '')
			,'1', '')
			,'2', '')
			,'3', '')
			,'4', '')
			,'5', '')
			,'6', '')
			,'7', '')
			,'8', '')
			,'9', '')
			,'()', '')
			) AS shipping_name_trim,
			MAX(CASE 	WHEN u.user_type = 'Private insurance' THEN 'Private insurance'
							WHEN u.user_type = 'B2B2C' THEN 'B2B2C'
							WHEN u.user_type = 'B2C' THEN 'B2C'
							WHEN u.user_type = 'B2B' THEN 'B2B'
							WHEN u.user_type IS NULL THEN 'B2C'		
							ELSE u.user_type
				END) AS user_type
FROM  incoming_orders i 
LEFT JOIN IN_user_type u
ON (LOWER(i.billing_name) LIKE CONCAT('%', u.search_string, '%') OR LOWER(i.shipping_name) LIKE CONCAT('%', u.search_string, '%'))
WHERE deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
AND LOWER(deletion_comment) NOT LIKE '%dupl%'
AND LOWER(deletion_comment) NOT LIKE '%teszt%'
AND is_deleted = 'yes'
/*removing test user*/
AND related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing szállítási díjak*/
AND	item_SKU  NOT IN ('GLS', 'GPS', 'PP', 'PPP', 'SPRINTER', 'Sprinter', 'TOF', 'WEIGHT_CORRECTION', 'szallitas', 'Személyes átvétel')
/*removing Előleg records*/
AND item_type = 'T'
AND item_SKU <> 'MCO' /*removing marketing campaigns*/
GROUP BY sql_id
ORDER BY created DESC
;

ALTER TABLE CANCELLED_ORDERS_00a ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00a ADD INDEX `shipping_name_trim` (`shipping_name_trim`) USING BTREE;
ALTER TABLE CANCELLED_ORDERS_00a ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;