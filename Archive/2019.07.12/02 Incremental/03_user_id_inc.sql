/* BASE TABLE feltöltése üres mezőkkel: START*/
ALTER TABLE BASE_00i_TABLE ADD `user_id` INT(10);
ALTER TABLE BASE_00i_TABLE ADD `cohort_id` VARCHAR(10) COMMENT 'Cohort ID (ev, honap)';
ALTER TABLE BASE_00i_TABLE ADD `first_purchase` DATETIME COMMENT 'Date of first purchase of the user (ev, honap, nap)';
ALTER TABLE BASE_00i_TABLE ADD `last_purchase` DATETIME COMMENT 'Date of last purchase of the user (ev, honap, nap)';
ALTER TABLE BASE_00i_TABLE ADD `one_before_last_purchase` DATETIME COMMENT 'Date of one before last purchase of the user (ev, honap, nap)';
ALTER TABLE BASE_00i_TABLE ADD `contact_lens_last_purchase` DATETIME COMMENT 'Date of last contact lens purchase of the user (ev, honap, nap)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_yearmonth` VARCHAR(10) COMMENT 'Year and month of invoicing (text)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_year` INT(4) COMMENT 'Year of invoicing (number)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_month` INT(2) COMMENT 'Month of invoicing (1 to 12, number)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_quarter` INT(1) COMMENT 'Quarter of invoicing (1 to 4, number)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_day_in_month` INT(2) COMMENT 'Calendar day of invoicing (1 to 31, number)';
ALTER TABLE BASE_00i_TABLE ADD `invoice_hour` INT(2) COMMENT 'Hour of invoicing (0 to 23, number, rounded down)';
ALTER TABLE BASE_00i_TABLE ADD `order_year` INT(4) COMMENT 'Year of order received (number)';
ALTER TABLE BASE_00i_TABLE ADD `order_month` INT(2) COMMENT 'Month of order received (1 to 12, number)';
ALTER TABLE BASE_00i_TABLE ADD `order_quarter` INT(1) COMMENT 'Quarter of order received (1 to 4, number)';
ALTER TABLE BASE_00i_TABLE ADD `order_day_in_month` INT(2) COMMENT 'Calendar day of order received (1 to 31, number)';
ALTER TABLE BASE_00i_TABLE ADD `order_hour` INT(2) COMMENT 'Hour of order received ( 1 to 24, number, rounded down)';
ALTER TABLE BASE_00i_TABLE ADD `order_weekday` INT(1) COMMENT 'Weekday code of order received (0=Monday, Sunday=6, number)';
ALTER TABLE BASE_00i_TABLE ADD `order_week_in_month` INT(1) COMMENT 'Monthly week code of order received (1 to 5, number)';
ALTER TABLE BASE_00i_TABLE ADD `cohort_month_since` INT(6) COMMENT 'Hanyadik honapban tortent a tranzakcio a user elso vasarlasa ota (amikor bekerult a cohortba). Csak számláknál értelmezhető!';
ALTER TABLE BASE_00i_TABLE ADD `user_cum_transactions` FLOAT COMMENT 'Hány tranzakciója volt eddig a usernek. Az ügyfelet leíró mező, nem a tételt vagy a rendelést!!!';
ALTER TABLE BASE_00i_TABLE ADD `user_cum_gross_revenue_in_base_currency` FLOAT COMMENT 'User kumulativ AFA-s arbevetele eddig';
ALTER TABLE BASE_00i_TABLE ADD `repeat_buyer` VARCHAR(20) COMMENT 'Visszatérő, vagy egyszeri vásárló';

ALTER TABLE BASE_00i_TABLE ADD `primary_email` VARCHAR(100) COMMENT 'Elsődleged email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.';
ALTER TABLE BASE_00i_TABLE ADD `secondary_email` VARCHAR(100) COMMENT 'Másodlagos email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.';
ALTER TABLE BASE_00i_TABLE ADD `primary_newsletter_flg` VARCHAR(100);
ALTER TABLE BASE_00i_TABLE ADD `secondary_newsletter_flg` VARCHAR(100);

ALTER TABLE BASE_00i_TABLE ADD `source` VARCHAR(100) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD `medium` VARCHAR(100) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD `campaign` VARCHAR(100) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD `trx_marketing_channel` VARCHAR(100) NOT NULL;

ALTER TABLE BASE_00i_TABLE ADD `item_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Net Price - in base currency';
ALTER TABLE BASE_00i_TABLE ADD `item_vat_in_base_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in base currency';
ALTER TABLE BASE_00i_TABLE ADD `item_gross_revenue_in_base_currency` FLOAT COMMENT 'Quantity * Gross Price - in HUF';
ALTER TABLE BASE_00i_TABLE ADD `time_order_to_dispatch` INT(10) COMMENT 'Elapsed time between order and dispatch in hours';
ALTER TABLE BASE_00i_TABLE ADD `time_dispatch_to_delivery` INT(10) COMMENT 'Elapsed time between dispatch and delivery in hours';
ALTER TABLE BASE_00i_TABLE ADD `source_of_trx` VARCHAR(20) COMMENT 'Online/offlien source of transaction';

ALTER TABLE BASE_00i_TABLE ADD multi_user_account VARCHAR(20);
ALTER TABLE BASE_00i_TABLE ADD pwr_eye1 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD pwr_eye2 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD last_shipping_method VARCHAR(100);
ALTER TABLE BASE_00i_TABLE ADD last_payment_method VARCHAR(100);
ALTER TABLE BASE_00i_TABLE ADD user_active_flg VARCHAR(20);
ALTER TABLE BASE_00i_TABLE ADD SKU_on_stock INT(2) COMMENT 'SKU is on stock. (0=no, 1=yes)';
ALTER TABLE BASE_00i_TABLE ADD newsletter_current VARCHAR(100) COMMENT 'Email address used for latest newsletter';
ALTER TABLE BASE_00i_TABLE ADD newsletter_ever INT(2) COMMENT 'Ever received a newsletter (0=no, 1=yes)';
ALTER TABLE BASE_00i_TABLE ADD loyalty_points DECIMAL(6,2) COMMENT 'Loyalty points earned by user';
ALTER TABLE BASE_00i_TABLE ADD trx_rank INT(10) NOT NULL DEFAULT 0;
ALTER TABLE BASE_00i_TABLE ADD typical_wear_days_eye1 INT(4);
ALTER TABLE BASE_00i_TABLE ADD typical_wear_days_eye2 INT(4);
ALTER TABLE BASE_00i_TABLE ADD typical_wear_duration_eye1 VARCHAR(32);
ALTER TABLE BASE_00i_TABLE ADD typical_wear_duration_eye2 VARCHAR(32);

ALTER TABLE BASE_00i_TABLE ADD bc_eye1 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD bc_eye2 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD cyl_eye1 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD cyl_eye2 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD ax_eye1 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD ax_eye2 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD dia_eye1 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD dia_eye2 DECIMAL(6,2);
ALTER TABLE BASE_00i_TABLE ADD add_eye1 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD add_eye2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD clr_eye1 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD clr_eye2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_type_eye1 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_type_eye2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT1 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT1_sku VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT1 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT1_sku VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_solution_CT2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_eye_drop_CT2 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT3 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT3 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_solution_CT3 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_eye_drop_CT3 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT4 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT4 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_solution_CT4 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_eye_drop_CT4 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye1_CT5 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_eye2_CT5 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_solution_CT5 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_eye_drop_CT5 VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_lens_pack_size VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_solution_pack_size VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD typical_eye_drop_pack_size VARCHAR(64);
ALTER TABLE BASE_00i_TABLE ADD contact_lens_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD solution_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD eye_drops_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD sunglass_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD vitamin_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD frames_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD lenses_for_spectacles_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD spectacles_user INT(1);
ALTER TABLE BASE_00i_TABLE ADD other_product_user INT(1);

ALTER TABLE BASE_00i_TABLE ADD contact_lens_trials_user INT(1);

ALTER TABLE BASE_00i_TABLE ADD date_lenses_run_out DATETIME COMMENT 'The date when placing a new order for a contact lens user is due.';
ALTER TABLE BASE_00i_TABLE ADD date_lens_cleaners_run_out DATETIME COMMENT 'The date when placing a new order for a solutions user is due.';
ALTER TABLE BASE_00i_TABLE ADD pickup_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD personal_geogr_region VARCHAR(32) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD LVCR_item_flg INT(1) NOT NULL;
ALTER TABLE BASE_00i_TABLE ADD experiment VARCHAR(255) DEFAULT NULL;
ALTER TABLE BASE_00i_TABLE ADD product_group_2 VARCHAR(100) DEFAULT NULL;
ALTER TABLE BASE_00i_TABLE ADD GDPR_status VARCHAR(100) DEFAULT NULL;

ALTER TABLE BASE_00i_TABLE CHANGE `sql_id` `item_id` INT(10);
ALTER TABLE BASE_00i_TABLE CHANGE `erp_id` `erp_invoice_id` VARCHAR(20);
ALTER TABLE BASE_00i_TABLE CHANGE `origin` `origin` VARCHAR(25) COMMENT 'Invoices = paid invoices; Orders = cancelled order. Invoices+Orders = all orders';
ALTER TABLE BASE_00i_TABLE CHANGE `created` `created` DATETIME COMMENT 'Date of entry creation. Hour and minute set to zero';
ALTER TABLE BASE_00i_TABLE CHANGE `fulfillment_date` `fulfillment_date` DATETIME COMMENT 'Fulfillment date from invoice';
ALTER TABLE BASE_00i_TABLE CHANGE `due_date` `due_date` DATETIME COMMENT '(Payment) Due date from invoice';
ALTER TABLE BASE_00i_TABLE CHANGE `payment_method` `payment_method` VARCHAR(255) COMMENT 'Payment method (values: Bankkártya, Kupon, Készpénz, Online fizetés, Paypal, Utánvét, Átutalás)';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_method` `shipping_method` VARCHAR(100) COMMENT 'Method of shipping: GLS, GPSe, MPL, Pick-Pack, Sprinter, Személyes átvétel, TOF';
ALTER TABLE BASE_00i_TABLE CHANGE `related_division` `related_division` VARCHAR(255) COMMENT 'Which business division generated the order: eOptika - HU, RO, IT, SK, UK';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_name` `billing_name` VARCHAR(255) COMMENT 'Billing info for user and other user data';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_country` `billing_country` VARCHAR(100) COMMENT 'Billing info for user';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_zip_code` `billing_zip_code` VARCHAR(20) COMMENT 'Billing info for user';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_city` `billing_city` VARCHAR(50) COMMENT 'Billing info for user';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_address` `billing_address` VARCHAR(255) COMMENT 'Billing info for user';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_name` `shipping_name` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_country` `shipping_country` VARCHAR(100) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_zip_code` `shipping_zip_code` VARCHAR(20) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_city` `shipping_city` VARCHAR(50) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_address` `shipping_address` VARCHAR(255) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_phone` `shipping_phone` VARCHAR(20) COMMENT 'Shipping info';
ALTER TABLE BASE_00i_TABLE CHANGE `real_name` `personal_name` VARCHAR(255) COMMENT 'Personal name of user';
ALTER TABLE BASE_00i_TABLE CHANGE `real_zip_code` `personal_zip_code` VARCHAR(20) COMMENT 'Zip code of place where user lives';
ALTER TABLE BASE_00i_TABLE CHANGE `real_country` `personal_country` VARCHAR(50) COMMENT 'Country where user lives';
ALTER TABLE BASE_00i_TABLE CHANGE `real_city` `personal_city` VARCHAR(50) COMMENT 'City where user lives';
ALTER TABLE BASE_00i_TABLE CHANGE `real_address` `personal_address` VARCHAR(255) COMMENT 'Personal address';
ALTER TABLE BASE_00i_TABLE CHANGE `real_province` `personal_province` VARCHAR(255) COMMENT 'Personal address';
ALTER TABLE BASE_00i_TABLE CHANGE `real_city_size` `personal_city_size` VARCHAR(255) COMMENT 'Personal address';
ALTER TABLE BASE_00i_TABLE CHANGE `related_webshop` `related_webshop` VARCHAR(50) COMMENT 'Webshop the order coming from: LenteContatto.it, b2b, eMAG.hu, eOptika.hu, lealkudtuk.hu, napszemuvegcenter.hu, napszemuvegplaza.hu, netoptika.ro, netoptika.sk, policenapszemuveg.hu, vatera.hu. Not every item has a value., From incoming_orders table';
ALTER TABLE BASE_00i_TABLE CHANGE `currency` `currency` VARCHAR(3) COMMENT 'Currency of the order (EUR, HUF, RON)';
ALTER TABLE BASE_00i_TABLE CHANGE `exchange_rate_of_currency` `exchange_rate_of_currency` FLOAT COMMENT 'Exchange rate - Hungarian Central Bank mid-rate.';
ALTER TABLE BASE_00i_TABLE CHANGE `related_comment` `related_comment` VARCHAR(255) COMMENT 'Comment written on the invoice - free text column, not useful';
ALTER TABLE BASE_00i_TABLE CHANGE `related_warehouse` `related_warehouse` VARCHAR(255) COMMENT 'Warehouse the item coming from (values: Anyagok - Teréz körút, Eszközök - Teréz körút, Baross utca, Teréz körút, Táblás utca)';
ALTER TABLE BASE_00i_TABLE CHANGE `item_type` `item_type` VARCHAR(2) COMMENT 'T - Termék (Product), S - Szolgáltatás (Service)';
ALTER TABLE BASE_00i_TABLE CHANGE `item_comment` `item_comment` VARCHAR(255) COMMENT 'Free text column for comments - manual and automamtic entries as well.';
ALTER TABLE BASE_00i_TABLE CHANGE `item_vat_rate` `item_vat_rate` FLOAT COMMENT 'VAT - country dependent';
ALTER TABLE BASE_00i_TABLE CHANGE `item_net_purchase_price_in_base_currency` `item_net_purchase_price_in_base_currency` FLOAT COMMENT 'Net purchase price in HUF - FIFO method.';
ALTER TABLE BASE_00i_TABLE CHANGE `item_net_sale_price_in_currency` `item_net_sale_price_in_currency` FLOAT COMMENT 'Net sale price - in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `item_gross_sale_price_in_currency` `item_gross_sale_price_in_currency` FLOAT COMMENT 'Gross sale price - in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `item_net_sale_price_in_base_currency` `item_net_sale_price_in_base_currency` FLOAT COMMENT 'Item net price in HUF';
ALTER TABLE BASE_00i_TABLE CHANGE `item_gross_sale_price_in_base_currency` `item_gross_sale_price_in_base_currency` FLOAT COMMENT 'Item gross price in HUF';
ALTER TABLE BASE_00i_TABLE CHANGE `item_quantity` `item_quantity` INT(10) COMMENT 'Quantity';
ALTER TABLE BASE_00i_TABLE CHANGE `unit_of_quantity_hun` `unit_of_quantity_hun` VARCHAR(20) COMMENT 'Unit HU';
ALTER TABLE BASE_00i_TABLE CHANGE `unit_of_quantity_eng` `unit_of_quantity_eng` VARCHAR(20) COMMENT 'Unit EN';
ALTER TABLE BASE_00i_TABLE CHANGE `item_weight_in_kg` `item_weight_in_kg` FLOAT COMMENT 'Weight of the item (from ITEMS table) * Quantity';
ALTER TABLE BASE_00i_TABLE CHANGE `connected_order_erp_id` `connected_order_erp_id` VARCHAR(20) COMMENT 'Refers to incoming_orders table erp_idq column.';
ALTER TABLE BASE_00i_TABLE CHANGE `connected_delivery_note_erp_id` `connected_delivery_note_erp_id` VARCHAR(20) COMMENT 'Refers to delivery_notes table erp_id column.';
ALTER TABLE BASE_00i_TABLE CHANGE `item_is_canceled` `item_is_canceled` VARCHAR(20) COMMENT 'Yes if order/item is deleted.';
ALTER TABLE BASE_00i_TABLE CHANGE `cancellation_comment` `cancellation_comment` VARCHAR(255) COMMENT 'Comment about cancellation - free text';
ALTER TABLE BASE_00i_TABLE CHANGE `is_canceled` `is_canceled` VARCHAR(20) COMMENT 'Yes if order/item is canceled. Melyikre kell szurni? Értékek: Yes, No, Élő, Storno';
ALTER TABLE BASE_00i_TABLE CHANGE `related_email_clean` `buyer_email` VARCHAR(100) COMMENT 'Megtisztitott email cim';
ALTER TABLE BASE_00i_TABLE CHANGE `user_type` `user_type` VARCHAR(20) COMMENT 'Vevo-kategorizalas (B2C, B2B, B2B2C, Egeszsegpenztar)';
ALTER TABLE BASE_00i_TABLE CHANGE `CT1_SKU` `CT1_SKU` VARCHAR(50) COMMENT 'SKU / SKU - Termektorzsbol SKU kod, elso szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `CT1_SKU_name` `CT1_SKU_name` VARCHAR(100) COMMENT 'Termektorzsbol SKU neve, elso szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `CT2_pack` `CT2_pack` VARCHAR(100) COMMENT 'Kiszereles / Pack - masodik szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `CT3_product` `CT3_product` VARCHAR(100) COMMENT 'Termek / Product - harmadik szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `CT3_product_short` `CT3_product_short` VARCHAR(100) COMMENT 'Termek / Product - harmadik szintu kategorizalas, de a szférikus és a tórikus összevonva';
ALTER TABLE BASE_00i_TABLE CHANGE `CT4_product_brand` `CT4_product_brand` VARCHAR(100) COMMENT 'Termekmarka / Product brand - negyedik szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `CT5_manufacturer` `CT5_manufacturer` VARCHAR(100) COMMENT 'Gyarto / Manufacturer - Gyarto neve, otodik szintu kategorizalas';
ALTER TABLE BASE_00i_TABLE CHANGE `product_group` `product_group` VARCHAR(255) COMMENT 'Lehetséges értékek: Lencse, Folyadek, Szemcsepp, Egyebek, Napszemuveg, Szemuveg, Szallitasi dij';
ALTER TABLE BASE_00i_TABLE CHANGE `lens_type` `lens_type` VARCHAR(100) COMMENT 'Lehetseges ertekek: Szferikus, Torikus, BiFokalis, Multifokalis, Ures. Torikusba betenni azokat, amik tobb kategoriaba is kerulhetnek. Progressziv lencsek a multifokalis kategoriakba keruljenek';
ALTER TABLE BASE_00i_TABLE CHANGE `is_color` `is_color` INT(1) COMMENT 'Színes-e a lencse?';
ALTER TABLE BASE_00i_TABLE CHANGE `wear_days` `wear_days` INT(3) COMMENT 'Mennyi ideig használható az egész doboz?';
ALTER TABLE BASE_00i_TABLE CHANGE `wear_duration` `wear_duration` VARCHAR(20) COMMENT 'Mennyi ideig használható egy db lencse a dobozból?';
ALTER TABLE BASE_00i_TABLE CHANGE `revenues_wdisc_in_local_currency` `revenues_wdisc_in_local_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `revenues_wdisc_in_base_currency` `revenues_wdisc_in_base_currency` FLOAT COMMENT 'Modositott arbevetel (kedvezmenyekkel korrigalt), in base currency';
ALTER TABLE BASE_00i_TABLE CHANGE `net_invoiced_shipping_costs_in_base_currency` `net_invoiced_shipping_costs_in_base_currency` FLOAT COMMENT 'Az a szállítási díj, ami a vevő ténylegesen kifizetett, in base currency';
ALTER TABLE BASE_00i_TABLE CHANGE `gross_margin_wodisc_in_base_currency` `gross_margin_wodisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (eredeti)';
ALTER TABLE BASE_00i_TABLE CHANGE `gross_margin_wdisc_in_base_currency` `gross_margin_wdisc_in_base_currency` FLOAT COMMENT 'Gross margin in base currency (modositott)';
ALTER TABLE BASE_00i_TABLE CHANGE `gross_margin_wodisc_%` `gross_margin_wodisc_%` FLOAT COMMENT 'Gross margin % (eredeti)';
ALTER TABLE BASE_00i_TABLE CHANGE `gross_margin_wdisc_%` `gross_margin_wdisc_%` FLOAT COMMENT 'Gross margin % (modositott)';
ALTER TABLE BASE_00i_TABLE CHANGE `trx_marketing_channel` `trx_marketing_channel` VARCHAR(100) COMMENT 'Marketing csatorna: melyik marketing csatornan jott be a megrendeles';
ALTER TABLE BASE_00i_TABLE CHANGE `net_margin_wodisc_in_base_currency` `net_margin_wodisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency (eredeti) Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_00i_TABLE CHANGE `net_margin_wdisc_in_base_currency` `net_margin_wdisc_in_base_currency` FLOAT COMMENT 'Net margin in base currency  (modositott)  Adam scriptje figyelebe vette egyedul itt a szallitasi dijbevetelt is';
ALTER TABLE BASE_00i_TABLE CHANGE `net_margin_wodisc_%` `net_margin_wodisc_%` FLOAT COMMENT 'Net margin % (eredeti)';
ALTER TABLE BASE_00i_TABLE CHANGE `net_margin_wdisc_%` `net_margin_wdisc_%` FLOAT COMMENT 'Net margin % (modositott)';
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_cost_in_base_currency` `shipping_cost_in_base_currency` FLOAT COMMENT 'Shipping cost in base currency';
ALTER TABLE BASE_00i_TABLE CHANGE `payment_cost_in_base_currency` `payment_cost_in_base_currency` FLOAT COMMENT 'Payment cost in base currency';
ALTER TABLE BASE_00i_TABLE CHANGE `packaging_cost_in_base_currency` `packaging_cost_in_base_currency` FLOAT COMMENT 'Packaging cost in base currency';
ALTER TABLE BASE_00i_TABLE CHANGE `barcode` `barcode` VARCHAR(100) COMMENT 'Barcode, From Adams items table';
ALTER TABLE BASE_00i_TABLE CHANGE `goods_nomenclature_code` `goods_nomenclature_code` VARCHAR(20) COMMENT 'Customs Tariff Number - CTN, From Adams items table';
ALTER TABLE BASE_00i_TABLE CHANGE `packaging` `packaging` VARCHAR(50) COMMENT 'Unit name of the item (tekercs, karton, etc), From Adams items table';
ALTER TABLE BASE_00i_TABLE CHANGE `quantity_in_a_pack` `quantity_in_a_pack` DOUBLE COMMENT 'How many item is in a pack., From Adams items table';
ALTER TABLE BASE_00i_TABLE CHANGE `estimated_supplier_lead_time` `estimated_supplier_lead_time` INT(3) COMMENT 'Estimated time of delivery, From Adams items table';
ALTER TABLE BASE_00i_TABLE CHANGE `qty_per_storage_unit` `qty_per_storage_unit` INT(6) COMMENT 'How many boxes fits a storage unit, From Adams item_groups table';
ALTER TABLE BASE_00i_TABLE CHANGE `box_width` `box_width` INT(6) COMMENT 'Box width, From Adams item_groups table';
ALTER TABLE BASE_00i_TABLE CHANGE `box_height` `box_height` INT(6) COMMENT 'Box height, From Adams item_groups table';
ALTER TABLE BASE_00i_TABLE CHANGE `box_depth` `box_depth` INT(6) COMMENT 'Box depth, From Adams item_groups table';
ALTER TABLE BASE_00i_TABLE CHANGE `pack_size` `pack_size` FLOAT(10,2) COMMENT 'Kiszerelés: a dobozban hány db lencse vagy ml folyadék van?';
ALTER TABLE BASE_00i_TABLE CHANGE `package_unit` `package_unit` VARCHAR(10) COMMENT 'Kiszerelés mértékegysége: db vagy ml?';

ALTER TABLE BASE_00i_TABLE CHANGE `product_introduction_dt` `product_introduction_dt` DATE COMMENT 'A termék bevezetésének a dátuma';
ALTER TABLE BASE_00i_TABLE CHANGE `lens_clr` `lens_clr` VARCHAR(25) COMMENT 'Lencse színe' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_add` `lens_add` VARCHAR(25) COMMENT 'Lencse ADD-je' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_dia` `lens_dia` DECIMAL(6,2) COMMENT 'Lencse DIA-je' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_ax` `lens_ax` DECIMAL(6,2) COMMENT 'Lencse AX-je' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_cyl` `lens_cyl` DECIMAL(6,2) COMMENT 'Lencse AX-je' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_pwr` `lens_pwr` DECIMAL(6,2) COMMENT 'Lencse cilinder értéke' AFTER wear_duration;
ALTER TABLE BASE_00i_TABLE CHANGE `lens_bc` `lens_bc` DECIMAL(6,2) COMMENT 'Lencse BC-je' AFTER wear_duration;

