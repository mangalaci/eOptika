/*1. le kell válogatni, hogy mely user_id-khez tartoznak az új vásárlások (erp_id)*/
DROP TABLE IF EXISTS user_id_list;
CREATE TABLE IF NOT EXISTS user_id_list
SELECT DISTINCT user_id
FROM BASE_00i_TABLE_inc
where origin = 'invoices'
and user_id is not null
;

ALTER TABLE user_id_list ADD INDEX `user_id` (`user_id`) USING BTREE;



/*2. le kell válogatni meglévő userek régi tételeit is, nem csak az újakat*/
DROP TABLE IF EXISTS item_list_union;
CREATE TABLE IF NOT EXISTS item_list_union
SELECT 	item_id,
		erp_invoice_id,
		user_id,
		shipping_phone,
		personal_name,
		personal_address,
		personal_zip_code,
		personal_city,
		personal_city_size,	
		personal_province,
		personal_country,	
		pickup_name,
		pickup_address,
		pickup_zip_code,
		pickup_city,
		pickup_city_size,	
		pickup_province,
		pickup_country,
		business_name,
		business_address,
		business_zip_code,
		business_city,
		business_city_size,
		business_province,
		business_country,
		health_insurance,
		catchment_area,
		personal_location_catchment_area,
		pickup_location_catchment_area,
		last_modified_date,
		billing_country_standardized,
		billing_zip_code,
		billing_city,
		shipping_country_standardized,
		shipping_zip_code,
		shipping_city,
		related_division,
		item_quantity,
		item_net_purchase_price_in_base_currency,
		item_net_sale_price_in_currency,
		item_gross_sale_price_in_currency,
		item_net_sale_price_in_base_currency,
		item_gross_sale_price_in_base_currency,
		item_revenue_in_local_currency,
		item_vat_value_in_local_currency,
		item_revenue_in_base_currency,
		item_vat_in_base_currency,
		item_gross_revenue_in_base_currency,
		user_type,
		gender,
		full_name,
		first_name,
		last_name,
		salutation,
		revenues_wdisc_in_local_currency,
		revenues_wdisc_in_base_currency,
		gross_margin_wodisc_in_base_currency,
		gross_margin_wdisc_in_base_currency,
		`gross_margin_wodisc_%`,
		`gross_margin_wdisc_%`,
		item_gross_revenue_in_local_currency,
		related_webshop,
		exchange_rate_of_currency,
		origin,
		net_margin_wodisc_in_base_currency,
		net_margin_wdisc_in_base_currency,
		`net_margin_wodisc_%`,
		`net_margin_wdisc_%`,
		net_invoiced_shipping_costs_in_base_currency,
		shipping_cost_in_base_currency,
		packaging_cost_in_base_currency,
		payment_cost_in_base_currency,
		date_lenses_run_out,
		date_lens_cleaners_run_out,
		contact_lens_last_purchase,
		created,
		product_group,
		newsletter_current,
		newsletter_ever,
		experiment,
		GDPR_status,
		user_cum_transactions,
		trx_rank,
		first_purchase,
		last_purchase,
		wear_days,
		wear_duration,
		multi_user_account,
		pwr_eye1,
		pwr_eye2,
		lens_pwr,
		lens_bc,
		lens_cyl,
		lens_ax,
		lens_dia,
		lens_add,
		lens_clr,
		lens_type,
		CT1_SKU_name,
		CT1_SKU,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		pack_size,
		shipping_method,
		payment_method,
		contact_lens_user,
		solution_user,
		eye_drops_user,
		sunglass_user,
		vitamin_user,
		frames_user,
		lenses_for_spectacles_user,
		contact_lens_trials_user,
		spectacles_user,
		other_product_user,
		typical_wear_duration_eye2,
		primary_email,
		secondary_email,
		buyer_email,
		time_order_to_dispatch,
		time_dispatch_to_delivery,
		order_year,
		order_month,
		order_day_in_month,
		connected_order_erp_id

FROM BASE_03_TABLE 
union all
SELECT 	item_id,
		erp_invoice_id,
		user_id,
		shipping_phone,
		personal_name,
		personal_address,
		personal_zip_code,
		personal_city,
		personal_city_size,	
		personal_province,
		personal_country,	
		pickup_name,
		pickup_address,
		pickup_zip_code,
		pickup_city,
		pickup_city_size,	
		pickup_province,
		pickup_country,
		business_name,
		business_address,
		business_zip_code,
		business_city,
		business_city_size,
		business_province,
		business_country,
		health_insurance,
		catchment_area,
		personal_location_catchment_area,
		pickup_location_catchment_area,
		last_modified_date,
		billing_country_standardized,
		billing_zip_code,
		billing_city,
		shipping_country_standardized,
		shipping_zip_code,
		shipping_city,
		related_division,
		item_quantity,
		item_net_purchase_price_in_base_currency,
		item_net_sale_price_in_currency,
		item_gross_sale_price_in_currency,
		item_net_sale_price_in_base_currency,
		item_gross_sale_price_in_base_currency,
		item_revenue_in_local_currency,
		item_vat_value_in_local_currency,
		item_revenue_in_base_currency,
		item_vat_in_base_currency,
		item_gross_revenue_in_base_currency,
		user_type,
		gender,
		full_name,
		first_name,
		last_name,
		salutation,
		revenues_wdisc_in_local_currency,
		revenues_wdisc_in_base_currency,
		gross_margin_wodisc_in_base_currency,
		gross_margin_wdisc_in_base_currency,
		`gross_margin_wodisc_%`,
		`gross_margin_wdisc_%`,
		item_gross_revenue_in_local_currency,
		related_webshop,
		exchange_rate_of_currency,
		origin,
		net_margin_wodisc_in_base_currency,
		net_margin_wdisc_in_base_currency,
		`net_margin_wodisc_%`,
		`net_margin_wdisc_%`,
		net_invoiced_shipping_costs_in_base_currency,
		shipping_cost_in_base_currency,
		packaging_cost_in_base_currency,
		payment_cost_in_base_currency,
		date_lenses_run_out,
		date_lens_cleaners_run_out,
		contact_lens_last_purchase,
		created,
		product_group,
		newsletter_current,
		newsletter_ever,
		experiment,
		GDPR_status,
		user_cum_transactions,
		trx_rank,
		first_purchase,
		last_purchase,
		wear_days,
		wear_duration,
		multi_user_account,
		pwr_eye1,
		pwr_eye2,
		lens_pwr,
		lens_bc,
		lens_cyl,
		lens_ax,
		lens_dia,
		lens_add,
		lens_clr,
		lens_type,
		CT1_SKU_name,
		CT1_SKU,
		CT2_pack,
		CT3_product,
		CT3_product_short,
		CT4_product_brand,
		CT5_manufacturer,
		pack_size,
		shipping_method,
		payment_method,
		contact_lens_user,
		solution_user,
		eye_drops_user,
		sunglass_user,
		vitamin_user,
		frames_user,
		lenses_for_spectacles_user,
		contact_lens_trials_user,
		spectacles_user,
		other_product_user,
		typical_wear_duration_eye2,
		primary_email,
		secondary_email,
		buyer_email,
		time_order_to_dispatch,
		time_dispatch_to_delivery,
		order_year,
		order_month,
		order_day_in_month,
		connected_order_erp_id
FROM BASE_00i_TABLE_inc
;


ALTER TABLE item_list_union ADD INDEX `user_id` (`user_id`) USING BTREE;





