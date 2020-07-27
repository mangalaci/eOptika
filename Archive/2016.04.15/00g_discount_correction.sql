/*1. A RABAT_xxxxxx sorok beolvasztása a tétel sorokba*/
UPDATE
  BASE_00f_TABLE AS C
  INNER JOIN (
SELECT 	
        t1.sql_id,
		(t1.item_net_value_in_currency + t1.rabat_item_net_value_in_currency/t2.n) AS item_net_value_in_currency,
		(t1.item_net_purchase_price_in_base_currency + t1.rabat_item_net_purchase_price_in_base_currency/t2.n) AS item_net_purchase_price_in_base_currency
FROM
(
SELECT  a.sql_id,
        b.sql_id AS rabat_sql_id,
		a.item_net_value_in_currency,
		a.item_net_purchase_price_in_base_currency,
		b.item_net_value_in_currency AS rabat_item_net_value_in_currency,
		b.item_net_purchase_price_in_base_currency AS rabat_item_net_purchase_price_in_base_currency
FROM
(
SELECT *
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT 	sql_id,
		erp_id,
    	item_net_value_in_currency,
		item_net_purchase_price_in_base_currency,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
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
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) a LEFT JOIN

(
SELECT 	sql_id,
		erp_id,
    	item_net_value_in_currency,
		item_net_purchase_price_in_base_currency,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
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
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) x LEFT JOIN
(
SELECT 	sql_id,
		erp_id,
		item_quantity,
    	item_net_value_in_currency,
		item_net_purchase_price_in_base_currency,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
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
SET C.item_net_value_in_currency = A.item_net_value_in_currency,
 C.item_net_purchase_price_in_base_currency = A.item_net_purchase_price_in_base_currency
;




/*1.2. A RABAT_ sor törlése: csak azokat a RABAT_ sorokat kell törölni, amiknek van termék párjuk*/
DELETE FROM BASE_00f_TABLE
WHERE sql_id IN 
(
SELECT  
        b.sql_id
FROM
(
SELECT *
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT 	sql_id,
		erp_id,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
WHERE item_sku LIKE 'RABAT_%'
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.item_sku) > 0
)
;


/*2. Az 1 termékhez tartozó RABAT és KUPON sorok beolvasztása a tétel sorokba*/
/*2.1. A később törlendő RABAT sor megjelölése*/  
DROP TABLE IF EXISTS BASE_00g_TABLE;
CREATE TABLE BASE_00g_TABLE
SELECT x.*,
        y.rabat_sql_id
FROM BASE_00f_TABLE x
 LEFT JOIN
(
SELECT
		DISTINCT b.*,
		CASE WHEN abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency) THEN 1 ELSE 0 END AS rabat_sql_id
FROM
(
SELECT *
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT 	sql_id,
		erp_id,
    	item_net_value_in_currency,
    	item_net_purchase_price_in_base_currency
FROM  BASE_00f_TABLE
WHERE item_sku in ('KUPON', 'RABAT', '0')
) b
ON a.erp_id = b.erp_id
WHERE abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency)
) y
ON x.sql_id = y.sql_id
;


/*2.2 A RABAT értékének a kivonása hozzá tartozó tételből*/  
UPDATE
  BASE_00g_TABLE as C
  INNER JOIN (
      SELECT  
		a.sql_id,
        b.rabat_sql_id,
		(a.item_net_value_in_currency + b.item_net_value_in_currency) AS item_net_value_in_currency,
		(a.item_net_purchase_price_in_base_currency + b.item_net_purchase_price_in_base_currency) AS item_net_purchase_price_in_base_currency
FROM
(
SELECT *
FROM BASE_00g_TABLE
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT 	sql_id AS rabat_sql_id,
		erp_id,
    	item_net_value_in_currency,
    	item_net_purchase_price_in_base_currency
FROM  BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT', '0')
) b
ON a.erp_id = b.erp_id
WHERE ABS(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency)
  ) as A on C.sql_id = A.sql_id
set C.item_net_value_in_currency = A.item_net_value_in_currency,
 C.item_net_purchase_price_in_base_currency = A.item_net_purchase_price_in_base_currency
;


/*2.3. A RABAT sor törlése*/  
DELETE FROM BASE_00g_TABLE
WHERE rabat_sql_id = 1
;


/*3. Több termékhez tartozó egy rendelésen több RABAT sor beolvasztása a tétel sorokba*/
UPDATE
  BASE_00g_TABLE as C
  inner join (
SELECT
		a.sql_id,
		(a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency) AS item_net_value_in_currency,
		(a.item_net_purchase_price_in_base_currency + b.rabat_item_net_purchase_price_in_base_currency*a.item_net_purchase_price_in_base_currency/c.sum_item_net_purchase_price_in_base_currency) AS item_net_purchase_price_in_base_currency
FROM
(
SELECT *
FROM BASE_00g_TABLE
WHERE item_type = 'T'
) a,
(
SELECT 	erp_id,
    	SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency,
        SUM(item_net_purchase_price_in_base_currency) AS rabat_item_net_purchase_price_in_base_currency
FROM  BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT', '0')
GROUP BY erp_id
) b,
(
SELECT 	erp_id,
    	SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency,
    	SUM(item_net_purchase_price_in_base_currency) AS sum_item_net_purchase_price_in_base_currency
FROM BASE_00g_TABLE
WHERE item_type = 'T'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) as A on C.sql_id = A.sql_id
set C.item_net_value_in_currency = A.item_net_value_in_currency,
 C.item_net_purchase_price_in_base_currency = A.item_net_purchase_price_in_base_currency
;


/*3.1. A maradék RABAT sorok törlése*/  
DELETE FROM BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT', '0', 'TEST')
;



ALTER TABLE BASE_00g_TABLE ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

