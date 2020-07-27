DROP TABLE IF EXISTS trx_list_union;
CREATE TABLE IF NOT EXISTS trx_list_union
SELECT user_id, erp_invoice_id 
FROM BASE_03_TABLE 
union all
SELECT user_id, erp_invoice_id 
FROM BASE_00i_TABLE_inc
;

ALTER TABLE trx_list_union ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;
ALTER TABLE trx_list_union ADD INDEX `user_id` (`user_id`) USING BTREE;




DROP TABLE IF EXISTS trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE IF NOT EXISTS trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT user_id, erp_invoice_id FROM trx_list_union ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
;

ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;

UPDATE
BASE_00i_TABLE_inc AS u
LEFT JOIN trx_numbering r
ON (r.erp_invoice_id = u.erp_invoice_id AND r.user_id = u.user_id)
SET
u.trx_rank = r.trx_rank
;



/* MARKETING costs számítás segédtáblái: START */

/*marketing cost: div+webshop+month*/
drop table if EXISTS marketing_costs_by_month_div_webshop_in_base_currency;
create table marketing_costs_by_month_div_webshop_in_base_currency
select 	m.invoice_yearmonth, 
		m.related_division,
		m.related_webshop,
	round(sum(case 
		when m.currency = 'EUR' then m.amount * e.EUR
		when m.currency = 'GBP' then m.amount * e.GBP
		when m.currency = 'PLN' then m.amount * e.PLN
		when m.currency = 'SEK' then m.amount * e.SEK
		when m.currency = 'DKK' then m.amount * e.DKK
		when m.currency = 'NOK' then m.amount * e.NOK
		when m.currency = 'HRK' then m.amount * e.HRK
		when m.currency = 'RSD' then m.amount * e.RSD
		when m.currency = 'RON' then m.amount * e.RON
		when m.currency = 'HUF' then m.amount * e.HUF
		when m.currency = 'USD' then m.amount * e.USD
		end)) as marketing_cost_in_base_currency
FROM IN_marketing_costs m
INNER JOIN exchange_rates_ext AS e 
	ON date(concat(substr(m.invoice_yearmonth,1,4), '-', substr(m.invoice_yearmonth,6,2), '-','01')) = e.DATE
	AND 
		case 
			when m.currency = 'EUR' then e.EUR
			when m.currency = 'GBP' then e.GBP
			when m.currency = 'PLN' then e.PLN
			when m.currency = 'SEK' then e.SEK
			when m.currency = 'DKK' then e.DKK
			when m.currency = 'NOK' then e.NOK
			when m.currency = 'HRK' then e.HRK
			when m.currency = 'RSD' then e.RSD
			when m.currency = 'RON' then e.RON
			when m.currency = 'HUF' then e.HUF
			when m.currency = 'USD' then e.USD
		end
where m.related_division <> 'All'
and m.related_webshop <> 'All'
group by m.invoice_yearmonth, m.related_division, m.related_webshop
;

ALTER table marketing_costs_by_month_div_webshop_in_base_currency add INDEX (`invoice_yearmonth`) USING BTREE;
ALTER table marketing_costs_by_month_div_webshop_in_base_currency add INDEX (`related_division`) USING BTREE;
ALTER table marketing_costs_by_month_div_webshop_in_base_currency add INDEX (`related_webshop`) USING BTREE;




/*marketing cost: div+month*/
drop table IF EXISTS marketing_costs_by_month_div_all_webshop_in_base_currency;
create table marketing_costs_by_month_div_all_webshop_in_base_currency
select 	m.invoice_yearmonth, 
		m.related_division,
	round(sum(case 
		when m.currency = 'EUR' then m.amount * e.EUR
		when m.currency = 'GBP' then m.amount * e.GBP
		when m.currency = 'PLN' then m.amount * e.PLN
		when m.currency = 'SEK' then m.amount * e.SEK
		when m.currency = 'DKK' then m.amount * e.DKK
		when m.currency = 'NOK' then m.amount * e.NOK
		when m.currency = 'HRK' then m.amount * e.HRK
		when m.currency = 'RSD' then m.amount * e.RSD
		when m.currency = 'RON' then m.amount * e.RON
		when m.currency = 'HUF' then m.amount * e.HUF
		when m.currency = 'USD' then m.amount * e.USD
		end)) as marketing_cost_in_base_currency