/*3. a AGGR_USER_UNSANITIZED_inc táblát csak a user_id_list táblában szereplő user_id-k halmazán kell létrehozni*/
drop table if exists AGGR_USER_UNSANITIZED_inc;
create table AGGR_USER_UNSANITIZED_inc (
    user_id int(10) comment 'Egyedi ügyfél azonosító',
	user_active_flg ENUM('active', 'inactive'),
    primary_email varchar(100) comment 'Elsődleges email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.',
    secondary_email varchar(100) comment 'Másodlagos email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.',
	shipping_phone varchar(20),
	personal_name varchar(255),
	personal_address varchar(255),
	personal_zip_code varchar(20),
	personal_city varchar(50),
	personal_city_size int(11),
	personal_province varchar(255),
	personal_country varchar(50),
	pickup_name varchar(255),
	pickup_address varchar(255),
	pickup_zip_code varchar(20),
	pickup_city varchar(50),
	pickup_city_size int(11),
	pickup_province varchar(255),
	pickup_country varchar(50),
	business_name varchar(255),
	business_address varchar(255),
	business_zip_code varchar(20),
	business_city varchar(50),
	business_city_size int(11),
	business_province varchar(255),
	business_country varchar(50),
	health_insurance varchar(100),
	catchment_area varchar(40),
	personal_location_catchment_area varchar(40),
	pickup_location_catchment_area varchar(40),
	num_of_orders int(11),
	num_of_items int(11),
	first_purchase TIMESTAMP NULL DEFAULT NULL,
	last_purchase TIMESTAMP NULL DEFAULT NULL ,
	one_before_last_purchase TIMESTAMP NULL DEFAULT NULL,
	billing_country_standardized varchar(50),
	billing_zip_code varchar(20),
	billing_city varchar(50),
	shipping_country_standardized varchar(50),
	shipping_zip_code  varchar(20),
	shipping_city varchar(50),
	related_division varchar(255),
	item_net_purchase_price_in_base_currency decimal(11),
	item_net_sale_price_in_currency decimal(11),
	item_gross_sale_price_in_currency decimal(11),
	item_net_sale_price_in_base_currency decimal(11),
	item_gross_sale_price_in_base_currency decimal(11),
	item_quantity int(11),
	item_revenue_in_local_currency decimal(14),
	item_vat_value_in_local_currency decimal(14),
	item_revenue_in_base_currency decimal(14),
	item_vat_in_base_currency decimal(14),
	item_gross_revenue_in_base_currency decimal(14),
	user_type varchar(20),
	gender varchar(20),
	user_age tinyint(1),
	full_name varchar(64),
	first_name varchar(64),
	last_name varchar(64),
	salutation varchar(64),
	revenues_wdisc_in_local_currency decimal(14),
	revenues_wdisc_in_base_currency decimal(14),
	gross_margin_wodisc_in_base_currency decimal(14),
	gross_margin_wdisc_in_base_currency decimal(14),
	`gross_margin_wodisc_%` decimal(14,2),
	`gross_margin_wdisc_%` decimal(14,2),
    primary_newsletter_flg varchar(30),
    secondary_newsletter_flg varchar(30),
	cohort_id varchar(7),
	cohort_month_since smallint(1),
	user_cum_transactions int(11),
	user_cum_gross_revenue_in_base_currency decimal(14,0),
	related_webshop varchar(50),
	net_margin_wodisc_in_base_currency int(11),
	net_margin_wdisc_in_base_currency int(11),
	`net_margin_wodisc_%` decimal(11,2),
	`net_margin_wdisc_%` decimal(11,2),
	net_invoiced_shipping_costs_in_base_currency int(11),
	shipping_cost_in_base_currency int(11),
	packaging_cost_in_base_currency int(11),
	payment_cost_in_base_currency int(11),
	repeat_buyer varchar(30),
	contact_lens_user tinyint(1),
	solution_user tinyint(1),
	eye_drops_user tinyint(1),
	sunglass_user tinyint(1),
	vitamin_user tinyint(1),
	frames_user tinyint(1),
	lenses_for_spectacles_user tinyint(1),
	contact_lens_trials_user tinyint(1),
	spectacles_user tinyint(1),
	other_product_user tinyint(1),
	first_year_contact_lens_revenues_wdisc_in_base_currency decimal(14,0),
	first_year_contact_lens_gross_margin_wdisc_in_base_currency decimal(14,0),
	first_year_contact_lens_net_margin_wodisc_in_base_currency decimal(14,0),
	first_year_contact_lens_boxes int(10),
	after_first_year_contact_lens_boxes int(10),
	first_year_contact_lens_projected_boxes decimal(10,2),
	first_year_contact_lens_overuse_ratio decimal(7,2),
	first_year_contact_lens_days_covered int(10),
	one_year_contact_lens_max_days_covered int(5),
	date_lenses_run_out TIMESTAMP NULL DEFAULT NULL,
	date_lens_cleaners_run_out TIMESTAMP NULL DEFAULT NULL,
	contact_lens_last_purchase TIMESTAMP NULL DEFAULT NULL,
	last_modified_date TIMESTAMP NULL DEFAULT NULL,
    multi_user_account ENUM('single user', 'multi user', 'no lens yet'),
    pwr_eye1 decimal(6,2),
    pwr_eye2 decimal(6,2),
    typical_wear_days_eye1 int(4),
    typical_wear_days_eye2 int(4),
    typical_wear_duration_eye1 varchar(30),
    typical_wear_duration_eye2 varchar(30),
	bc_eye1 decimal(6,2),
	bc_eye2 decimal(6,2),
	cyl_eye1 decimal(6,2),
	cyl_eye2 decimal(6,2),
	ax_eye1 decimal(6,2),
	ax_eye2 decimal(6,2),
	dia_eye1 decimal(6,2),
	dia_eye2 decimal(6,2),
	add_eye1 varchar(30),
	add_eye2 varchar(30),
	clr_eye1 varchar(30),
	clr_eye2 varchar(30),
	typical_lens_type_eye1 varchar(30),
	typical_lens_type_eye2 varchar(30),
	typical_lens_eye1_CT1 varchar(255),
	typical_lens_eye1_CT1_sku varchar(30),
	typical_lens_eye2_CT1 varchar(255),
	typical_lens_eye2_CT1_sku varchar(30),
	typical_lens_eye1_CT2 varchar(64),
	typical_lens_eye2_CT2 varchar(64),
	typical_solution_CT2 varchar(64),
	typical_eye_drop_CT2 varchar(64),
	typical_lens_eye1_CT3 varchar(64),
	typical_lens_eye2_CT3 varchar(64),
	typical_solution_CT3 varchar(64),
	typical_eye_drop_CT3 varchar(64),
	typical_lens_eye1_CT4 varchar(64),
	typical_lens_eye2_CT4 varchar(64),
	typical_solution_CT4 varchar(64),
	typical_eye_drop_CT4 varchar(64),
	typical_lens_eye1_CT5 varchar(64),
	typical_lens_eye2_CT5 varchar(64),
	typical_solution_CT5 varchar(64),
	typical_eye_drop_CT5 varchar(64),
	typical_lens_pack_size int(4),
	typical_solution_pack_size int(4),
	typical_eye_drop_pack_size int(4),
	last_shipping_method varchar(64),
	last_payment_method varchar(64),
	newsletter_current varchar(64),
	newsletter_ever int(2),
	loyalty_points decimal(10,2),
	experiment varchar(255),
	GDPR_status varchar(255),
	personal_geogr_region varchar(255),
	elso_lencse_CT2 varchar(255),
	elso_lencse_CT3 varchar(255),
	elso_folyadek_CT2 varchar(255),
	elso_folyadek_CT3 varchar(255),
	elso_szemcsepp_CT2 varchar(255),
	elso_lens_type varchar(255),
	elso_is_color int(1),
	elso_wear_days int(6),
	elso_wear_duration varchar(20),
	elso_pack_size int(6),
	elso_lens_too_slow_dispatch int(7),
	elso_shipping_method varchar(255),
	elso_payment_method varchar(255),
	elso_order_month  int(6),
	elso_order_weekday int(6),
	elso_order_week_in_month int(6),
	elso_source_of_trx varchar(255),
	elso_trx_marketing_channel varchar(255),
	elso_coupon_code varchar(255),
	elso_personal_geogr_region varchar(255),
	elso_pickup_geogr_region varchar(255),
	elso_contact_lens_vol int(6),
	elso_solution_vol int(6),
	elso_eye_drops_vol int(6),
	elso_order_value int(11),
	last_time_order_to_dispatch int(11),
	brand_switcher_same_manufacturer tinyint(1),
	brand_and_manufacturer_switcher tinyint(1),
	repeat_prediction varchar(55),
	active_prediction varchar(55),
	repeat_prediction_date TIMESTAMP NULL DEFAULT NULL,
	active_prediction_date TIMESTAMP NULL DEFAULT NULL,
	second_purchase_within_391_days varchar(55),
    constraint uix_user_id unique (user_id)
);




