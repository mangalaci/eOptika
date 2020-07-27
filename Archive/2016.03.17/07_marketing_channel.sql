DROP INDEX `email` ON IN_affiliate_forrasok;
ALTER TABLE IN_affiliate_forrasok ADD INDEX `email` (`email`) USING BTREE;

DROP TABLE IN_affiliate_forrasok_02;
CREATE TABLE IN_affiliate_forrasok_02
SELECT DISTINCT b.*, e.user_id
FROM IN_affiliate_forrasok AS b LEFT JOIN 
(
SELECT DISTINCT related_email_clean, user_id
FROM BASE_06_TABLE
WHERE length(related_email_clean) > 3
) AS e
ON e.related_email_clean = b.email;
;


ALTER TABLE IN_affiliate_forrasok_02 ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE IN_KPI_marketing_prime_channels ADD INDEX `source_medium` (`source_medium`) USING BTREE;

/*Levi-féle code table importálása*/
DROP TABLE IN_affiliate_forrasok_03;
CREATE TABLE IN_affiliate_forrasok_03
SELECT DISTINCT b.*, e.KPI_marketing_prime_channels
FROM IN_affiliate_forrasok_02 AS b LEFT JOIN 
IN_KPI_marketing_prime_channels AS e
ON e.source_medium = CONCAT(b.source, ' / ', b.medium);
;




ALTER TABLE IN_affiliate_forrasok_03 ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE IN_affiliate_forrasok_03 ADD INDEX `orderid` (`orderid`) USING BTREE;



/*Levi-féle prime channels importálása*/

ALTER TABLE IN_prime_channels ADD PRIMARY KEY (`orderid`) USING BTREE;



DROP TABLE BASE_07_TABLE;
CREATE TABLE BASE_07_TABLE
SELECT b.*, channel AS trx_marketing_channel
FROM BASE_06_TABLE AS b LEFT JOIN IN_prime_channels AS e
ON (substring(b.reference_id,3) = e.orderid AND substring(b.reference_id,1,2) = 'EO')
;


/*
DROP TABLE BASE_07_TABLE;
CREATE TABLE BASE_07_TABLE
SELECT b.*, 		 
		CASE WHEN elso = 0 THEN KPI_marketing_prime_channels END AS first_marketing_channel,
        CASE WHEN elso = 1 THEN KPI_marketing_prime_channels END AS trx_marketing_channel
FROM BASE_06_TABLE AS b LEFT JOIN (SELECT orderid, elso, MAX(KPI_marketing_prime_channels) AS KPI_marketing_prime_channels FROM IN_affiliate_forrasok_03 GROUP BY orderid) AS e
ON (substring(b.reference_id,3) = e.orderid AND substring(b.reference_id,1,2) = 'EO')
;
*/

ALTER TABLE BASE_07_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_07_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;