FROM IN_marketing_costs m
INNER JOIN exchange_rates_ext AS e 
	ON date(concat(substr(m.invoice_yearmonth,1,4), '-', substr(m.invoice_yearmonth,6,2), '-','01')) = e.DATE
	AND 
		case 
			when m.currency = 'EUR' then e.EUR
			when m.currency = 'GBP' then e.GBP
			when m.currency = 'PLN' then e.PLN
			when m.currency = 'SEK' then e.SEK
			when m.currency = 'DKK' then e.DKK
			when m.currency = 'NOK' then e.NOK
			when m.currency = 'HRK' then e.HRK
			when m.currency = 'RSD' then e.RSD
			when m.currency = 'RON' then e.RON
			when m.currency = 'HUF' then e.HUF
			when m.currency = 'USD' then e.USD
		end
where m.related_division <> 'All'
and m.related_webshop = 'All'
group by m.invoice_yearmonth, m.related_division
;

ALTER table marketing_costs_by_month_div_all_webshop_in_base_currency add INDEX (`invoice_yearmonth`) USING BTREE;
ALTER table marketing_costs_by_month_div_all_webshop_in_base_currency add INDEX (`related_division`) USING BTREE;


/*marketing cost: month*/
drop table IF EXISTS marketing_costs_by_month_in_base_currency;
create table marketing_costs_by_month_in_base_currency
select 	m.invoice_yearmonth,
	round(sum(case 
		when m.currency = 'EUR' then m.amount * e.EUR
		when m.currency = 'GBP' then m.amount * e.GBP
		when m.currency = 'PLN' then m.amount * e.PLN
		when m.currency = 'SEK' then m.amount * e.SEK
		when m.currency = 'DKK' then m.amount * e.DKK
		when m.currency = 'NOK' then m.amount * e.NOK
		when m.currency = 'HRK' then m.amount * e.HRK
		when m.currency = 'RSD' then m.amount * e.RSD
		when m.currency = 'RON' then m.amount * e.RON
		when m.currency = 'HUF' then m.amount * e.HUF
		when m.currency = 'USD' then m.amount * e.USD
		end)) as marketing_cost_in_base_currency
FROM IN_marketing_costs m
INNER JOIN exchange_rates_ext AS e 
	ON date(concat(substr(m.invoice_yearmonth,1,4), '-', substr(m.invoice_yearmonth,6,2), '-','01')) = e.DATE
	AND 
		case 
			when m.currency = 'EUR' then e.EUR
			when m.currency = 'GBP' then e.GBP
			when m.currency = 'PLN' then e.PLN
			when m.currency = 'SEK' then e.SEK
			when m.currency = 'DKK' then e.DKK
			when m.currency = 'NOK' then e.NOK
			when m.currency = 'HRK' then e.HRK
			when m.currency = 'RSD' then e.RSD
			when m.currency = 'RON' then e.RON
			when m.currency = 'HUF' then e.HUF
			when m.currency = 'USD' then e.USD
		end
where m.related_division = 'All'
group by m.invoice_yearmonth
;

ALTER table marketing_costs_by_month_in_base_currency add INDEX (`invoice_yearmonth`) USING BTREE;



/*revenues: div+webshop+month*/
drop table IF EXISTS revenues_wdisc_by_month_div_webshop;
create table revenues_wdisc_by_month_div_webshop
select 
		concat(year(n.created), '_', lpad(month(n.created),2,'0')) as invoice_yearmonth,
		n.related_division,
		n.related_webshop,
		round(sum(revenues_wdisc_in_base_currency)) as sum_revenues_wdisc_in_base_currency
from INVOICES_00_inc as n
group by invoice_yearmonth, n.related_division, n.related_webshop
;

ALTER table revenues_wdisc_by_month_div_webshop add INDEX (`invoice_yearmonth`) USING BTREE;
ALTER table revenues_wdisc_by_month_div_webshop add INDEX (`related_division`) USING BTREE;
ALTER table revenues_wdisc_by_month_div_webshop add INDEX (`related_webshop`) USING BTREE;




/*revenues: div+month*/
drop table IF EXISTS revenues_wdisc_by_month_div;
create table revenues_wdisc_by_month_div
select 
		concat(year(n.created), '_', lpad(month(n.created),2,'0')) as invoice_yearmonth,
		n.related_division,
		round(sum(revenues_wdisc_in_base_currency)) as sum_revenues_wdisc_in_base_currency
from INVOICES_00_inc as n
group by invoice_yearmonth, n.related_division
;

ALTER table revenues_wdisc_by_month_div add INDEX (`invoice_yearmonth`) USING BTREE;
ALTER table revenues_wdisc_by_month_div add INDEX (`related_division`) USING BTREE;



/*revenues: month*/
drop table IF EXISTS all_revenues_wdisc_by_month;
create table all_revenues_wdisc_by_month
select 
		concat(year(n.created), '_', lpad(month(n.created),2,'0')) as invoice_yearmonth,
		round(sum(revenues_wdisc_in_base_currency)) as sum_revenues_wdisc_in_base_currency
