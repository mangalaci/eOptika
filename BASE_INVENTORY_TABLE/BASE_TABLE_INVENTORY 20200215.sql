DROP TABLE IF EXISTS last_procurement;
CREATE TABLE IF NOT EXISTS last_procurement
SELECT 	item_sku, 
		MIN(created) AS first_procurement_date,
		MAX(created) AS last_procurement_date
FROM purchases_dedupl
GROUP BY item_sku
;

ALTER TABLE last_procurement ADD PRIMARY KEY (`item_sku`) USING BTREE;


DROP TABLE IF EXISTS last_purchase;
CREATE TABLE IF NOT EXISTS last_purchase
SELECT 	CT1_SKU, 
		MIN(created) AS first_sale_date, 
		MAX(created) AS last_sale_date 
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY CT1_SKU
;


ALTER TABLE last_purchase ADD PRIMARY KEY (`CT1_SKU`) USING BTREE;
ALTER TABLE last_purchase ADD INDEX (`last_sale_date`) USING BTREE;



DROP TABLE IF EXISTS last_purchase_price;
CREATE TABLE IF NOT EXISTS last_purchase_price
SELECT 
		b.CT1_SKU, 
		AVG(b.item_net_purchase_price_in_base_currency) AS  avg_last_purchase_price,
		first_sale_date,
		last_sale_date
FROM BASE_03_TABLE b, last_purchase l
WHERE b.CT1_SKU = l.CT1_SKU 
AND b.created = l.last_sale_date
AND b.origin = 'invoices'
GROUP BY b.CT1_SKU
;

ALTER TABLE last_purchase_price ADD PRIMARY KEY (`CT1_SKU`) USING BTREE;



DROP TABLE IF EXISTS last_procurement_dt_purchase_price;
CREATE TABLE IF NOT EXISTS last_procurement_dt_purchase_price
SELECT p.*, s.avg_last_purchase_price, s.first_sale_date, s.last_sale_date
FROM last_procurement p
LEFT JOIN last_purchase_price s
ON p.item_sku = s.CT1_SKU
;

