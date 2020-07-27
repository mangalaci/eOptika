DROP TABLE IF EXISTS INVOICES_00h;
CREATE TABLE IF NOT EXISTS INVOICES_00h LIKE INVOICES_00f2;

ALTER TABLE INVOICES_00h
  ADD `revenues_wdisc_in_local_currency` float DEFAULT NULL,
  ADD `revenues_wdisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wodisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wdisc_in_base_currency` double DEFAULT NULL,
  ADD `gross_margin_wodisc_%` double DEFAULT NULL,
  ADD `gross_margin_wdisc_%` double DEFAULT NULL;

INSERT INTO INVOICES_00h
SELECT  f2.*, 
    g.item_net_value_in_currency AS revenues_wdisc_in_local_currency,
    g.item_net_value_in_currency*g.exchange_rate_of_currency AS revenues_wdisc_in_base_currency,
    (f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wodisc_in_base_currency,
    (g.item_net_value_in_currency*g.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity) AS gross_margin_wdisc_in_base_currency,
    /*ha negatív a revenue, akkor a purchase price-szal osztjuk a gross margin-t*/
    CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
    (f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency) 
       ELSE 
    (f2.item_net_value_in_currency*f2.exchange_rate_of_currency-f2.item_net_purchase_price_in_base_currency*f2.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.item_quantity) 
    END AS `gross_margin_wodisc_%`,
    CASE WHEN (f2.item_net_value_in_currency*f2.exchange_rate_of_currency) > 0 THEN
    (g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_value_in_currency*f2.exchange_rate_of_currency) 
       ELSE
    (g.item_net_value_in_currency*g.exchange_rate_of_currency-g.item_net_purchase_price_in_base_currency*g.item_quantity)/(f2.item_net_purchase_price_in_base_currency*f2.exchange_rate_of_currency) 
    END AS `gross_margin_wdisc_%`
FROM INVOICES_00g AS g, INVOICES_00f2 AS f2
WHERE g.sql_id = f2.sql_id;

ALTER TABLE INVOICES_00h
  DROP COLUMN ct_csoport,
  DROP COLUMN item_sku,
  DROP COLUMN item_name_hun,
  DROP COLUMN item_name_eng;
ALTER TABLE INVOICES_00h MODIFY COLUMN item_type VARCHAR(255) AFTER wear_duration;
