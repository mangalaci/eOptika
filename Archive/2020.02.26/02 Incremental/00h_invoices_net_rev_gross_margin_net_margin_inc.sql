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
WHERE g.new_entry = 1 /*csak az uj sorokat update-eljük*/
;

/*
https://www.omnicalculator.com/business/margin-discount
*/



/*LOGISTIC COST BLOCK: START*/


/*Itt már nincs szükség a 'Szállítási díjak' sorokra*/
DELETE FROM INVOICES_00
WHERE CT2_pack = 'Szállítási díjak'
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;



/*Net order table*/
DROP TABLE IF EXISTS net_orders;
CREATE TABLE net_orders
SELECT
	n.erp_id AS order_id,
	n.reference_id,
	n.created AS DATE,
	n.billing_method AS payment_method,
	n.shipping_method,
	n.pudo_type,
	n.shipping_city,
	n.pickup_city,
	n.personal_city,
	n.shipping_country_standardized,
	n.related_division,
	n.exchange_rate_of_currency,
	n.currency,
	COUNT(n.sql_id) AS total_item_number,
	SUM(CASE WHEN n.product_group = 'Contact lenses' THEN 1 ELSE 0 END) AS total_lens_item_number,
	SUM(n.item_quantity) AS item_quantity,
	ROUND(SUM(ABS(n.net_weight_in_kg * n.item_quantity)),3) AS total_weight_in_kg, /*ABS a storno miatt kell*/
	/*	ROUND(SUM(ABS(item_net_value_in_currency)*exchange_rate_of_currency),2) AS net_invoiced_shipping_costs, */
	ROUND(SUM(n.item_net_purchase_price_in_base_currency*n.item_quantity),2) AS order_cogs,
	ROUND(SUM(n.item_net_value_in_currency*(1+n.item_vat_rate/100)*n.exchange_rate_of_currency),2) AS gross_order_value_in_base_currency,
	ROUND(SUM(n.item_net_value_in_currency*(1+n.item_vat_rate/100)),2) AS gross_order_value_in_local_currency,
	ROUND(SUM(ABS(n.item_net_value_in_currency)*n.exchange_rate_of_currency),2) AS net_order_value
FROM INVOICES_00 n
WHERE n.new_entry = 1 /*csak az uj sorokat update-eljük*/
GROUP BY n.erp_id
;

ALTER TABLE net_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*filling gaps of weekends in exchange rate series*/


DROP TABLE IF EXISTS exchange_rates_ext;
CREATE TABLE IF NOT EXISTS exchange_rates_ext
SELECT date, CHF, CZK, DKK, EUR, GBP, HRK,  HUF, NOK, PLN, RON, RSD, SEK, USD
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



/*stored procedure for filling date gaps (weekends, holidays) in exchange rate time-series*/
DROP PROCEDURE IF EXISTS FillDateGap;

DELIMITER //

CREATE PROCEDURE FillDateGap()
BEGIN

DECLARE CurrDate date;
DECLARE VALUE decimal(6,2);
DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
SELECT DATEDIFF(max(DATE),min(DATE))+1 FROM exchange_rates_ext INTO n;
 
SET @CurrDate = (select min(Date) from exchange_rates_ext);
SET @CHF = (select CHF from exchange_rates_ext where Date = @CurrDate);
SET @CZK = (select CZK from exchange_rates_ext where Date = @CurrDate);
SET @EUR = (select EUR from exchange_rates_ext where Date = @CurrDate);
SET @GBP = (select GBP from exchange_rates_ext where Date = @CurrDate);
SET @PLN = (select PLN from exchange_rates_ext where Date = @CurrDate);
SET @SEK = (select SEK from exchange_rates_ext where Date = @CurrDate);
SET @DKK = (select DKK from exchange_rates_ext where Date = @CurrDate);
SET @NOK = (select NOK from exchange_rates_ext where Date = @CurrDate);
SET @HRK = (select HRK from exchange_rates_ext where Date = @CurrDate);
SET @HUF = (select HUF from exchange_rates_ext where Date = @CurrDate);
SET @RSD = (select RSD from exchange_rates_ext where Date = @CurrDate);
SET @RON = (select RON from exchange_rates_ext where Date = @CurrDate);
SET @USD = (select USD from exchange_rates_ext where Date = @CurrDate);
SET i=0;