ALTER TABLE BASE_00i_TABLE CHANGE `item_net_value_in_currency` `item_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Net Price - in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `item_vat_value_in_currency` `item_vat_value_in_local_currency` FLOAT COMMENT 'Quantity * Price * VAT % - in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `item_gross_value_in_currency` `item_gross_revenue_in_local_currency` FLOAT COMMENT 'Quantity * Gross Price - in local currency';
ALTER TABLE BASE_00i_TABLE CHANGE `cancelled_bill_erp_id` `ERP_cancelled_invoice_ID` VARCHAR(255) COMMENT 'In case of cancelled order, the invoice number (erp_id) of the original order. Or the cancellation note ID in case of the original cancelled invoice.';
ALTER TABLE BASE_00i_TABLE CHANGE `processed` `last_modified_date` DATETIME COMMENT 'Last date something happened with the item (or anything with same erp_id)';
ALTER TABLE BASE_00i_TABLE CHANGE `user` `last_modified_by` VARCHAR(255) COMMENT 'User who created or last modified the item.';
ALTER TABLE BASE_00i_TABLE CHANGE `billing_country_standardized` `billing_country_standardized` VARCHAR(100) COMMENT 'English name of country of billing address' AFTER billing_country;
ALTER TABLE BASE_00i_TABLE CHANGE `shipping_country_standardized` `shipping_country_standardized` VARCHAR(100) COMMENT 'English name of country of shipment destination' AFTER shipping_country;



ALTER TABLE BASE_00i_TABLE ADD INDEX (`gender`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`user_id`) USING BTREE COMMENT 'Egyedi ügyfél azonosító';
ALTER TABLE BASE_00i_TABLE ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE BASE_00i_TABLE ADD INDEX (`secondary_email`) USING BTREE;


/* BASE TABLE feltöltése üres mezőkkel: END*/





UPDATE BASE_00i_TABLE AS m
    LEFT JOIN USER_01_returning_emails AS s 
		ON m.buyer_email = s.related_email_clean
SET    m.user_id = s.user_id
;


UPDATE BASE_00i_TABLE AS m
	LEFT JOIN USER_02_new_emails AS s 
		ON m.buyer_email = s.related_email_clean
SET m.user_id = s.user_id
	WHERE m.user_id IS NULL
;


UPDATE BASE_00i_TABLE AS m
	LEFT JOIN USER_37_matching_emails_plus_ID AS s
		ON m.billing_zip_code = s.billing_zip_code AND m.personal_name = s.real_name
SET m.user_id = s.user_id
WHERE m.user_id IS NULL
;


UPDATE BASE_00i_TABLE AS m
        LEFT JOIN
    USER_39_non_matching_emails AS s 
	ON m.billing_zip_code = s.billing_zip_code AND m.personal_name = s.real_name
SET
    m.user_id = s.user_id
WHERE m.user_id IS NULL
;



UPDATE BASE_00i_TABLE AS m
SET
    m.id = m.id + (select max(id) from BASE_03_TABLE)
;




/*SZÁMLÁK: a napi új tételeket hozzárakjuk a többi, historikusan összegyűjtött tételhez*/
INSERT INTO BASE_03_TABLE
SELECT *
FROM BASE_00i_TABLE
WHERE origin = 'invoices'
AND new_entry = 1
;



/*le kell nullázni a korábbi insertek new_entry flag-jeit, mielőtt az új tételeket insertáljuk*/
UPDATE BASE_03_TABLE
SET new_entry = 0
WHERE new_entry = 1
;

UPDATE INVOICES_00
SET new_entry = 0
WHERE new_entry = 1
;

UPDATE INVOICES_002
SET new_entry = 0
WHERE new_entry = 1
;


/*RENDELÉSEK: a korábbi tételeket le kell törölni és napi új tételeket hozzáadni a BASE_03_TABLE-hez*/

/*már nincs szükség a korábbi napi rendelésekre*/
DELETE
FROM BASE_03_TABLE
WHERE origin = 'orders'
;


INSERT INTO BASE_03_TABLE
SELECT *
FROM BASE_00i_TABLE
WHERE origin = 'orders'
;



/*   NÉV ÉS EMAIL NÉLKÜLIEK erp_invoice_id SZERINTI USER_ID KIOSZTÁSA   START */
UPDATE
BASE_03_TABLE
SET user_id = id*5
WHERE shipping_name = 'EOPTIKA KFT.'
OR 
(
LENGTH(buyer_email) <= 3 /* nincs email, se más azonosító */
AND  LENGTH(personal_name) <= 3 /* nincs név */
)
OR 
user_id is null
;
/*   NÉV ÉS EMAIL NÉLKÜLIEK erp_invoice_id SZERINTI USER_ID KIOSZTÁSA   END */
