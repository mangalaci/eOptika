UPDATE INVOICES_00 AS g
LEFT JOIN INVOICES_002 AS f2
ON g.sql_id = f2.sql_id
SET
g.revenues_wdisc_in_local_currency = g.item_net_value_in_currency,
g.revenues_wdisc_in_base_currency = g.item_net_value_in_currency*g.exchange_rate_of_currency,
g.gross_margin_wodisc_in_base_currency = (f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity),
g.gross_margin_wdisc_in_base_currency = (g.item_net_value_in_currency*g.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity),
g.`gross_margin_wodisc_%` = 
CASE WHEN f2.item_quantity > 0 THEN
			    (f2.item_net_sale_price_in_base_currency-f2.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency
	ELSE 	-1*((f2.item_net_sale_price_in_base_currency-f2.item_net_purchase_price_in_base_currency)/f2.item_net_sale_price_in_base_currency)
END,
g.`gross_margin_wdisc_%` =
CASE WHEN f2.item_quantity > 0 THEN
			    (g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*f2.item_quantity)/g.item_net_value_in_currency*g.exchange_rate_of_currency
	ELSE 	-1*((g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*f2.item_quantity)/g.item_net_value_in_currency*g.exchange_rate_of_currency)
END
;

/*
https://www.omnicalculator.com/business/margin-discount
*/



/*LOGISTIC COST BLOCK: START*/

/*Shipping_fees table*/
DROP TABLE IF EXISTS shipping_fees;
CREATE TABLE shipping_fees
SELECT
	erp_id,
	reference_id,
	created,
	billing_method,
	shipping_method,
	shipping_country_standardized,
	related_division,
	exchange_rate_of_currency,
	SUM(item_quantity) AS item_quantity,
	ROUND(SUM(ABS(item_net_value_in_currency)*exchange_rate_of_currency),2) AS net_invoiced_shipping_costs /*ABS a storno miatt kell*/
FROM SHIPPING_FEES_001
GROUP BY erp_id
;

ALTER TABLE shipping_fees ADD PRIMARY KEY (`erp_id`) USING BTREE;


/*Itt már nincs szükség a 'Szállítási díjak' sorokra*/
DELETE FROM INVOICES_00
WHERE CT2_pack = 'Szállítási díjak'
;




/*Net order table*/
DROP TABLE IF EXISTS net_orders;
CREATE TABLE net_orders
SELECT
	erp_id AS order_id,
	reference_id,
	created AS DATE,
	billing_method AS payment_method,
	shipping_method,
	shipping_country_standardized,
	related_division,
	exchange_rate_of_currency,
	SUM(item_quantity) AS item_quantity,
/*	ROUND(SUM(ABS(item_net_value_in_currency)*exchange_rate_of_currency),2) AS net_invoiced_shipping_costs, */
	ROUND(SUM(ABS(item_weight_in_kg)),3) AS order_weight, /*ABS a storno miatt kell*/
	ROUND(SUM(item_net_purchase_price_in_base_currency*ABS(item_quantity)),2) AS order_cogs, /*ABS a storno miatt kell*/
	ROUND(SUM(ABS(item_gross_value_in_currency)*exchange_rate_of_currency),2) AS gross_order_value, /*ABS a storno miatt kell*/
	ROUND(SUM(ABS(item_net_value_in_currency)*exchange_rate_of_currency),2) AS net_order_value /*ABS a storno miatt kell*/
FROM INVOICES_00
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

ALTER TABLE exchange_rates_ext ADD PRIMARY KEY (`Date`) USING BTREE;


/*
https://stackoverflow.com/questions/28585735/sql-insert-data-rows-for-weekends-and-holidays-from-previous-value

INSERT INTO exchange_rates_ext
SELECT date, NULL AS CHF, NULL AS CZK, NULL AS DKK,	NULL AS EUR, NULL AS GBP, NULL AS HRK, NULL AS HUF,	NULL AS NOK, NULL AS PLN, NULL AS RON, NULL AS RSD, NULL AS SEK, NULL AS USD, NULL AS mark_as
FROM calendar_table
;
*/ 



DROP PROCEDURE IF EXISTS FillDateGap;

DELIMITER //

CREATE PROCEDURE FillDateGap()
BEGIN

DECLARE CurrDate date;
DECLARE VALUE decimal(6,2);
DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
SELECT COUNT(*) FROM exchange_rates_ext INTO n;

SET @CurrDate = (select min(Date) from exchange_rates_ext);
SET @VALUE = (select EUR from exchange_rates_ext where Date = @CurrDate);
SET i=0;

WHILE i<n DO 
  SET @CurrDate = ADDDATE(@CurrDate, INTERVAL 1 DAY);
  IF EXISTS (SELECT Date FROM exchange_rates_ext WHERE Date = @CurrDate) THEN SET @VALUE = (select EUR from exchange_rates_ext where Date = @CurrDate);
    SET i = i + 1;
  ELSE
INSERT INTO exchange_rates_ext (Date, EUR) VALUES (@CurrDate, @VALUE);
  SET i = i + 1;
END IF;
END WHILE;

END;
//
DELIMITER ;

CALL FillDateGap();



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
LEFT JOIN exchange_rates_ext AS e
ON	n.date = e.date
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
	 CASE	WHEN 	n.payment_method IN ('PayPal', 'Bankkártya, PayPal, VPoS') AND exchange_rate_of_currency <> 1
			THEN	(p.payment_fee_perc + 0.02) * n.gross_order_value
			ELSE	p.payment_fee_perc * n.gross_order_value
	 END AS payment_cost_value	 
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
CREATE TABLE INVOICES_00i
SELECT DISTINCT
	 t.*,
     t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency AS net_margin_wodisc_in_base_currency,
	
     t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency AS net_margin_wdisc_in_base_currency,
	
    (t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.revenues_wodisc_in_base_currency) AS `net_margin_wodisc_%`,
	
    (t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency + COALESCE(t.net_invoiced_shipping_costs,0) - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.revenues_wdisc_in_base_currency) AS `net_margin_wdisc_%`
	
FROM
(
SELECT  a.*,

	CASE 	WHEN total_lens_item_number = 0 THEN COALESCE(s.shipping_cost_fix,0)/a.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(s.shipping_cost_fix,0)/a.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(s.shipping_cost_weight,0)*(a.net_weight_in_kg*a.item_quantity)/a.total_weight_in_kg,0)
	AS shipping_cost_in_base_currency,
	
    CASE WHEN a.item_quantity > 0 AND a.shipping_method <> 'Pickup in person' THEN
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
	
	COALESCE(COALESCE(f.net_invoiced_shipping_costs,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value,0) 
	AS net_invoiced_shipping_costs

FROM 
(
SELECT  m.sql_id,
		m.erp_id, 
		m.product_group, 
		m.net_weight_in_kg, 
		m.item_quantity, 
		m.shipping_method, 
		m.item_net_value_in_currency, 
		m.item_vat_value_in_currency, 
		m.exchange_rate_of_currency, 
		m.item_gross_value_in_currency,
		m.revenues_wdisc_in_base_currency,
		m.item_quantity*item_net_sale_price_in_base_currency AS revenues_wodisc_in_base_currency,
		m.gross_margin_wodisc_in_base_currency,
		m.gross_margin_wdisc_in_base_currency,
		n.total_item_number, 
		n.total_lens_item_number, 
		n.total_weight_in_kg, 
		n.order_value
FROM INVOICES_00 m LEFT JOIN
(
SELECT 	erp_id,
		COUNT(sql_id) total_item_number,
		SUM(CASE WHEN product_group = 'Contact lenses' THEN 1 ELSE 0 END) AS total_lens_item_number,
		SUM(net_weight_in_kg * item_quantity) AS total_weight_in_kg,
		SUM(item_net_value_in_currency*exchange_rate_of_currency) AS order_value
FROM INVOICES_00
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



ALTER TABLE INVOICES_00i ADD PRIMARY KEY (`sql_id`) USING BTREE;


UPDATE INVOICES_00 AS m
        LEFT JOIN
    INVOICES_00i AS s ON m.sql_id = s.sql_id
SET
    m.net_margin_wodisc_in_base_currency = s.net_margin_wodisc_in_base_currency,
    m.net_margin_wdisc_in_base_currency = s.net_margin_wdisc_in_base_currency,
    m.`net_margin_wodisc_%` = s.`net_margin_wodisc_%`,
    m.`net_margin_wdisc_%` = s.`net_margin_wdisc_%`,
    m.shipping_cost_in_base_currency = s.shipping_cost_in_base_currency,
    m.packaging_cost_in_base_currency = s.packaging_cost_in_base_currency,
    m.payment_cost_in_base_currency = s.payment_cost_in_base_currency,
    m.item_revenue_in_base_currency = s.item_revenue_in_base_currency,
    m.item_vat_in_base_currency = s.item_vat_in_base_currency,
    m.item_gross_revenue_in_base_currency = s.item_gross_revenue_in_base_currency,
    m.net_invoiced_shipping_costs = s.net_invoiced_shipping_costs
;