ALTER TABLE last_procurement_dt_purchase_price ADD PRIMARY KEY (`item_sku`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_INNER;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_INNER
select 	related_warehouse,
		CT1_sku,
		CT1_sku_name,
		CONCAT(CT1_sku, related_warehouse) as concat_sku_warehouse,
		product_introduction_dt,
		LVCR_item_flg,
		item_quantity,
		revenues_wdisc_in_base_currency,
		erp_invoice_id,
		user_id,
		STR_TO_DATE(concat(order_year, '-',lpad(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') as order_date 
from BASE_03_TABLE
where origin = 'invoices'
and item_quantity > 0
and CT1_sku is not null
;

ALTER TABLE BASE_TABLE_INVENTORY_INNER ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_INNER ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_INNER ADD INDEX (`concat_sku_warehouse`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_01_i;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_01_i
SELECT  
		UPPER(i.item_sku) AS stock_sku,
		i.item_name_hun AS stock_name_hun,
		i.warehouse_id AS stock_warehouse_id,
		i.warehouse AS stock_warehouse,
		CONCAT(i.item_sku, i.warehouse) AS concat_sku_warehouse,
		ROUND(i.actual_quantity) AS stock_actual_quantity,
		ROUND(i.actual_quantity*l.avg_last_purchase_price,0) AS net_inventory_value,
		a.CT2_sku,
		a.CT2_pack,
		a.CT3_product,
		a.CT3_product_short,
		a.CT4_product_brand,
		a.CT5_manufacturer,
		a.product_group,
		a.lens_type,
		a.lens_bc,
		a.lens_pwr,
		a.lens_cyl,
		a.lens_ax,
		a.lens_add,
		a.is_color,
		a.wear_duration,
		a.quantity_in_a_pack,
		a.qty_per_storage_unit,
		a.pack_size,
		a.package_unit,
		a.box_width,
		a.box_height,
		a.box_depth,
		a.net_weight_in_kg,
		a.lens_width,
		a.bridge_width,
		a.temple_length,
		b.LVCR_item_flg,
		'inventory' AS supplier,
		l.first_procurement_date,
		l.last_procurement_date,
		l.first_sale_date, 
		l.last_sale_date,
		CASE WHEN b.items_sold_30days IS NULL THEN 0 ELSE b.items_sold_30days END AS invoice_items_sold_30days,
		CASE WHEN b.items_sold_60days IS NULL THEN 0 ELSE b.items_sold_60days END AS invoice_items_sold_60days,
		CASE WHEN b.items_sold_90days IS NULL THEN 0 ELSE b.items_sold_90days END AS invoice_items_sold_90days,
		CASE WHEN b.items_sold_120days IS NULL THEN 0 ELSE b.items_sold_120days END AS invoice_items_sold_120days,
		CASE WHEN b.items_sold_180days IS NULL THEN 0 ELSE b.items_sold_180days END AS invoice_items_sold_180days,
		CASE WHEN b.items_sold_365days IS NULL THEN 0 ELSE b.items_sold_365days END AS invoice_items_sold_365days,
		CASE WHEN b.items_sold_all_time IS NULL THEN 0 ELSE b.items_sold_all_time END AS invoice_items_sold_all_time,

		ROUND(COALESCE(b.items_sold_30days,0)/i.actual_quantity,2) AS inventory_turns_in_30days,
		ROUND(COALESCE(b.items_sold_60days,0)/i.actual_quantity,2) AS inventory_turns_in_60days,
		ROUND(COALESCE(b.items_sold_90days,0)/i.actual_quantity,2) AS inventory_turns_in_90days,
		ROUND(COALESCE(b.items_sold_120days,0)/i.actual_quantity,2) AS inventory_turns_in_120days,
		ROUND(COALESCE(b.items_sold_180days,0)/i.actual_quantity,2) AS inventory_turns_in_180days,
		ROUND(COALESCE(b.items_sold_365days,0)/i.actual_quantity,2) AS inventory_turns_in_365days,
		ROUND(COALESCE(b.items_sold_all_time,0)/i.actual_quantity,2) AS inventory_turns_in_all_time,
		
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_30days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_30days END) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_60days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_60days END) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_90days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_90days END) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_120days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_120days END) AS invoice_revenues_wdisc_in_base_currency_120days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_180days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_180days END) AS invoice_revenues_wdisc_in_base_currency_180days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_365days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_365days END) AS invoice_revenues_wdisc_in_base_currency_365days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_all_time IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_all_time END) AS invoice_revenues_wdisc_in_base_currency_all_time,

		CASE WHEN b.num_of_transactions_30days IS NULL THEN 0 ELSE b.num_of_transactions_30days END AS invoice_num_of_transactions_30days,
		CASE WHEN b.num_of_transactions_60days IS NULL THEN 0 ELSE b.num_of_transactions_60days END AS invoice_num_of_transactions_60days,
		CASE WHEN b.num_of_transactions_90days IS NULL THEN 0 ELSE b.num_of_transactions_90days END AS invoice_num_of_transactions_90days,
		CASE WHEN b.num_of_transactions_120days IS NULL THEN 0 ELSE b.num_of_transactions_120days END AS invoice_num_of_transactions_120days,
		CASE WHEN b.num_of_transactions_180days IS NULL THEN 0 ELSE b.num_of_transactions_180days END AS invoice_num_of_transactions_180days,
		CASE WHEN b.num_of_transactions_365days IS NULL THEN 0 ELSE b.num_of_transactions_365days END AS invoice_num_of_transactions_365days,
		CASE WHEN b.num_of_transactions_all_time IS NULL THEN 0 ELSE b.num_of_transactions_all_time END AS invoice_num_of_transactions_all_time,
		
		CASE WHEN b.num_of_users_30days IS NULL THEN 0 ELSE b.num_of_users_30days END AS invoice_num_of_users_30days,
		CASE WHEN b.num_of_users_60days IS NULL THEN 0 ELSE b.num_of_users_60days END AS invoice_num_of_users_60days,
		CASE WHEN b.num_of_users_90days IS NULL THEN 0 ELSE b.num_of_users_90days END AS invoice_num_of_users_90days,
		CASE WHEN b.num_of_users_120days IS NULL THEN 0 ELSE b.num_of_users_120days END AS invoice_num_of_users_120days,
		CASE WHEN b.num_of_users_180days IS NULL THEN 0 ELSE b.num_of_users_180days END AS invoice_num_of_users_180days,
		CASE WHEN b.num_of_users_365days IS NULL THEN 0 ELSE b.num_of_users_365days END AS invoice_num_of_users_365days,
		CASE WHEN b.num_of_users_all_time IS NULL THEN 0 ELSE b.num_of_users_all_time END AS invoice_num_of_users_all_time,

		s.sum_reserved_30days,
		s.sum_reserved_60days,
		s.sum_reserved_90days,
		s.sum_reserved_120days,
		s.sum_reserved_180days,
		s.sum_reserved_365days,

		s.sum_ordered_30days,
		s.sum_ordered_60days,
		s.sum_ordered_90days,
		s.sum_ordered_120days,
		s.sum_ordered_180days,
		s.sum_ordered_365days
		
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		t.related_warehouse,
		t.CT1_sku,
		t.LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days,
		SUM(t.item_quantity) AS items_sold_all_time,

		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_365days,
		SUM(t.revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.erp_invoice_id END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.erp_invoice_id END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.erp_invoice_id END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.erp_invoice_id END) AS num_of_transactions_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.erp_invoice_id END) AS num_of_transactions_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.erp_invoice_id END) AS num_of_transactions_365days,
		COUNT(DISTINCT t.erp_invoice_id) AS num_of_transactions_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.user_id END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.user_id END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.user_id END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.user_id END) AS num_of_users_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.user_id END) AS num_of_users_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.user_id END) AS num_of_users_365days,
		COUNT(DISTINCT t.user_id) AS num_of_users_all_time