insert into AGGR_USER_UNSANITIZED_inc
select
		t.user_id,
		null as user_active_flg,
		null as primary_email,
		null as secondary_email,
		t.shipping_phone,
		t.personal_name,
		t.personal_address,
		t.personal_zip_code,
		t.personal_city,
		t.personal_city_size,	
		t.personal_province,
		t.personal_country,	
		t.pickup_name,
		t.pickup_address,
		t.pickup_zip_code,
		t.pickup_city,
		t.pickup_city_size,	
		t.pickup_province,
		t.pickup_country,
		t.business_name,
		t.business_address,
		t.business_zip_code,
		t.business_city,
		t.business_city_size,
		t.business_province,
		t.business_country,
		t.health_insurance,
		t.catchment_area,
		t.personal_location_catchment_area,
		t.pickup_location_catchment_area,
		count(distinct t.erp_invoice_id) as num_of_orders,
		count(t.item_id) as num_of_items,
		min(last_modified_date) as first_purchase,
		max(last_modified_date) as last_purchase,
		case when user_cum_transactions = trx_rank + 1 then last_modified_date else null end as one_before_last_purchase,
		t.billing_country_standardized,
		t.billing_zip_code,
		t.billing_city,
		t.shipping_country_standardized,
		t.shipping_zip_code,
		t.shipping_city,
		t.related_division,
		ROUND(SUM(t.item_net_purchase_price_in_base_currency*t.item_quantity),0) as item_net_purchase_price_in_base_currency,
		ROUND(SUM(t.item_net_sale_price_in_currency*t.item_quantity),0) as item_net_sale_price_in_currency,
		ROUND(SUM(t.item_gross_sale_price_in_currency*t.item_quantity),0) as item_gross_sale_price_in_currency,
		ROUND(SUM(t.item_net_sale_price_in_base_currency*t.item_quantity),0) as item_net_sale_price_in_base_currency,
		ROUND(SUM(t.item_gross_sale_price_in_base_currency*t.item_quantity),0) as item_gross_sale_price_in_base_currency,
		ROUND(SUM(t.item_quantity),0) as item_quantity,
		ROUND(SUM(t.item_revenue_in_local_currency),0) as item_revenue_in_local_currency,
		ROUND(SUM(t.item_vat_value_in_local_currency),0) as item_vat_value_in_local_currency,
		ROUND(SUM(t.item_revenue_in_base_currency),0) as item_revenue_in_base_currency,
		ROUND(SUM(t.item_vat_in_base_currency),0) as item_vat_in_base_currency,
		ROUND(SUM(t.item_gross_revenue_in_base_currency),0) as item_gross_revenue_in_base_currency,
		t.user_type,
		t.gender,
		null as user_age,
		t.full_name,
		t.first_name,
		t.last_name,
		t.salutation,
		ROUND(SUM(t.revenues_wdisc_in_local_currency),0) AS revenues_wdisc_in_local_currency,		
		ROUND(SUM(t.revenues_wdisc_in_base_currency),0) AS revenues_wdisc_in_base_currency,
		ROUND(SUM(t.gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(t.gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(t.`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(t.`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		null as primary_newsletter_flg,
		null as secondary_newsletter_flg,
		CONCAT(YEAR(MIN(t.last_modified_date)),'_',LPAD(MONTH(MIN(t.last_modified_date)),2,'0')) AS cohort_id,
		case when origin = 'invoices' then TIMESTAMPDIFF(month, min(last_modified_date), max(last_modified_date)) end as cohort_month_since,
		count(distinct t.erp_invoice_id) as user_cum_transactions,
		sum(t.item_gross_revenue_in_local_currency*t.exchange_rate_of_currency) as user_cum_gross_revenue_in_base_currency,
		t.related_webshop,
		SUM(t.net_margin_wodisc_in_base_currency) AS net_margin_wodisc_in_base_currency,
		SUM(t.net_margin_wdisc_in_base_currency) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(t.`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(t.`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,
		SUM(t.net_invoiced_shipping_costs_in_base_currency) AS net_invoiced_shipping_costs_in_base_currency,
		SUM(t.shipping_cost_in_base_currency) AS shipping_cost_in_base_currency,
		SUM(t.packaging_cost_in_base_currency) AS packaging_cost_in_base_currency,
		SUM(t.payment_cost_in_base_currency) AS payment_cost_in_base_currency,
		case 	when COUNT(DISTINCT t.erp_invoice_id) > 1 AND DATEDIFF(MAX(t.last_modified_date),MIN(t.last_modified_date)) > 30
				then 'repeat' 
				else '1-time' 
		end	as repeat_buyer,
		max(case when t.product_group = 'Contact lenses' then 1 else 0 end) as contact_lens_user,
		max(case when t.product_group = 'Contact lens cleaners' then 1 else 0 end) as solution_user,
		max(CASE WHEN t.product_group  = 'Eye drops' THEN 1 ELSE 0 END) as eye_drops_user,
		max(CASE WHEN t.product_group  = 'Sunglasses' THEN 1 ELSE 0 END) as sunglass_user,
		max(CASE WHEN t.product_group  = 'Vitamins' THEN 1 ELSE 0 END) as vitamin_user,
		max(CASE WHEN t.product_group  = 'Frames' THEN 1 ELSE 0 END) as frames_user,
		max(CASE WHEN t.product_group  = 'Lenses for spectacles' THEN 1 ELSE 0 END) as lenses_for_spectacles_user,
		max(CASE WHEN t.product_group  = 'Contact lenses - Trials' THEN 1 ELSE 0 END) as contact_lens_trials_user,
		max(CASE WHEN t.product_group  = 'Spectacles' THEN 1 ELSE 0 END) as spectacles_user,
		max(CASE WHEN t.product_group  = 'Other' THEN 1 ELSE 0 END) as other_product_user,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.revenues_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) as first_year_contact_lens_revenues_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.gross_margin_wdisc_in_base_currency ELSE 0 END ELSE 0 END), 0) as first_year_contact_lens_gross_margin_wdisc_in_base_currency,
		ROUND(SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.net_margin_wodisc_in_base_currency ELSE 0 END ELSE 0 END), 0) as first_year_contact_lens_net_margin_wodisc_in_base_currency,
		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(t.item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) as first_year_contact_lens_boxes,
		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  >= 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN ABS(t.item_quantity) /*abs a storno miatt kell*/ ELSE 0 END ELSE 0 END) as after_first_year_contact_lens_boxes,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END)), 2) AS first_year_contact_lens_projected_boxes,
		0 first_year_contact_lens_overuse_ratio,
		SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days*t.item_quantity ELSE 0 END ELSE 0 END) AS first_year_contact_lens_days_covered,
		720 AS one_year_contact_lens_max_days_covered,
		MAX(t.date_lenses_run_out) AS date_lenses_run_out,
		MAX(t.date_lens_cleaners_run_out) AS date_lens_cleaners_run_out,
		MAX(CASE WHEN t.product_group = 'Contact lenses' THEN t.last_modified_date END) as contact_lens_last_purchase,
		t.last_modified_date,
		null as multi_user_account,
		max(case when product_group = 'Contact lenses' and created between date_sub(case when t.product_group = 'Contact lenses' then t.last_modified_date end, INTERVAL 360 day) and case when t.product_group = 'Contact lenses' THEN t.last_modified_date END THEN lens_pwr END) AS pwr_eye1,
		CASE WHEN product_group = 'Contact lenses' AND created BETWEEN DATE_SUB(CASE WHEN t.product_group = 'Contact lenses' THEN t.last_modified_date END, INTERVAL 360 DAY) AND CASE WHEN t.product_group = 'Contact lenses' THEN t.last_modified_date END AND MAX(lens_pwr) = MIN(lens_pwr) THEN '' ELSE MIN(lens_pwr) END AS pwr_eye2,
		0 typical_wear_days_eye1,
		0 typical_wear_days_eye2,
		null typical_wear_duration_eye1,
		null typical_wear_duration_eye2,
		0 bc_eye1,
		0 bc_eye2,
		0 cyl_eye1,
		0 cyl_eye2,
		0 ax_eye1,
		0 ax_eye2,
		0 dia_eye1,
		0 dia_eye2,
		null add_eye1,
		null add_eye2,
		null clr_eye1,
		null clr_eye2,
		null typical_lens_type_eye1,
		null typical_lens_type_eye2,
		null typical_lens_eye1_CT1,
		null typical_lens_eye1_CT1_sku,
		null typical_lens_eye2_CT1,
		null typical_lens_eye2_CT1_sku,
		null typical_lens_eye1_CT2,
		null typical_lens_eye2_CT2,
		null typical_solution_CT2,
		null typical_eye_drop_CT2,
		null typical_lens_eye1_CT3,
		null typical_lens_eye2_CT3,
		null typical_solution_CT3,
		null typical_eye_drop_CT3,
		null typical_lens_eye1_CT4,
		null typical_lens_eye2_CT4,
		null typical_solution_CT4,
		null typical_eye_drop_CT4,
		null typical_lens_eye1_CT5,
		null typical_lens_eye2_CT5,
		null typical_solution_CT5,
		null typical_eye_drop_CT5,
		null typical_lens_pack_size,
		null typical_solution_pack_size,
		null typical_eye_drop_pack_size,
		case when t.last_purchase = t.last_modified_date then shipping_method end as last_shipping_method,
		case when t.last_purchase = t.last_modified_date then payment_method end as last_payment_method,
		t.newsletter_current,
		t.newsletter_ever,
		null loyalty_points,
		t.experiment,
		t.GDPR_status,
		case 
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN t.personal_province IN ('Budapest') AND SUBSTR(t.personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE t.personal_province
		END AS personal_geogr_region,
		null elso_lencse_CT2,
		null elso_lencse_CT3,
		null elso_folyadek_CT2,
		null elso_folyadek_CT3,
		null elso_szemcsepp_CT2,
		null elso_lens_type,
		null elso_is_color,
		null elso_wear_days,
		null elso_wear_duration,
		null elso_pack_size,	
		null elso_lens_too_slow_dispatch,
		null elso_shipping_method,
		null elso_payment_method,
		null elso_order_month,
		null elso_order_weekday,
		null elso_order_week_in_month,
		null elso_source_of_trx,
		null elso_trx_marketing_channel,
		null elso_coupon_code,
		null elso_personal_geogr_region,
		null elso_pickup_geogr_region,
		null elso_contact_lens_vol,
		null elso_solution_vol,
		null elso_eye_drops_vol,
		null elso_order_value,
		null last_time_order_to_dispatch,
		case when /*repeat_buyer = 'repeat' and multi_user_account = 'single user' and contact_lens_user = 1 and*/ product_group = 'Contact lenses' and count(DISTINCT CT3_product_short) > 1 and count(DISTINCT CT5_manufacturer) = 1 
			then 1 else 0 
		end as brand_switcher_same_manufacturer,
		case when /*repeat_buyer = 'repeat' and multi_user_account = 'single user' and contact_lens_user = 1 and*/ product_group = 'Contact lenses' and count(DISTINCT CT3_product_short) > 1 and count(DISTINCT CT5_manufacturer) > 1 
			then 1 else 0 
		end as brand_and_manufacturer_switcher,
		null repeat_prediction,
		null active_prediction,
		'9999-12-31' repeat_prediction_date,
		'9999-12-31' active_prediction_date,
		null second_purchase_within_391_days	
from (select * from item_list_union where user_id in (select user_id from user_id_list) order by created desc /*azért kell csökkenő sorrendben, mert ha a user_id alatt több név is van, akkor az utolsót vegyük*/) t
group by t.user_id
;



/* SINGLE-MULTIPLE USER BLOCK: START */
DROP TABLE IF EXISTS multiple_lens_user;
CREATE TABLE IF NOT EXISTS multiple_lens_user
SELECT z.user_id,
		CASE
			WHEN IFNULL(z.num_of_pwr_per_trx_over_limit,0) + z.pwr_diff_over_limit = 0 THEN 'single user'
			ELSE 'multi user'
		END AS multi_user_account
FROM
(
SELECT v.user_id,
/* ha 1 trx-ben több, mint 2-féle dioptria van (1 vagy 2 szemre ), akkor biztosan nem csak magának vette */
	CASE WHEN MAX(num_of_pwr_per_trx) > 2 THEN 1 ELSE 0
	END AS num_of_pwr_per_trx_over_limit,
/* ha 2 különböző trx (pwr+cyl) per tétel átlagának különbsége nagyobb, mint 0.25, amennyiben mind a két trx-ben legalább 2-féle lencse volt, akkor biztosan nem magának vette */
		CASE WHEN MAX(ABS(CASE WHEN num_of_pwr_per_trx > 1 THEN avg_pwr_per_item END))-MIN(ABS(CASE WHEN num_of_pwr_per_trx > 1 THEN avg_pwr_per_item END)) > 0.25  THEN 1 ELSE 0
		END AS pwr_diff_over_limit
FROM
(
SELECT 	user_id,
		erp_invoice_id,
		SUM(DISTINCT lens_pwr+IFNULL(lens_cyl,0))/COUNT(DISTINCT (lens_pwr+IFNULL(lens_cyl,0))) AS avg_pwr_per_item,
        COUNT(DISTINCT lens_pwr) AS num_of_pwr_per_trx
FROM item_list_union
WHERE origin = 'invoices'
AND product_group  = 'Contact lenses'
AND created BETWEEN DATE_SUB(CASE WHEN product_group = 'Contact lenses' THEN last_modified_date END, INTERVAL 360 DAY) AND CASE WHEN product_group = 'Contact lenses' THEN last_modified_date END
GROUP BY user_id, erp_invoice_id
) v
GROUP BY user_id
) z
;

ALTER TABLE multiple_lens_user ADD PRIMARY KEY (user_id);


UPDATE AGGR_USER_UNSANITIZED_inc as b
SET b.multi_user_account = (SELECT m.multi_user_account FROM multiple_lens_user as m WHERE b.user_id = m.user_id)
;

UPDATE AGGR_USER_UNSANITIZED_inc o 
SET o.multi_user_account = 'no lens yet'
WHERE o.multi_user_account IS NULL
;


/* SINGLE-MULTIPLE USER BLOCK: END */




/* AGGR_USER_UNSANITIZED visszatöltése a BASE_03_TABLE táblába: START */

UPDATE
BASE_00i_TABLE_inc AS u
INNER JOIN AGGR_USER_UNSANITIZED_inc r
ON r.user_id = u.user_id
SET 
	u.first_purchase = r.first_purchase,
	u.last_purchase = r.last_purchase,
	u.contact_lens_last_purchase = r.contact_lens_last_purchase,
	u.multi_user_account = r.multi_user_account,
	u.pwr_eye1 = r.pwr_eye1,
	u.pwr_eye2 = r.pwr_eye2,
	u.contact_lens_user = r.contact_lens_user,
	u.solution_user = r.solution_user,
	u.eye_drops_user = r.eye_drops_user,
	u.sunglass_user = r.sunglass_user,
	u.vitamin_user = r.vitamin_user,
	u.frames_user = r.frames_user,
	u.lenses_for_spectacles_user = r.lenses_for_spectacles_user,
	u.contact_lens_trials_user = r.contact_lens_trials_user,
	u.spectacles_user = r.spectacles_user,
	u.other_product_user = r.other_product_user
;


UPDATE
BASE_03_TABLE AS u
INNER JOIN AGGR_USER_UNSANITIZED_inc r
ON r.user_id = u.user_id
SET 
	u.first_purchase = r.first_purchase,
	u.last_purchase = r.last_purchase,
	u.contact_lens_last_purchase = r.contact_lens_last_purchase,
	u.multi_user_account = r.multi_user_account,
	u.pwr_eye1 = r.pwr_eye1,
	u.pwr_eye2 = r.pwr_eye2,
	u.contact_lens_user = r.contact_lens_user,
	u.solution_user = r.solution_user,
	u.eye_drops_user = r.eye_drops_user,
	u.sunglass_user = r.sunglass_user,
	u.vitamin_user = r.vitamin_user,
	u.frames_user = r.frames_user,
	u.lenses_for_spectacles_user = r.lenses_for_spectacles_user,
	u.contact_lens_trials_user = r.contact_lens_trials_user,
	u.spectacles_user = r.spectacles_user,
	u.other_product_user = r.other_product_user
;

UPDATE
item_list_union AS u
INNER JOIN AGGR_USER_UNSANITIZED_inc r
ON r.user_id = u.user_id
SET 
	u.first_purchase = r.first_purchase,
	u.last_purchase = r.last_purchase,
	u.contact_lens_last_purchase = r.contact_lens_last_purchase,
	u.multi_user_account = r.multi_user_account,
	u.pwr_eye1 = r.pwr_eye1,
	u.pwr_eye2 = r.pwr_eye2,
	u.contact_lens_user = r.contact_lens_user,
	u.solution_user = r.solution_user,
	u.eye_drops_user = r.eye_drops_user,
	u.sunglass_user = r.sunglass_user,
	u.vitamin_user = r.vitamin_user,
	u.frames_user = r.frames_user,
	u.lenses_for_spectacles_user = r.lenses_for_spectacles_user,
	u.contact_lens_trials_user = r.contact_lens_trials_user,
	u.spectacles_user = r.spectacles_user,
	u.other_product_user = r.other_product_user
;
/* AGGR_USER_UNSANITIZED visszatöltése a BASE_03_TABLE táblába: END */





/* TYPICAL LENS, SOUTION, EYE DROPS CALCULATION: START */



/*
https://stackoverflow.com/questions/34505799/how-to-pass-dynamic-table-name-into-mysql-procedure-with-this-query
*/

CALL TypicalProduct('typical_wear_days_eye1', 'pwr_eye1', 'wear_days', "'Contact lenses'");
ALTER TABLE typical_wear_days_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_days_eye2', 'pwr_eye2', 'wear_days', "'Contact lenses'");
ALTER TABLE typical_wear_days_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_duration_eye1', 'pwr_eye1', 'wear_duration', "'Contact lenses'");
ALTER TABLE typical_wear_duration_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_wear_duration_eye2', 'pwr_eye2', 'wear_duration', "'Contact lenses'");
ALTER TABLE typical_wear_duration_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('bc_eye1', 'pwr_eye1', 'lens_bc', "'Contact lenses'");
ALTER TABLE bc_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('bc_eye2', 'pwr_eye2', 'lens_bc', "'Contact lenses'");
ALTER TABLE bc_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('cyl_eye1', 'pwr_eye1', 'lens_cyl', "'Contact lenses'");
ALTER TABLE cyl_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('cyl_eye2', 'pwr_eye2', 'lens_cyl', "'Contact lenses'");
ALTER TABLE cyl_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('ax_eye1', 'pwr_eye1', 'lens_ax', "'Contact lenses'");
ALTER TABLE ax_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('ax_eye2', 'pwr_eye2', 'lens_ax', "'Contact lenses'");
ALTER TABLE ax_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('dia_eye1', 'pwr_eye1', 'lens_dia', "'Contact lenses'");
ALTER TABLE dia_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('dia_eye2', 'pwr_eye2', 'lens_dia', "'Contact lenses'");
ALTER TABLE dia_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('add_eye1', 'pwr_eye1', 'lens_add', "'Contact lenses'");
ALTER TABLE add_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('add_eye2', 'pwr_eye2', 'lens_add', "'Contact lenses'");
ALTER TABLE add_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('clr_eye1', 'pwr_eye1', 'lens_clr', "'Contact lenses'");
ALTER TABLE clr_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('clr_eye2', 'pwr_eye2', 'lens_clr', "'Contact lenses'");
ALTER TABLE clr_eye2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_type_eye1', 'pwr_eye1', 'lens_type', "'Contact lenses'");
ALTER TABLE typical_lens_type_eye1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_type_eye2', 'pwr_eye2', 'lens_type', "'Contact lenses'");
ALTER TABLE typical_lens_type_eye2 ADD PRIMARY KEY (user_id);


CALL TypicalProduct('typical_lens_eye1_CT1', 'pwr_eye1', 'CT1_SKU_name', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT1', 'pwr_eye2', 'CT1_SKU_name', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT1 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT1_sku', 'pwr_eye1', 'CT1_SKU', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT1_sku ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT1_sku', 'pwr_eye2', 'CT1_SKU', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT1_sku ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT2', 'pwr_eye1', 'CT2_pack', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT2', 'pwr_eye2', 'CT2_pack', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT2', 'lens_pwr', 'CT2_pack', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT2', 'lens_pwr', 'CT2_pack', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT2 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT3', 'pwr_eye1', 'CT3_product', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT3', 'pwr_eye2', 'CT3_product', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT3', 'lens_pwr', 'CT3_product', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT3', 'lens_pwr', 'CT3_product', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT3 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT4', 'pwr_eye1', 'CT4_product_brand', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT4', 'pwr_eye2', 'CT4_product_brand', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT4', 'lens_pwr', 'CT4_product_brand', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT4', 'lens_pwr', 'CT4_product_brand', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT4 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye1_CT5', 'pwr_eye1', 'CT5_manufacturer', "'Contact lenses'");
ALTER TABLE typical_lens_eye1_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_eye2_CT5', 'pwr_eye2', 'CT5_manufacturer', "'Contact lenses'");
ALTER TABLE typical_lens_eye2_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_CT5', 'lens_pwr', 'CT5_manufacturer', "'Contact lens cleaners'");
ALTER TABLE typical_solution_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_CT5', 'lens_pwr', 'CT5_manufacturer', "'Eye drops'");
ALTER TABLE typical_eye_drop_CT5 ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_lens_pack_size', 'lens_pwr', 'pack_size', "'Contact lenses'");
ALTER TABLE typical_lens_pack_size ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_solution_pack_size', 'lens_pwr', 'pack_size', "'Contact lens cleaners'");
ALTER TABLE typical_solution_pack_size ADD PRIMARY KEY (user_id);

CALL TypicalProduct('typical_eye_drop_pack_size', 'lens_pwr', 'pack_size', "'Eye drops'");
ALTER TABLE typical_eye_drop_pack_size ADD PRIMARY KEY (user_id);



/*ezt a sok UPDATE-et be lehetne dolgozni a CALL eljárásokba*/

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_wear_days_eye1 s
ON m.user_id = s.user_id
SET m.typical_wear_days_eye1 = s.typical_wear_days_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_wear_days_eye2 s
ON m.user_id = s.user_id
SET m.typical_wear_days_eye2 = s.typical_wear_days_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_wear_duration_eye1 s
ON m.user_id = s.user_id
SET m.typical_wear_duration_eye1 = s.typical_wear_duration_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_wear_duration_eye2 s
ON m.user_id = s.user_id
SET m.typical_wear_duration_eye2 = s.typical_wear_duration_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN bc_eye1 s
ON m.user_id = s.user_id
SET m.bc_eye1 = s.bc_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN bc_eye2 s
ON m.user_id = s.user_id
SET m.bc_eye2 = s.bc_eye2
;



UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN cyl_eye1 s
ON m.user_id = s.user_id
SET m.cyl_eye1 = s.cyl_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN cyl_eye2 s
ON m.user_id = s.user_id
SET m.cyl_eye2 = s.cyl_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN ax_eye1 s
ON m.user_id = s.user_id
SET m.ax_eye1 = s.ax_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN ax_eye2 s
ON m.user_id = s.user_id
SET m.ax_eye2 = s.ax_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN dia_eye1 s
ON m.user_id = s.user_id
SET m.dia_eye1 = s.dia_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN dia_eye2 s
ON m.user_id = s.user_id
SET m.dia_eye2 = s.dia_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN add_eye1 s
ON m.user_id = s.user_id
SET m.add_eye1 = s.add_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN add_eye2 s
ON m.user_id = s.user_id
SET m.add_eye2 = s.add_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN clr_eye1 s
ON m.user_id = s.user_id
SET m.clr_eye1 = s.clr_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN clr_eye2 s
ON m.user_id = s.user_id
SET m.clr_eye2 = s.clr_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_type_eye1 s
ON m.user_id = s.user_id
SET m.typical_lens_type_eye1 = s.typical_lens_type_eye1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_type_eye2 s
ON m.user_id = s.user_id
SET m.typical_lens_type_eye2 = s.typical_lens_type_eye2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT1 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT1 = s.typical_lens_eye1_CT1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT1_sku s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT1_sku = s.typical_lens_eye1_CT1_sku
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT1 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT1 = s.typical_lens_eye2_CT1
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT1_sku s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT1_sku = s.typical_lens_eye2_CT1_sku
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT2 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT2 = s.typical_lens_eye1_CT2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT2 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT2 = s.typical_lens_eye2_CT2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_solution_CT2 s
ON m.user_id = s.user_id
SET m.typical_solution_CT2 = s.typical_solution_CT2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_eye_drop_CT2 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT2 = s.typical_eye_drop_CT2
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT3 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT3 = s.typical_lens_eye1_CT3
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT3 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT3 = s.typical_lens_eye2_CT3
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_solution_CT3 s
ON m.user_id = s.user_id
SET m.typical_solution_CT3 = s.typical_solution_CT3
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_eye_drop_CT3 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT3 = s.typical_eye_drop_CT3
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT4 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT4 = s.typical_lens_eye1_CT4
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT4 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT4 = s.typical_lens_eye2_CT4
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_solution_CT4 s
ON m.user_id = s.user_id
SET m.typical_solution_CT4 = s.typical_solution_CT4
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_eye_drop_CT4 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT4 = s.typical_eye_drop_CT4
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye1_CT5 s
ON m.user_id = s.user_id
SET m.typical_lens_eye1_CT5 = s.typical_lens_eye1_CT5
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_eye2_CT5 s
ON m.user_id = s.user_id
SET m.typical_lens_eye2_CT5 = s.typical_lens_eye2_CT5
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_solution_CT5 s
ON m.user_id = s.user_id
SET m.typical_solution_CT5 = s.typical_solution_CT5
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_eye_drop_CT5 s
ON m.user_id = s.user_id
SET m.typical_eye_drop_CT5 = s.typical_eye_drop_CT5
;


UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_lens_pack_size s
ON m.user_id = s.user_id
SET m.typical_lens_pack_size = s.typical_lens_pack_size
;


UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_solution_pack_size s
ON m.user_id = s.user_id
SET m.typical_solution_pack_size = s.typical_solution_pack_size
;

UPDATE
AGGR_USER_UNSANITIZED_inc AS m
LEFT JOIN typical_eye_drop_pack_size s
ON m.user_id = s.user_id
SET m.typical_eye_drop_pack_size = s.typical_eye_drop_pack_size
;




/* TYPICAL LENS, SOUTION, EYE DROPS CALCULATION: END */



/* first_year_contact_lens_overuse_ratio: START */


DROP TABLE IF EXISTS user_active;
CREATE TABLE user_active
SELECT	user_id,
		max(case 	when t.contact_lens_user = 0 AND t.solution_user = 0 AND t.eye_drops_user = 0	THEN 'buy_me_once'
					when t.product_group = 'Contact lenses' 				THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > t.wear_days*t.item_quantity THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Contact lens cleaners' 		THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > 180 THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Eye drops' 					THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > 180 THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Shipping fees' 				THEN 'inactive'
					else 'inactive'
		end) as user_active_flg,
		CASE WHEN typical_wear_duration_eye2 IS NOT NULL THEN
			ROUND(
			((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END))))
			, 2) 
		ELSE 
			ROUND(
			((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END)))
			, 2) 	
		END	AS first_year_contact_lens_overuse_ratio /* függ attól, hogy egy, vagy két szemre hord lencsét*/
