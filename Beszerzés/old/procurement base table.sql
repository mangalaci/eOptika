
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




DROP TABLE IF EXISTS BASE_PRODUCT_SUPPLY;
CREATE TABLE IF NOT EXISTS BASE_PRODUCT_SUPPLY
SELECT 	DISTINCT
		p.connected_outgoing_order_erp_id AS order_erp_id,
		p.sql_id AS receipt_sql_id,
		p.erp_id AS receipt_erp_id,
		p.reference_id AS receipt_reference_id,
		o.created AS order_dt,
		p.created AS receipt_dt,
		p.supplier_name AS receipt_supplier_name,
		p.currency AS receipt_currency,
		p.exchange_rate_of_currency AS receipt_exchange_rate_of_currency,
		p.related_warehouse,
		p.item_sku AS receipt_item_sku,
		p.item_name_hun AS receipt_item_name_hun,
		p.item_group_name AS receipt_item_group_name,
		p.manufacturer,
		p.item_vat_rate AS receipt_item_vat_rate,
		p.item_net_purchase_price_in_currency AS receipt_item_net_purchase_price_in_currency,
		p.item_gross_purchase_price_in_currency AS receipt_item_gross_purchase_price_in_currency,
		p.item_net_purchase_price_in_base_currency AS receipt_item_net_purchase_price_in_base_currency,
		o.item_quantity AS order_item_quantity,
		p.item_quantity AS receipt_item_quantity,
		p.unit_of_quantity_hun AS receipt_unit_of_quantity_hun,
		p.item_net_value_in_currency AS receipt_item_net_value_in_currency,
		p.item_vat_value_in_currency AS receipt_item_vat_value_in_currency,
		p.item_gross_value_in_currency AS receipt_item_gross_value_in_currency,
		p.item_net_value AS receipt_item_net_value,
		p.item_vat_value AS receipt_item_vat_value,
		p.item_gross_value AS receipt_item_gross_value,
		o.quantity_ordered AS order_quantity_ordered,
		o.quantity_arrived AS order_quantity_arrived,
		o.quantity_marked_as_fulfilled AS order_quantity_marked_as_fulfilled,
		o.is_deleted AS order_is_deleted,
		p.is_deleted AS receipt_is_deleted,
		o.processed AS order_processed,
		p.processed AS receipt_processed,
		o.user AS order_user,
		p.user AS receipt_user
FROM purchases_dedupl p
LEFT JOIN
outgoing_orders o
ON (o.erp_id = p.connected_outgoing_order_erp_id AND o.item_sku = p.item_sku)
WHERE (o.is_deleted  = 'no' OR o.is_deleted IS NULL)
;


