ALTER TABLE affiliate_forrasok CHANGE `orderid` `orderid` INT(10) NOT NULL;


DROP TABLE IF EXISTS BASE_05eo_TABLE;
CREATE TABLE BASE_05eo_TABLE
SELECT sql_id, erp_id, origin, SUBSTR(reference_id,LOCATE('EO', reference_id)+2,8) AS new_reference_id 
FROM BASE_05d_TABLE 
WHERE (reference_id LIKE '%EO%' AND reference_id NOT LIKE '%EO/%')
;

ALTER TABLE BASE_05eo_TABLE ADD INDEX(`sql_id`);
ALTER TABLE BASE_05eo_TABLE ADD INDEX `new_reference_id` (`new_reference_id`) USING BTREE;
ALTER TABLE BASE_05eo_TABLE CHANGE `new_reference_id` `new_reference_id` INT(10) NULL DEFAULT NULL;


DROP TABLE IF EXISTS BASE_05m_TABLE;
CREATE TABLE BASE_05m_TABLE
SELECT b.*, e.source, e.medium, e.campaign, e.prime_channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b LEFT JOIN 
(
SELECT a.*, m.prime_channel AS prime_channel
FROM affiliate_forrasok AS a
LEFT JOIN IN_marketing_channels m
ON CONCAT(a.source,' / ', a.medium) = m.source_medium
GROUP BY orderid
ORDER BY datum DESC
)
 AS e
ON b.new_reference_id = e.orderid
LIMIT 0;

INSERT INTO BASE_05m_TABLE
SELECT b.*, e.source, e.medium, e.campaign, e.prime_channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b LEFT JOIN 
(
SELECT a.*, m.prime_channel AS prime_channel
FROM affiliate_forrasok AS a
LEFT JOIN IN_marketing_channels m
ON CONCAT(a.source,' / ', a.medium) = m.source_medium
GROUP BY orderid
ORDER BY datum DESC
)
 AS e
ON b.new_reference_id = e.orderid
;

ALTER TABLE BASE_05m_TABLE ADD INDEX (`sql_id`);
ALTER TABLE BASE_05m_TABLE ADD INDEX (`origin`);

DROP TABLE IF EXISTS BASE_06_TABLE;
CREATE TABLE BASE_06_TABLE
SELECT DISTINCT b.*, e.source, e.medium, e.campaign, e.trx_marketing_channel
FROM BASE_05d_TABLE AS b LEFT JOIN BASE_05m_TABLE AS e
ON (b.sql_id = e.sql_id AND b.origin = e.origin)
;

ALTER TABLE BASE_06_TABLE ADD PRIMARY KEY (`id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;
ALTER TABLE BASE_06_TABLE ADD INDEX `origin` (`origin`) USING BTREE;
