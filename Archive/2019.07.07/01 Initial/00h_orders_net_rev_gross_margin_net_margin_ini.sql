DROP TABLE IF EXISTS ORDERS_00h;
CREATE TABLE ORDERS_00h 
SELECT  m.sql_id,
    m.item_net_value_in_currency AS revenues_wdisc_in_local_currency,
    m.item_net_value_in_currency*m.exchange_rate_of_currency AS revenues_wdisc_in_base_currency,
	NULL AS connected_order_erp_id,
	NULL AS connected_delivery_note_erp_id
FROM ORDERS_00 AS m, ORDERS_002 AS s
WHERE m.sql_id = s.sql_id;


ALTER TABLE ORDERS_00h ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ORDERS_00h ADD INDEX `revenues_wdisc_in_local_currency` (`revenues_wdisc_in_local_currency`) USING BTREE;
ALTER TABLE ORDERS_00h ADD INDEX `revenues_wdisc_in_base_currency` (`revenues_wdisc_in_base_currency`) USING BTREE;

UPDATE ORDERS_00 AS m
        LEFT JOIN
    ORDERS_00h AS s ON m.sql_id = s.sql_id
SET
    m.revenues_wdisc_in_local_currency = s.revenues_wdisc_in_local_currency,
    m.revenues_wdisc_in_base_currency = s.revenues_wdisc_in_base_currency
;