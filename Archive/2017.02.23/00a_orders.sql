DROP TABLE IF EXISTS ORDERS_00a1;
CREATE TABLE IF NOT EXISTS ORDERS_00a1 LIKE incoming_orders;
ALTER TABLE `ORDERS_00a1` ADD `related_email_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00a1` ADD `shipping_name_trim` VARCHAR(255) NOT NULL;
ALTER TABLE `ORDERS_00a1` ADD `user_type` VARCHAR(17) NOT NULL;

INSERT INTO ORDERS_00a1
SELECT DISTINCT
		 i.*,
			TRIM(REPLACE(REPLACE((CASE
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
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')				
			,'PROVITA EGÉSZSÉGPÉNZTÁR','')	
			,'TICKET WELLNESS EGÉSZSÉGPÉNZTÁR','')				
			,'K&H MEDICINA EGÉSZSÉGPÉNZTÁR','')
			,'K&H MEDICINA EP.','')
			,'K&H','')	
			,'DIMENZIÓ EGÉSZSÉGPÉNZTÁR','')
			,'DIMENZIO EGÉSZSÉGPÉNZTÁR','')
			,'DANUBIUS EGÉSZSÉGPÉNZTÁR','')				
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
			,' / ', ' /')			
			,'UNDEFINED', '')
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
AND is_deleted = 'Yes'
AND LOWER(deletion_comment) NOT LIKE '%dupl%'
AND LOWER(deletion_comment) NOT LIKE '%teszt%'
/*removing test user*/
AND related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
/*removing NON-CORE: szállítási díjak, marketing campaigns*/
AND	item_SKU NOT IN ('GHW', 'GLS_COD', 'MCO', 'GROWWW', 'GLS', 'GPS', 'PP', 'PPP', 'SPRINTER', 'Sprinter', 'TOF', 'WEIGHT_CORRECTION', 'szallitas', 'ajandek', 'Személyes átvétel', 'FP', 'FPE')
/*removing Előleg records*/
AND item_type = 'T'
GROUP BY sql_id
ORDER BY created DESC
;

ALTER TABLE ORDERS_00a1 ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `shipping_name_trim` (`shipping_name_trim`) USING BTREE;
ALTER TABLE ORDERS_00a1 ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;


DROP TABLE IF EXISTS ORDERS_00a2;
CREATE TABLE IF NOT EXISTS ORDERS_00a2 LIKE ORDERS_00a1;

INSERT INTO ORDERS_00a2
SELECT r.*
FROM ORDERS_00a1 r
LEFT JOIN TIME_ORDER_TO_DISPATCH_PICKUP sz
ON sz.r_erp_id = r.erp_id
WHERE sz.r_erp_id IS NULL
;


DROP TABLE IF EXISTS ORDERS_00a3;
CREATE TABLE IF NOT EXISTS ORDERS_00a3 LIKE ORDERS_00a2;

INSERT INTO ORDERS_00a3
SELECT r.*
FROM ORDERS_00a2 r
LEFT JOIN TIME_ORDER_TO_DISPATCH_CARRIER_03 sz
ON sz.r_erp_id = r.erp_id
WHERE sz.r_erp_id IS NULL
;