FROM BASE_TABLE_INVENTORY_INNER t
GROUP BY
		t.related_warehouse,
		t.CT1_sku,
		t.LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse
LEFT JOIN ab_cikkto_full a
ON i.item_sku = a.CT1_sku
LEFT JOIN last_procurement_dt_purchase_price l
ON i.item_sku = l.item_sku
LEFT JOIN 
(
SELECT 	CT1_sku,
		related_warehouse,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Reserved ELSE 0 END) AS sum_reserved_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Ordered ELSE 0 END) AS sum_ordered_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Reserved ELSE 0 END) AS sum_reserved_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Ordered ELSE 0 END) AS sum_ordered_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Reserved ELSE 0 END) AS sum_reserved_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Ordered ELSE 0 END) AS sum_ordered_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Reserved ELSE 0 END) AS sum_reserved_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Ordered ELSE 0 END) AS sum_ordered_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Reserved ELSE 0 END) AS sum_reserved_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Ordered ELSE 0 END) AS sum_ordered_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Reserved ELSE 0 END) AS sum_reserved_365days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Ordered ELSE 0 END) AS sum_ordered_365days
FROM inventory_service_level
GROUP BY CT1_sku, related_warehouse
) s
ON i.item_sku = s.CT1_sku AND i.warehouse = s.related_warehouse
WHERE i.warehouse_id <> 16
;