FROM 
(
SELECT 	z.user_id,
		z.created,
		z.product_group,
		z.item_quantity,
		z.last_modified_date,
		z.contact_lens_user,
		z.solution_user,
		z.eye_drops_user,
		z.typical_wear_duration_eye2,
		z.wear_days,
		z.first_purchase
FROM (select * from item_list_union where user_id in (select user_id from user_id_list) order by created desc) z
) t
GROUP BY t.user_id
;


ALTER TABLE user_active ADD PRIMARY KEY (`user_id`) USING BTREE;


UPDATE
AGGR_USER_UNSANITIZED_inc AS u
INNER JOIN 
(
SELECT	user_id,
		max(case 	when t.contact_lens_user = 0 AND t.solution_user = 0 AND t.eye_drops_user = 0	THEN 'buy_me_once'
					when t.product_group = 'Contact lenses' 				THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > t.wear_days*t.item_quantity THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Contact lens cleaners' 		THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > 180 THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Eye drops' 					THEN CASE WHEN DATEDIFF(CURDATE(), t.last_modified_date) > 180 THEN 'inactive' ELSE 'active' END
					when t.product_group = 'Shipping fees' 				THEN 'inactive'
					else 'inactive'
		end) as user_active_flg,
		CASE WHEN typical_wear_duration_eye2 IS NOT NULL THEN
			ROUND(
			((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END))))
			, 2) 
		ELSE 
			ROUND(
			((SUM(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN t.item_quantity ELSE 0 END ELSE 0 END)) / (360 / AVG(CASE WHEN DATEDIFF(t.created, first_purchase)  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN t.wear_days END END)))
			, 2) 	
		END	AS first_year_contact_lens_overuse_ratio /* függ attól, hogy egy, vagy két szemre hord lencsét*/
