DROP TABLE IF EXISTS BASE_00i_TABLE;
CREATE TABLE BASE_00i_TABLE
SELECT 	DISTINCT
		sz.sql_id, 
		sz.erp_id, 
		sz.reference_id, 
		sz.created,
		sz.fulfillment_date,
		sz.due_date, 
		sz.our_bank_account_number,
		sz.packaging_deadline,
		sz.related_division,
		sz.real_name,
		sz.real_address,
		sz.real_zip_code,
		sz.real_city,
		sz.pickup_name,
		sz.pickup_address,
		sz.pickup_zip_code,
		sz.pickup_city,
		sz.business_name,
		sz.business_address,
		sz.business_zip_code,
		sz.business_city,		
		sz.billing_name,
		sz.billing_country,
		sz.billing_zip_code,
		sz.billing_city,
		sz.billing_address,
		sz.shipping_name,
		sz.shipping_country,
		sz.shipping_zip_code,
		sz.shipping_city,
		sz.shipping_address,
		sz.shipping_phone_clean AS shipping_phone,
		sz.related_warehouse,
		sz.related_webshop,
		sz.currency,
		sz.exchange_rate_of_currency,
		sz.related_comment,
		sz.item_comment,
		sz.item_vat_rate,
		sz.item_net_purchase_price_in_base_currency,		
		sz.item_net_sale_price_in_currency,
		sz.item_gross_sale_price_in_currency,
		sz.item_net_sale_price_in_base_currency,
		sz.item_gross_sale_price_in_base_currency,
		sz.item_quantity,
		sz.unit_of_quantity_hun,
		sz.unit_of_quantity_eng,
		sz.item_net_value_in_currency,
		sz.item_vat_value_in_currency,
		sz.item_gross_value_in_currency,
		sz.item_net_value,
		sz.item_vat_value,
		sz.item_gross_value,
		ABS(sz.net_weight_in_kg * sz.item_quantity) AS item_weight_in_kg,
		quantity_booked,
		quantity_delivered,
		quantity_billed,
		quantity_marked_as_fulfilled,
		sz.connected_order_erp_id,
		sz.connected_delivery_note_erp_id,
		NULL AS erp_id_of_delivery_note,
		NULL AS erp_id_of_bill,
		sz.item_is_canceled,
		sz.cancelled_bill_erp_id,
		sz.cancellation_comment,
		sz.is_canceled,
		sz.processed,
		sz.user,
		sz.related_email_clean,
		sz.user_type,
		sz.real_name_clean,
		sz.shipping_method,
		sz.payment_method,
		sz.real_province,
		sz.real_city_size,
		sz.billing_country_standardized,
		sz.shipping_country_standardized,
		sz.gender,
		sz.full_name,
		sz.first_name,
		sz.last_name,
		sz.salutation,
		sz.CT1_SKU,
		sz.CT1_SKU_name,
		sz.CT2_sku,
		sz.CT2_pack,
		sz.CT3_product,
		sz.CT3_product_short,		
		sz.CT4_product_brand,
		sz.CT5_manufacturer,
		sz.barcode,
		sz.goods_nomenclature_code,
		sz.packaging,
		sz.quantity_in_a_pack,
		sz.estimated_supplier_lead_time,
		sz.lens_bc,
		sz.lens_pwr,
		sz.lens_cyl,
		sz.lens_ax,
		sz.lens_dia,
		sz.lens_add,
		sz.lens_clr,
		sz.pack_size,
		sz.package_unit,
		sz.lens_material,
		sz.product_introduction_dt,
		sz.product_group,
		sz.lens_type,
		sz.is_color,
		sz.wear_days,
		sz.wear_duration,
		sz.item_type,
		sz.qty_per_storage_unit,
		sz.box_width,
		sz.box_height,
		sz.box_depth,
		sz.revenues_wdisc_in_local_currency,
		sz.revenues_wdisc_in_base_currency,
		sz.gross_margin_wodisc_in_base_currency,
		sz.gross_margin_wdisc_in_base_currency,
		sz.net_margin_wodisc_in_base_currency,
		sz.net_margin_wdisc_in_base_currency,
		`gross_margin_wodisc_%`,
		`gross_margin_wdisc_%`,
		`net_margin_wodisc_%`,
		`net_margin_wdisc_%`,
		sz.shipping_cost_in_base_currency,
		sz.payment_cost_in_base_currency,		
		sz.packaging_cost_in_base_currency,
		'invoices' AS origin 