FROM INVOICES_00_inc AS n
group by invoice_yearmonth
;


ALTER table all_revenues_wdisc_by_month add INDEX (`invoice_yearmonth`) USING BTREE;



/* MARKETING costs számítás segédtáblái: END */




/* OVERHEAD costs számítás segédtáblái: START */

drop table IF EXISTS overhead_costs_by_month_div_in_base_currency;
create table overhead_costs_by_month_div_in_base_currency
select 	m.invoice_yearmonth, 
		m.related_division,
	round(sum(case 
		when m.currency = 'EUR' then m.amount * e.EUR
		when m.currency = 'GBP' then m.amount * e.GBP
		when m.currency = 'PLN' then m.amount * e.PLN
		when m.currency = 'SEK' then m.amount * e.SEK
		when m.currency = 'DKK' then m.amount * e.DKK
		when m.currency = 'NOK' then m.amount * e.NOK
		when m.currency = 'HRK' then m.amount * e.HRK
		when m.currency = 'RSD' then m.amount * e.RSD
		when m.currency = 'RON' then m.amount * e.RON
		when m.currency = 'HUF' then m.amount * e.HUF
		when m.currency = 'USD' then m.amount * e.USD
		end)) as overhead_cost_in_base_currency
FROM IN_overhead_costs m
INNER JOIN exchange_rates_ext AS e 
	ON date(concat(substr(m.invoice_yearmonth,1,4), '-', substr(m.invoice_yearmonth,6,2), '-','01')) = e.DATE
	AND 
		case 
			when m.currency = 'EUR' then e.EUR
			when m.currency = 'GBP' then e.GBP
			when m.currency = 'PLN' then e.PLN
			when m.currency = 'SEK' then e.SEK
			when m.currency = 'DKK' then e.DKK
			when m.currency = 'NOK' then e.NOK
			when m.currency = 'HRK' then e.HRK
			when m.currency = 'RSD' then e.RSD
			when m.currency = 'RON' then e.RON
			when m.currency = 'HUF' then e.HUF
			when m.currency = 'USD' then e.USD
		end
where m.related_division <> 'All'
group by m.invoice_yearmonth, m.related_division
;

ALTER table overhead_costs_by_month_div_in_base_currency add INDEX (`invoice_yearmonth`) USING BTREE;
ALTER table overhead_costs_by_month_div_in_base_currency add INDEX (`related_division`) USING BTREE;


drop table IF EXISTS overhead_costs_by_month_in_base_currency;
create table overhead_costs_by_month_in_base_currency
select 	m.invoice_yearmonth,
	round(sum(case 
		when m.currency = 'EUR' then m.amount * e.EUR
		when m.currency = 'GBP' then m.amount * e.GBP
		when m.currency = 'PLN' then m.amount * e.PLN
		when m.currency = 'SEK' then m.amount * e.SEK
		when m.currency = 'DKK' then m.amount * e.DKK
		when m.currency = 'NOK' then m.amount * e.NOK
		when m.currency = 'HRK' then m.amount * e.HRK
		when m.currency = 'RSD' then m.amount * e.RSD
		when m.currency = 'RON' then m.amount * e.RON
		when m.currency = 'HUF' then m.amount * e.HUF
		when m.currency = 'USD' then m.amount * e.USD
		end)) as overhead_cost_in_base_currency
FROM IN_overhead_costs m
INNER JOIN exchange_rates_ext AS e 
	ON date(concat(substr(m.invoice_yearmonth,1,4), '-', substr(m.invoice_yearmonth,6,2), '-','01')) = e.DATE
	AND 
		case 
			when m.currency = 'EUR' then e.EUR
			when m.currency = 'GBP' then e.GBP
			when m.currency = 'PLN' then e.PLN
			when m.currency = 'SEK' then e.SEK
			when m.currency = 'DKK' then e.DKK
			when m.currency = 'NOK' then e.NOK
			when m.currency = 'HRK' then e.HRK
			when m.currency = 'RSD' then e.RSD
			when m.currency = 'RON' then e.RON
			when m.currency = 'HUF' then e.HUF
			when m.currency = 'USD' then e.USD
		end
where m.related_division = 'All'
group by m.invoice_yearmonth
;

ALTER table overhead_costs_by_month_in_base_currency add INDEX (`invoice_yearmonth`) USING BTREE;




/* OVERHEAD costs számítás segédtáblái: END */



