/*kivétel kezelés*/
UPDATE purchases
SET item_quantity = 1,
	item_net_value_in_currency = 4650,
	item_gross_value_in_currency = 4650,
	item_gross_value = 4650
WHERE sql_id = 5592
;

DROP TABLE IF EXISTS purchases_last;
CREATE TABLE IF NOT EXISTS purchases_last
SELECT SUBSTRING_INDEX(erp_id, '/', 2) AS root_erp_id, MAX(erp_id) AS last_erp_id
FROM purchases
WHERE erp_id LIKE '%/%/%'
GROUP BY SUBSTRING_INDEX(erp_id, '/', 2)
;

ALTER TABLE purchases_last ADD PRIMARY KEY (`root_erp_id`) USING BTREE;
ALTER TABLE purchases_last ADD UNIQUE (`last_erp_id`) USING BTREE;


DROP TABLE IF EXISTS purchases_before_last;
CREATE TABLE IF NOT EXISTS purchases_before_last
SELECT *
FROM purchases p, purchases_last l
WHERE SUBSTRING_INDEX(p.erp_id, '/', 2) = l.root_erp_id
AND p.erp_id <> l.last_erp_id
;

ALTER TABLE purchases_before_last ADD PRIMARY KEY (`sql_id`) USING BTREE;


DROP TABLE IF EXISTS purchases_dedupl;
CREATE TABLE IF NOT EXISTS purchases_dedupl LIKE purchases;
INSERT INTO purchases_dedupl
SELECT m.*
FROM purchases m
WHERE m.erp_id NOT IN
(
SELECT erp_id 
FROM purchases_before_last
)
;


/*fulfilled, fulfilled without order*/
DROP TABLE IF EXISTS product_supply_purchase;
CREATE TABLE IF NOT EXISTS product_supply_purchase
SELECT 	DISTINCT
		o.erp_id AS order_erp_id,
		o.sql_id AS order_sql_id,
		p.sql_id AS purchase_sql_id,
		p.erp_id AS purchase_erp_id,
		p.reference_id AS purchase_reference_id,
		o.created AS order_created,
		p.created AS purchase_created,
		o.supplier_name AS order_supplier_name,
		p.supplier_name AS purchase_supplier_name,
		p.currency AS currency,
		p.exchange_rate_of_currency AS exchange_rate_of_currency,
		p.related_warehouse,
		p.item_sku AS CT1_SKU,
		a.CT1_SKU_name,
		a.CT2_pack,
		a.CT3_product,
		a.CT4_product_brand,
		p.manufacturer AS CT5_manufacturer,
		a.product_group,
		a.group_id,
		p.item_vat_rate AS item_vat_rate,
		p.item_net_purchase_price_in_currency AS item_net_purchase_price_in_currency,
		p.item_gross_purchase_price_in_currency AS item_gross_purchase_price_in_currency,
		p.item_net_purchase_price_in_base_currency AS item_net_purchase_price_in_base_currency,
		o.item_quantity AS order_item_qty, /* Ez nem ugyanaz mint a quantity_ordered? Ha igen, akkor töröljük a quantity_ordered cellát. */
		p.item_quantity - o.quantity_marked_as_fulfilled AS purchase_item_qty, /* Ez nem ugyanaz mint a quantity_arrived? */
		p.unit_of_quantity_hun AS unit_of_qty_hun,
		p.item_net_value_in_currency AS item_net_value_in_currency,
		p.item_vat_value_in_currency AS item_vat_value_in_currency,
		p.item_gross_value_in_currency AS item_gross_value_in_currency,
		p.item_gross_value - p.item_vat_value AS item_net_value_in_base_currency,
		p.item_vat_value AS item_vat_value_in_base_currency,
		p.item_gross_value AS item_gross_value_in_base_currency,
		o.quantity_marked_as_fulfilled AS order_item_qty_marked_as_fulfilled,
		o.is_deleted AS order_is_deleted,
		p.is_deleted AS purchase_is_deleted,
		o.processed AS order_processed,
		p.processed AS purchase_processed,
		CASE WHEN o.user IS NULL THEN 'purchase without order' ELSE o.user END AS order_user,
		p.user AS purchase_user
FROM purchases_dedupl p
LEFT JOIN
outgoing_orders o
ON (o.erp_id = p.connected_outgoing_order_erp_id AND o.item_sku = p.item_sku)
LEFT JOIN ab_cikkto_full AS a
ON p.item_sku = a.CT1_SKU
;




ALTER TABLE product_supply_purchase ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



