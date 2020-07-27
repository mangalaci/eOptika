DROP TABLE IF EXISTS BASE_00h_TABLE;
CREATE TABLE BASE_00h_TABLE
SELECT 	f2.*, 
		g.item_net_value_in_currency AS revenues_wdisc_in_local_currency,
		g.item_net_value_in_currency*g.exchange_rate_of_currency AS revenues_wdisc_in_base_currency,
		(f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wodisc_in_base_currency,
		(g.item_net_value_in_currency*g.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wdisc_in_base_currency,
		/*ha negatív a revenue, akkor a purchase price-szal osztjuk a gross margin-t*/
		CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
		(f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency) 
			 ELSE 
		(f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.item_quantity) 
		END AS `gross_margin_wodisc_%`,
		CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
		(g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency) 
			 ELSE
		(g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.exchange_rate_of_currency) 
		END AS `gross_margin_wdisc_%`
FROM BASE_00g_TABLE AS g, BASE_00f2_TABLE AS f2
WHERE g.sql_id = f2.sql_id
;

ALTER TABLE BASE_00h_TABLE
  DROP COLUMN ct_csoport,
  DROP COLUMN item_sku,
  DROP COLUMN item_name_hun,
  DROP COLUMN item_name_eng  
;


ALTER TABLE BASE_00h_TABLE MODIFY COLUMN item_type VARCHAR(255) AFTER wear_duration;


ALTER TABLE BASE_00h_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00h_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_00h_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00h_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00h_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00h_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;