drop table if exists AGGR_ORDER_inc;
create table AGGR_ORDER_inc (
		origin varchar(25),
		erp_invoice_id varchar(20),
		reference_id varchar(40),
		new_reference_id varchar(40),
		connected_order_erp_id varchar(40),
		connected_delivery_note_erp_id varchar(40),
		num_of_items smallint(11),
		user_id int(11),
		user_active_flg varchar(20),
		created TIMESTAMP NULL DEFAULT NULL,
		due_date TIMESTAMP NULL DEFAULT NULL,
		fulfillment_date TIMESTAMP NULL DEFAULT NULL,
		primary_email varchar(100) comment 'Elsődleges email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.',
		secondary_email varchar(100) comment 'Másodlagos email cím: ha több email cím is tartozik a user-hez, akkor vegyük a frissebbet, ha van 180 nap a kettő utolsó használati dátuma között. Ha nincs 180 nap differencia, akkor vegyük azt, amelyiket többször használta.',
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
		billing_country_standardized varchar(50),
		shipping_country_standardized varchar(50),
		item_is_canceled varchar(20),
		last_modified_date TIMESTAMP NULL DEFAULT NULL,
		last_modified_by varchar(255),
		related_warehouse varchar(255),
		payment_method varchar(255),
		shipping_method varchar(255),
		related_division varchar(255),
		related_webshop varchar(64),
		currency varchar(3),
		exchange_rate_of_currency decimal(7,2),
		item_vat_rate decimal(7,3),
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
		item_weight_in_kg decimal(11,2),
		user_type varchar(20),
		gender varchar(20),
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
		last_purchase TIMESTAMP NULL DEFAULT NULL,
		time_order_to_dispatch int(10),
		time_dispatch_to_delivery int(10),
		invoice_yearmonth varchar(10),
		invoice_year int(4),
		invoice_quarter int(4),
		invoice_month int(4),
		invoice_day_in_month int(4),
		invoice_hour int(4),
		cohort_month_since smallint(4),
		user_cum_transactions int(12),
		user_cum_gross_revenue_in_base_currency decimal(11,2),
		order_date_and_time TIMESTAMP NULL DEFAULT NULL,
		order_year int(4),
		order_quarter int(4),
		order_month int(4),
		order_day_in_month int(4),
		order_weekday int(4),
		order_week_in_month int(4),
		order_hour tinyint(1),
		source varchar(255),
		medium varchar(255),
		campaign varchar(255),
		trx_marketing_channel varchar(255),
		repeat_buyer varchar(30),
		trx_rank smallint(5),
		source_of_trx varchar(64),
		order_value decimal(11,2),
		net_margin_wodisc_in_base_currency int(11),
		net_margin_wdisc_in_base_currency int(11),
		`net_margin_wodisc_%` decimal(11,2),
		`net_margin_wdisc_%` decimal(11,2),
		net_invoiced_shipping_costs_in_base_currency int(11),
		shipping_cost_in_base_currency int(11),
		packaging_cost_in_base_currency int(11),
		payment_cost_in_base_currency int(11),
		contact_lens_trx int(4),
		solution_trx int(4),
		eye_drops_trx int(4),
		sunglass_trx int(4),
		vitamin_trx int(4),
		frames_trx int(4),
		lenses_for_spectacles_trx int(4),
		contact_lens_trials_trx int(4),
		spectacles_trx int(4),
		other_product_trx int(4),
		contact_lens_vol int(8),
		solution_vol int(8),
		eye_drops_vol int(8),
		multi_user_account varchar(30),
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
		coupon_code varchar(255),
		experiment varchar(255),
		personal_geogr_region varchar(255),
		marketing_cost_in_base_currency int(11),
		overhead_cost_in_base_currency int(11),
		product_group_2 VARCHAR(100),
    constraint uix_erp_invoice_id unique (erp_invoice_id)
);



