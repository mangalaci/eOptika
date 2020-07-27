DROP TABLE IF EXISTS IN_affiliate_forrasok_02;
CREATE TABLE IN_affiliate_forrasok_02
SELECT DISTINCT b.*, e.user_id
FROM IN_affiliate_forrasok AS b LEFT JOIN 
(
SELECT DISTINCT related_email_clean, user_id
FROM BASE_05_TABLE
WHERE LENGTH(related_email_clean) > 3
) AS e
ON e.related_email_clean = b.email;
;

ALTER TABLE IN_affiliate_forrasok_02 ADD INDEX `user_id` (`user_id`) USING BTREE;

/*Levi-féle code table importálása*/
DROP TABLE IF EXISTS IN_affiliate_forrasok_03;
CREATE TABLE IN_affiliate_forrasok_03
SELECT DISTINCT b.*, e.KPI_marketing_prime_channels
FROM IN_affiliate_forrasok_02 AS b LEFT JOIN 
IN_KPI_marketing_prime_channels AS e
ON e.source_medium = CONCAT(b.source, ' / ', b.medium);
;

ALTER TABLE IN_affiliate_forrasok_03 ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE IN_affiliate_forrasok_03 ADD INDEX `orderid` (`orderid`) USING BTREE;


/*Levi-féle prime channels importálása*/


ALTER TABLE IN_prime_channels CHANGE `orderid` `orderid` INT(10) NOT NULL;


DROP TABLE IF EXISTS BASE_05eo_TABLE;
CREATE TABLE BASE_05eo_TABLE
SELECT sql_id, erp_id, SUBSTR(reference_id,LOCATE('EO', reference_id)+2,8) AS new_reference_id 
FROM BASE_05_TABLE 
WHERE (reference_id LIKE '%EO%' AND reference_id NOT LIKE '%EO/%')
AND origin = 'invoices'
;

ALTER TABLE BASE_05eo_TABLE ADD INDEX(`sql_id`);
ALTER TABLE BASE_05eo_TABLE ADD INDEX `new_reference_id` (`new_reference_id`) USING BTREE;
ALTER TABLE BASE_05eo_TABLE CHANGE `new_reference_id` `new_reference_id` INT(10) NULL DEFAULT NULL;

DROP TABLE IF EXISTS BASE_05m_TABLE;
CREATE TABLE BASE_05m_TABLE
SELECT b.*, channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b LEFT JOIN IN_prime_channels AS e
ON b.new_reference_id = e.orderid
LIMIT 0;

INSERT INTO BASE_05m_TABLE
SELECT b.*, channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b LEFT JOIN IN_prime_channels AS e
ON b.new_reference_id = e.orderid
;

ALTER TABLE BASE_05m_TABLE ADD INDEX (`sql_id`);

DROP TABLE IF EXISTS BASE_06_TABLE;
CREATE TABLE BASE_06_TABLE
SELECT b.*, e.trx_marketing_channel
FROM BASE_05_TABLE AS b LEFT JOIN BASE_05m_TABLE AS e
ON b.sql_id = e.sql_id
;

ALTER TABLE BASE_06_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;