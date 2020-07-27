ALTER TABLE affiliate_sources CHANGE `orderid` `orderid` INT(10) NOT NULL;

/* a reference_id-k megtisztítása */
DROP TABLE IF EXISTS BASE_05eo_TABLE;
CREATE TABLE BASE_05eo_TABLE
SELECT 	sql_id,
		erp_id,
		origin,
		related_webshop,
		reference_id,
		CASE 	
			WHEN SUBSTR(reference_id,1,2) IN ('EO', 'IT', 'UK') THEN SUBSTR(reference_id,3,8)
		END AS new_reference_id
FROM BASE_05a_TABLE
;

/*
WHERE (reference_id LIKE '%EO%' AND reference_id NOT LIKE '%EO/%')

SELECT substr(reference_id,1,2) , count(*)
FROM `BASE_05eo_TABLE` 
WHERE related_webshop = 'eOptika.hu'
group by substr(reference_id,1,2)
order by 2 desc
*/


ALTER TABLE BASE_05eo_TABLE ADD INDEX(`sql_id`);
ALTER TABLE BASE_05eo_TABLE ADD INDEX `related_webshop` (`related_webshop`) USING BTREE;
ALTER TABLE BASE_05eo_TABLE ADD INDEX `new_reference_id` (`new_reference_id`) USING BTREE;
ALTER TABLE BASE_05eo_TABLE CHANGE `new_reference_id` `new_reference_id` INT(10) NULL DEFAULT NULL;


DROP TABLE IF EXISTS BASE_05m_TABLE;
CREATE TABLE BASE_05m_TABLE
SELECT 	b.*,
		e.source,
		e.medium,
		e.campaign,
		e.prime_channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b
LEFT JOIN
(
SELECT a.*, m.prime_channel AS prime_channel
FROM affiliate_sources AS a
LEFT JOIN IN_marketing_channels m
ON CONCAT(a.source,' / ', a.medium) = m.source_medium
GROUP BY orderid
ORDER BY processed DESC
) AS e
ON (b.new_reference_id = e.orderid AND LOWER(b.related_webshop) = e.webshop)
LIMIT 0;


INSERT INTO BASE_05m_TABLE
SELECT 	b.*,
		e.source,
		e.medium,
		e.campaign,
		e.prime_channel AS trx_marketing_channel
FROM BASE_05eo_TABLE AS b
LEFT JOIN
(
SELECT a.*, m.prime_channel AS prime_channel
FROM affiliate_sources AS a
LEFT JOIN IN_marketing_channels m
ON CONCAT(a.source,' / ', a.medium) = m.source_medium
GROUP BY orderid
ORDER BY processed DESC
) AS e
ON (b.new_reference_id = e.orderid AND b.related_webshop = e.webshop)
;

ALTER TABLE BASE_05m_TABLE ADD INDEX (`sql_id`);
ALTER TABLE BASE_05m_TABLE ADD INDEX (`origin`);

DROP TABLE IF EXISTS BASE_06_TABLE;
CREATE TABLE BASE_06_TABLE
SELECT DISTINCT b.*, e.source, e.medium, e.campaign, e.trx_marketing_channel
FROM BASE_05a_TABLE AS b LEFT JOIN BASE_05m_TABLE AS e
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
