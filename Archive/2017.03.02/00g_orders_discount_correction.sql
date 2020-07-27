/*1. A RABAT_xxxxxx sorok beolvasztása a tétel sorokba*/
UPDATE
  ORDERS_00f AS C
  INNER JOIN (
SELECT  
        t1.sql_id,
    (t1.item_net_value_in_currency + t1.rabat_item_net_value_in_currency/t2.n) AS item_net_value_in_currency
FROM
(
SELECT  a.sql_id,
        b.sql_id AS rabat_sql_id,
    a.item_net_value_in_currency,
    b.item_net_value_in_currency AS rabat_item_net_value_in_currency
FROM
(
SELECT *
FROM ORDERS_00f
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT  sql_id,
    erp_id,
      item_net_value_in_currency,
      SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  ORDERS_00f
WHERE item_sku LIKE 'RABAT_%'
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.item_sku) > 0
) t1,
/*a t2 lekérdezés azért kell, mert ez adja meg, hogy hány darab valódi tételből kell levonni a RABAT tételt*/
(

SELECT
        b.sql_id AS rabat_sql_id,
        COUNT(b.erp_id)/num_of_rabat AS n
FROM
(
SELECT *
FROM ORDERS_00f
WHERE item_type = 'T'
) a LEFT JOIN

(
SELECT  sql_id,
    erp_id,
      item_net_value_in_currency,
      SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  ORDERS_00f
WHERE item_sku LIKE 'RABAT_%'
) b 
ON a.erp_id = b.erp_id
 LEFT JOIN
(
SELECT
        x.sql_id,
    COUNT(y.sql_id) AS num_of_rabat
FROM
(
SELECT *
FROM ORDERS_00f
WHERE item_type = 'T'
) x LEFT JOIN
(
SELECT  sql_id,
    erp_id,
    item_quantity,
      item_net_value_in_currency,
      SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  ORDERS_00f
WHERE item_sku LIKE 'RABAT_%'
) y
ON x.erp_id = y.erp_id 
WHERE LOCATE(y.service_item_sku, x.item_sku) > 0
GROUP BY x.sql_id
) c
ON a.sql_id = c.sql_id
WHERE LOCATE(b.service_item_sku, a.item_sku) > 0
GROUP BY b.sql_id
) t2
WHERE t1.rabat_sql_id = t2.rabat_sql_id
  ) as A on C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

/*1.2. A RABAT_ sor törlése: csak azokat a RABAT_ sorokat kell törölni, amiknek van termék párjuk*/
DELETE FROM ORDERS_00f
WHERE sql_id IN 
(
SELECT  
        b.sql_id
FROM
(
SELECT *
FROM ORDERS_00f
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT  sql_id,
    erp_id,
      SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  ORDERS_00f
WHERE item_sku LIKE 'RABAT_%'
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.item_sku) > 0
);

DROP TABLE IF EXISTS ORDERS_00g;
CREATE TABLE IF NOT EXISTS ORDERS_00g LIKE ORDERS_00f;
ALTER TABLE ORDERS_00g ADD `rabat_sql_id` INT(1) NOT NULL;

INSERT INTO ORDERS_00g
SELECT x.*,
        y.rabat_sql_id
FROM ORDERS_00f AS x
 LEFT JOIN
(
SELECT
    DISTINCT b.*,
    CASE WHEN abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency) THEN 1 ELSE 0 END AS rabat_sql_id
FROM
(
SELECT *
FROM ORDERS_00f
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT  sql_id,
    erp_id,
      item_net_value_in_currency
FROM  ORDERS_00f
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT')
) b
ON a.erp_id = b.erp_id
WHERE abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency)
) y
ON x.sql_id = y.sql_id
;

UPDATE
  ORDERS_00g AS C
  INNER JOIN (
      SELECT  
    a.sql_id,
        b.rabat_sql_id,
    (a.item_net_value_in_currency + b.item_net_value_in_currency) AS item_net_value_in_currency
FROM
(
SELECT *
FROM ORDERS_00g
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT  sql_id AS rabat_sql_id,
    erp_id,
      item_net_value_in_currency
FROM  ORDERS_00g
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT')
) b
ON a.erp_id = b.erp_id
WHERE ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency)
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

DELETE FROM ORDERS_00g WHERE rabat_sql_id = 1;

UPDATE
  ORDERS_00g AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT *
FROM ORDERS_00g
WHERE item_type = 'T'
) a,
(
SELECT  erp_id,
      SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  ORDERS_00g
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT')
GROUP BY erp_id
) b,
(
SELECT  erp_id,
      SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM ORDERS_00g
WHERE item_type = 'T'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

DELETE FROM INVOICES_00g WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'TEST', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'ajandek');