FROM (select * from item_list_union where user_id in (select user_id from user_id_list) order by created desc) t
GROUP BY t.user_id
) r
ON r.user_id = u.user_id
SET u.user_active_flg = r.user_active_flg,
	u.first_year_contact_lens_overuse_ratio = r.first_year_contact_lens_overuse_ratio
;

/* first_year_contact_lens_overuse_ratio: END */




/* ELSŐ VÁSÁRLÁS TULAJDONSÁGAI: START */





DROP TABLE IF EXISTS AGGR_ORDER_ABR_inc;
CREATE TABLE AGGR_ORDER_ABR_inc
SELECT 
erp_invoice_id,
contact_lens_vol,
solution_vol,
eye_drops_vol,
order_value
FROM AGGR_ORDER_inc
;

ALTER TABLE AGGR_ORDER_ABR_inc ADD PRIMARY KEY (`erp_invoice_id`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit_hi_vol;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit_hi_vol
SELECT 
CT1_sku,
AVG(time_order_to_dispatch) + STD(time_order_to_dispatch) AS tolerance_limit
FROM item_list_union
WHERE product_group = 'Contact lenses'
GROUP BY CT1_sku
HAVING COUNT(*) > 6
;

ALTER TABLE dispatch_time_tolerance_limit_hi_vol ADD PRIMARY KEY (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit_lo_vol;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit_lo_vol
SELECT a.CT1_sku, b.tolerance_limit
FROM
(
SELECT 
CT1_sku,
CT2_sku,
COUNT(*)
FROM `BASE_03_TABLE`
WHERE product_group = 'Contact lenses'
GROUP BY CT1_sku, CT2_sku
HAVING COUNT(*) <= 6
ORDER BY 3 DESC
) a
LEFT JOIN
(
SELECT 
CT2_sku,
AVG(time_order_to_dispatch) + STD(time_order_to_dispatch) AS tolerance_limit,
COUNT(*)
FROM `BASE_03_TABLE`
WHERE product_group = 'Contact lenses'
GROUP BY CT2_sku
ORDER BY 3 DESC
) b
ON a.CT2_sku = b.CT2_sku
;

ALTER TABLE dispatch_time_tolerance_limit_lo_vol ADD PRIMARY KEY (`CT1_sku`) USING BTREE;


DROP TABLE IF EXISTS dispatch_time_tolerance_limit;
CREATE TABLE IF NOT EXISTS dispatch_time_tolerance_limit
SELECT *
FROM dispatch_time_tolerance_limit_hi_vol
UNION
SELECT *
FROM dispatch_time_tolerance_limit_lo_vol
;

ALTER TABLE dispatch_time_tolerance_limit ADD PRIMARY KEY (`CT1_sku`) USING BTREE;



UPDATE
AGGR_USER_UNSANITIZED_inc AS u
INNER JOIN 
(
SELECT user_id,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN CT2_pack END) AS elso_lencse_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN CT3_product_short END) AS elso_lencse_CT3,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lens cleaners' THEN CT2_pack END) AS elso_folyadek_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lens cleaners' THEN CT3_product_short END) AS elso_folyadek_CT3,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Eye drops' THEN CT2_pack END) AS elso_szemcsepp_CT2,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN lens_type END) AS elso_lens_type,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN is_color END) AS elso_is_color,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN wear_days END) AS elso_wear_days,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN wear_duration END) AS elso_wear_duration,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id AND t.product_group = 'Contact lenses' THEN pack_size END) AS elso_pack_size,
		null as elso_lens_too_slow_dispatch,
		
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.shipping_method END) AS elso_shipping_method,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.payment_method END) AS elso_payment_method,		
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_month END) AS elso_order_month,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_weekday END) AS elso_order_weekday,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.order_week_in_month END) AS elso_order_week_in_month,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.source_of_trx END) AS elso_source_of_trx,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.trx_marketing_channel END) AS elso_trx_marketing_channel,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.coupon_code END) AS elso_coupon_code,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.personal_geogr_region END) AS elso_personal_geogr_region,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN t.pickup_geogr_region END) AS elso_pickup_geogr_region,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.contact_lens_vol END) AS elso_contact_lens_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.solution_vol END) AS elso_solution_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.eye_drops_vol END) AS elso_eye_drops_vol,
		MIN(CASE WHEN CONCAT(YEAR(t.created),'_',LPAD(MONTH(t.created),2,'0')) = t.cohort_id THEN o.order_value END) AS elso_order_value,
		CASE WHEN DATE(created) = DATE(last_purchase) THEN time_order_to_dispatch END AS last_time_order_to_dispatch
		FROM (SELECT * FROM BASE_03_TABLE WHERE origin = 'invoices' ORDER BY created DESC) t
LEFT JOIN AGGR_ORDER_ABR o
ON t.erp_invoice_id = o.erp_invoice_id
GROUP BY t.user_id
ORDER BY t.created
) r
ON r.user_id = u.user_id
SET 
	u.elso_lencse_CT2 = r.elso_lencse_CT2,
	u.elso_lencse_CT3 = r.elso_lencse_CT3,
	u.elso_folyadek_CT2 = r.elso_folyadek_CT2,
	u.elso_folyadek_CT3 = r.elso_folyadek_CT3,
	u.elso_szemcsepp_CT2 = r.elso_szemcsepp_CT2,
	u.elso_lens_type = r.elso_lens_type,
	u.elso_is_color = r.elso_is_color,
	u.elso_wear_days = r.elso_wear_days,
	u.elso_wear_duration = r.elso_wear_duration,
	u.elso_pack_size = r.elso_pack_size,	
	u.elso_lens_too_slow_dispatch = r.elso_lens_too_slow_dispatch,
	u.elso_shipping_method = r.elso_shipping_method,
	u.elso_payment_method = r.elso_payment_method,
	u.elso_order_month = r.elso_order_month,
	u.elso_order_weekday = r.elso_order_weekday,
	u.elso_order_week_in_month = r.elso_order_week_in_month,
	u.elso_source_of_trx = r.elso_source_of_trx,
	u.elso_trx_marketing_channel = r.elso_trx_marketing_channel,
	u.elso_coupon_code = r.elso_coupon_code,
	u.elso_personal_geogr_region = r.elso_personal_geogr_region,
	u.elso_pickup_geogr_region = r.elso_pickup_geogr_region,
	u.elso_contact_lens_vol = r.elso_contact_lens_vol,
	u.elso_solution_vol = r.elso_solution_vol,
	u.elso_eye_drops_vol = r.elso_eye_drops_vol,
	u.elso_order_value = r.elso_order_value,
	u.last_time_order_to_dispatch = r.last_time_order_to_dispatch