ALTER TABLE BASE_TABLE_INVENTORY_01_i ADD INDEX (`concat_sku_warehouse`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_01_i ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_01_i ADD INDEX (`stock_warehouse_id`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_01_s;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_01_s
SELECT
		UPPER(b.CT1_sku) AS stock_sku,
		b.CT1_sku_name AS stock_name_hun,
		0 AS stock_warehouse_id,
		b.related_warehouse AS stock_warehouse,
		0 AS stock_actual_quantity,
		0 AS net_inventory_value,		
		a.CT2_sku,
		a.CT2_pack,
		a.CT3_product,
		a.CT3_product_short,
		a.CT4_product_brand,
		a.CT5_manufacturer,
		a.product_group,
		a.lens_type,
		a.lens_bc,
		a.lens_pwr,
		a.lens_cyl,
		a.lens_ax,
		a.lens_add,
		a.is_color,
		a.wear_duration,
		a.quantity_in_a_pack,
		a.qty_per_storage_unit,
		a.pack_size,
		a.package_unit,
		a.box_width,
		a.box_height,
		a.box_depth,
		a.net_weight_in_kg,
		a.lens_width,
		a.bridge_width,
		a.temple_length,		
		b.LVCR_item_flg,
		'ever_sold' AS supplier,
		l.first_procurement_date,
		l.last_procurement_date,
		l.first_sale_date, 
		l.last_sale_date,		
		CASE WHEN b.items_sold_30days IS NULL THEN 0 ELSE b.items_sold_30days END AS invoice_items_sold_30days,
		CASE WHEN b.items_sold_60days IS NULL THEN 0 ELSE b.items_sold_60days END AS invoice_items_sold_60days,
		CASE WHEN b.items_sold_90days IS NULL THEN 0 ELSE b.items_sold_90days END AS invoice_items_sold_90days,
		CASE WHEN b.items_sold_120days IS NULL THEN 0 ELSE b.items_sold_120days END AS invoice_items_sold_120days,
		CASE WHEN b.items_sold_180days IS NULL THEN 0 ELSE b.items_sold_180days END AS invoice_items_sold_180days,
		CASE WHEN b.items_sold_365days IS NULL THEN 0 ELSE b.items_sold_365days END AS invoice_items_sold_365days,
		CASE WHEN b.items_sold_all_time IS NULL THEN 0 ELSE b.items_sold_all_time END AS invoice_items_sold_all_time,

		0 AS inventory_turns_in_30days,
		0 AS inventory_turns_in_60days,
		0 AS inventory_turns_in_90days,
		0 AS inventory_turns_in_120days,
		0 AS inventory_turns_in_180days,
		0 AS inventory_turns_in_365days,
		0 AS inventory_turns_in_all_time,

		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_30days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_30days END) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_60days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_60days END) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_90days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_90days END) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_120days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_120days END) AS invoice_revenues_wdisc_in_base_currency_120days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_180days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_180days END) AS invoice_revenues_wdisc_in_base_currency_180days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_365days IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_365days END) AS invoice_revenues_wdisc_in_base_currency_365days,
		ROUND(CASE WHEN b.revenues_wdisc_in_base_currency_all_time IS NULL THEN 0 ELSE b.revenues_wdisc_in_base_currency_all_time END) AS invoice_revenues_wdisc_in_base_currency_all_time,

		CASE WHEN b.num_of_transactions_30days IS NULL THEN 0 ELSE b.num_of_transactions_30days END AS invoice_num_of_transactions_30days,
		CASE WHEN b.num_of_transactions_60days IS NULL THEN 0 ELSE b.num_of_transactions_60days END AS invoice_num_of_transactions_60days,
		CASE WHEN b.num_of_transactions_90days IS NULL THEN 0 ELSE b.num_of_transactions_90days END AS invoice_num_of_transactions_90days,
		CASE WHEN b.num_of_transactions_120days IS NULL THEN 0 ELSE b.num_of_transactions_120days END AS invoice_num_of_transactions_120days,
		CASE WHEN b.num_of_transactions_180days IS NULL THEN 0 ELSE b.num_of_transactions_180days END AS invoice_num_of_transactions_180days,
		CASE WHEN b.num_of_transactions_365days IS NULL THEN 0 ELSE b.num_of_transactions_365days END AS invoice_num_of_transactions_365days,
		CASE WHEN b.num_of_transactions_all_time IS NULL THEN 0 ELSE b.num_of_transactions_all_time END AS invoice_num_of_transactions_all_time,

		CASE WHEN b.num_of_users_30days IS NULL THEN 0 ELSE b.num_of_users_30days END AS invoice_num_of_users_30days,
		CASE WHEN b.num_of_users_60days IS NULL THEN 0 ELSE b.num_of_users_60days END AS invoice_num_of_users_60days,
		CASE WHEN b.num_of_users_90days IS NULL THEN 0 ELSE b.num_of_users_90days END AS invoice_num_of_users_90days,
		CASE WHEN b.num_of_users_120days IS NULL THEN 0 ELSE b.num_of_users_120days END AS invoice_num_of_users_120days,
		CASE WHEN b.num_of_users_180days IS NULL THEN 0 ELSE b.num_of_users_180days END AS invoice_num_of_users_180days,
		CASE WHEN b.num_of_users_365days IS NULL THEN 0 ELSE b.num_of_users_365days END AS invoice_num_of_users_365days,
		CASE WHEN b.num_of_users_all_time IS NULL THEN 0 ELSE b.num_of_users_all_time END AS invoice_num_of_users_all_time,
		
		s.sum_reserved_30days,
		s.sum_reserved_60days,
		s.sum_reserved_90days,
		s.sum_reserved_120days,
		s.sum_reserved_180days,
		s.sum_reserved_365days,
		
		s.sum_ordered_30days,
		s.sum_ordered_60days,
		s.sum_ordered_90days,
		s.sum_ordered_120days,
		s.sum_ordered_180days,
		s.sum_ordered_365days
		
FROM 
(
SELECT 
		t.related_warehouse,
		t.CT1_sku,
		t.CT1_sku_name,
		t.concat_sku_warehouse,
		t.LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days,
		SUM(t.item_quantity) AS items_sold_all_time,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_365days,
		SUM(t.revenues_wdisc_in_base_currency) AS revenues_wdisc_in_base_currency_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.erp_invoice_id END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.erp_invoice_id END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.erp_invoice_id END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.erp_invoice_id END) AS num_of_transactions_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.erp_invoice_id END) AS num_of_transactions_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.erp_invoice_id END) AS num_of_transactions_365days,
		COUNT(DISTINCT t.erp_invoice_id) AS num_of_transactions_all_time,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.user_id END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.user_id END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.user_id END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.user_id END) AS num_of_users_120days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.user_id END) AS num_of_users_180days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.user_id END) AS num_of_users_365days,
		COUNT(DISTINCT t.user_id) AS num_of_users_all_time

