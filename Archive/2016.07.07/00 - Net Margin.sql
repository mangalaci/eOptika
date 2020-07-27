/*Net order table*/
DROP TABLE IF EXISTS net_orders;
CREATE TABLE net_orders
SELECT
	o.erp_id AS order_id,
	o.reference_id,
	o.created AS DATE,
	o.billing_method,
	o.shipping_method,
	o.related_division,
	o.exchange_rate_of_currency,
	IFNULL(w.weight, 0) AS order_weight,
	SUM(o.item_net_purchase_price_in_base_currency * item_quantity) AS order_cogs,
	SUM(o.item_gross_value_in_currency*exchange_rate_of_currency) AS gross_order_value,
	SUM(o.item_net_value_in_currency*exchange_rate_of_currency) AS net_order_value
FROM outgoing_bills o
LEFT JOIN
	it_order_weights AS w ON w.erp_id = o.erp_id
WHERE
	o.is_canceled NOT IN ('yes', 'storno') 
    AND	o.item_net_value != ''
GROUP BY o.erp_id
;

ALTER TABLE net_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*Shipping cost calculation*/
DROP TABLE IF EXISTS shipping_costs_on_orders;
CREATE TABLE shipping_costs_on_orders
SELECT
	a.order_id as order_id,
	SUM(a.shipping_cost) as shipping_cost

FROM

(SELECT
	n.order_id as order_id,
	s.HUF_item*1 + s.EUR_item*exchange_rate_of_currency + s.EUR_kg*n.order_weight*exchange_rate_of_currency as shipping_cost
	
FROM	  
  	net_orders as n, shipping_costs as s

WHERE
  	n.related_division = s.related_division AND
  	n.shipping_method = s.shipping_type AND
  	s.Category = 
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
	/* in case the order is lighter than half a kilo we can use the tariff of category “G” otherwise we have to use “E”.*/

UNION ALL

/* the part below should be deleted. Now we have to use since in the order table at Italian orders we have “személyes átvétel” which should be GPSe. To not break the SQL script we have to use this part to handle that. */

SELECT
	n.order_id as order_id,
	s.HUF_item* 1 + s.EUR_item*exchange_rate_of_currency + s.EUR_kg*n.order_weight*exchange_rate_of_currency as shipping_cost
	
FROM	  
  	net_orders as n, shipping_costs as s

WHERE
  	n.related_division = 'Optika - IT' AND
  	n.shipping_method = 'Személyes átvétel' AND
  	n.shipping_method = s.shipping_type AND
  	n.related_division = s.related_division AND
  	s.Category = 
  	CASE
  		WHEN (n.order_weight < 0.5)
  			THEN 'G'
  			ELSE 'E'
  	END  	  	
  	
  	) as a
  	
GROUP BY a.order_id;

ALTER TABLE shipping_costs_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*Payment fee calculation*/
DROP INDEX payment_method ON payment_fees;
ALTER TABLE payment_fees ADD INDEX `payment_method` (`payment_method`) USING BTREE;

DROP TABLE payment_fees_on_orders;
CREATE TABLE payment_fees_on_orders
SELECT
	 n.order_id as order_id,
	 ((p.payment_fee_perc * n.gross_order_value) + p.payment_fee_fix) as payment_fee
		 
FROM  
	net_orders AS n,
	payment_fees AS p 

WHERE
	n.billing_method  = p.payment_method AND
	(n.related_division  = p.related_division OR p.related_division IS NULL) AND
	(n.shipping_method  = p.shipping_method OR	p.shipping_method  IS NULL)
;

ALTER TABLE payment_fees_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*Net margin calculation*/
DROP TABLE IF EXISTS net_margin;
CREATE TABLE net_margin
SELECT
	n.order_id as order_id,
	n.reference_id as reference_id,
	n.date as date,
 	n.billing_method as billing_method,
  	n.shipping_method as shipping_method,
  	n.related_division as related_division,
  	n.net_order_value as net_order_value,
  	n.order_cogs as order_cogs,
  	s.shipping_cost as shipping_cost,
  	p.payment_fee as payment_fee,
  	28 as packaging_cost,
  	n.net_order_value - n.order_cogs as gross_margin,
	(n.net_order_value - n.order_cogs) / n.net_order_value as gross_margin_perc,
	n.net_order_value - n.order_cogs - s.shipping_cost - p.payment_fee - 28 as net_margin,
	(n.net_order_value - n.order_cogs - s.shipping_cost - p.payment_fee - 28) / n.net_order_value as net_margin_perc
FROM
	net_orders as n, shipping_costs_on_orders as s, payment_fees_on_orders as p
WHERE
	 n.order_id = s.order_id AND
	 n.order_id = p.order_id
;


ALTER TABLE net_margin ADD PRIMARY KEY (`order_id`) USING BTREE;
ALTER TABLE net_margin ADD INDEX `reference_id` (`reference_id`) USING BTREE;