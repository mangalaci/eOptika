
DROP TABLE IF EXISTS purchases_last;
CREATE TABLE IF NOT EXISTS purchases_last
SELECT SUBSTRING_INDEX(erp_id, '/', 2) AS root_erp_id, MAX(erp_id) AS last_erp_id
FROM purchases
WHERE erp_id LIKE '%/%/%'
GROUP BY SUBSTRING_INDEX(erp_id, '/', 2)
;

ALTER TABLE purchases_last ADD PRIMARY KEY (`root_erp_id`) USING BTREE;
ALTER TABLE purchases_last ADD UNIQUE (`last_erp_id`) USING BTREE;


DROP TABLE IF EXISTS purchases_root;
CREATE TABLE IF NOT EXISTS purchases_root
SELECT SUBSTRING_INDEX(erp_id, '/', 2) AS root_erp_id, MAX(erp_id) AS last_erp_id
FROM purchases
WHERE erp_id LIKE '%/%/%'
GROUP BY SUBSTRING_INDEX(erp_id, '/', 2)
;




DROP TABLE IF EXISTS purchases_without_last;
CREATE TABLE IF NOT EXISTS purchases_without_last
SELECT *
FROM purchases m
WHERE m.erp_id NOT IN
(
SELECT last_erp_id
FROM purchases_last
)
;



SELECT DISTINCT m.erp_id
FROM purchases m
WHERE m.erp_id NOT IN
(
SELECT last_erp_id
FROM purchases_last
)
AND m.erp_id IN
(
SELECT root_erp_id 
FROM purchases_last
)
;

ALTER TABLE purchases_before_last ADD PRIMARY KEY (`erp_id`) USING BTREE;


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
		p.item_sku AS item_sku,
		p.item_name_hun AS item_name_hun,
		p.item_group_name AS item_group_name,
		p.manufacturer,
		p.item_vat_rate AS item_vat_rate,
		p.item_net_purchase_price_in_currency AS item_net_purchase_price_in_currency,
		p.item_gross_purchase_price_in_currency AS item_gross_purchase_price_in_currency,
		p.item_net_purchase_price_in_base_currency AS item_net_purchase_price_in_base_currency,
		o.item_quantity AS order_item_qty, /* Ez nem ugyanaz mint a quantity_ordered? Ha igen, akkor töröljük a quantity_ordered cellát. */
		p.item_quantity AS purchase_item_qty, /* Ez nem ugyanaz mint a quantity_arrived? */
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
		o.user AS order_user,
		p.user AS purchase_user
FROM purchases_dedupl p
LEFT JOIN
outgoing_orders o
ON (o.erp_id = p.connected_outgoing_order_erp_id AND o.item_sku = p.item_sku)
;



ALTER TABLE product_supply_purchase ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);




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
		o.item_sku AS item_sku,
		o.item_name_hun AS item_name_hun,
		o.item_group_name AS item_group_name,
		'' AS manufacturer,
		o.item_vat_rate AS item_vat_rate,
		o.item_net_purchase_price_in_currency AS item_net_purchase_price_in_currency,
		o.item_gross_purchase_price_in_currency AS item_gross_purchase_price_in_currency,
		o.item_net_purchase_price_in_base_currency AS item_net_purchase_price_in_base_currency,
		o.item_quantity AS order_item_qty,
		o.item_quantity AS purchase_item_qty,
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
WHERE p.connected_outgoing_order_erp_id IS NULL
;

ALTER TABLE product_supply_order ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);



DROP TABLE IF EXISTS BASE_PRODUCT_SUPPLY;
CREATE TABLE BASE_PRODUCT_SUPPLY
SELECT *
FROM product_supply_purchase
UNION 
SELECT *
FROM product_supply_order
;

ALTER TABLE BASE_PRODUCT_SUPPLY
DROP id;


ALTER TABLE BASE_PRODUCT_SUPPLY ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);






/* ellenőrzés */






WHERE (o.is_deleted  = 'no' OR o.is_deleted IS NULL)

SELECT order_erp_id, purhcase_sql_id, purchase_erp_id, order_item_qty - quantity_ordered AS a, purchase_item_qty - quantity_arrived AS b,
order_item_qty, quantity_ordered, purchase_item_qty, quantity_arrived
FROM BASE_PRODUCT_SUPPLY