FROM BASE_TABLE_INVENTORY_INNER t
GROUP BY
		t.related_warehouse,
		t.CT1_sku,
		t.CT1_sku_name,
		t.concat_sku_warehouse,
		t.LVCR_item_flg
) b
LEFT JOIN ab_cikkto_full a
ON b.CT1_sku = a.CT1_sku
LEFT JOIN last_procurement_dt_purchase_price l
ON b.CT1_sku = l.item_sku
LEFT JOIN
(
SELECT 	CT1_sku, 
		related_warehouse,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Reserved ELSE 0 END) AS sum_reserved_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 30 THEN Ordered ELSE 0 END) AS sum_ordered_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Reserved ELSE 0 END) AS sum_reserved_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 60 THEN Ordered ELSE 0 END) AS sum_ordered_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Reserved ELSE 0 END) AS sum_reserved_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 90 THEN Ordered ELSE 0 END) AS sum_ordered_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Reserved ELSE 0 END) AS sum_reserved_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 120 THEN Ordered ELSE 0 END) AS sum_ordered_120days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Reserved ELSE 0 END) AS sum_reserved_180days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 180 THEN Ordered ELSE 0 END) AS sum_ordered_180days,		
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Reserved ELSE 0 END) AS sum_reserved_365days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d')) <= 365 THEN Ordered ELSE 0 END) AS sum_ordered_365days

FROM inventory_service_level
GROUP BY CT1_sku, related_warehouse
) s
ON b.CT1_sku = s.CT1_sku AND b.related_warehouse = s.related_warehouse
WHERE b.concat_sku_warehouse NOT IN
(
SELECT DISTINCT concat_sku_warehouse 
FROM BASE_TABLE_INVENTORY_01_i
)
;


ALTER TABLE BASE_TABLE_INVENTORY_01_s ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_01_s ADD INDEX (`stock_warehouse_id`) USING BTREE;


ALTER TABLE BASE_TABLE_INVENTORY_01_i DROP COLUMN concat_sku_warehouse;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_01;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_01
SELECT *
FROM BASE_TABLE_INVENTORY_01_i
UNION
SELECT *
FROM BASE_TABLE_INVENTORY_01_s
;

ALTER TABLE BASE_TABLE_INVENTORY_01 ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_01 ADD INDEX (`stock_warehouse_id`) USING BTREE;




INSERT INTO calendar_table
SELECT CURRENT_DATE FROM DUAL
;

/* teszt eleje */



DROP TABLE IF EXISTS x_bar_30;
CREATE TABLE IF NOT EXISTS x_bar_30
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/30,2) AS avg_items_sold_30days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_30 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_30 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_30 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_30;
CREATE TABLE IF NOT EXISTS x_i_30
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 30 THEN t.item_quantity ELSE 0 END) AS items_sold_30days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 30
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_30 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_30 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_30 ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_30;

DELIMITER //

CREATE PROCEDURE STD_30()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_30 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_30 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 30-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_30);		
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_30 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_30 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_30 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_30 (order_date, related_warehouse, CT1_sku, items_sold_30days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_30();



/* 60 days */

DROP TABLE IF EXISTS x_bar_60;
CREATE TABLE IF NOT EXISTS x_bar_60
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/60,2) AS avg_items_sold_60days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_60 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_60 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_60 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_60;
CREATE TABLE IF NOT EXISTS x_i_60
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 60 THEN t.item_quantity ELSE 0 END) AS items_sold_60days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 60
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_60 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_60 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_60 ADD INDEX (`CT1_sku`) USING BTREE;




DROP PROCEDURE IF EXISTS STD_60;

DELIMITER //

CREATE PROCEDURE STD_60()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_60 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_60 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 60-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_60);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_60 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_60 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_60 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_60 (order_date, related_warehouse, CT1_sku, items_sold_60days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_60();




/* 90 days */

DROP TABLE IF EXISTS x_bar_90;
CREATE TABLE IF NOT EXISTS x_bar_90
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/90,2) AS avg_items_sold_90days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_90 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_90 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_90 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_90;
CREATE TABLE IF NOT EXISTS x_i_90
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 90 THEN t.item_quantity ELSE 0 END) AS items_sold_90days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 90
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_90 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_90 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_90 ADD INDEX (`CT1_sku`) USING BTREE;





DROP PROCEDURE IF EXISTS STD_90;

DELIMITER //

CREATE PROCEDURE STD_90()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_90 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_90 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 90-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_90);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_90 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_90 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_90 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_90 (order_date, related_warehouse, CT1_sku, items_sold_90days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_90();




/* 120 days */

DROP TABLE IF EXISTS x_bar_120;
CREATE TABLE IF NOT EXISTS x_bar_120
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/120,2) AS avg_items_sold_120days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_120 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_120 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_120 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_120;
CREATE TABLE IF NOT EXISTS x_i_120
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 120 THEN t.item_quantity ELSE 0 END) AS items_sold_120days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 120
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_120 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_120 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_120 ADD INDEX (`CT1_sku`) USING BTREE;



