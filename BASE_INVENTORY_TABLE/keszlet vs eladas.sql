DROP TABLE IF EXISTS BASE_TABLE_INVENTORY;
CREATE TABLE IF NOT EXISTS BASE_TABLE_INVENTORY
SELECT  
		i.item_sku AS stock_sku,
		i.item_name_hun AS stock_name_hun,
		i.warehouse_id AS stock_warehouse_id,
		i.warehouse AS stock_warehouse,
		ROUND(i.actual_quantity) AS stock_actual_quantity,
		b.related_division AS invoice_related_division,
		b.related_webshop AS invoice_related_webshop,
		b.CT2_sku AS invoice_CT2_sku,
		b.CT2_pack AS invoice_CT2_pack,
		b.CT3_product AS invoice_CT3_product,
		b.CT3_product_short AS invoice_CT3_product_short,
		b.CT4_product_brand AS invoice_CT4_product_brand,
		b.CT5_manufacturer AS invoice_CT5_manufacturer,
		b.product_group AS invoice_product_group,
		b.lens_type AS invoice_lens_type,
		b.is_color AS invoice_is_color,
		b.wear_duration AS invoice_wear_duration,
		b.quantity_in_a_pack AS invoice_quantity_in_a_pack,
		b.qty_per_storage_unit AS invoice_qty_per_storage_unit,
		b.pack_size AS invoice_pack_size,
		b.package_unit AS invoice_package_unit,
		b.box_width AS invoice_box_width,
		b.box_height AS invoice_box_height,
		b.box_depth AS invoice_box_depth,
		b.LVCR_item_flg AS invoice_LVCR_item_flg,
		NULL AS supplier,
		b.items_sold_30days AS invoice_items_sold_30days,
		b.items_sold_60days AS invoice_items_sold_60days,
		b.items_sold_90days AS invoice_items_sold_90days,
		b.items_sold_120days AS invoice_items_sold_120days,
		(b.items_sold_30+b.items_sold_29+b.items_sold_28) AS invoice_items_sold_30days_stddev_samp,
		ROUND(COALESCE(b.items_sold_30days,0)/i.actual_quantity,2) AS inventory_turns_in_30days,
		ROUND(COALESCE(b.items_sold_60days,0)/i.actual_quantity,2) AS inventory_turns_in_60days,
		ROUND(COALESCE(b.items_sold_90days,0)/i.actual_quantity,2) AS inventory_turns_in_90days,
		ROUND(COALESCE(b.items_sold_120days,0)/i.actual_quantity,2) AS inventory_turns_in_120days,
		
		ROUND(revenues_wdisc_in_base_currency_30days) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(revenues_wdisc_in_base_currency_60days) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(revenues_wdisc_in_base_currency_90days) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(revenues_wdisc_in_base_currency_120days) as invoice_revenues_wdisc_in_base_currency_120days,
		b.num_of_transactions_30days AS invoice_num_of_transactions_30days,
		b.num_of_transactions_60days AS invoice_num_of_transactions_60days,
		b.num_of_transactions_90days AS invoice_num_of_transactions_90days,
		b.num_of_transactions_120days AS invoice_num_of_transactions_120days,
		b.num_of_users_30days AS invoice_num_of_users_30days,
		b.num_of_users_60days AS invoice_num_of_users_60days,
		b.num_of_users_90days AS invoice_num_of_users_90days,
		b.num_of_users_120days AS invoice_num_of_users_120days
		
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN item_quantity ELSE 0 END) AS items_sold_120days,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 30 THEN item_quantity ELSE 0 END) AS items_sold_30,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 29 THEN item_quantity ELSE 0 END) AS items_sold_29,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 28 THEN item_quantity ELSE 0 END) AS items_sold_28,
		
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_120days,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN user_id ELSE 0 END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN user_id ELSE 0 END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN user_id ELSE 0 END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN user_id ELSE 0 END) AS num_of_users_120days
		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
GROUP BY 
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse

UNION

SELECT  
		i.item_sku AS stock_sku, 
		i.item_name_hun AS stock_name_hun, 
		i.warehouse_id AS stock_warehouse_id, 
		i.warehouse AS stock_warehouse, 
		ROUND(i.actual_quantity) AS stock_actual_quantity,
		b.related_division AS invoice_related_division,
		b.related_webshop AS invoice_related_webshop,
		b.CT2_sku AS invoice_CT2_sku,
		b.CT2_pack AS invoice_CT2_pack,
		b.CT3_product AS invoice_CT3_product,
		b.CT3_product_short AS invoice_CT3_product_short,
		b.CT4_product_brand AS invoice_CT4_product_brand,
		b.CT5_manufacturer AS invoice_CT5_manufacturer,
		b.product_group AS invoice_product_group,
		b.lens_type AS invoice_lens_type,
		b.is_color AS invoice_is_color,
		b.wear_duration AS invoice_wear_duration,
		b.quantity_in_a_pack AS invoice_quantity_in_a_pack,		
		b.qty_per_storage_unit AS invoice_qty_per_storage_unit,		
		b.pack_size AS invoice_pack_size,	
		b.package_unit AS invoice_package_unit,
		b.box_width AS invoice_box_width,
		b.box_height AS invoice_box_height,
		b.box_depth AS invoice_box_depth,
		b.LVCR_item_flg AS invoice_LVCR_item_flg,
		NULL AS supplier,
		b.items_sold_30days AS invoice_items_sold_30days,
		b.items_sold_60days AS invoice_items_sold_60days,
		b.items_sold_90days AS invoice_items_sold_90days,
		b.items_sold_120days AS invoice_items_sold_120days,
		(b.items_sold_30+b.items_sold_29+b.items_sold_28) AS invoice_items_sold_30days_stddev_samp,
		ROUND(COALESCE(b.items_sold_30days,0)/i.actual_quantity,2) AS inventory_turns_in_30days,
		ROUND(COALESCE(b.items_sold_60days,0)/i.actual_quantity,2) AS inventory_turns_in_60days,
		ROUND(COALESCE(b.items_sold_90days,0)/i.actual_quantity,2) AS inventory_turns_in_90days,
		ROUND(COALESCE(b.items_sold_120days,0)/i.actual_quantity,2) AS inventory_turns_in_120days,		
		ROUND(revenues_wdisc_in_base_currency_30days) AS invoice_revenues_wdisc_in_base_currency_30days,
		ROUND(revenues_wdisc_in_base_currency_60days) AS invoice_revenues_wdisc_in_base_currency_60days,
		ROUND(revenues_wdisc_in_base_currency_90days) AS invoice_revenues_wdisc_in_base_currency_90days,
		ROUND(revenues_wdisc_in_base_currency_120days) as invoice_revenues_wdisc_in_base_currency_120days,
		b.num_of_transactions_30days AS invoice_num_of_transactions_30days,
		b.num_of_transactions_60days AS invoice_num_of_transactions_60days,
		b.num_of_transactions_90days AS invoice_num_of_transactions_90days,
		b.num_of_transactions_120days AS invoice_num_of_transactions_120days,
		b.num_of_users_30days AS invoice_num_of_users_30days,
		b.num_of_users_60days AS invoice_num_of_users_60days,
		b.num_of_users_90days AS invoice_num_of_users_90days,
		b.num_of_users_120days AS invoice_num_of_users_120days