/*pending, cancelled*/
DROP TABLE IF EXISTS product_supply_order;
CREATE TABLE IF NOT EXISTS product_supply_order
SELECT 	DISTINCT
		o.erp_id AS order_erp_id,
		o.sql_id AS order_sql_id,
		'' AS purchase_sql_id,
		'' AS purchase_erp_id,		
		'' AS purchase_reference_id,
		o.created AS order_created,
		'' AS purchase_created,
		o.supplier_name AS order_supplier_name,
		'' AS purchase_supplier_name,
		o.currency AS currency,
		o.exchange_rate_of_currency AS exchange_rate_of_currency,		
		'' AS related_warehouse,
		o.item_sku AS CT1_SKU,
		a.CT1_SKU_name,
		a.CT2_pack,
		a.CT3_product,
		a.CT4_product_brand,
		a.CT5_manufacturer,
		a.product_group,
		a.group_id,		
		o.item_vat_rate AS item_vat_rate,
		o.item_net_purchase_price_in_currency AS item_net_purchase_price_in_currency,
		o.item_gross_purchase_price_in_currency AS item_gross_purchase_price_in_currency,
		o.item_net_purchase_price_in_base_currency AS item_net_purchase_price_in_base_currency,
		o.item_quantity AS order_item_qty,
		o.item_quantity - o.quantity_marked_as_fulfilled AS purchase_item_qty,
		o.unit_of_quantity_hun AS unit_of_qty_hun,
		o.item_net_value_in_currency AS item_net_value_in_currency,
		o.item_vat_value_in_currency AS item_vat_value_in_currency,
		o.item_gross_value_in_currency AS item_gross_value_in_currency,
		o.item_gross_value - o.item_vat_value AS item_net_value_in_base_currency,
		o.item_vat_value AS item_vat_value_in_base_currency,
		o.item_gross_value AS item_gross_value_in_base_currency,
		o.quantity_marked_as_fulfilled AS order_item_qty_marked_as_fulfilled,
		o.is_deleted AS order_is_deleted,
		'' AS purchase_is_deleted,
		o.processed AS order_processed,
		'' AS purchase_processed,
		o.user AS order_user,
		'' AS purchase_user
FROM outgoing_orders o
LEFT JOIN
purchases_dedupl p
ON (o.erp_id = p.connected_outgoing_order_erp_id AND o.item_sku = p.item_sku)
LEFT JOIN ab_cikkto_full AS a
ON o.item_sku = a.CT1_SKU
WHERE p.connected_outgoing_order_erp_id IS NULL
;

ALTER TABLE product_supply_order ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



DROP TABLE IF EXISTS BASE_TABLE_PRODUCT_SUPPLY;
CREATE TABLE BASE_TABLE_PRODUCT_SUPPLY
SELECT *
FROM product_supply_purchase
UNION 
SELECT *
FROM product_supply_order
;

ALTER TABLE BASE_TABLE_PRODUCT_SUPPLY
DROP id;


ALTER TABLE BASE_TABLE_PRODUCT_SUPPLY ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


/*
1. a szűréstől függően értelmezzük a mezőt: ha megjött az áru, akkor a rendeléstől számítjuk  az eltelt időt, ha még nem jött meg, akkor a jelen pillanattól
2. az order_fulfilled mezőnek 3 értéke lesz: 
	a. megjött, pedig meg se rendelték
	b. még nem jött meg
	c. megjött
3. kellene egy zoho mappa
4. vannak a valóban pending-ek és a valami miatt beragadt rendelések akár 2000 nappal
*/

/* CT2-es aggregált tábla lesz */
SELECT order_erp_id, 
purchase_erp_id, 
MAX(order_created) AS order_created, 
MAX(purchase_created) AS purchase_created,
order_supplier_name, 
purchase_supplier_name,
CT2_pack,
FROM `BASE_TABLE_PRODUCT_SUPPLY` 
GROUP BY order_erp_id, purchase_erp_id, order_supplier_name, purchase_supplier_name, CT2_pack
;



/* ellenőrzés */


-- ezeknek nincs CT1 a cikktörzsből
SELECT order_erp_id, purchase_erp_id, CT1_SKU_name, item_name_hun 
FROM BASE_TABLE_PRODUCT_SUPPLY 
WHERE CT1_SKU_name IS NULL
;

/*ami a pruchase táblában megvan, de a cikktörzsben nincs meg*/
SELECT 	DISTINCT
		p.item_sku,
        p.item_name_hun
FROM purchases p
LEFT JOIN ab_cikkto_full AS a
ON p.item_sku = a.CT1_SKU
WHERE a.CT1_SKU IS NULL
;

/*ami a outgoing_orders táblában megvan, de a cikktörzsben nincs meg*/
SELECT 	DISTINCT
		o.item_sku,
        o.item_name_hun
FROM outgoing_orders o
LEFT JOIN ab_cikkto_full AS a
ON o.item_sku = a.CT1_SKU
WHERE a.CT1_SKU IS NULL
;



SELECT 	*
FROM items
WHERE sku = 'PV2MF.86+0025L'
;


SELECT *
FROM purchases
WHERE item_name_hun = 'PureVision 2 Multi-Focal (1 db), BC: 8.6, PWR: -2.50, ADD: Low'
;



WHERE (o.is_deleted  = 'no' OR o.is_deleted IS NULL)

SELECT order_erp_id, purhcase_sql_id, purchase_erp_id, order_item_qty - quantity_ordered AS a, purchase_item_qty - quantity_arrived AS b,
order_item_qty, quantity_ordered, purchase_item_qty, quantity_arrived
FROM BASE_TABLE_PRODUCT_SUPPLY




IF(isnull( "purchase_created")=1,datediff(currentdate(),"order_created") 
- ((weekofyear(currentdate()) - weekofyear("order_created")) * 2) 
+ IF(weekday("order_created") = 5,1,0) 
- IF(weekofyear(currentdate())=weekofyear("order_created"),IF(weekday(currentdate()) = 5,1,0),0),datediff("purchase_created","order_created") - ((weekofyear("purchase_created") - weekofyear("order_created")) * 2) 
+ IF(weekday("order_created") = 5,1,0) - IF(weekofyear("order_created")=weekofyear("purchase_created"),IF(weekday("purchase_created") = 5,1,0),0))