/*Net order table*/
DROP TABLE IF EXISTS net_orders;
CREATE TABLE net_orders
SELECT
	o.erp_id AS order_id,
	o.reference_id,
	o.created AS DATE,
	o.billing_method AS payment_method,
	o.shipping_method,
	o.related_division,
	o.exchange_rate_of_currency,
	ROUND(SUM(o.item_weight_in_kg),3) AS order_weight,
	ROUND(SUM(o.item_net_purchase_price_in_base_currency * item_quantity),2) AS order_cogs,
	ROUND(SUM(o.item_gross_value_in_currency*exchange_rate_of_currency),2) AS gross_order_value,
	ROUND(SUM(o.item_net_value_in_currency*exchange_rate_of_currency),2) AS net_order_value
FROM outgoing_bills o
WHERE o.is_canceled NOT IN ('yes', 'storno')
GROUP BY o.erp_id
;

ALTER TABLE net_orders ADD PRIMARY KEY (`order_id`) USING BTREE;


/*Shipping cost calculation*/
DROP TABLE IF EXISTS shipping_costs_on_orders;
CREATE TABLE shipping_costs_on_orders
SELECT
	a.order_id as order_id,
	SUM(a.shipping_cost_fix) as shipping_cost_fix,
	SUM(a.shipping_cost_weight) as shipping_cost_weight

FROM

(SELECT
	n.order_id as order_id,
	s.HUF_item*1 + s.EUR_item*exchange_rate_of_currency as shipping_cost_fix,
	s.EUR_kg*n.order_weight*exchange_rate_of_currency as shipping_cost_weight
	
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
	s.HUF_item* 1 + s.EUR_item*n.exchange_rate_of_currency as shipping_cost_fix,
	s.EUR_kg*n.order_weight*n.exchange_rate_of_currency as shipping_cost_weight
	
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
  	
  	) AS a
  	
GROUP BY a.order_id;

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
	CASE WHEN 	n.payment_method = 'Utánvét' THEN
				n.payment_method = p.payment_method 
				AND n.related_division  = p.related_division 
				AND n.shipping_method  = p.shipping_method
		 ELSE	n.payment_method = p.payment_method
	END
;


ALTER TABLE payment_fees_on_orders ADD PRIMARY KEY (`order_id`) USING BTREE;
