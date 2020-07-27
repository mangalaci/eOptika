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
	 
		    /*ha negatív a revenue, akkor a purchase price-szal osztjuk a gross margin-t*/
		CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
					(f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency)
			ELSE (f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.item_quantity)
		END AS `gross_margin_wodisc_%`,
	 
		    /*ha negatív a revenue, akkor a purchase price-szal osztjuk a gross margin-t*/
		CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
					(g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency)
			ELSE (g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.item_quantity)
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


DROP TABLE IF EXISTS INVOICES_00i;
CREATE TABLE IF NOT EXISTS INVOICES_00i LIKE INVOICES_00h;

ALTER TABLE INVOICES_00i
  ADD `order_value` double DEFAULT NULL,
  ADD `net_margin_wodisc_in_base_currency` double DEFAULT NULL,
  ADD `net_margin_wdisc_in_base_currency` double DEFAULT NULL,
  ADD `net_margin_wodisc_%` double DEFAULT NULL,
  ADD `net_margin_wdisc_%` double DEFAULT NULL,
  ADD `shipping_cost_in_base_currency` double DEFAULT NULL,
  ADD `packaging_cost_in_base_currency` double DEFAULT NULL,
  ADD `payment_cost_in_base_currency` double DEFAULT NULL,
  ADD `item_revenue_in_base_currency` double DEFAULT NULL,
  ADD `item_vat_in_base_currency` double DEFAULT NULL,
  ADD `item_gross_revenue_in_base_currency` double DEFAULT NULL
  ;




INSERT INTO INVOICES_00i
SELECT  a.*, 
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    a.gross_margin_wodisc_in_base_currency - (COALESCE(s.shipping_cost,0) + COALESCE(p.payment_fee,0) + 28)*(a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value) 
    ELSE 0 END AS net_margin_wodisc_in_base_currency,
	
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    a.gross_margin_wdisc_in_base_currency - (COALESCE(s.shipping_cost,0) + COALESCE(p.payment_fee,0) + 28)*(a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value) 
    ELSE 0 END AS net_margin_wdisc_in_base_currency,
    
    CASE WHEN item_quantity > 0 THEN
    (a.gross_margin_wodisc_in_base_currency - (COALESCE(s.shipping_cost,0) + COALESCE(p.payment_fee,0) + 28)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value)/(a.item_net_value_in_currency*a.exchange_rate_of_currency)
    ELSE 0 END AS `net_margin_wodisc_%`,
	
    CASE WHEN item_quantity > 0 THEN
    (a.gross_margin_wdisc_in_base_currency - (COALESCE(s.shipping_cost,0) + COALESCE(p.payment_fee,0) + 28)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value)/(a.item_net_value_in_currency*a.exchange_rate_of_currency)
    ELSE 0 END AS `net_margin_wdisc_%`,
    
    CASE WHEN item_quantity > 0 THEN
    COALESCE(s.shipping_cost,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
    ELSE 0 END AS shipping_cost_in_base_currency,
    CASE WHEN item_quantity > 0 THEN
    28*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
    ELSE 0 END AS packaging_cost_in_base_currency,
    CASE WHEN item_quantity > 0 THEN
    COALESCE(p.payment_fee,0)*a.item_net_value_in_currency*a.exchange_rate_of_currency/a.order_value 
    ELSE 0 END AS payment_cost_in_base_currency,
    
    a.item_net_value_in_currency*a.exchange_rate_of_currency AS item_revenue_in_base_currency,
    a.item_vat_value_in_currency*a.exchange_rate_of_currency AS item_vat_in_base_currency,
    a.item_gross_value_in_currency*a.exchange_rate_of_currency AS item_gross_revenue_in_base_currency
    
FROM 
(
SELECT  m.*, n.order_value
FROM INVOICES_00h m LEFT JOIN
(
SELECT erp_id, SUM(item_net_value_in_currency*exchange_rate_of_currency) AS order_value
FROM INVOICES_00h 
WHERE item_quantity > 0 /*ahol storno van, oda csak a pozitív rendelési értékre osztunk logisztikai költséget*/
GROUP BY erp_id
) n
ON m.erp_id = n.erp_id
) a 
LEFT JOIN shipping_costs_on_orders AS s
ON 	 a.erp_id = s.order_id
LEFT JOIN payment_fees_on_orders AS p
ON 	 a.erp_id = p.order_id
;

ALTER TABLE INVOICES_00i
	ADD packaging_deadline datetime DEFAULT NULL,
	ADD	quantity_booked float DEFAULT NULL,
	ADD quantity_delivered float DEFAULT NULL,
	ADD quantity_billed float DEFAULT NULL,
	ADD	quantity_marked_as_fulfilled float DEFAULT NULL
  ;