DROP PROCEDURE IF EXISTS STD_120;

DELIMITER //

CREATE PROCEDURE STD_120()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_120 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_120 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 120-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_120);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_120 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_120 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_120 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_120 (order_date, related_warehouse, CT1_sku, items_sold_120days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_120();




/* 180 days */

DROP TABLE IF EXISTS x_bar_180;
CREATE TABLE IF NOT EXISTS x_bar_180
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/180,2) AS avg_items_sold_180days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_180 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_180 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_180 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_180;
CREATE TABLE IF NOT EXISTS x_i_180
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 180 THEN t.item_quantity ELSE 0 END) AS items_sold_180days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 180
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_180 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_180 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_180 ADD INDEX (`CT1_sku`) USING BTREE;





DROP PROCEDURE IF EXISTS STD_180;

DELIMITER //

CREATE PROCEDURE STD_180()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_180 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_180 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 180-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_180);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_180 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_180 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_180 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_180 (order_date, related_warehouse, CT1_sku, items_sold_180days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_180();




/* 365 days */

DROP TABLE IF EXISTS x_bar_365;
CREATE TABLE IF NOT EXISTS x_bar_365
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/365,2) AS avg_items_sold_365days,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_365 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_365 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_365 ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_365;
CREATE TABLE IF NOT EXISTS x_i_365
SELECT
		t.order_date,
		t.related_warehouse,
		t.CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), t.order_date) <= 365 THEN t.item_quantity ELSE 0 END) AS items_sold_365days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE DATEDIFF(CURDATE(), t.order_date) <= 365
GROUP BY 	t.order_date,
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_i_365 ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_365 ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_365 ADD INDEX (`CT1_sku`) USING BTREE;





DROP PROCEDURE IF EXISTS STD_365;

DELIMITER //

CREATE PROCEDURE STD_365()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_365 b
		LEFT JOIN (SELECT related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_365 GROUP BY related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = 365-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_365);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_365 WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_365 WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_365 WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_365 (order_date, related_warehouse, CT1_sku, items_sold_365days) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;


CALL STD_365();





/* all time */

DROP TABLE IF EXISTS x_bar_all_time;
CREATE TABLE IF NOT EXISTS x_bar_all_time
SELECT
		t.related_warehouse,
		t.CT1_sku,
		ROUND(SUM(t.item_quantity)/DATEDIFF(CURDATE(), t.product_introduction_dt),2) AS avg_items_sold_all_time,
		0 AS missing_days
FROM BASE_TABLE_INVENTORY_INNER t
WHERE t.order_date > t.product_introduction_dt
GROUP BY
		t.related_warehouse,
		t.CT1_sku
;

ALTER TABLE x_bar_all_time ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE x_bar_all_time ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_bar_all_time ADD INDEX (`CT1_sku`) USING BTREE;



DROP TABLE IF EXISTS x_i_all_time;
CREATE TABLE IF NOT EXISTS x_i_all_time
SELECT
		t.order_date,
		t.product_introduction_dt,
		t.related_warehouse,
		t.CT1_sku,
		SUM(t.item_quantity) AS items_sold_all_time
FROM BASE_TABLE_INVENTORY_INNER t
WHERE t.order_date > t.product_introduction_dt
GROUP BY 	t.order_date,
			t.product_introduction_dt,
			t.related_warehouse,
			t.CT1_sku
;

ALTER TABLE x_i_all_time ADD INDEX (`order_date`) USING BTREE;
ALTER TABLE x_i_all_time ADD INDEX (`related_warehouse`) USING BTREE;
ALTER TABLE x_i_all_time ADD INDEX (`CT1_sku`) USING BTREE;





DROP PROCEDURE IF EXISTS STD_all_time;

DELIMITER //

CREATE PROCEDURE STD_all_time()
BEGIN

DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE b INT DEFAULT 0;
DECLARE rowcount INT DEFAULT 0;


UPDATE 	x_bar_all_time b
		LEFT JOIN (SELECT product_introduction_dt, related_warehouse, CT1_sku, COUNT(*) AS selling_days FROM x_i_all_time GROUP BY product_introduction_dt, related_warehouse, CT1_sku) i
		ON (b.related_warehouse = i.related_warehouse AND b.CT1_sku = i.CT1_sku)
		SET missing_days = DATEDIFF(CURDATE(), i.product_introduction_dt)-i.selling_days;

SET @rowcount = (SELECT COUNT(*) FROM x_bar_all_time);
SET b=1;

WHILE b < @rowcount+1 DO 
SET @related_warehouse = (SELECT related_warehouse FROM x_bar_all_time WHERE id = b);
SET @CT1_sku = (SELECT CT1_sku FROM x_bar_all_time WHERE id = b);
SET @n = (SELECT missing_days FROM x_bar_all_time WHERE id = b);

