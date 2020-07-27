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


DROP TABLE BASE_07a_TABLE;
CREATE TABLE BASE_07a_TABLE
SELECT b.*, 		 
		CASE WHEN medium = 'newsletter' THEN 'Email newsletter'
			  WHEN medium = 'email' THEN 'Email reminder'
			  WHEN medium = 'alairas' THEN 'Other email'
			  WHEN medium = 'level' THEN 'Other email'
			  WHEN medium = 'mail' THEN 'Other email'
			  WHEN medium = 'affiliate_CT' THEN 'Affiliate marketing'
			  WHEN medium = 'banner' THEN 'Banner / Google'
			  WHEN medium = 'cpc' THEN 'PPC / Google'
			  WHEN medium = 'cpc' THEN 'PPC / FB'
			  WHEN medium = 'cpc' THEN 'PPC / Other'
			  WHEN medium = 'organic' THEN 'SEO / Google'
			  WHEN medium = 'fb' THEN 'Facebook / social'
			  WHEN medium = 'fb' THEN 'poszt'
			  WHEN medium = 'Content marketing' THEN 'kep'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-link'
			  WHEN medium = 'Content marketing' THEN 'cikk-kozepi-link'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-kep'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-banner'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-gomb'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-link'
			  WHEN medium = 'pop-up' THEN 'In-site ads'
			  WHEN medium = '(none)' THEN 'Direct visitor / Not available'
			  WHEN medium = '(not set)' THEN 'Direct visitor / Not available'
			  WHEN medium = 'referral' THEN 'Referral'
			  ELSE 'Other'
		 END AS first_marketing_channel
FROM BASE_06_TABLE AS b LEFT JOIN (SELECT min(datum), user_id, orderid, medium, term FROM IN_affiliate_forrasok_02 GROUP BY user_id) AS e
ON b.user_id = e.user_id
;

ALTER TABLE BASE_07a_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_07a_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;

DROP TABLE BASE_07b_TABLE;
CREATE TABLE BASE_07b_TABLE
SELECT DISTINCT b.*, 		 
		CASE WHEN medium = 'newsletter' THEN 'Email newsletter'
			  WHEN medium = 'email' THEN 'Email reminder'
			  WHEN medium = 'alairas' THEN 'Other email'
			  WHEN medium = 'level' THEN 'Other email'
			  WHEN medium = 'mail' THEN 'Other email'
			  WHEN medium = 'affiliate_CT' THEN 'Affiliate marketing'
			  WHEN medium = 'banner' THEN 'Banner / Google'
			  WHEN medium = 'cpc' THEN 'PPC / Google'
			  WHEN medium = 'cpc' THEN 'PPC / FB'
			  WHEN medium = 'cpc' THEN 'PPC / Other'
			  WHEN medium = 'organic' THEN 'SEO / Google'
			  WHEN medium = 'fb' THEN 'Facebook / social'
			  WHEN medium = 'fb' THEN 'poszt'
			  WHEN medium = 'Content marketing' THEN 'kep'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-link'
			  WHEN medium = 'Content marketing' THEN 'cikk-kozepi-link'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-kep'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-banner'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA-gomb'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-CTA'
			  WHEN medium = 'Content marketing' THEN 'cikk-vegi-link'
			  WHEN medium = 'pop-up' THEN 'In-site ads'
			  WHEN medium = '(none)' THEN 'Direct visitor / Not available'
			  WHEN medium = '(not set)' THEN 'Direct visitor / Not available'
			  WHEN medium = 'referral' THEN 'Referral'
			  ELSE 'Other'
		 END AS trx_marketing_channel
FROM BASE_07a_TABLE AS b LEFT JOIN (SELECT orderid, MAX(medium) AS medium FROM IN_affiliate_forrasok GROUP BY orderid) AS e
ON substring(b.reference_id,3) = e.orderid
;


ALTER TABLE BASE_07b_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_07b_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;