;

*/



/* ELSŐ VÁSÁRLÁS TULAJDONSÁGAI: END */





/* ACTIVE-INACTIVE PREDICTION: START */

UPDATE
AGGR_USER_UNSANITIZED_inc AS u
INNER JOIN 
(
SELECT	user_id,
		CASE 	WHEN TRIM(t.primary_email) = '.eoptika kft.@eoptikafiktiv.hu' THEN NULL
				WHEN TRIM(p.pred) = 1 THEN '1-time'
				WHEN TRIM(p.pred) = 2 THEN 'repeat'
				ELSE NULL 
		END AS repeat_prediction,
		CASE 	WHEN TRIM(t.primary_email) = '.eoptika kft.@eoptikafiktiv.hu' THEN NULL
				WHEN TRIM(p_i.pred) = 1 THEN 'active'
				WHEN TRIM(p_i.pred) = 2 THEN 'inactive'
				ELSE NULL 
		END AS active_prediction,
		'2018-01-07' AS repeat_prediction_date,
		'2018-01-07' AS active_prediction_date,
		MAX(CASE 
				WHEN t.trx_rank = 2 AND DATEDIFF(t.created, t.first_purchase)  < 391 THEN 'yes'
				ELSE 'no'
		END) AS second_purchase_within_391_days
		
		FROM (select * from item_list_union where user_id in (select user_id from user_id_list) order by created desc) t
LEFT JOIN prediction_1_time p
ON t.primary_email = p.email
LEFT JOIN prediction_inactive p_i
ON t.primary_email = p_i.email
GROUP BY t.user_id
) s
ON u.user_id = s.user_id
SET u.repeat_prediction = s.repeat_prediction,
	u.repeat_prediction_date = s.repeat_prediction_date,
	u.active_prediction = s.active_prediction,
	u.active_prediction_date = s.active_prediction_date,
	u.second_purchase_within_391_days = s.second_purchase_within_391_days
;


/* ACTIVE-INACTIVE PREDICTION: END */







/* PRIMARY / SECONDARY EMAIL: START */

/* hányszor vásárolt az adott email címmel az a user, akinek több email címe van */
DROP TABLE IF EXISTS user_by_email;
CREATE TABLE IF NOT EXISTS user_by_email
SELECT user_id, buyer_email, MAX(created) AS last_email_usage, COUNT(DISTINCT erp_invoice_id) AS num_of_email_usage
FROM item_list_union
WHERE buyer_email LIKE '%@%'
AND origin = 'invoices'
GROUP BY user_id, buyer_email
;

ALTER TABLE user_by_email ADD INDEX (`buyer_email`) USING BTREE;
ALTER TABLE user_by_email ADD INDEX (`user_id`) USING BTREE;



SET @prev := null;
SET @cnt := 1;

DROP TABLE IF EXISTS user_by_email_rank;
CREATE TABLE IF NOT EXISTS user_by_email_rank
SELECT t.user_id, t.buyer_email, t.last_email_usage, num_of_email_usage, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS email_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, buyer_email, last_email_usage, num_of_email_usage FROM user_by_email ORDER BY user_id) as t
ORDER BY t.user_id, t.last_email_usage DESC
;

ALTER TABLE user_by_email_rank ADD INDEX (`buyer_email`) USING BTREE;
ALTER TABLE user_by_email_rank ADD INDEX (`user_id`) USING BTREE;

DROP TABLE IF EXISTS user_by_email_tab;
CREATE TABLE IF NOT EXISTS user_by_email_tab
SELECT 	user_id, 
		CASE WHEN email_rank = 1 THEN buyer_email END AS buyer_email_1, 
		CASE WHEN email_rank = 2 THEN buyer_email END AS buyer_email_2,
		CASE WHEN email_rank = 3 THEN buyer_email END AS buyer_email_3,
		CASE WHEN email_rank = 4 THEN buyer_email END AS buyer_email_4,
		CASE WHEN email_rank = 5 THEN buyer_email END AS buyer_email_5,
		CASE WHEN email_rank = 6 THEN buyer_email END AS buyer_email_6,
		CASE WHEN email_rank = 7 THEN buyer_email END AS buyer_email_7,
		CASE WHEN email_rank = 8 THEN buyer_email END AS buyer_email_8,
		CASE WHEN email_rank = 8 THEN buyer_email END AS buyer_email_9,

		CASE WHEN email_rank = 1 THEN last_email_usage END AS last_email_usage_1, 
		CASE WHEN email_rank = 2 THEN last_email_usage END AS last_email_usage_2,
		CASE WHEN email_rank = 3 THEN last_email_usage END AS last_email_usage_3,
		CASE WHEN email_rank = 4 THEN last_email_usage END AS last_email_usage_4,
		CASE WHEN email_rank = 5 THEN last_email_usage END AS last_email_usage_5,
		CASE WHEN email_rank = 6 THEN last_email_usage END AS last_email_usage_6,
		CASE WHEN email_rank = 7 THEN last_email_usage END AS last_email_usage_7,
		CASE WHEN email_rank = 8 THEN last_email_usage END AS last_email_usage_8,
		CASE WHEN email_rank = 8 THEN last_email_usage END AS last_email_usage_9,

		CASE WHEN email_rank = 1 THEN num_of_email_usage END AS num_of_email_usage_1, 
		CASE WHEN email_rank = 2 THEN num_of_email_usage END AS num_of_email_usage_2,
		CASE WHEN email_rank = 3 THEN num_of_email_usage END AS num_of_email_usage_3,
		CASE WHEN email_rank = 4 THEN num_of_email_usage END AS num_of_email_usage_4,
		CASE WHEN email_rank = 5 THEN num_of_email_usage END AS num_of_email_usage_5,
		CASE WHEN email_rank = 6 THEN num_of_email_usage END AS num_of_email_usage_6,
		CASE WHEN email_rank = 7 THEN num_of_email_usage END AS num_of_email_usage_7,
		CASE WHEN email_rank = 8 THEN num_of_email_usage END AS num_of_email_usage_8,
		CASE WHEN email_rank = 8 THEN num_of_email_usage END AS num_of_email_usage_9
FROM user_by_email_rank
;


ALTER TABLE user_by_email_tab ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);


DROP TABLE IF EXISTS user_by_email_01;
CREATE TABLE IF NOT EXISTS user_by_email_01
SELECT 	user_id, 
		CASE WHEN id = 1 THEN MAX(buyer_email_2) ELSE MAX(buyer_email_1) END AS buyer_email_1,
		CASE WHEN id = 1 THEN MAX(buyer_email_3) ELSE MAX(buyer_email_2) END AS buyer_email_2,
		CASE WHEN id = 1 THEN MAX(buyer_email_4) ELSE MAX(buyer_email_3) END AS buyer_email_3,
		MAX(buyer_email_4) AS buyer_email_4,
		MAX(buyer_email_5) AS buyer_email_5,
		MAX(buyer_email_6) AS buyer_email_6,
		MAX(buyer_email_7) AS buyer_email_7,
		MAX(buyer_email_8) AS buyer_email_8,
		MAX(buyer_email_9) AS buyer_email_9,

		CASE WHEN id = 1 THEN MAX(last_email_usage_2) ELSE MAX(last_email_usage_1) END AS last_email_usage_1,
		CASE WHEN id = 1 THEN MAX(last_email_usage_3) ELSE MAX(last_email_usage_2) END AS last_email_usage_2,
		CASE WHEN id = 1 THEN MAX(last_email_usage_4) ELSE MAX(last_email_usage_3) END AS last_email_usage_3,
		MAX(last_email_usage_4) AS last_email_usage_4,
		MAX(last_email_usage_5) AS last_email_usage_5,
		MAX(last_email_usage_6) AS last_email_usage_6,
		MAX(last_email_usage_7) AS last_email_usage_7,
		MAX(last_email_usage_8) AS last_email_usage_8,
		MAX(last_email_usage_9) AS last_email_usage_9,

		CASE WHEN id = 1 THEN MAX(num_of_email_usage_2) ELSE MAX(num_of_email_usage_1) END AS num_of_email_usage_1,
		CASE WHEN id = 1 THEN MAX(num_of_email_usage_3) ELSE MAX(num_of_email_usage_2) END AS num_of_email_usage_2,
		CASE WHEN id = 1 THEN MAX(num_of_email_usage_4) ELSE MAX(num_of_email_usage_3) END AS num_of_email_usage_3,
		MAX(num_of_email_usage_4) AS num_of_email_usage_4,
		MAX(num_of_email_usage_5) AS num_of_email_usage_5,
		MAX(num_of_email_usage_6) AS num_of_email_usage_6,
		MAX(num_of_email_usage_7) AS num_of_email_usage_7,
		MAX(num_of_email_usage_8) AS num_of_email_usage_8,
		MAX(num_of_email_usage_9) AS num_of_email_usage_9
FROM user_by_email_tab
GROUP BY user_id
;

ALTER TABLE user_by_email_01 ADD PRIMARY KEY (`user_id`) USING BTREE;

DROP TABLE IF EXISTS user_by_email_02;
CREATE TABLE IF NOT EXISTS user_by_email_02
SELECT 	a.*,
		IF(DATEDIFF(last_email_usage_1,last_email_usage_2)>180, buyer_email_1, IF(num_of_email_usage_2>num_of_email_usage_1, buyer_email_2, buyer_email_1)) AS primary_email
FROM user_by_email_01 a
;

ALTER TABLE user_by_email_02 ADD PRIMARY KEY (`user_id`) USING BTREE;


DROP TABLE IF EXISTS user_by_email_03;
CREATE TABLE IF NOT EXISTS user_by_email_03
SELECT 	a.*,
		IF(buyer_email_2 = primary_email, buyer_email_1, buyer_email_2) AS secondary_email
FROM user_by_email_02 a
;

ALTER TABLE user_by_email_03 ADD PRIMARY KEY (`user_id`) USING BTREE;


DROP TABLE IF EXISTS user_by_email_04;
CREATE TABLE IF NOT EXISTS user_by_email_04
SELECT DISTINCT a.user_id,
IF(b.primary_email <> '', REPLACE(REPLACE(special_char_replace(b.primary_email),' ',''),'  ',''), REPLACE(REPLACE(special_char_replace(a.buyer_email),' ',''),'  ',''))
	AS primary_email,
	REPLACE(REPLACE(special_char_replace(b.secondary_email),' ',''),'  ','') AS secondary_email