FROM inventory_report i
LEFT JOIN 
(
SELECT 
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN item_quantity ELSE 0 END) AS items_sold_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN item_quantity ELSE 0 END) AS items_sold_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN item_quantity ELSE 0 END) AS items_sold_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN item_quantity ELSE 0 END) AS items_sold_120days,

		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 30 THEN item_quantity ELSE 0 END) AS items_sold_30,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 29 THEN item_quantity ELSE 0 END) AS items_sold_29,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) = 28 THEN item_quantity ELSE 0 END) AS items_sold_28,		
				
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_30days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_60days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_90days,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN revenues_wdisc_in_base_currency ELSE 0 END) AS revenues_wdisc_in_base_currency_120days,
		
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN erp_invoice_id ELSE 0 END) AS num_of_transactions_120days,

		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN user_id ELSE 0 END) AS num_of_users_30days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN user_id ELSE 0 END) AS num_of_users_60days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN user_id ELSE 0 END) AS num_of_users_90days,
		COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN user_id ELSE 0 END) AS num_of_users_120days
		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
GROUP BY 
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		CT1_sku_name,
		CT2_sku,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		product_group,
		lens_type,
		is_color,
		wear_duration,
		quantity_in_a_pack,
		qty_per_storage_unit,
		pack_size,
		package_unit,
		box_width,
		box_height,
		box_depth,
		LVCR_item_flg
) b
ON i.item_sku = b.CT1_sku AND i.warehouse = b.related_warehouse
;


ALTER TABLE BASE_TABLE_INVENTORY ADD INDEX (`stock_sku`) USING BTREE;







SELECT 
		t30.related_division,
		t30.related_warehouse,
		t30.related_webshop,
		t30.CT1_sku,
		ROUND(STDDEV_SAMP(t30.items_sold_30days),2) AS items_sold_30days_std,
		ROUND(STDDEV_SAMP(t60.items_sold_60days),2) AS items_sold_60days_std,
		ROUND(STDDEV_SAMP(t90.items_sold_90days),2) AS items_sold_90days_std,
		ROUND(STDDEV_SAMP(t120.items_sold_120days),2) AS items_sold_120days_std
FROM
(
SELECT 
		created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 30 THEN item_quantity ELSE 0 END) AS items_sold_30days		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
AND CT1_SKU = 'BIOT300'
AND DATEDIFF(CURDATE(), created) < 30
GROUP BY 	created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku
    ) t30
LEFT JOIN
(
SELECT 
		created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 60 THEN item_quantity ELSE 0 END) AS items_sold_60days		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
AND CT1_SKU = 'BIOT300'
AND DATEDIFF(CURDATE(), created) < 60
GROUP BY 	created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku
    ) t60	
ON 	(t30.related_division = t60.related_division AND t30.related_warehouse = t60.related_warehouse AND t30.related_webshop = t60.related_webshop AND t30.CT1_sku = t60.CT1_sku)
LEFT JOIN
(
SELECT 
		created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 90 THEN item_quantity ELSE 0 END) AS items_sold_90days		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
AND CT1_SKU = 'BIOT300'
AND DATEDIFF(CURDATE(), created) < 90
GROUP BY 	created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku
    ) t90	
ON 	(t30.related_division = t90.related_division AND t30.related_warehouse = t90.related_warehouse AND t30.related_webshop = t90.related_webshop AND t30.CT1_sku = t90.CT1_sku)
LEFT JOIN
(
SELECT 
		created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku,
		SUM(CASE WHEN DATEDIFF(CURDATE(), created) < 120 THEN item_quantity ELSE 0 END) AS items_sold_120days		
FROM BASE_03_TABLE
WHERE origin = 'invoices'
AND item_quantity > 0
AND CT1_SKU = 'BIOT300'
AND DATEDIFF(CURDATE(), created) < 120
GROUP BY 	created,
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku
    ) t120
ON 	(t30.related_division = t120.related_division AND t30.related_warehouse = t120.related_warehouse AND t30.related_webshop = t120.related_webshop AND t30.CT1_sku = t120.CT1_sku)

GROUP BY 
		related_division,
		related_warehouse,
		related_webshop,
		CT1_sku
;
