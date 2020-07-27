ALTER TABLE BASE_00e_TABLE
  DROP COLUMN __ZDBID,
  DROP COLUMN related_department,
  DROP COLUMN related_customer_group,
  DROP COLUMN lot_number,
  DROP COLUMN unknown,
  DROP COLUMN ProductID,
  DROP COLUMN ParentID,
  DROP COLUMN IsSpheric,
  DROP COLUMN IsMultifocal,
  DROP COLUMN IsToric,
  DROP COLUMN Net_revenue_per_item,
  DROP COLUMN Net_revenue_per_order,
  DROP COLUMN item_net_registered_price_in_base_currency,
  DROP COLUMN item_net_clearing_price_in_base_currency,
  DROP COLUMN packaging_weight_in_kg
  ;



/*1. A RABAT_xxxxxx sorok beolvasztása a tétel sorokba*/
  
  
CREATE TABLE BASE_00g_TABLE AS
SELECT e.*, f.Revenues_wdisc_in_local_currency,
			f.Revenues_wdisc_in_base_currency,
			f.Gross_margin_wdisc_in_base_currency
FROM BASE_00f_TABLE e LEFT JOIN
(
SELECT 	
        t1.sql_id,
		(t1.item_net_value_in_currency + t1.rabat_item_net_value_in_currency/t2.num_of_rabat) AS Revenues_wdisc_in_local_currency,
		(t1.item_net_value + t1.rabat_item_net_value/t2.num_of_rabat) AS Revenues_wdisc_in_base_currency,
		(t1.item_gross_value + t1.rabat_item_gross_value/t2.num_of_rabat) AS Gross_margin_wdisc_in_base_currency
		FROM
(
SELECT  DISTINCT
		a.sql_id,
		b.rabat_sql_id,
		a.item_net_value_in_currency,
		a.item_net_value,
		a.item_gross_value,
		b.item_net_value_in_currency AS rabat_item_net_value_in_currency,
		b.item_net_value AS rabat_item_net_value,
        b.item_gross_value AS rabat_item_gross_value
FROM
(
SELECT *
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) a LEFT JOIN
(
SELECT 	MAX(sql_id) AS rabat_sql_id,
		MAX(erp_id) AS erp_id,
    	SUM(item_net_value_in_currency) AS item_net_value_in_currency,
        SUM(item_net_value) AS item_net_value,
    	SUM(item_gross_value) AS item_gross_value,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
WHERE item_sku LIKE 'RABAT_%'
AND erp_id = 'SO14/63657'
GROUP BY SUBSTRING_INDEX(item_sku,'RABAT_',-1)
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.item_sku) > 0
) t1,


/*a t2 lekérdezés azért kell, mert ez adja meg, hogy hány darab valódi tételből kell levonni a RABAT tételt*/
(
SELECT
       y.rabat_sql_id,
		COUNT(x.sql_id) AS num_of_rabat
FROM
(
SELECT sql_id, erp_id, item_sku
FROM BASE_00f_TABLE
WHERE item_type = 'T'
) x LEFT JOIN

(
SELECT 	sql_id AS rabat_sql_id, erp_id,
    	SUBSTRING_INDEX(item_sku,'RABAT_',-1) AS service_item_sku
FROM  BASE_00f_TABLE
WHERE item_sku LIKE 'RABAT_%'
AND erp_id = 'SO14/63657'
) y
ON x.erp_id = y.erp_id 
WHERE LOCATE(y.service_item_sku, x.item_sku) > 0
GROUP BY y.rabat_sql_id
) t2



WHERE t1.rabat_sql_id = t2.rabat_sql_id
) f
ON e.sql_id = f.sql_id


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
        item_vat_value_in_currency,
    	item_gross_value_in_currency
FROM  BASE_00f_TABLE
WHERE item_sku in ('KUPON', 'RABAT')
) b
ON a.erp_id = b.erp_id
WHERE abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency)
) y
ON x.sql_id = y.sql_id
;


/*2.2 A RABAT értékének a kivonása hozzá tartozó tételből*/  
UPDATE
  BASE_00g_TABLE as C
  inner join (
      SELECT  
		a.sql_id,
        b.rabat_sql_id,
		(a.item_net_value_in_currency + b.item_net_value_in_currency) AS item_net_value_in_currency,
		(a.item_vat_value_in_currency + b.item_vat_value_in_currency) AS item_vat_value_in_currency,
        (a.item_gross_value_in_currency + b.item_gross_value_in_currency) AS item_gross_value_in_currency
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
        item_vat_value_in_currency,
    	item_gross_value_in_currency
FROM  BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT')
) b
ON a.erp_id = b.erp_id
WHERE abs(a.item_net_value_in_currency) = abs(b.item_net_value_in_currency)
  ) as A on C.sql_id = A.sql_id
set C.item_net_value_in_currency = A.item_net_value_in_currency,
 C.item_vat_value_in_currency = A.item_vat_value_in_currency,
 C.item_gross_value_in_currency = A.item_gross_value_in_currency
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
		(a.item_vat_value_in_currency + b.rabat_item_vat_value_in_currency*a.item_vat_value_in_currency/c.sum_item_vat_value_in_currency) AS item_vat_value_in_currency,
        (a.item_gross_value_in_currency + b.rabat_item_gross_value_in_currency*a.item_gross_value_in_currency/c.sum_item_gross_value_in_currency) AS item_gross_value_in_currency
FROM
(
SELECT *
FROM BASE_00g_TABLE
WHERE item_type = 'T'
) a,
(
SELECT 	erp_id,
    	SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency,
        SUM(item_vat_value_in_currency) AS rabat_item_vat_value_in_currency,
    	SUM(item_gross_value_in_currency) AS rabat_item_gross_value_in_currency
FROM  BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT')
GROUP BY erp_id
) b,
(
SELECT 	erp_id,
    	SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency,
        SUM(item_vat_value_in_currency) AS sum_item_vat_value_in_currency,
    	SUM(item_gross_value_in_currency) AS sum_item_gross_value_in_currency
FROM BASE_00g_TABLE
WHERE item_type = 'T'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) as A on C.sql_id = A.sql_id
set C.item_net_value_in_currency = A.item_net_value_in_currency,
 C.item_vat_value_in_currency = A.item_vat_value_in_currency,
 C.item_gross_value_in_currency = A.item_gross_value_in_currency
;


/*3.1. A maradék RABAT sorok törlése*/  
DELETE FROM BASE_00g_TABLE
WHERE item_sku in ('KUPON', 'RABAT')
;



ALTER TABLE BASE_00g_TABLE ADD PRIMARY KEY (`__ZDBID`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD UNIQUE `sql_id` (`sql_id`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `related_email_clean` (`related_email_clean`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `shipping_name_clean` (`shipping_name_clean`) USING BTREE;
ALTER TABLE BASE_00g_TABLE ADD INDEX `billing_zip_code` (`billing_zip_code`) USING BTREE;

