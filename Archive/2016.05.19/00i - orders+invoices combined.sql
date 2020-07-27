
DROP TABLE IF EXISTS BASE_00i_TABLE;
CREATE TABLE BASE_00i_TABLE
SELECT 	DISTINCT 
		r.sql_id, 
		r.erp_id, 
		r.reference_id, 
		r.created, 
		NULL AS fulfillment_date,
		NULL AS due_date,
		NULL AS our_bank_account_number,
		packaging_deadline,
		r.related_division,
		r.related_email,
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
		r.shipping_phone,
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
		NULL AS item_weight_in_kg,
		r.quantity_booked,
		r.quantity_delivered,
		r.quantity_billed,
		r.quantity_marked_as_fulfilled,
		r.erp_id_of_delivery_note,
		r.erp_id_of_bill,
		NULL AS connected_order_erp_id,
		NULL AS connected_delivery_note_erp_id,
		r.item_is_deleted AS item_is_canceled,
		NULL AS cancelled_bill_erp_id,
		r.deletion_comment AS cancellation_comment,
		r.is_deleted AS is_canceled,
		r.processed,
		user,
		r.related_email_clean,
		r.user_type,
		r.shipping_name_clean,
		r.billing_city_clean,
		r.shipping_method,
		NULL AS payment_method,
		r.province,
		r.city_size,
		r.billing_country_standardized,
		r.shipping_country_standardized,
		r.gender,
		r.reminder_day,
		r.CT1_SKU,
		r.CT1_SKU_name,
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
		r.product_group,
		r.lens_type,
		r.is_color,
		r.wear_days,
		r.wear_duration,
		r.item_type,
		r.qty_per_storageunit,
		r.box_width,
		r.box_height,
		r.box_depth,
		NULL AS revenues_wdisc_in_local_currency,
		NULL AS revenues_wdisc_in_base_currency,
		NULL AS gross_margin_wodisc_in_base_currency,
		NULL AS gross_margin_wdisc_in_base_currency,
		NULL AS `gross_margin_wodisc_%`,
		NULL AS `gross_margin_wdisc_%`,		
		'orders' AS origin 
FROM CANCELLED_ORDERS_00f r

UNION

SELECT 	DISTINCT
		sz.sql_id, 
		sz.erp_id, 
		sz.reference_id, 
		sz.created,
		sz.fulfillment_date,
		sz.due_date, 
		sz.our_bank_account_number,
		NULL AS packaging_deadline,
		sz.related_division,
		sz.related_email,
		sz.billing_name,
		sz.billing_country,
		sz.billing_zip_code,
		sz.billing_city,
		sz.billing_address,
		sz.shipping_name,
		sz.shipping_country,
		sz.shipping_zip_code,
		sz.shipping_city,
		shipping_address,
		shipping_phone,
		related_warehouse,
		related_webshop,
		currency,
		exchange_rate_of_currency,
		related_comment,
		item_comment,
		item_vat_rate,
		item_net_purchase_price_in_base_currency,		
		item_net_sale_price_in_currency,
		item_gross_sale_price_in_currency,
		item_net_sale_price_in_base_currency,
		item_gross_sale_price_in_base_currency,
		item_quantity,
		unit_of_quantity_hun,
		unit_of_quantity_eng,
		item_net_value_in_currency,
		item_vat_value_in_currency,
		item_gross_value_in_currency,
		item_net_value,
		item_vat_value,
		item_gross_value,
		item_weight_in_kg,
		NULL AS quantity_booked,
		NULL AS quantity_delivered,
		NULL AS quantity_billed,
		NULL AS quantity_marked_as_fulfilled,
		connected_order_erp_id,
		connected_delivery_note_erp_id,
		NULL AS erp_id_of_delivery_note,
		NULL AS erp_id_of_bill,
		item_is_canceled,
		cancelled_bill_erp_id,
		cancellation_comment,
		is_canceled,
		processed,
		user,
		related_email_clean,
		user_type,
		shipping_name_clean,
		billing_city_clean,
		shipping_method,
		payment_method,
		province,
		city_size,
		billing_country_standardized,
		shipping_country_standardized,
		gender,
		reminder_day,
		CT1_SKU,
		CT1_SKU_name,
		CT2_pack,
		CT3_product,
		CT3_product_short,		
		CT4_product_brand,
		CT5_manufacturer,
		barcode,
		goods_nomenclature_code,
		packaging,
		quantity_in_a_pack,
		estimated_supplier_lead_time,
		product_group,
		lens_type,
		is_color,
		wear_days,
		wear_duration,
		item_type,
		qty_per_storageunit,
		box_width,
		box_height,
		box_depth,
		revenues_wdisc_in_local_currency,
		revenues_wdisc_in_base_currency,
		gross_margin_wodisc_in_base_currency,
		gross_margin_wdisc_in_base_currency,
		`gross_margin_wodisc_%`,
		`gross_margin_wdisc_%`,
		'invoices' AS origin 
FROM INVOICES_00h sz
;

ALTER TABLE BASE_00i_TABLE ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE BASE_00i_TABLE ADD INDEX (`sql_id`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX `erp_id` (`erp_id`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX `reference_id` (`reference_id`) USING BTREE;