SET i=0;

WHILE i <= @n DO 
    INSERT INTO x_i_all_time (order_date, related_warehouse, CT1_sku, items_sold_all_time) VALUES (ADDDATE('1990-12-01', INTERVAL i DAY), @related_warehouse, @CT1_sku, 0);
    SET i = i + 1;
END WHILE;
SET b = b + 1;
END WHILE;

END;
//
DELIMITER ;



DROP PROCEDURE IF EXISTS run_all_time;

DELIMITER //

CREATE PROCEDURE run_all_time()
BEGIN

    IF DAYOFWEEK(CURRENT_DATE) = 7
		THEN CALL STD_all_time();
	END IF;
 

END;
//
DELIMITER ;


CALL run_all_time();




/* teszt vege */




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_02;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_02
SELECT DISTINCT
		x_i_30.related_warehouse,
		x_i_30.CT1_sku,
		ROUND(STDDEV_SAMP(x_i_30.items_sold_30days),2) AS items_sold_30days_std,
		ROUND(STDDEV_SAMP(x_i_60.items_sold_60days),2) AS items_sold_60days_std
FROM x_i_30
LEFT JOIN x_i_60
ON 	(x_i_30.related_warehouse = x_i_60.related_warehouse AND x_i_30.CT1_sku = x_i_60.CT1_sku)
GROUP BY 
		related_warehouse,
		CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_02 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_02 ADD INDEX (`related_warehouse`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_03;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_03
SELECT DISTINCT
		t02.*,
		ROUND(STDDEV_SAMP(x_i_90.items_sold_90days),2) AS items_sold_90days_std
FROM BASE_TABLE_INVENTORY_02 t02
LEFT JOIN x_i_90
ON 	(t02.related_warehouse = x_i_90.related_warehouse AND t02.CT1_sku = x_i_90.CT1_sku)
GROUP BY 
		t02.related_warehouse,
		t02.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_03 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_03 ADD INDEX (`related_warehouse`) USING BTREE;



DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_04;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_04
SELECT DISTINCT
		t03.*,
		ROUND(STDDEV_SAMP(x_i_120.items_sold_120days),2) AS items_sold_120days_std
FROM BASE_TABLE_INVENTORY_03 t03
LEFT JOIN x_i_120
ON	(t03.related_warehouse = x_i_120.related_warehouse AND t03.CT1_sku = x_i_120.CT1_sku)
GROUP BY 
		t03.related_warehouse,
		t03.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_04 ADD INDEX (`related_warehouse`) USING BTREE;


DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_05;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_05
SELECT DISTINCT
		t04.*,
		ROUND(STDDEV_SAMP(x_i_180.items_sold_180days),2) AS items_sold_180days_std
FROM BASE_TABLE_INVENTORY_04 t04
LEFT JOIN x_i_180
ON	(t04.related_warehouse = x_i_180.related_warehouse AND t04.CT1_sku = x_i_180.CT1_sku)
GROUP BY 
		t04.related_warehouse,
		t04.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_05 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_05 ADD INDEX (`related_warehouse`) USING BTREE;




DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_06;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_06
SELECT DISTINCT
		t05.*,
		ROUND(STDDEV_SAMP(x_i_365.items_sold_365days),2) AS items_sold_365days_std
FROM BASE_TABLE_INVENTORY_05 t05
LEFT JOIN x_i_365
ON	(t05.related_warehouse = x_i_365.related_warehouse AND t05.CT1_sku = x_i_365.CT1_sku)
GROUP BY 
		t05.related_warehouse,
		t05.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_06 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_06 ADD INDEX (`related_warehouse`) USING BTREE;






DROP TABLE IF EXISTS BASE_TABLE_INVENTORY_07;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY_07
SELECT DISTINCT
		t06.*,
		ROUND(STDDEV_SAMP(x_i_all_time.items_sold_all_time),2) AS items_sold_all_time_std
FROM BASE_TABLE_INVENTORY_06 t06
LEFT JOIN x_i_all_time
ON	(t06.related_warehouse = x_i_all_time.related_warehouse AND t06.CT1_sku = x_i_all_time.CT1_sku)
GROUP BY 
		t06.related_warehouse,
		t06.CT1_sku
;

ALTER TABLE BASE_TABLE_INVENTORY_07 ADD INDEX (`CT1_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY_07 ADD INDEX (`related_warehouse`) USING BTREE;





DROP TABLE IF EXISTS BASE_TABLE_INVENTORY;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY
SELECT DISTINCT

		m.stock_sku,
		m.stock_name_hun,
		m.stock_warehouse_id,
		m.stock_warehouse,
		m.stock_actual_quantity,
		m.net_inventory_value,
		m.CT2_sku,
		m.CT2_pack,
		m.CT3_product,
		m.CT3_product_short,
		m.CT4_product_brand,
		m.CT5_manufacturer,
		m.product_group,
		m.lens_type,
		m.lens_bc,
		m.lens_pwr,
		m.lens_cyl,
		m.lens_ax,
		m.lens_add,
		m.is_color,
		m.wear_duration,
		m.quantity_in_a_pack,
		m.qty_per_storage_unit,
		m.pack_size,
		m.package_unit,
		m.box_width,
		m.box_height,
		m.box_depth,
		m.net_weight_in_kg,
		m.lens_width,
		m.bridge_width,
		m.temple_length,
		m.LVCR_item_flg,
		m.supplier,
		m.first_procurement_date,
		m.last_procurement_date,
		m.first_sale_date, 
		m.last_sale_date,
		m.invoice_items_sold_30days,
		m.invoice_items_sold_60days,
		m.invoice_items_sold_90days,
		m.invoice_items_sold_120days,
		m.invoice_items_sold_180days,
		m.invoice_items_sold_365days,
		m.invoice_items_sold_all_time,

		m.inventory_turns_in_30days,
		m.inventory_turns_in_60days,
		m.inventory_turns_in_90days,
		m.inventory_turns_in_120days,
		m.inventory_turns_in_180days,
		m.inventory_turns_in_365days,
		m.inventory_turns_in_all_time,
		
		m.invoice_revenues_wdisc_in_base_currency_30days,
		m.invoice_revenues_wdisc_in_base_currency_60days,
		m.invoice_revenues_wdisc_in_base_currency_90days,
		m.invoice_revenues_wdisc_in_base_currency_120days,
		m.invoice_revenues_wdisc_in_base_currency_180days,
		m.invoice_revenues_wdisc_in_base_currency_365days,
		m.invoice_revenues_wdisc_in_base_currency_all_time,

		m.invoice_num_of_transactions_30days,
		m.invoice_num_of_transactions_60days,
		m.invoice_num_of_transactions_90days,
		m.invoice_num_of_transactions_120days,
		m.invoice_num_of_transactions_180days,
		m.invoice_num_of_transactions_365days,
		m.invoice_num_of_transactions_all_time,
		
		m.invoice_num_of_users_30days,
		m.invoice_num_of_users_60days,
		m.invoice_num_of_users_90days,
		m.invoice_num_of_users_120days,
		m.invoice_num_of_users_180days,
		m.invoice_num_of_users_365days,
		m.invoice_num_of_users_all_time,
		
		s.items_sold_30days_std AS invoice_items_sold_30days_std,
		s.items_sold_60days_std AS invoice_items_sold_60days_std,
		s.items_sold_90days_std AS invoice_items_sold_90days_std,
		s.items_sold_120days_std AS invoice_items_sold_120days_std,
		s.items_sold_180days_std AS invoice_items_sold_180days_std,
		s.items_sold_365days_std AS invoice_items_sold_365days_std,
		s.items_sold_all_time_std AS invoice_items_sold_all_time_std,

		m.sum_reserved_30days,
		m.sum_reserved_60days,
		m.sum_reserved_90days,
		m.sum_reserved_120days,
		m.sum_reserved_180days,
		m.sum_reserved_365days,
		
		m.sum_ordered_30days,
		m.sum_ordered_60days,
		m.sum_ordered_90days,
		m.sum_ordered_120days,
		m.sum_ordered_180days,
		m.sum_ordered_365days,

CASE 	WHEN m.stock_warehouse_id = 1 THEN i.`001_terez_korut_41`
		WHEN m.stock_warehouse_id = 10 THEN i.`010_terez_korut_50`
		WHEN m.stock_warehouse_id = 15 THEN i.`015_cloud_fulfilment`
		WHEN m.stock_warehouse_id = 17 THEN i.`017_pueblo_torrequebrada`
		WHEN m.stock_warehouse_id = 20 THEN i.`020_iotticait_magazzino_amalfi`
END  AS buffer_level
FROM BASE_TABLE_INVENTORY_01 m
LEFT JOIN BASE_TABLE_INVENTORY_07 s
ON (m.stock_sku = s.CT1_sku
AND m.stock_warehouse = s.related_warehouse)
LEFT JOIN zoho_inventory_min_stock i
ON m.stock_sku = i.sku
;


ALTER TABLE BASE_TABLE_INVENTORY ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_sku`) USING BTREE;
ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_warehouse`) USING BTREE;
