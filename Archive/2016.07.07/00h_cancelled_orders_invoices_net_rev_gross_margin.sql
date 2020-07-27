DROP TABLE IF EXISTS CANCELLED_ORDERS_00h;
CREATE TABLE IF NOT EXISTS CANCELLED_ORDERS_00h LIKE CANCELLED_ORDERS_00f2;

ALTER TABLE CANCELLED_ORDERS_00h
  ADD `revenues_wdisc_in_local_currency` float DEFAULT NULL,
  ADD `revenues_wdisc_in_base_currency` double DEFAULT NULL
;

INSERT INTO CANCELLED_ORDERS_00h
SELECT  f2.*, 
    g.item_net_value_in_currency AS revenues_wdisc_in_local_currency,
    g.item_net_value_in_currency*g.exchange_rate_of_currency AS revenues_wdisc_in_base_currency
FROM CANCELLED_ORDERS_00g AS g, CANCELLED_ORDERS_00f2 AS f2
WHERE g.sql_id = f2.sql_id;

ALTER TABLE CANCELLED_ORDERS_00h
  DROP COLUMN group_id,
  DROP COLUMN item_sku,
  DROP COLUMN item_name_hun,
  DROP COLUMN item_name_eng;
ALTER TABLE CANCELLED_ORDERS_00h MODIFY COLUMN item_type VARCHAR(255) AFTER wear_duration;
