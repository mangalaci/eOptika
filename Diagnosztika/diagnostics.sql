/*item_name_eng*/
SELECT COUNT(*)
FROM outgoing_bills
WHERE (item_name_hun IS NULL OR item_name_hun = '')
;

/*mikori a legfrissebb adat az exchange rate táblában*/
SELECT MAX(date)
FROM exchange_rates_ext
;


/*mikori a legfrissebb adat az ITEMS SOLD alaptáblában*/
SELECT MIN(created), MAX(created)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
;

/*related_division*/
SELECT related_division, COUNT(*)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY related_division
ORDER BY COUNT(*) DESC
;

/*related_warehouse*/
SELECT related_warehouse, COUNT(*)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY related_warehouse
ORDER BY COUNT(*) DESC
;

/*related_webshop*/
SELECT related_webshop, COUNT(*)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY related_webshop
ORDER BY COUNT(*) DESC
;

/* ahol a personal_name hiányzik*/
SELECT DISTINCT shipping_name, billing_name
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (personal_name IS NULL OR personal_name = '')
;

/*personal_address*/
SELECT DISTINCT shipping_address, billing_address
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (personal_address IS NULL OR personal_address = '')
;

/*personal_zip_code*/
SELECT DISTINCT shipping_zip_code, billing_zip_code
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (personal_zip_code IS NULL OR personal_zip_code = '')
;

/*personal_city*/
SELECT DISTINCT shipping_city, billing_city
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (personal_city IS NULL OR personal_city = '')
;





/*catchment_area*/
SELECT catchment_area, COUNT(DISTINCT user_id)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY catchment_area
ORDER BY COUNT(DISTINCT user_id) DESC
;

/*shipping_phone*/
SELECT DISTINCT shipping_name, billing_name, buyer_email
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (shipping_phone IS NULL OR shipping_phone = '')
;

/*currency*/
SELECT currency, COUNT(*)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY currency
ORDER BY COUNT(*) DESC
;

/* lehetetlen exchange_rate_of_currency*/
SELECT MIN(exchange_rate_of_currency), MAX(exchange_rate_of_currency)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
;

SELECT DISTINCT erp_invoice_id,  currency
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND exchange_rate_of_currency = 0
;


/*hol hiányzik a shipping_country_standardized*/
SELECT DISTINCT shipping_name, shipping_country_standardized
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND (shipping_country_standardized IS NULL OR shipping_country_standardized = '')
;


/*cohort_month_since*/
SELECT cohort_month_since, repeat_buyer, COUNT(*)
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
GROUP BY cohort_month_since, repeat_buyer
ORDER BY COUNT(*) DESC
;
--ez a mező a user élettartamát vagy a adot trx idejét az első trx-től kellene jelentse? 




/* *** CIKKTÖRZS *** */

/*product_group*/
SELECT DISTINCT product_group
FROM `BASE_03_TABLE`
;

SELECT DISTINCT CT1_sku_name
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
AND product_group = 'Other'
;


/* CT1_sku */
SELECT CT1_sku, COUNT(*)
FROM `BASE_03_TABLE`
WHERE LENGTH(CT1_sku) < 3
GROUP BY CT1_sku
ORDER BY COUNT(*) DESC;

SELECT *
FROM `BASE_03_TABLE`
WHERE CT1_sku IS NULL
OR CT1_SKU = ''
;

3 db ilyen sor volt: 2018-12-31


/* CT1_sku_name */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT1_sku_name IS NULL
OR CT1_sku_name = ''
;



/* CT2_sku */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT2_sku IS NULL
OR CT2_sku = ''
;

3947 db ilyen sor volt: 2019-01-03



SELECT *
FROM zoho_item_groups
WHERE parent_id = 8
;


SELECT *
FROM ab_cikkto_full
WHERE CT2_sku IS NULL
OR CT2_sku = ''
;

33716  db ilyen sor volt: 2019-01-04
33566 
33127 
32818


/* sku_eoptika_hu */
SELECT *
FROM zoho_item_groups 
WHERE sku_eoptika_hu IS NULL
;


/* CT4_product_brand */
SELECT *
FROM zoho_item_groups 
WHERE CT4_product_brand IS NULL
;




SELECT *
FROM items
WHERE name_hu = 'PureVision 2 (1 db), BC: 8.6, PWR: -2.50'


/* CT2_pack */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT2_pack IS NULL
OR CT2_pack = ''
;

3 db ilyen sor volt: 2019-01-03


SELECT *
FROM ab_cikkto_full
WHERE CT2_pack IS NULL
OR CT2_pack = ''
;

0 db ilyen sor volt: 2019-01-03



/* CT3_product */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT3_product IS NULL
OR CT3_product = ''
;

3947 db ilyen sor volt: 2019-01-03



SELECT *
FROM ab_cikkto_full
WHERE CT3_product IS NULL
OR CT3_product = ''
;

0 db ilyen sor volt: 2019-01-03





/* CT3_product_short */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT3_product_short IS NULL
OR CT3_product_short = ''
;

3947 db ilyen sor volt: 2019-01-03



SELECT *
FROM ab_cikkto_full
WHERE CT3_product_short IS NULL
OR CT3_product_short = ''
;

0 db ilyen sor volt: 2019-01-03




/* CT4_product_brand */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT4_product_brand IS NULL
OR CT4_product_brand = ''
;

3947 db ilyen sor volt: 2019-01-03



SELECT *
FROM ab_cikkto_full
WHERE CT4_product_brand IS NULL
OR CT4_product_brand = ''
;

0 db ilyen sor volt: 2019-01-03




/* CT5_manufacturer */
SELECT *
FROM `BASE_03_TABLE`
WHERE CT5_manufacturer IS NULL
OR CT5_manufacturer = ''
;

3947 db ilyen sor volt: 2019-01-03


SELECT *
FROM ab_cikkto_full
WHERE CT5_manufacturer IS NULL
OR CT5_manufacturer = ''
;

0 db ilyen sor volt: 2019-01-03



SELECT *
FROM outgoing_bills
WHERE sql_id = 7781

SELECT *
FROM outgoing_bills
WHERE sql_id = 1786916
;






















SELECT catchment_area, shipping_method, pickup_zip_code
FROM `BASE_03_TABLE`
WHERE origin = 'invoices'
;


/*primary email*/
SELECT primary_email, buyer_email
FROM BASE_03_TABLE
WHERE LENGTH(buyer_email) - LENGTH(REPLACE(buyer_email, '@', '')) = 0  



-- repeat_buyer = one-time-nál nincs gross margin %
-- repeat_buyer = one-time és multi_account_user = single hogy lehet együtt?


/* 322 db group_id volt 2018-10-09-én */
SELECT COUNT(DISTINCT group_id)
FROM items
;


/* 17 db parent_id volt 2018-10-09-én */
SELECT COUNT(DISTINCT parent_id)
FROM zoho_item_groups
;



/* hihetetlen purchase price */
SELECT *
FROM `BASE_03_TABLE` 
WHERE created >= '2019-07-01'
AND item_net_purchase_price_in_base_currency > 100000
;

SELECT *
FROM `BASE_03_TABLE` 
WHERE created > '2011-08-01'
AND item_net_purchase_price_in_base_currency < 1
;


/* hihetetlen net margin */
SELECT *
FROM `BASE_03_TABLE` 
WHERE created > '2011-08-01'
AND ABS(net_margin_wodisc_in_base_currency) > 100000
;


  
/* hihetetlen net weight */
SELECT MAX(net_weight_in_kg)
FROM ab_cikkto_full
;