ALTER table AGGR_ORDER_inc add INDEX (`reference_id`) USING BTREE;
ALTER table AGGR_ORDER_inc add INDEX (`related_division`) USING BTREE;
ALTER table AGGR_ORDER_inc add INDEX (`related_webshop`) USING BTREE;
ALTER table AGGR_ORDER_inc add INDEX (`invoice_yearmonth`) USING BTREE;

			
insert into AGGR_ORDER_inc
select
		origin,
		erp_invoice_id,
		reference_id,
	null new_reference_id,
	max(connected_order_erp_id) as connected_order_erp_id,
	connected_delivery_note_erp_id,		
		COUNT(item_id) AS num_of_items,
		user_id,
		user_active_flg,
		created,
		due_date,
		fulfillment_date,
		primary_email,
		secondary_email,
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
		billing_country_standardized,
		shipping_country_standardized,
		item_is_canceled,
		last_modified_date,
		last_modified_by,
		related_warehouse,
		payment_method,
		shipping_method,
		n.related_division,
		related_webshop,
		n.currency,
		exchange_rate_of_currency,
		item_vat_rate,
		ROUND(SUM(item_net_purchase_price_in_base_currency*item_quantity),0) AS item_net_purchase_price_in_base_currency,
		ROUND(SUM(item_net_sale_price_in_currency*item_quantity),0) AS item_net_sale_price_in_currency,
		ROUND(SUM(item_gross_sale_price_in_currency*item_quantity),0) AS item_gross_sale_price_in_currency,
		ROUND(SUM(item_net_sale_price_in_base_currency*item_quantity),0) AS item_net_sale_price_in_base_currency,
		ROUND(SUM(item_gross_sale_price_in_base_currency*item_quantity),0) AS item_gross_sale_price_in_base_currency,
		SUM(item_quantity) AS item_quantity,
		ROUND(SUM(item_revenue_in_local_currency),0) AS item_revenue_in_local_currency,
		ROUND(SUM(item_vat_value_in_local_currency),0) AS item_vat_value_in_local_currency,
		ROUND(SUM(item_revenue_in_base_currency),0) AS item_revenue_in_base_currency,
		ROUND(SUM(item_vat_in_base_currency),0) AS item_vat_in_base_currency,
		ROUND(SUM(item_gross_revenue_in_base_currency),0) AS item_gross_revenue_in_base_currency,
		ROUND(SUM(item_weight_in_kg),3) AS item_weight_in_kg,
		user_type,
		gender,
		salutation,
		ROUND(SUM(revenues_wdisc_in_local_currency),0) as revenues_wdisc_in_local_currency,
		ROUND(SUM(revenues_wdisc_in_base_currency),0) as revenues_wdisc_in_base_currency,
		ROUND(SUM(gross_margin_wodisc_in_base_currency),0) AS gross_margin_wodisc_in_base_currency,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS gross_margin_wdisc_in_base_currency,
		ROUND(AVG(`gross_margin_wodisc_%`),2) AS `gross_margin_wodisc_%`,
		ROUND(AVG(`gross_margin_wdisc_%`),2) AS `gross_margin_wdisc_%`,
		primary_newsletter_flg,
		secondary_newsletter_flg,
		cohort_id,
		last_purchase,
		time_order_to_dispatch,
		time_dispatch_to_delivery,
    CASE WHEN origin = 'invoices' then CONCAT(YEAR(last_modified_date),'_',lpad(MONTH(last_modified_date),2,'0')) END AS invoice_yearmonth,
    CASE WHEN origin = 'invoices' then YEAR(last_modified_date) END AS invoice_year,
    CASE WHEN origin = 'invoices' then QUARTER(last_modified_date) END AS invoice_quarter,
    CASE WHEN origin = 'invoices' then MONTH(last_modified_date) END AS invoice_month,
    CASE WHEN origin = 'invoices' then DAY(last_modified_date) END AS invoice_day_in_month,
    CASE WHEN origin = 'invoices' then HOUR(last_modified_date) END AS invoice_hour,

	0 as cohort_month_since,
		user_cum_transactions,
		user_cum_gross_revenue_in_base_currency,
		NULL AS order_date_and_time,
		IF(origin = 'orders',YEAR(created),null) order_year,
		IF(origin = 'orders',QUARTER(created),null) order_quarter,
		IF(origin = 'orders',MONTH(created),null) order_month,
		IF(origin = 'orders',DAY(created),null) order_day_in_month,
		IF(origin = 'orders',weekday(created),null) order_weekday,
		IF(origin = 'orders',WEEK(created) - WEEK(DATE_SUB(created, INTERVAL DAYOFMONTH(created)-1 DAY)) + 1,null) order_week_in_month,
		null as order_hour,
		null source,
		null medium,
		null campaign,		
		trx_marketing_channel,
		repeat_buyer,
		trx_rank,
		source_of_trx,
		SUM(item_revenue_in_base_currency) AS order_value,
		ROUND(SUM(net_margin_wodisc_in_base_currency),0) AS net_margin_wodisc_in_base_currency,
		ROUND(SUM(net_margin_wdisc_in_base_currency),0) AS net_margin_wdisc_in_base_currency,
		ROUND(AVG(`net_margin_wodisc_%`),2) AS `net_margin_wodisc_%`,
		ROUND(AVG(`net_margin_wdisc_%`),2) AS `net_margin_wdisc_%`,	
		ROUND(SUM(net_invoiced_shipping_costs_in_base_currency),0) AS net_invoiced_shipping_costs_in_base_currency,
		ROUND(SUM(shipping_cost_in_base_currency),0) AS shipping_cost_in_base_currency,
		ROUND(SUM(packaging_cost_in_base_currency),0) AS packaging_cost_in_base_currency,
		ROUND(SUM(payment_cost_in_base_currency),0) AS payment_cost_in_base_currency,		
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS contact_lens_trx,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS solution_trx,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS eye_drops_trx,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS sunglass_trx,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS vitamin_trx,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS frames_trx,
		MAX(CASE WHEN product_group  = 'Lenses for spectacles' THEN 1 ELSE 0 END) AS lenses_for_spectacles_trx,
		MAX(CASE WHEN product_group  = 'Contact lenses - Trials' THEN 1 ELSE 0 END) AS contact_lens_trials_trx,
		MAX(CASE WHEN product_group  = 'Spectacles' THEN 1 ELSE 0 END) AS spectacles_trx,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS other_product_trx,
		
		SUM(CASE WHEN product_group = 'Contact lenses' and item_quantity > 0 then item_quantity else 0 end) AS contact_lens_vol,
		SUM(CASE WHEN product_group = 'Contact lens cleaners' and item_quantity > 0 then item_quantity else 0 end) AS solution_vol,
		SUM(CASE WHEN product_group = 'Eye drops' and item_quantity > 0 then item_quantity else 0 end) AS eye_drops_vol,
		multi_user_account,
		pwr_eye1,
		pwr_eye2,
		typical_wear_duration_eye1,
		typical_wear_duration_eye2,
		typical_wear_days_eye1,
		typical_wear_days_eye2,
		bc_eye1,
		bc_eye2,
		cyl_eye1,
		cyl_eye2,
		ax_eye1,
		ax_eye2,
		dia_eye1,
		dia_eye2,
		add_eye1,
		add_eye2,
		clr_eye1,
		clr_eye2,
		typical_lens_type_eye1,
		typical_lens_type_eye2,
		typical_lens_eye1_CT1,
		typical_lens_eye1_CT1_sku,
		typical_lens_eye2_CT1,
		typical_lens_eye2_CT1_sku,
		typical_lens_eye1_CT2,
		typical_lens_eye2_CT2,
		typical_solution_CT2,
		typical_eye_drop_CT2,
		typical_lens_eye1_CT3,
		typical_lens_eye2_CT3,
		typical_solution_CT3,
		typical_eye_drop_CT3,
		typical_lens_eye1_CT4,
		typical_lens_eye2_CT4,
		typical_solution_CT4,
		typical_eye_drop_CT4,
		typical_lens_eye1_CT5,
		typical_lens_eye2_CT5,
		typical_solution_CT5,
		typical_eye_drop_CT5,
		typical_lens_pack_size,
		typical_solution_pack_size,
		typical_eye_drop_pack_size,
		last_shipping_method,
		last_payment_method,
		newsletter_current,
		newsletter_ever,
		loyalty_points,
		coupon_code,
		experiment,
		CASE 
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('101') THEN '1. kerület' 
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('102') THEN '2. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('103') THEN '3. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('104') THEN '4. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('105') THEN '5. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('106') THEN '6. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('107') THEN '7. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('108') THEN '8. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('109') THEN '9. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('110') THEN '10. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('111') THEN '11. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('112') THEN '12. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('113') THEN '13. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('114') THEN '14. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('115') THEN '15. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('116') THEN '16. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('117') THEN '17. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('118') THEN '18. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('119') THEN '19. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('120') THEN '20. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('121') THEN '21. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('122') THEN '22. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			WHEN personal_province IN ('Budapest') AND SUBSTR(personal_zip_code, 1, 3) IN ('123') THEN '23. kerület'
			ELSE personal_province
		END AS personal_geogr_region,
		0 as marketing_cost_in_base_currency,
		0 as overhead_cost_in_base_currency,
		MAX(CASE WHEN product_group IN ('Frames', 'Lenses for spectacles', 'Eye tests') OR CT2_pack IN ('Szemüvegkellékek', 'Munkadíjak') THEN 'Spectacles' ELSE 'no Spectacles involved' END) as product_group_2

