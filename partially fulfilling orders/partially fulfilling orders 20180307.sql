DROP TABLE IF EXISTS partially_fulfilling_orders;
CREATE TABLE IF NOT EXISTS partially_fulfilling_orders
SELECT
w.erp_invoice_id,
w.reference_id,
w.created,
CASE
WHEN SUM(w.stock_flg) = 0 THEN 'all out of stock'
WHEN SUM(w.stock_flg) = w.order_quantity THEN 'in stock'
WHEN SUM(w.stock_flg) < w.order_quantity THEN 'partially fulfilled'
END AS fulfillment_rate,
ROUND(w.net_basket_value,2) AS net_basket_value
FROM
(
SELECT DISTINCT
b.item_id,
b.erp_invoice_id,
b.reference_id,
b.created,
b.CT1_SKU,
b.CT1_SKU_name,
q.order_quantity,
q.net_basket_value,
t.actual_quantity,
CASE WHEN t.actual_quantity > 0 THEN 1 ELSE 0 END stock_flg
FROM BASE_03_TABLE b
LEFT JOIN
(
SELECT
b.erp_invoice_id, 
COUNT(b.item_id) AS order_quantity,
SUM(revenues_wdisc_in_base_currency) AS net_basket_value
FROM BASE_03_TABLE b
WHERE b.origin = 'orders'
AND b.is_canceled = 'no'
GROUP BY erp_invoice_id
) q
ON b.erp_invoice_id = q.erp_invoice_id
LEFT JOIN
(
SELECT m.item_sku, m.actual_quantity
FROM
(
SELECT item_sku, MAX(processed) AS max_processed
FROM inventory_report
GROUP BY item_sku
) s,
inventory_report m
WHERE (m.item_sku = s.item_sku AND m.processed = s.max_processed)
) t
ON b.CT1_SKU = t.item_sku
WHERE b.origin = 'orders'
AND b.is_canceled = 'no'
) w
GROUP BY erp_invoice_id
;

ALTER TABLE partially_fulfilling_orders ADD PRIMARY KEY (`erp_invoice_id`) USING BTREE;





ellenorzes:

SELECT 
b.item_id,
b.erp_invoice_id,
b.created,
b.CT1_SKU,
b.CT1_SKU_name
FROM BASE_03_TABLE b
WHERE erp_invoice_id = 'VO18/011205'
;



SELECT m.item_sku, m.actual_quantity
FROM  
(
SELECT item_sku, MAX(processed) AS max_processed
FROM inventory_report
GROUP BY item_sku
) s,
inventory_report m
WHERE (m.item_sku = s.item_sku AND m.processed = s.max_processed)
AND m.item_sku IN ('AOPHG386-0450', 'AOPHG386-0500')
;




