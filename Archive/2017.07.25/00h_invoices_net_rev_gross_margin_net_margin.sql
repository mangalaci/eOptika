DROP TABLE IF EXISTS INVOICES_00h;
CREATE TABLE IF NOT EXISTS INVOICES_00h LIKE INVOICES_00f2;

ALTER TABLE INVOICES_00h
  ADD `revenues_wdisc_in_local_currency` float DEFAULT NULL,
  ADD `revenues_wdisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wodisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wdisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wodisc_%` double DEFAULT NULL,
  ADD `gross_margin_wdisc_%` double DEFAULT NULL;


INSERT INTO INVOICES_00h
SELECT  f2.*,
    g.item_net_value_in_currency AS revenues_wdisc_in_local_currency,
    g.item_net_value_in_currency*g.exchange_rate_of_currency AS revenues_wdisc_in_base_currency,

	(f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wodisc_in_base_currency,
	(g.item_net_value_in_currency*g.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wdisc_in_base_currency,

CASE WHEN f2.item_quantity > 0 THEN
			    (f2.item_net_sale_price_in_base_currency-f2.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency
	ELSE 	-1*((f2.item_net_sale_price_in_base_currency-f2.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency)
END AS `gross_margin_wodisc_%`,

CASE WHEN f2.item_quantity > 0 THEN
			    (g.item_net_sale_price_in_base_currency-g.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency
	ELSE 	-1*((g.item_net_sale_price_in_base_currency-g.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency)
END AS `gross_margin_wdisc_%`

FROM INVOICES_00g AS g
LEFT JOIN INVOICES_00f2 AS f2
ON g.sql_id = f2.sql_id
;



ALTER TABLE INVOICES_00h
  DROP COLUMN group_id,
  DROP COLUMN item_sku,
  DROP COLUMN item_name_hun,
  DROP COLUMN item_name_eng;
ALTER TABLE INVOICES_00h MODIFY COLUMN item_type VARCHAR(255) AFTER wear_duration;



/*LOGISTIC COST BLOCK: START*/

/*Shipping_fees table*/
DROP TABLE IF EXISTS shipping_fees;
CREATE TABLE shipping_fees
SELECT
	erp_id,
	reference_id,
	created,
	payment_method,
	shipping_method,
	shipping_country_standardized,
	related_division,
	exchange_rate_of_currency,
	SUM(item_quantity) AS item_quantity,
	ROUND(SUM(ABS(item_net_value)*exchange_rate_of_currency),2) AS net_invoiced_shipping_costs /*ABS a storno miatt kell*/
FROM SHIPPING_FEES_001
GROUP BY erp_id
;

ALTER TABLE shipping_fees ADD PRIMARY KEY (`erp_id`) USING BTREE;


/*Net order table*/
DROP TABLE IF EXISTS net_orders;
CREATE TABLE net_orders
SELECT
	erp_id AS order_id,
	reference_id,
	created AS DATE,
	payment_method,
	shipping_method,
	shipping_country_standardized,
	related_division,
	exchange_rate_of_currency,
	SUM(item_quantity) AS item_quantity,
	ROUND(SUM(ABS(item_net_value)*exchange_rate_of_currency),2) AS net_invoiced_shipping_costs, /*ABS a storno miatt kell*/
	ROUND(SUM(ABS(item_weight_in_kg)),3) AS order_weight, /*ABS a storno miatt kell*/
	ROUND(SUM(item_net_purchase_price_in_base_currency*ABS(item_quantity)),2) AS order_cogs, /*ABS a storno miatt kell*/
	ROUND(SUM(ABS(item_gross_value_in_currency)*exchange_rate_of_currency),2) AS gross_order_value, /*ABS a storno miatt kell*/
	ROUND(SUM(ABS(item_net_value_in_currency)*exchange_rate_of_currency),2) AS net_order_value /*ABS a storno miatt kell*/
FROM INVOICES_00h
GROUP BY erp_id
;

ALTER TABLE net_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*filling gaps of weekends in exchange rate series*/


DROP TABLE IF EXISTS exchange_rates_ext;
CREATE TABLE IF NOT EXISTS exchange_rates_ext
SELECT date, EUR
FROM exchange_rates
ORDER BY date
;

/*
https://stackoverflow.com/questions/28585735/sql-insert-data-rows-for-weekends-and-holidays-from-previous-value
*/


INSERT INTO exchange_rates_ext
SELECT date, NULL AS CHF, NULL AS CZK, NULL AS DKK,	NULL AS EUR, NULL AS GBP, NULL AS HRK, NULL AS HUF,	NULL AS NOK, NULL AS PLN, NULL AS RON, NULL AS RSD, NULL AS SEK, NULL AS USD, NULL AS mark_as
FROM calendar_table
;
 


DROP TABLE IF EXISTS calendar_table_lag;
CREATE TABLE IF NOT EXISTS calendar_table_lag
SELECT t.date, t.prev_date, prev_2_date
  FROM
(
  SELECT t.date,
  (
    SELECT date
     FROM calendar_table
     WHERE DATEDIFF(date,t.date) = -1
  ) prev_date,
  (
    SELECT date
     FROM calendar_table
     WHERE DATEDIFF(date,t.date) = -2
  ) prev_2_date  
    FROM calendar_table t
) t LEFT JOIN calendar_table p
     ON t.prev_date = p.date
  LEFT JOIN calendar_table p2
     ON t.prev_2_date = p2.date	 
ORDER BY 1
;

DROP TABLE IF EXISTS test;
CREATE TABLE IF NOT EXISTS test
SELECT c.date AS c_date, c.prev_date, c.prev_2_date, e.date AS e_date, e.EUR, CONCAT(c.date,e.date) AS id
FROM calendar_table_lag c
LEFT JOIN exchange_rates e
ON 
CASE 
WHEN c.date = e.date THEN c.date = e.date 
WHEN c.prev_date = e.date THEN c.prev_date = e.date 
ELSE c.prev_2_date = e.date END
ORDER BY 1
;

DROP TABLE IF EXISTS test2;
CREATE TABLE IF NOT EXISTS test2
SELECT c_date, MAX(e_date) AS e_date, CONCAT(c_date,e_date) AS id
FROM test
GROUP BY c_date
;

DROP TABLE IF EXISTS exchange_rates2;
CREATE TABLE IF NOT EXISTS exchange_rates2
SELECT t1.c_date, t1.EUR
FROM test t1,  
test2 t2
WHERE t1.id = t2.id
;

/*
https://stackoverflow.com/questions/20849098/mysql-how-get-value-in-previous-row-and-value-in-next-row
*/


/*Shipping cost calculation*/
DROP TABLE IF EXISTS shipping_costs_on_orders;
CREATE TABLE shipping_costs_on_orders
SELECT
	n.order_id,
	SUM(s.HUF_item*1 + s.EUR_item*e.EUR) AS shipping_cost_fix,
	SUM(s.EUR_kg*n.order_weight*e.EUR) AS shipping_cost_weight
FROM
  	net_orders AS n
LEFT JOIN shipping_costs AS s
ON 
(  	CASE
  		WHEN s.DESTINATIONS IS NOT NULL
  			THEN n.shipping_country_standardized = s.DESTINATIONS
  			ELSE s.DESTINATIONS =  'Rest of World (b)' 
 	END

AND  	n.shipping_method = s.shipping_type 
AND		s.Category = 
  	CASE
  		WHEN n.shipping_method != 'GPSe'
  			THEN '0'
  			ELSE
  				CASE
  					WHEN (n.order_weight < 0.5)
  						THEN 'G'
  						ELSE 'E'
  				END
  	END
)
LEFT JOIN exchange_rates2 AS e
ON	n.date = e.c_date
WHERE (n.DATE >= s.start_date AND n.DATE <= s.expiration_date)
GROUP BY n.order_id
;


ALTER TABLE shipping_costs_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*Payment fee calculation*/
DROP INDEX payment_method ON payment_fees;
ALTER TABLE payment_fees ADD INDEX `payment_method` (`payment_method`) USING BTREE;

DROP TABLE IF EXISTS payment_fees_on_orders;
CREATE TABLE payment_fees_on_orders
SELECT DISTINCT
	 n.order_id AS order_id,
	 p.payment_fee_fix AS payment_cost_fix,
	 p.payment_fee_perc * n.gross_order_value AS payment_cost_value	 
FROM  
	net_orders AS n,
	payment_fees AS p 

WHERE
	CASE WHEN 	n.payment_method IN ('Utánvét', 'Cash on delivery') THEN
				n.payment_method = p.payment_method 
				AND n.shipping_country_standardized = p.DESTINATIONS
				AND n.shipping_method  = p.shipping_method
		 ELSE	n.payment_method = p.payment_method
	END
AND n.DATE >= p.start_date
AND n.DATE <= p.expiration_date
;


ALTER TABLE payment_fees_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*LOGISTIC COST BLOCK: END*/


DROP TABLE IF EXISTS INVOICES_00i;
CREATE TABLE IF NOT EXISTS INVOICES_00i LIKE INVOICES_00h;

ALTER TABLE INVOICES_00i
  ADD `total_item_number` INTEGER DEFAULT NULL,
  ADD `total_lens_item_number` INTEGER DEFAULT NULL,
  ADD `total_weight_in_kg` DOUBLE DEFAULT NULL,
  ADD `order_value` DOUBLE DEFAULT NULL,
  ADD `shipping_cost_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `packaging_cost_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `payment_cost_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `item_revenue_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `item_vat_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `item_gross_revenue_in_base_currency` DOUBLE DEFAULT NULL,
  ADD net_invoiced_shipping_costs DOUBLE DEFAULT NULL,  
  ADD `net_margin_wodisc_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `net_margin_wdisc_in_base_currency` DOUBLE DEFAULT NULL,
  ADD `net_margin_wodisc_%` DOUBLE DEFAULT NULL,
  ADD `net_margin_wdisc_%` DOUBLE DEFAULT NULL
/*  
  ,ADD `weight` DOUBLE DEFAULT NULL
  ,ADD `fix` DOUBLE DEFAULT NULL
*/
;




INSERT INTO INVOICES_00i
SELECT t.*,
    t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency AS net_margin_wodisc_in_base_currency,
	
    t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency AS net_margin_wdisc_in_base_currency,
	
   (t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.item_net_value_in_currency*t.exchange_rate_of_currency) AS `net_margin_wodisc_%`,
	
    (t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.item_net_value_in_currency*t.exchange_rate_of_currency) AS `net_margin_wdisc_%`
	
FROM
(
SELECT  a.*,

	CASE 	WHEN total_lens_item_number = 0 THEN COALESCE(s.shipping_cost_fix,0)/a.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(s.shipping_cost_fix,0)/a.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(s.shipping_cost_weight,0)*(a.net_weight_in_kg*a.item_quantity)/a.total_weight_in_kg,0)
	AS shipping_cost_in_base_currency,
	
    CASE WHEN a.item_quantity > 0 THEN
    150/a.total_item_number
    ELSE 0 END AS packaging_cost_in_base_currency,
	
	CASE WHEN a.item_quantity > 0 THEN
    (
	CASE 	WHEN total_lens_item_number = 0 THEN COALESCE(p.payment_cost_fix,0)/a.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(p.payment_cost_fix,0)/a.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(p.payment_cost_value,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value,0)
	)
    ELSE 0 END AS payment_cost_in_base_currency,
    
    a.item_net_value_in_currency*a.exchange_rate_of_currency AS item_revenue_in_base_currency,
    a.item_vat_value_in_currency*a.exchange_rate_of_currency AS item_vat_in_base_currency,
    a.item_gross_value_in_currency*a.exchange_rate_of_currency AS item_gross_revenue_in_base_currency,
	f.net_invoiced_shipping_costs

FROM 
(
SELECT  m.*, n.total_item_number, n.total_lens_item_number, n.total_weight_in_kg, n.order_value
FROM INVOICES_00h m LEFT JOIN
(
SELECT 	erp_id,
		COUNT(sql_id) total_item_number,
		SUM(CASE WHEN product_group = 'Contact lenses' THEN 1 ELSE 0 END) AS total_lens_item_number,
		SUM(net_weight_in_kg * item_quantity) AS total_weight_in_kg,
		SUM(item_net_value_in_currency*exchange_rate_of_currency) AS order_value
FROM INVOICES_00h 

GROUP BY erp_id
) n
ON m.erp_id = n.erp_id
) a 
LEFT JOIN shipping_costs_on_orders AS s
ON 	 a.erp_id = s.order_id
LEFT JOIN payment_fees_on_orders AS p
ON 	 a.erp_id = p.order_id
LEFT JOIN shipping_fees AS f
ON 	 a.erp_id = f.erp_id
) t
;

ALTER TABLE INVOICES_00i
	ADD packaging_deadline datetime DEFAULT NULL,
	ADD	quantity_booked float DEFAULT NULL,
	ADD quantity_delivered float DEFAULT NULL,
	ADD quantity_billed float DEFAULT NULL,
	ADD	quantity_marked_as_fulfilled float DEFAULT NULL
  ;