FROM BASE_00i_TABLE_inc n
group by n.erp_invoice_id
;


/*marketing costs: div+webshop+month*/
UPDATE AGGR_ORDER_inc as n
        INNER JOIN marketing_costs_by_month_div_webshop_in_base_currency AS m
			ON n.related_division = m.related_division 
			AND n.related_webshop = m.related_webshop
			AND n.invoice_yearmonth = m.invoice_yearmonth
		INNER JOIN revenues_wdisc_by_month_div_webshop AS r
			ON n.related_division = r.related_division 
			AND n.related_webshop = r.related_webshop 
			AND n.invoice_yearmonth = r.invoice_yearmonth	
SET n.marketing_cost_in_base_currency = round(m.marketing_cost_in_base_currency*n.revenues_wdisc_in_base_currency/r.sum_revenues_wdisc_in_base_currency)
;


/*marketing costs: div+month*/
UPDATE AGGR_ORDER_inc as n
        INNER JOIN marketing_costs_by_month_div_all_webshop_in_base_currency AS m
			ON n.related_division = m.related_division 
			AND n.invoice_yearmonth = m.invoice_yearmonth
		INNER JOIN revenues_wdisc_by_month_div AS r
			ON n.related_division = r.related_division
			AND n.invoice_yearmonth = r.invoice_yearmonth	