FROM INVOICES_00i sz
UNION ALL
SELECT 	DISTINCT 
		r.sql_id, 
		r.erp_id, 
		r.reference_id, 
		r.created, 
		NULL AS fulfillment_date,
		NULL AS due_date,
		NULL AS our_bank_account_number,
		r.packaging_deadline,
		r.related_division,
		r.real_name,
		r.real_address,
		r.real_zip_code,
		r.real_city,
		r.pickup_name,
		r.pickup_address,
		r.pickup_zip_code,
		r.pickup_city,
		r.business_name,
		r.business_address,
		r.business_zip_code,
		r.business_city,
		r.billing_name,
		r.billing_country,
		r.billing_zip_code,
		r.billing_city,
		r.billing_address,
		r.shipping_name,
		r.shipping_country,
		r.shipping_zip_code,
		r.shipping_city,
		r.shipping_address,
		r.shipping_phone_clean AS shipping_phone,
		r.related_warehouse,
		r.related_webshop,
		r.currency,
		r.exchange_rate_of_currency,
		r.related_comment,
		r.item_note AS item_comment,
		r.item_vat_rate,
		NULL AS item_net_purchase_price_in_base_currency,
		r.item_net_sale_price_in_currency,
		r.item_gross_sale_price_in_currency,
		r.item_net_sale_price_in_base_currency,
		r.item_gross_sale_price_in_base_currency,		
		r.item_quantity,
		r.unit_of_quantity_hun,
		r.unit_of_quantity_eng,
		r.item_net_value_in_currency,
		r.item_vat_value_in_currency,
		r.item_gross_value_in_currency,
		r.item_net_value,
		r.item_vat_value,
		r.item_gross_value,
		ABS(r.net_weight_in_kg * r.item_quantity) AS item_weight_in_kg,
		r.quantity_booked,
		r.quantity_delivered,
		r.quantity_billed,
		r.quantity_marked_as_fulfilled,
		r.erp_id_of_delivery_note,
		r.erp_id_of_bill,
		r.connected_order_erp_id,
		r.connected_delivery_note_erp_id,
		r.item_is_deleted AS item_is_canceled,
		NULL AS cancelled_bill_erp_id,
		r.deletion_comment AS cancellation_comment,
		r.is_deleted AS is_canceled,
		r.processed,
		r.user,
		r.related_email_clean,
		r.user_type,
		r.real_name_clean,
		r.shipping_method,
		NULL AS payment_method,
		r.real_province,
		r.real_city_size,
		r.billing_country_standardized,
		r.shipping_country_standardized,
		r.gender,
		r.full_name,
		r.first_name,
		r.last_name,		
		r.salutation,
		r.CT1_SKU,
		r.CT1_SKU_name,
		r.CT2_sku,
		r.CT2_pack,
		r.CT3_product,
		r.CT3_product_short,		
		r.CT4_product_brand,
		r.CT5_manufacturer,
		r.barcode,
		r.goods_nomenclature_code,
		r.packaging,
		r.quantity_in_a_pack,
		r.estimated_supplier_lead_time,
		r.lens_bc,
		r.lens_pwr,
		r.lens_cyl,	
		r.lens_ax,
		r.lens_dia,		
		r.lens_add,		
		r.lens_clr,		
		r.pack_size,
		r.package_unit,
		r.lens_material,
		r.product_introduction_dt,
		r.product_group,
		r.lens_type,
		r.is_color,
		r.wear_days,
		r.wear_duration,
		r.item_type,
		r.qty_per_storage_unit,
		r.box_width,
		r.box_height,
		r.box_depth,
		r.revenues_wdisc_in_local_currency,
		r.revenues_wdisc_in_base_currency,
		NULL AS gross_margin_wodisc_in_base_currency,
		NULL AS gross_margin_wdisc_in_base_currency,
		NULL AS net_margin_wodisc_in_base_currency,
		NULL AS net_margin_wdisc_in_base_currency,
		NULL AS `gross_margin_wodisc_%`,
		NULL AS `gross_margin_wdisc_%`,	
		NULL AS `net_margin_wodisc_%`,
		NULL AS `net_margin_wdisc_%`,
		NULL AS shipping_cost_in_base_currency,
		NULL AS payment_cost_in_base_currency,		
		NULL AS packaging_cost_in_base_currency,
		'orders' AS origin 
FROM ORDERS_00h r
;

ALTER TABLE BASE_00i_TABLE ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_00i_TABLE ADD INDEX (`sql_id`) USING BTREE COMMENT 'Unique ID given by the KPI system to each item';
ALTER TABLE BASE_00i_TABLE ADD INDEX (`erp_id`) USING BTREE COMMENT 'Order number given by the ERP system automatically. First 2 characters:
SO - Hungary
SI - Italy
SR - Romania
SS - Slovakia
Follow by the year (11, 12, 13, etc)';
ALTER TABLE BASE_00i_TABLE ADD INDEX (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`real_name_clean`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`reference_id`) USING BTREE COMMENT 'Order number coming from the webstore automatically or in case of manual entry it is a free text cell. This goes through on all the tables.';
ALTER TABLE BASE_00i_TABLE ADD INDEX (`shipping_phone`) USING BTREE;