FROM (select * from item_list_union where user_id in (select user_id from user_id_list)) AS a
LEFT JOIN user_by_email_03 AS b
ON a.user_id = b.user_id
;



ALTER TABLE user_by_email_04 ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE user_by_email_04 ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE user_by_email_04 ADD INDEX (`secondary_email`) USING BTREE;
ALTER TABLE user_by_email_04 ADD INDEX (`user_id`) USING BTREE;




UPDATE
AGGR_USER_UNSANITIZED_inc AS c
LEFT JOIN user_by_email_04 AS g 
ON c.user_id = g.user_id
SET
c.primary_email = /* keresztnev.csaladnev@eoptikafiktiv.hu email cím hozzátétele, ha nincs email cím megadva */
  IF(LENGTH(g.primary_email) - LENGTH(REPLACE(g.primary_email, '@', '')) = 0, CONCAT(LOWER(TRIM(c.first_name)), '.', LOWER(TRIM(c.last_name)), '@eoptikafiktiv.hu'), g.primary_email)
, c.secondary_email = g.secondary_email
;


UPDATE AGGR_USER_UNSANITIZED_inc SET primary_email = 'email_blacklist' WHERE primary_email = 'evagorda@gmail.com';
UPDATE AGGR_USER_UNSANITIZED_inc SET secondary_email = 'email_blacklist' WHERE secondary_email = 'evagorda@gmail.com';




/* PRIMARY / SECONDARY EMAIL: END */




/*   N E W S L E T T E R:   S T A R T   */

UPDATE
AGGR_USER_UNSANITIZED_inc AS c
LEFT JOIN IN_subscribe AS g 
ON g.email = c.primary_email
SET
c.primary_newsletter_flg =
  IF(g.email IS NOT NULL, 'subscribed', 'never subscribed')
;


UPDATE
AGGR_USER_UNSANITIZED_inc AS c
LEFT JOIN IN_subscribe AS g 
ON g.email = c.secondary_email
SET
c.secondary_newsletter_flg =
  IF(g.email IS NOT NULL, 'subscribed', 'never subscribed')
;

/*   N E W S L E T T E R:   E N D   */




/*   U S E R  A G E:   S T A R T   */

ALTER TABLE AGGR_USER_UNSANITIZED_inc ADD INDEX (`primary_email`) USING BTREE;
ALTER TABLE AGGR_USER_UNSANITIZED_inc ADD INDEX (`secondary_email`) USING BTREE;



UPDATE
AGGR_USER_UNSANITIZED_inc AS c
inner JOIN IN_user_szulido AS g 
	ON g.email = c.primary_email
SET
	c.user_age = round(DATEDIFF(CURRENT_DATE, g.szulido)/365)
;


UPDATE
AGGR_USER_UNSANITIZED_inc AS c
inner JOIN IN_user_szulido AS g 
	ON g.email = c.secondary_email and c.user_age is null
SET
	c.user_age = round(DATEDIFF(CURRENT_DATE, g.szulido)/365)
;



/*   U S E R  A G E:   E N D   */


/* AGGR_USER_UNSANITIZED_inc visszatöltése a BASE_03_TABLE táblába: START */

UPDATE
BASE_00i_TABLE_inc AS u
INNER JOIN AGGR_USER_UNSANITIZED_inc r
ON r.user_id = u.user_id
SET	u.user_active_flg = r.user_active_flg,
	u.one_before_last_purchase = r.one_before_last_purchase,
	u.cohort_id = r.cohort_id,
	u.cohort_month_since = r.cohort_month_since,
	u.user_cum_transactions = r.user_cum_transactions,
	u.user_cum_gross_revenue_in_base_currency = r.user_cum_gross_revenue_in_base_currency,
	u.repeat_buyer = r.repeat_buyer,
	u.typical_wear_days_eye1 = r.typical_wear_days_eye1,
	u.typical_wear_days_eye2 = r.typical_wear_days_eye2,
	u.typical_wear_duration_eye1 = r.typical_wear_duration_eye1,
	u.typical_wear_duration_eye2 = r.typical_wear_duration_eye2,
	u.bc_eye1 = r.bc_eye1,
	u.bc_eye2 = r.bc_eye2,
	u.cyl_eye1 = r.cyl_eye1,
	u.cyl_eye2 = r.cyl_eye2,
	u.ax_eye1 = r.ax_eye1,
	u.ax_eye2 = r.ax_eye2,
	u.dia_eye1 = r.dia_eye1,
	u.dia_eye2 = r.dia_eye2,
	u.add_eye1 = r.add_eye1,
	u.add_eye2 = r.add_eye2,
	u.clr_eye1 = r.clr_eye1,
	u.clr_eye2 = r.clr_eye2,
	u.typical_lens_type_eye1 = r.typical_lens_type_eye1,
	u.typical_lens_type_eye2 = r.typical_lens_type_eye2,
	u.typical_lens_eye1_CT1 = r.typical_lens_eye1_CT1,
	u.typical_lens_eye1_CT1_sku = r.typical_lens_eye1_CT1_sku,
	u.typical_lens_eye2_CT1 = r.typical_lens_eye2_CT1,
	u.typical_lens_eye2_CT1_sku = r.typical_lens_eye2_CT1_sku,
	u.typical_lens_eye1_CT2 = r.typical_lens_eye1_CT2,
	u.typical_lens_eye2_CT2 = r.typical_lens_eye2_CT2,
	u.typical_solution_CT2 = r.typical_solution_CT2,
	u.typical_eye_drop_CT2 = r.typical_eye_drop_CT2,
	u.typical_lens_eye1_CT3 = r.typical_lens_eye1_CT3,
	u.typical_lens_eye2_CT3 = r.typical_lens_eye2_CT3,
	u.typical_solution_CT3 = r.typical_solution_CT3,
	u.typical_eye_drop_CT3 = r.typical_eye_drop_CT3,
	u.typical_lens_eye1_CT4 = r.typical_lens_eye1_CT4,
	u.typical_lens_eye2_CT4 = r.typical_lens_eye2_CT4,
	u.typical_solution_CT4 = r.typical_solution_CT4,
	u.typical_eye_drop_CT4 = r.typical_eye_drop_CT4,
	u.typical_lens_eye1_CT5 = r.typical_lens_eye1_CT5,
	u.typical_lens_eye2_CT5 = r.typical_lens_eye2_CT5,
	u.typical_solution_CT5 = r.typical_solution_CT5,
	u.typical_eye_drop_CT5 = r.typical_eye_drop_CT5,
	u.typical_lens_pack_size = r.typical_lens_pack_size,
	u.typical_solution_pack_size = r.typical_solution_pack_size,
	u.typical_eye_drop_pack_size = r.typical_eye_drop_pack_size,
	u.last_shipping_method = r.last_shipping_method,
	u.last_payment_method = r.last_payment_method,	
	u.primary_email = r.primary_email,
	u.secondary_email = r.secondary_email,
	u.primary_newsletter_flg = r.primary_newsletter_flg,
	u.secondary_newsletter_flg = r.secondary_newsletter_flg
;

/* AGGR_USER_UNSANITIZED_inc visszatöltése a BASE_03_TABLE táblába: END */


/* AGGR_USER_UNSANITIZED_inc insert-je és update-je AGGR_USER_UNSANITIZED táblába: START */
INSERT INTO AGGR_USER_UNSANITIZED
SELECT * 
FROM AGGR_USER_UNSANITIZED_inc
WHERE user_id not in
(
SELECT user_id 
FROM AGGR_USER_UNSANITIZED
)
;