SET n.marketing_cost_in_base_currency = round(n.marketing_cost_in_base_currency + m.marketing_cost_in_base_currency*n.revenues_wdisc_in_base_currency/r.sum_revenues_wdisc_in_base_currency)
;


/*marketing costs: month*/
UPDATE AGGR_ORDER_inc as n
        INNER JOIN marketing_costs_by_month_in_base_currency AS m
			ON n.invoice_yearmonth = m.invoice_yearmonth
		INNER JOIN all_revenues_wdisc_by_month AS r
			ON n.invoice_yearmonth = r.invoice_yearmonth	
SET n.marketing_cost_in_base_currency = round(n.marketing_cost_in_base_currency + m.marketing_cost_in_base_currency*n.revenues_wdisc_in_base_currency/r.sum_revenues_wdisc_in_base_currency)
;



/*overhead: month*/
UPDATE AGGR_ORDER_inc as n
        INNER JOIN overhead_costs_by_month_in_base_currency AS m
			ON n.invoice_yearmonth = m.invoice_yearmonth
		INNER JOIN all_revenues_wdisc_by_month AS r
			ON n.invoice_yearmonth = r.invoice_yearmonth
SET n.overhead_cost_in_base_currency = round(m.overhead_cost_in_base_currency*n.revenues_wdisc_in_base_currency/r.sum_revenues_wdisc_in_base_currency)
;



/*WEBSHOPOS rendelés kiszállítással 1.*/
UPDATE AGGR_ORDER_inc as sz
        INNER JOIN
    incoming_orders as r 
	on substr(sz.connected_order_erp_id,1,11) = r.erp_id
set 
    sz.order_year = YEAR(r.created),
	sz.order_quarter = QUARTER(r.created),
	sz.order_month = MONTH(r.created),
	sz.order_day_in_month = DAY(r.created),
	sz.order_weekday = WEEKDAY(r.created),
	sz.order_week_in_month = WEEK(r.created) - WEEK(DATE_SUB(r.created, INTERVAL DAYOFMONTH(r.created)-1 DAY)) + 1,
	sz.order_hour = HOUR(r.created),
	sz.new_reference_id = 
	CASE
		WHEN SUBSTR(r.reference_id,1,2) IN ('EO', 'IT', 'UK') THEN SUBSTR(r.reference_id,3,8)
	END,
	sz.time_order_to_dispatch = TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date) 	
where sz.connected_order_erp_id <> ''
;

/*WEBSHOPOS rendelés kiszállítással 2.*/
UPDATE AGGR_ORDER_inc as sz
        INNER JOIN
    incoming_orders as r 
	on sz.reference_id = r.reference_id
SET 
    sz.order_year = YEAR(r.created),
	sz.order_quarter = QUARTER(r.created),
	sz.order_month = MONTH(r.created),
	sz.order_day_in_month = DAY(r.created),
	sz.order_weekday = WEEKDAY(r.created),
	sz.order_week_in_month = WEEK(r.created) - WEEK(DATE_SUB(r.created, INTERVAL DAYOFMONTH(r.created)-1 DAY)) + 1,
	sz.order_hour = HOUR(r.created),
	sz.new_reference_id = 
	CASE
		WHEN SUBSTR(r.reference_id,1,2) IN ('EO', 'IT', 'UK') THEN SUBSTR(r.reference_id,3,8)
	END,
	sz.time_order_to_dispatch = TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date)	
where sz.connected_order_erp_id = ''
;



/*WEBSHOPOS rendelés személyes átvétellel*/
UPDATE AGGR_ORDER_inc AS sz
        INNER JOIN
    delivery_notes AS b ON sz.connected_delivery_note_erp_id = b.erp_id
        INNER JOIN
    incoming_orders AS r ON b.erp_id_of_order = r.erp_id	
SET 
    sz.order_year = YEAR(r.created),
    sz.order_quarter = QUARTER(r.created),
	sz.order_month = MONTH(r.created),
	sz.order_day_in_month = DAY(r.created),
	sz.order_weekday = WEEKDAY(r.created),
	sz.order_week_in_month = WEEK(r.created) - WEEK(DATE_SUB(r.created, INTERVAL DAYOFMONTH(r.created)-1 DAY)) + 1,
	sz.order_hour = HOUR(r.created),
	sz.new_reference_id = r.reference_id,
	sz.time_order_to_dispatch = TIMESTAMPDIFF(HOUR,r.processed, sz.last_modified_date)	