WHILE i<n DO 
  SET @CurrDate = ADDDATE(@CurrDate, INTERVAL 1 DAY);
  IF EXISTS (SELECT Date FROM exchange_rates_ext WHERE Date = @CurrDate) THEN
	SET @CHF = (select CHF from exchange_rates_ext where Date = @CurrDate);
	SET @CZK = (select CZK from exchange_rates_ext where Date = @CurrDate);
	SET @EUR = (select EUR from exchange_rates_ext where Date = @CurrDate);
	SET @GBP = (select GBP from exchange_rates_ext where Date = @CurrDate);
	SET @PLN = (select PLN from exchange_rates_ext where Date = @CurrDate);
	SET @SEK = (select SEK from exchange_rates_ext where Date = @CurrDate);
	SET @DKK = (select DKK from exchange_rates_ext where Date = @CurrDate);
	SET @NOK = (select NOK from exchange_rates_ext where Date = @CurrDate);
	SET @HRK = (select HRK from exchange_rates_ext where Date = @CurrDate);
	SET @HUF = (select HUF from exchange_rates_ext where Date = @CurrDate);
	SET @RSD = (select RSD from exchange_rates_ext where Date = @CurrDate);
	SET @RON = (select RON from exchange_rates_ext where Date = @CurrDate);
	SET @USD = (select USD from exchange_rates_ext where Date = @CurrDate);
    SET i = i + 1;
  ELSE
    INSERT INTO exchange_rates_ext (Date, CHF, CZK, EUR, GBP, PLN, SEK, DKK, NOK, HRK, HUF, RSD, RON, USD) VALUES (@CurrDate, @CHF, @CZK, @EUR, @GBP, @PLN, @SEK, @DKK, @NOK, @HRK, @HUF, @RSD, @RON, @USD);
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
	n.total_weight_in_kg,
   	SUM(COALESCE(s.HUF_item,0)*1 + COALESCE(s.EUR_item*e.EUR,0)) AS shipping_cost_fix,	
	COALESCE(SUM(s.EUR_kg*n.total_weight_in_kg*e.EUR),0) AS shipping_cost_weight,
	s.Fulfilment_Porder_EUR*e.EUR AS Fulfilment_Porder_HUF,
	s.Fulfilment_Pitem_EUR*e.EUR AS Fulfilment_Pitem_HUF
FROM
  	net_orders AS n
LEFT JOIN shipping_costs AS s
ON 
(
CASE	WHEN (s.shipping_type = 'Sprinter' AND s.DESTINATIONS = 'HUNGARY') THEN
				CASE 	WHEN COALESCE(n.pickup_city,n.personal_city) = 'Budapest'
						THEN n.shipping_country_standardized = s.DESTINATIONS AND s.E_utdij  = 'Budapest'
						ELSE n.shipping_country_standardized = s.DESTINATIONS AND s.E_utdij  = 'Videk'
				END
				WHEN s.shipping_type IN ('MPL')
				THEN n.shipping_country_standardized = s.DESTINATIONS AND n.pudo_type = s.pudo_type
				ELSE CASE WHEN s.DESTINATIONS is NULL THEN 'Rest of World (b)' ELSE n.shipping_country_standardized END = s.DESTINATIONS
END

AND  	n.shipping_method = s.shipping_type 
AND		s.Category = 
  	CASE
  		WHEN n.shipping_method != 'GPSe' THEN '0'
		WHEN n.shipping_method = 'GPSe' THEN
  				CASE  WHEN (n.total_weight_in_kg < 0.5)	THEN 'G'
					ELSE 'E'
  				END
  	END
AND (n.DATE > s.start_date 
AND n.DATE <= s.expiration_date)
)
LEFT JOIN exchange_rates_ext AS e
ON	n.date = e.date
GROUP BY n.order_id
;

ALTER TABLE shipping_costs_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;




/*Payment fee calculation*/
DROP INDEX payment_method ON payment_fees;
ALTER TABLE payment_fees ADD INDEX `payment_method` (`payment_method`) USING BTREE;

DROP TABLE IF EXISTS payment_fees_on_orders;
CREATE TABLE payment_fees_on_orders
SELECT DISTINCT
		t.order_id,
		t.total_item_number, 
		t.total_lens_item_number,
		t.net_order_value,
		t.payment_method,
		COALESCE(t.payment_cost_fix,0) AS payment_cost_fix,
		t.payment_cost_perc,
		t.exchange_cost_perc
