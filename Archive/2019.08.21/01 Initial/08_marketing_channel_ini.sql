ALTER TABLE affiliate_sources CHANGE `orderid` `orderid` INT(10) NOT NULL;


DROP TABLE IF EXISTS BASE_05m_TABLE;
CREATE TABLE BASE_05m_TABLE
SELECT 	DISTINCT
		b.*,
		e.source,
		e.medium,
		e.campaign,
		CASE 	WHEN e.prime_channel IS NULL AND b.related_webshop = 'eOptika.hu' AND substr(b.reference_id,1,2) = 'VO' THEN 'Customer Service'
				WHEN e.prime_channel IS NULL AND b.related_webshop NOT IN ('eOptika.hu', '') THEN 'Site not measured'	
				WHEN e.prime_channel = 'Unidentified' AND LENGTH(coupon_code) > 2 THEN 'Coupon order'
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

ALTER TABLE BASE_05m_TABLE ADD INDEX (`erp_invoice_id`);
ALTER TABLE BASE_05m_TABLE ADD INDEX (`origin`);
ALTER TABLE BASE_03_TABLE ADD INDEX (`origin`);


UPDATE
BASE_03_TABLE AS b
LEFT JOIN BASE_05m_TABLE AS e
ON (b.erp_invoice_id = e.erp_invoice_id AND b.origin = e.origin)
SET
--b.cohort_id = e.cohort_id,
--b.first_purchase = e.first_purchase,
--b.last_purchase = e.last_purchase,
--b.contact_lens_last_purchase = e.contact_lens_last_purchase,
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
--b.user_cum_transactions = e.user_cum_transactions,
--b.user_cum_gross_revenue_in_base_currency = e.user_cum_gross_revenue_in_base_currency,
--b.repeat_buyer = e.repeat_buyer,
b.source = e.source,
b.medium = e.medium,
b.campaign = e.campaign,
b.trx_marketing_channel = e.trx_marketing_channel,
--b.contact_lens_user = e.contact_lens_user,
--b.solution_user = e.solution_user,
--b.eye_drops_user = e.eye_drops_user,
--b.sunglass_user = e.sunglass_user,
--b.vitamin_user = e.vitamin_user,
--b.frames_user = e.frames_user,
--b.spectacles_user = e.spectacles_user,
--b.other_product_user = e.other_product_user,
--b.user_active_flg = 
(CASE  
	WHEN e.user_active_flg = 0  THEN 'inactive' 
	WHEN e.user_active_flg = 1  THEN 'active' 
	WHEN e.user_active_flg = 2  THEN 'buy_me_once'
END)
;