;


/*OFFLINE vásárlás (utcáról bejött)*/
UPDATE AGGR_ORDER_inc m
        INNER JOIN outgoing_bills as r 
ON m.erp_invoice_id = r.erp_id
SET
    order_year = YEAR(r.processed),
    order_quarter = QUARTER(r.processed),
	order_month = MONTH(r.processed),
	order_day_in_month = DAY(r.processed),
	order_weekday = WEEKDAY(r.processed),
	order_week_in_month = WEEK(r.processed) - WEEK(DATE_SUB(r.processed, INTERVAL DAYOFMONTH(r.processed)-1 DAY)) + 1,
	order_hour = HOUR(r.processed),
	time_order_to_dispatch = TIMESTAMPDIFF(HOUR,r.processed, m.last_modified_date)		
WHERE m.order_year is null		
;





/*marketing channels*/
UPDATE AGGR_ORDER_inc as b
LEFT JOIN
(
select a.*, m.prime_channel AS prime_channel
FROM affiliate_sources AS a
LEFT JOIN IN_marketing_channels m
ON CONCAT(a.source,' / ', a.medium) = m.source_medium
) AS e
ON (b.new_reference_id = e.orderid AND LOWER(b.related_webshop) = e.webshop)
LEFT JOIN
(
select t.*, m.prime_channel AS prime_channel
FROM GA_transactions AS t
LEFT JOIN IN_marketing_channels m
ON t.source_medium = m.source_medium
GROUP BY transaction
) AS g
ON b.new_reference_id = g.transaction
SET
    b.source = e.source,
    b.medium = e.medium,
	b.campaign = e.campaign,
    b.trx_marketing_channel = 
			CASE 	WHEN e.prime_channel IS NULL AND b.related_webshop = 'eOptika.hu' AND substr(b.reference_id,1,2) = 'VO' THEN 'Customer Service'
				WHEN e.prime_channel IS NULL AND b.related_webshop NOT IN ('eOptika.hu', '') THEN 'Site not measured'	
				WHEN e.prime_channel = 'Unidentified' AND LENGTH(coupon_code) > 2 THEN 'Coupon order'
				WHEN e.prime_channel = 'Unidentified' AND g.transaction IS NOT NULL AND g.prime_channel IS NOT NULL THEN g.prime_channel
				ELSE e.prime_channel
		END
;



/* AGGR_ORDER visszatöltése a BASE_00i_TABLE_inc táblába: START */



UPDATE
BASE_00i_TABLE_inc AS u
INNER JOIN AGGR_ORDER_inc r
ON r.erp_invoice_id = u.erp_invoice_id
SET	u.invoice_yearmonth = r.invoice_yearmonth,
	u.invoice_year = r.invoice_year,
	u.invoice_quarter = r.invoice_quarter,
	u.invoice_month = r.invoice_month,
	u.invoice_day_in_month = r.invoice_day_in_month,
	u.invoice_hour = r.invoice_hour,
	u.order_year = r.order_year,
	u.order_quarter = r.order_quarter,
	u.order_month = r.order_month,
	u.order_day_in_month = r.order_day_in_month,
	u.order_weekday = r.order_weekday,
	u.order_week_in_month = r.order_week_in_month,
	u.order_hour = r.order_hour,
	u.source = r.source,
	u.medium = r.medium,
	u.campaign = r.campaign,
	u.trx_marketing_channel = r.trx_marketing_channel,
	u.trx_rank = r.trx_rank,
	u.source_of_trx = r.source_of_trx,
	u.personal_geogr_region = r.personal_geogr_region,
	u.marketing_cost_in_base_currency = case when u.item_net_sale_price_in_currency*u.item_quantity < 0 or r.item_net_sale_price_in_currency < 0 then 0 else round(r.marketing_cost_in_base_currency*abs(u.item_net_sale_price_in_currency*u.item_quantity/r.item_net_sale_price_in_currency)) end,
	u.overhead_cost_in_base_currency = case when u.item_net_sale_price_in_currency*u.item_quantity < 0 or r.item_net_sale_price_in_currency < 0 then 0 else round(r.overhead_cost_in_base_currency*abs(u.item_net_sale_price_in_currency*u.item_quantity/r.item_net_sale_price_in_currency)) end,
	u.product_group_2 = r.product_group_2,
	u.time_order_to_dispatch = r.time_order_to_dispatch	
;