FROM
(
SELECT DISTINCT
	n.order_id AS order_id,
	n.total_item_number, 
	n.total_lens_item_number,
	n.net_order_value,
	n.payment_method,
	CASE WHEN p.payment_fee_fix_currency = 'EUR' THEN p.payment_fee_fix * e.EUR
		 WHEN p.payment_fee_fix_currency = 'GBP' THEN p.payment_fee_fix * e.GBP
		 WHEN p.payment_fee_fix_currency = 'PLN' THEN p.payment_fee_fix * e.PLN
		 WHEN p.payment_fee_fix_currency = 'SEK' THEN p.payment_fee_fix * e.SEK
		 WHEN p.payment_fee_fix_currency = 'DKK' THEN p.payment_fee_fix * e.DKK
		 WHEN p.payment_fee_fix_currency = 'NOK' THEN p.payment_fee_fix * e.NOK
		 WHEN p.payment_fee_fix_currency = 'HRK' THEN p.payment_fee_fix * e.HRK
		 WHEN p.payment_fee_fix_currency = 'RSD' THEN p.payment_fee_fix * e.RSD
		 WHEN p.payment_fee_fix_currency = 'RON' THEN p.payment_fee_fix * e.RON
		 WHEN p.payment_fee_fix_currency = 'HUF' THEN p.payment_fee_fix
	END AS payment_cost_fix,
	 COALESCE(p.payment_fee_perc,0) * (n.gross_order_value_in_base_currency + COALESCE(s.net_invoiced_shipping_costs,0)*1.27) AS payment_cost_perc, /* net_invoiced_shipping_costs-ot bruttósítani kellett */
	 COALESCE(p.exchange_loss_perc,0) * n.gross_order_value_in_base_currency AS exchange_cost_perc
FROM	net_orders AS n
LEFT JOIN shipping_fees AS s
ON n.order_id = s.erp_id
LEFT JOIN exchange_rates AS e
ON n.DATE = e.date
LEFT JOIN	payment_fees AS p
ON
	CASE WHEN 	n.payment_method IN ('Utánvét', 'Cash on delivery') THEN
				n.payment_method = p.payment_method
				AND n.shipping_country_standardized = p.DESTINATIONS
				AND n.shipping_method  = p.shipping_method
				AND n.gross_order_value_in_base_currency > p.basket_value_lower_bound*n.exchange_rate_of_currency
				AND n.gross_order_value_in_base_currency <= p.basket_value_upper_bound*n.exchange_rate_of_currency
				AND n.DATE > p.start_date
				AND n.DATE <= p.expiration_date
		 ELSE	n.payment_method = p.payment_method 
				AND n.currency = p.billing_currency
				AND n.DATE > p.start_date
				AND n.DATE <= p.expiration_date
	END

) t
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
SELECT  
		a.sql_id,
		a.erp_id, 
		a.product_group, 
		a.net_weight_in_kg, 
		a.item_quantity, 
		a.shipping_method, 
		a.item_net_value_in_currency, 
		a.item_vat_value_in_currency, 
		a.exchange_rate_of_currency, 
		a.item_gross_value_in_currency,
		a.revenues_wdisc_in_base_currency,
		a.item_quantity*item_net_sale_price_in_base_currency AS revenues_wodisc_in_base_currency,
		a.gross_margin_wodisc_in_base_currency,
		a.gross_margin_wdisc_in_base_currency,

	CASE 	WHEN p.total_lens_item_number = 0 THEN COALESCE(s.shipping_cost_fix,0)/p.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(s.shipping_cost_fix,0)/p.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(s.shipping_cost_weight,0)*(a.net_weight_in_kg*a.item_quantity)/s.total_weight_in_kg,0)
	AS shipping_cost_in_base_currency,
	
    CASE WHEN a.item_quantity > 0 AND a.shipping_method <> 'Pickup in person' THEN
    s.Fulfilment_Porder_HUF/p.total_item_number
	+
	s.Fulfilment_Pitem_HUF*a.item_quantity
    ELSE 0 END AS packaging_cost_in_base_currency,
	
    (
	CASE 	WHEN p.total_lens_item_number = 0 THEN COALESCE(p.payment_cost_fix,0)/p.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(p.payment_cost_fix,0)/p.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(p.payment_cost_perc+exchange_cost_perc,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/p.net_order_value,0)
	) AS payment_cost_in_base_currency,
    
    a.item_net_value_in_currency*a.exchange_rate_of_currency AS item_revenue_in_base_currency,
    a.item_vat_value_in_currency*a.exchange_rate_of_currency AS item_vat_in_base_currency,
    a.item_gross_value_in_currency*a.exchange_rate_of_currency AS item_gross_revenue_in_base_currency,
	
	COALESCE(COALESCE(f.net_invoiced_shipping_costs,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/p.net_order_value,0) 
	AS net_invoiced_shipping_costs

FROM INVOICES_00 a
LEFT JOIN shipping_costs_on_orders AS s
ON 	 a.erp_id = s.order_id
LEFT JOIN payment_fees_on_orders AS p
ON 	 a.erp_id = p.order_id
LEFT JOIN shipping_fees AS f
ON 	 a.erp_id = f.erp_id
WHERE a.new_entry = 1 /*csak az uj sorokat update-eljük*/
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
WHERE new_entry = 1 /*csak az uj sorokat update-eljük*/
;
