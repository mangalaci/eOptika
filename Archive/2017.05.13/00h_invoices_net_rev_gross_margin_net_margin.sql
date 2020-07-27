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
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency
    ELSE 0 END AS net_margin_wodisc_in_base_currency,
	
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency
    ELSE 0 END AS net_margin_wdisc_in_base_currency,
	
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    (t.gross_margin_wodisc_in_base_currency - t.shipping_cost_in_base_currency - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.item_net_value_in_currency*t.exchange_rate_of_currency)
    ELSE 0 END AS `net_margin_wodisc_%`,
	
    CASE WHEN item_quantity > 0 THEN /*ki kell nullázni a net margin értékeket, ha stornó tételről van szó*/
    (t.gross_margin_wdisc_in_base_currency - t.shipping_cost_in_base_currency - t.packaging_cost_in_base_currency - t.payment_cost_in_base_currency)/(t.item_net_value_in_currency*t.exchange_rate_of_currency)
    ELSE 0 END AS `net_margin_wdisc_%`
	
FROM
(
SELECT  a.*,
	
    CASE WHEN item_quantity > 0 THEN
    (
	CASE 	WHEN total_lens_item_number = 0 THEN COALESCE(s.shipping_cost_fix,0)/a.total_item_number /*ha nincs lencse a kosárban, akkor a tételek számával osszuk szét a fix költséget */
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(s.shipping_cost_fix,0)/a.total_lens_item_number ELSE 0 END /*ha van lencse a kosárban, akkor csak lencsékre osszuk szét a fix költséget (a lencsés tételek számával) */
	END
	+
	COALESCE(COALESCE(s.shipping_cost_weight,0)*(a.net_weight_in_kg*a.item_quantity)/a.total_weight_in_kg,0)
	)
    ELSE 0 END AS shipping_cost_in_base_currency,
	
    CASE WHEN item_quantity > 0 THEN
    28/a.total_item_number
    ELSE 0 END AS packaging_cost_in_base_currency,
	
	CASE WHEN item_quantity > 0 THEN
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
    a.item_gross_value_in_currency*a.exchange_rate_of_currency AS item_gross_revenue_in_base_currency
/*      
	,COALESCE(COALESCE(s.shipping_cost_weight,0)*a.item_weight_in_kg/a.total_weight_in_kg,0) AS weight
	,	CASE 	WHEN total_lens_item_number = 0 THEN COALESCE(s.shipping_cost_fix,0)/a.total_item_number
			ELSE CASE WHEN product_group = 'Contact lenses' THEN COALESCE(s.shipping_cost_fix,0)/a.total_lens_item_number ELSE 0 END 
		END AS fix
  */
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
WHERE item_quantity > 0 /*ahol storno van, oda csak a pozitív rendelési értékre osztunk logisztikai költséget*/
GROUP BY erp_id
) n
ON m.erp_id = n.erp_id
) a 
LEFT JOIN shipping_costs_on_orders AS s
ON 	 a.erp_id = s.order_id
LEFT JOIN payment_fees_on_orders AS p
ON 	 a.erp_id = p.order_id
) t
;

ALTER TABLE INVOICES_00i
	ADD packaging_deadline datetime DEFAULT NULL,
	ADD	quantity_booked float DEFAULT NULL,
	ADD quantity_delivered float DEFAULT NULL,
	ADD quantity_billed float DEFAULT NULL,
	ADD	quantity_marked_as_fulfilled float DEFAULT NULL
  ;

