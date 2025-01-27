DROP TABLE IF EXISTS AGGR_USER;
CREATE TABLE IF NOT EXISTS AGGR_USER
SELECT 	user_id,
		COUNT(DISTINCT erp_invoice_id) AS num_of_orders,
		COUNT(item_id) AS num_of_items,
		MAX(created) AS last_purchase,
		related_division,
		SUM(item_net_purchase_price_in_base_currency) AS item_net_purchase_price_in_base_currency,
		SUM(item_net_sale_price_in_currency) AS item_net_sale_price_in_currency,
		SUM(item_gross_sale_price_in_currency) AS item_gross_sale_price_in_currency,
		SUM(item_net_sale_price_in_base_currency) AS item_net_sale_price_in_base_currency,
		SUM(item_gross_sale_price_in_base_currency) AS item_gross_sale_price_in_base_currency,
		SUM(item_quantity) AS item_quantity,
		SUM(item_revenue_in_local_currency) AS item_revenue_in_local_currency,
		SUM(item_vat_value_in_local_currency) AS item_vat_value_in_local_currency,
		SUM(item_revenue_in_base_currency) AS item_revenue_in_base_currency,
		SUM(item_vat_in_base_currency) AS item_vat_in_base_currency,
		SUM(item_gross_revenue_in_base_currency) AS item_gross_revenue_in_base_currency,
		user_type,
		province,
		city_size,
		gender,
		reminder_day,
		SUM(revenues_wdisc_in_local_currency) AS revenues_wdisc_in_local_currency,
		SUM(revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency,
		SUM(gross_margin_wodisc_in_base_currency) AS gross_margin_wodisc_in_base_currency,
		SUM(gross_margin_wdisc_in_base_currency) AS gross_margin_wdisc_in_base_currency,
		newsletter,
		cohort_id,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		related_webshop,
		SUM(order_value) AS order_value,
		SUM(net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		SUM(shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		num_of_purch
FROM `BASE_08_TABLE`
WHERE origin = 'invoices'
GROUP BY user_id
;

ALTER TABLE `AGGR_USER` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);