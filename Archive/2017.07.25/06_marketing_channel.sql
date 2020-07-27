ALTER TABLE affiliate_sources CHANGE `orderid` `orderid` INT(10) NOT NULL;


ALTER TABLE order_invoice_dates ADD INDEX `related_webshop` (`related_webshop`) USING BTREE;
ALTER TABLE order_invoice_dates ADD INDEX `new_reference_id` (`new_reference_id`) USING BTREE;
ALTER TABLE order_invoice_dates CHANGE `new_reference_id` `new_reference_id` INT(10) NULL DEFAULT NULL;


DROP TABLE IF EXISTS BASE_05m_TABLE;
CREATE TABLE BASE_05m_TABLE
SELECT 	DISTINCT
		b.*,
		e.source,
		e.medium,
		e.campaign,
		CASE 	WHEN e.prime_channel IS NULL AND b.related_webshop = 'eOptika.hu' AND substr(b.reference_id,1,2) = 'VO' THEN 'Customer Service'
				WHEN e.prime_channel IS NULL AND b.related_webshop NOT IN ('eOptika.hu', '') THEN 'Site not measured'
				WHEN e.prime_channel = 'Unidentified' AND UPPER(b.related_comment) LIKE '%KUPONKÓD%' THEN 'Coupon order'
				WHEN e.prime_channel = 'Unidentified' AND g.transaction IS NOT NULL AND g.prime_channel IS NOT NULL THEN g.prime_channel
				ELSE e.prime_channel
		END AS trx_marketing_channel
FROM order_invoice_dates AS b
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
LEFT JOIN
(
SELECT a.*, m.prime_channel AS prime_channel
FROM GA_transactions AS a
LEFT JOIN IN_marketing_channels m
ON a.source_medium = m.source_medium
) AS g
ON b.new_reference_id = g.transaction
LIMIT 0;


INSERT INTO BASE_05m_TABLE
SELECT 	DISTINCT
		b.*,
		e.source,
		e.medium,
		e.campaign,
		CASE 	WHEN e.prime_channel IS NULL AND b.related_webshop = 'eOptika.hu' AND substr(b.reference_id,1,2) = 'VO' THEN 'Customer Service'
				WHEN e.prime_channel IS NULL AND b.related_webshop NOT IN ('eOptika.hu', '') THEN 'Site not measured'	
				WHEN e.prime_channel = 'Unidentified' AND UPPER(b.related_comment) LIKE '%KUPONKÓD%' THEN 'Coupon order'
				WHEN e.prime_channel = 'Unidentified' AND g.transaction IS NOT NULL AND g.prime_channel IS NOT NULL THEN g.prime_channel				
				ELSE e.prime_channel
		END AS trx_marketing_channel
FROM order_invoice_dates AS b
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
LEFT JOIN
(
SELECT a.*, m.prime_channel AS prime_channel
FROM GA_transactions AS a
LEFT JOIN IN_marketing_channels m
ON a.source_medium = m.source_medium
GROUP BY transaction
) AS g
ON b.new_reference_id = g.transaction
;

ALTER TABLE BASE_05m_TABLE ADD INDEX (`sql_id`);
ALTER TABLE BASE_05m_TABLE ADD INDEX (`origin`);


UPDATE
BASE_03_TABLE AS b
LEFT JOIN BASE_05m_TABLE AS e
ON (b.sql_id = e.sql_id AND b.origin = e.origin)
LEFT JOIN INVOICES_coupon_codes AS c
ON (b.erp_id = c.erp_id)
SET
b.cohort_id = e.cohort_id,
b.last_purchase = e.last_purchase,
b.contact_lens_last_purchase = e.contact_lens_last_purchase,
b.invoice_yearmonth = e.invoice_yearmonth,
b.invoice_year = e.invoice_year,
b.invoice_quarter = e.invoice_quarter,
b.invoice_month = e.invoice_month,
b.invoice_day_in_month = e.invoice_day_in_month,
b.invoice_hour = e.invoice_hour,
b.order_year = e.order_year,
b.order_quarter = e.order_quarter,
b.order_month = e.order_month,
b.order_day_in_month = e.order_day_in_month,
b.order_weekday = e.order_weekday,
b.order_week_in_month = e.order_week_in_month,
b.order_hour = e.order_hour,
b.cohort_month_since = e.cohort_month_since,
b.user_cum_transactions = e.user_cum_transactions,
b.user_cum_gross_revenue_in_base_currency = e.user_cum_gross_revenue_in_base_currency,
b.repeat_buyer = e.repeat_buyer,
b.coupon_code = c.coupon_code,
b.source = e.source,
b.medium = e.medium,
b.campaign = e.campaign,
b.trx_marketing_channel = e.trx_marketing_channel
;
