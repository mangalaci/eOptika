DROP TABLE IF EXISTS turnover;
CREATE TABLE IF NOT EXISTS turnover
SELECT i.sql_id,
i.warehouse_id,
i.item_name_hun,
i.item_sku,
ROUND(i.actual_quantity) AS inventory,
CAST(COALESCE(b.item_quantity,0) AS SIGNED) AS sales_vol_per_month,
ROUND(COALESCE(b.item_quantity,0)/actual_quantity,2) AS turns_of_inventory_per_month,
ROUND(actual_quantity*30/COALESCE(b.item_quantity,0),2) AS days_per_turn,
ROUND(COALESCE(b.item_net_purchase_price_in_base_currency,0),0) AS net_COGS_per_month,
ROUND(COALESCE(b.revenues_wdisc_in_base_currency,0),0) AS net_sales_rev_per_month
FROM inventory_report i
LEFT JOIN 
(
SELECT CT1_SKU, SUM(item_net_purchase_price_in_base_currency) AS item_net_purchase_price_in_base_currency, SUM(revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency, SUM(item_quantity) AS item_quantity
FROM BASE_09_TABLE 
WHERE origin = 'invoices'
AND created >= '2017-11-01'
AND created <= '2017-11-30'    
GROUP BY CT1_SKU
) b
ON i.item_sku = b.CT1_sku
;

ALTER TABLE turnover ADD PRIMARY KEY (`sql_id`) USING BTREE;