UPDATE
AGGR_USER_UNSANITIZED AS u
INNER JOIN AGGR_USER_UNSANITIZED_inc r
ON r.user_id = u.user_id
SET	
u.user_active_flg = r.user_active_flg,
u.primary_email = r.primary_email,
u.secondary_email = r.secondary_email,
u.shipping_phone = r.shipping_phone,
u.personal_name = r.personal_name,
u.personal_address = r.personal_address,
u.personal_zip_code = r.personal_zip_code,
u.personal_city = r.personal_city,
u.personal_city_size = r.personal_city_size,
u.personal_province = r.personal_province,
u.personal_country = r.personal_country,
u.pickup_name = r.pickup_name,
u.pickup_address = r.pickup_address,
u.pickup_zip_code = r.pickup_zip_code,
u.pickup_city = r.pickup_city,
u.pickup_city_size = r.pickup_city_size,
u.pickup_province = r.pickup_province,
u.pickup_country = r.pickup_country,
u.business_name = r.business_name,
u.business_address = r.business_address,
u.business_zip_code = r.business_zip_code,
u.business_city = r.business_city,
u.business_city_size = r.business_city_size,
u.business_province = r.business_province,
u.business_country = r.business_country,
u.health_insurance = r.health_insurance,
u.catchment_area = r.catchment_area,
u.personal_location_catchment_area = r.personal_location_catchment_area,
u.pickup_location_catchment_area = r.pickup_location_catchment_area,
u.num_of_orders = r.num_of_orders,
u.num_of_items = r.num_of_items,
u.first_purchase = r.first_purchase,
u.last_purchase = r.last_purchase,
u.one_before_last_purchase = r.one_before_last_purchase,
u.billing_country_standardized = r.billing_country_standardized,
u.billing_zip_code = r.billing_zip_code,
u.billing_city = r.billing_city,
u.shipping_country_standardized = r.shipping_country_standardized,
u.shipping_zip_code = r.shipping_zip_code,
u.shipping_city = r.shipping_city,
u.related_division = r.related_division,
u.item_net_purchase_price_in_base_currency = r.item_net_purchase_price_in_base_currency,
u.item_net_sale_price_in_currency = r.item_net_sale_price_in_currency,
u.item_gross_sale_price_in_currency = r.item_gross_sale_price_in_currency,
u.item_net_sale_price_in_base_currency = r.item_net_sale_price_in_base_currency,
u.item_gross_sale_price_in_base_currency = r.item_gross_sale_price_in_base_currency,
u.item_quantity = r.item_quantity,
u.item_revenue_in_local_currency = r.item_revenue_in_local_currency,
u.item_vat_value_in_local_currency = r.item_vat_value_in_local_currency,
u.item_revenue_in_base_currency = r.item_revenue_in_base_currency,
u.item_vat_in_base_currency = r.item_vat_in_base_currency,
u.item_gross_revenue_in_base_currency = r.item_gross_revenue_in_base_currency,
u.user_type = r.user_type,
u.gender = r.gender,
u.user_age = r.user_age,
u.full_name = r.full_name,
u.first_name = r.first_name,
u.last_name = r.last_name,
u.salutation = r.salutation,
u.revenues_wdisc_in_local_currency = r.revenues_wdisc_in_local_currency,
u.revenues_wdisc_in_base_currency = r.revenues_wdisc_in_base_currency,
u.gross_margin_wodisc_in_base_currency = r.gross_margin_wodisc_in_base_currency,
u.gross_margin_wdisc_in_base_currency = r.gross_margin_wdisc_in_base_currency,
u.`gross_margin_wodisc_%` = r.`gross_margin_wodisc_%`,
u.`gross_margin_wdisc_%` = r.`gross_margin_wdisc_%`,
u.primary_newsletter_flg = r.primary_newsletter_flg,
u.secondary_newsletter_flg = r.secondary_newsletter_flg,
u.cohort_id = r.cohort_id,
u.cohort_month_since = r.cohort_month_since,
u.user_cum_transactions = r.user_cum_transactions,
u.user_cum_gross_revenue_in_base_currency = r.user_cum_gross_revenue_in_base_currency,
u.related_webshop = r.related_webshop,
u.net_margin_wodisc_in_base_currency = r.net_margin_wodisc_in_base_currency,
u.net_margin_wdisc_in_base_currency = r.net_margin_wdisc_in_base_currency,
u.`net_margin_wodisc_%` = r.`net_margin_wodisc_%`,
u.`net_margin_wdisc_%` = r.`net_margin_wdisc_%`,
u.net_invoiced_shipping_costs_in_base_currency = r.net_invoiced_shipping_costs_in_base_currency,
u.shipping_cost_in_base_currency = r.shipping_cost_in_base_currency,
u.packaging_cost_in_base_currency = r.packaging_cost_in_base_currency,
u.payment_cost_in_base_currency = r.payment_cost_in_base_currency,
u.repeat_buyer = r.repeat_buyer,
u.contact_lens_user = r.contact_lens_user,
u.solution_user = r.solution_user,
u.eye_drops_user = r.eye_drops_user,
u.sunglass_user = r.sunglass_user,
u.vitamin_user = r.vitamin_user,
u.frames_user = r.frames_user,
u.lenses_for_spectacles_user = r.lenses_for_spectacles_user,
u.contact_lens_trials_user = r.contact_lens_trials_user,
u.spectacles_user = r.spectacles_user,
u.other_product_user = r.other_product_user,
u.first_year_contact_lens_revenues_wdisc_in_base_currency = r.first_year_contact_lens_revenues_wdisc_in_base_currency,
u.first_year_contact_lens_gross_margin_wdisc_in_base_currency = r.first_year_contact_lens_gross_margin_wdisc_in_base_currency,
u.first_year_contact_lens_net_margin_wodisc_in_base_currency = r.first_year_contact_lens_net_margin_wodisc_in_base_currency,
u.first_year_contact_lens_boxes = r.first_year_contact_lens_boxes,
u.after_first_year_contact_lens_boxes = r.after_first_year_contact_lens_boxes,
u.first_year_contact_lens_projected_boxes = r.first_year_contact_lens_projected_boxes,
u.first_year_contact_lens_overuse_ratio = r.first_year_contact_lens_overuse_ratio,
u.first_year_contact_lens_days_covered = r.first_year_contact_lens_days_covered,
u.one_year_contact_lens_max_days_covered = r.one_year_contact_lens_max_days_covered,
u.date_lenses_run_out = r.date_lenses_run_out,
u.date_lens_cleaners_run_out = r.date_lens_cleaners_run_out,
u.contact_lens_last_purchase = r.contact_lens_last_purchase,
u.last_modified_date = r.last_modified_date,
u.multi_user_account = r.multi_user_account,
u.pwr_eye1 = r.pwr_eye1,
u.pwr_eye2 = r.pwr_eye2,
u.typical_wear_days_eye1 = r.typical_wear_days_eye1,
u.typical_wear_days_eye2 = r.typical_wear_days_eye2,
u.typical_wear_duration_eye1 = r.typical_wear_duration_eye1,
u.typical_wear_duration_eye2 = r.typical_wear_duration_eye2,
u.bc_eye1 = r.bc_eye1,
u.bc_eye2 = r.bc_eye2,
u.cyl_eye1 = r.cyl_eye1,
u.cyl_eye2 = r.cyl_eye2,
u.ax_eye1 = r.ax_eye1,
u.ax_eye2 = r.ax_eye2,
u.dia_eye1 = r.dia_eye1,
u.dia_eye2 = r.dia_eye2,
u.add_eye1 = r.add_eye1,
u.add_eye2 = r.add_eye2,
u.clr_eye1 = r.clr_eye1,
u.clr_eye2 = r.clr_eye2,
u.typical_lens_type_eye1 = r.typical_lens_type_eye1,
u.typical_lens_type_eye2 = r.typical_lens_type_eye2,
u.typical_lens_eye1_CT1 = r.typical_lens_eye1_CT1,
u.typical_lens_eye1_CT1_sku = r.typical_lens_eye1_CT1_sku,
u.typical_lens_eye2_CT1 = r.typical_lens_eye2_CT1,
u.typical_lens_eye2_CT1_sku = r.typical_lens_eye2_CT1_sku,
u.typical_lens_eye1_CT2 = r.typical_lens_eye1_CT2,
u.typical_lens_eye2_CT2 = r.typical_lens_eye2_CT2,
u.typical_solution_CT2 = r.typical_solution_CT2,
u.typical_eye_drop_CT2 = r.typical_eye_drop_CT2,
u.typical_lens_eye1_CT3 = r.typical_lens_eye1_CT3,
u.typical_lens_eye2_CT3 = r.typical_lens_eye2_CT3,
u.typical_solution_CT3 = r.typical_solution_CT3,
u.typical_eye_drop_CT3 = r.typical_eye_drop_CT3,
u.typical_lens_eye1_CT4 = r.typical_lens_eye1_CT4,
u.typical_lens_eye2_CT4 = r.typical_lens_eye2_CT4,
u.typical_solution_CT4 = r.typical_solution_CT4,
u.typical_eye_drop_CT4 = r.typical_eye_drop_CT4,
u.typical_lens_eye1_CT5 = r.typical_lens_eye1_CT5,
u.typical_lens_eye2_CT5 = r.typical_lens_eye2_CT5,
u.typical_solution_CT5 = r.typical_solution_CT5,
u.typical_eye_drop_CT5 = r.typical_eye_drop_CT5,
u.typical_lens_pack_size = r.typical_lens_pack_size,
u.typical_solution_pack_size = r.typical_solution_pack_size,
u.typical_eye_drop_pack_size = r.typical_eye_drop_pack_size,
u.last_shipping_method = r.last_shipping_method,
u.last_payment_method = r.last_payment_method,
u.newsletter_current = r.newsletter_current,
u.newsletter_ever = r.newsletter_ever,
u.loyalty_points = r.loyalty_points,
u.experiment = r.experiment,
u.GDPR_status = r.GDPR_status,
u.personal_geogr_region = r.personal_geogr_region,
u.elso_lencse_CT2 = r.elso_lencse_CT2,
u.elso_lencse_CT3 = r.elso_lencse_CT3,
u.elso_folyadek_CT2 = r.elso_folyadek_CT2,
u.elso_folyadek_CT3 = r.elso_folyadek_CT3,
u.elso_szemcsepp_CT2 = r.elso_szemcsepp_CT2,
u.elso_lens_type = r.elso_lens_type,
u.elso_is_color = r.elso_is_color,
u.elso_wear_days = r.elso_wear_days,
u.elso_wear_duration = r.elso_wear_duration,
u.elso_pack_size = r.elso_pack_size,
u.elso_lens_too_slow_dispatch = r.elso_lens_too_slow_dispatch,
u.elso_shipping_method = r.elso_shipping_method,
u.elso_payment_method = r.elso_payment_method,
u.elso_order_month = r.elso_order_month,
u.elso_order_weekday = r.elso_order_weekday,
u.elso_order_week_in_month = r.elso_order_week_in_month,
u.elso_source_of_trx = r.elso_source_of_trx,
u.elso_trx_marketing_channel = r.elso_trx_marketing_channel,
u.elso_coupon_code = r.elso_coupon_code,
u.elso_personal_geogr_region = r.elso_personal_geogr_region,
u.elso_pickup_geogr_region = r.elso_pickup_geogr_region,
u.elso_contact_lens_vol = r.elso_contact_lens_vol,
u.elso_solution_vol = r.elso_solution_vol,
u.elso_eye_drops_vol = r.elso_eye_drops_vol,
u.elso_order_value = r.elso_order_value,
u.last_time_order_to_dispatch = r.last_time_order_to_dispatch,
u.brand_switcher_same_manufacturer = r.brand_switcher_same_manufacturer,
u.brand_and_manufacturer_switcher = r.brand_and_manufacturer_switcher,
u.repeat_prediction = r.repeat_prediction,
u.active_prediction = r.active_prediction,
u.repeat_prediction_date = r.repeat_prediction_date,
u.active_prediction_date = r.active_prediction_date,
u.second_purchase_within_391_days = r.second_purchase_within_391_days
;



/* AGGR_USER_UNSANITIZED_inc insert-je és update-je AGGR_USER_UNSANITIZED táblába: END */




DROP TABLE IF EXISTS AGGR_USER_SANITIZED;
CREATE TABLE IF NOT EXISTS AGGR_USER_SANITIZED
SELECT *
FROM AGGR_USER_UNSANITIZED
;

ALTER TABLE AGGR_USER_SANITIZED DROP COLUMN GDPR_status;

ALTER TABLE AGGR_USER_SANITIZED ADD PRIMARY KEY (`user_id`) USING BTREE;

UPDATE AGGR_USER_SANITIZED SET primary_email = NULL WHERE primary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET secondary_email = NULL WHERE secondary_email IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET shipping_phone = NULL WHERE shipping_phone IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET full_name = NULL WHERE full_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET first_name = NULL WHERE first_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET last_name = NULL WHERE last_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET personal_name = NULL WHERE personal_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET pickup_name = NULL WHERE pickup_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET business_name = NULL WHERE business_name IS NOT NULL;
UPDATE AGGR_USER_SANITIZED SET user_age = NULL WHERE user_age IS NOT NULL;

