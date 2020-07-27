/*1. A RABAT_xxxxxx típusú kupon sorok beolvasztása a tétel sorokba*/
UPDATE
  INVOICES_00 AS C
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
SELECT 	sql_id, /*a kedvezmény tételek nélküli tétel-lista*/
		erp_id,
		item_net_value_in_currency,
		CASE 	WHEN SUBSTR(item_sku,1,2) = '17' THEN 'TAM' /*a szemvizsgálatok miatt kell ez a feltétel*/
				ELSE item_sku 
		END AS product_item_sku
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a 
LEFT JOIN
(
SELECT  /*a kedvezmény tételek listája*/
		sql_id,
		erp_id,
		item_net_value_in_currency,
        CASE WHEN LOCATE('RABAT-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT-',-1) /*a szemvizsgálatok miatt kell ez a feltétel*/
        WHEN LOCATE('RABAT_',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT_',-1)      
        END AS service_item_sku
FROM  INVOICES_00
WHERE item_sku LIKE 'RABAT_%' OR item_sku LIKE 'RABAT-%'
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.product_item_sku) > 0
) t1,

/*a t2 lekérdezés azért kell, mert ez adja meg, hogy hány darab valódi tételből kell levonni a RABAT tételt*/
(
SELECT
        b.sql_id AS rabat_sql_id,
        COUNT(b.erp_id)/num_of_rabat AS n
FROM
(
SELECT  sql_id, /*a kedvezmény tételek nélküli tétel-lista*/
		erp_id, 		
		CASE 	WHEN SUBSTR(item_sku,1,2) = '17' THEN 'TAM' /*a szemvizsgálatok miatt kell ez a feltétel*/
				ELSE item_sku 
		END AS product_item_sku
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a 
LEFT JOIN
(
SELECT  sql_id, /*a kedvezmény tételek listája*/
		erp_id,
		item_net_value_in_currency,
        CASE 	WHEN LOCATE('RABAT-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT-',-1) /*a szemvizsgálatok miatt kell ez a feltétel*/
				WHEN LOCATE('RABAT_',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT_',-1)      
        END AS service_item_sku
FROM  INVOICES_00
WHERE item_sku LIKE 'RABAT_%' OR item_sku LIKE 'RABAT-%'
) b 
ON a.erp_id = b.erp_id
LEFT JOIN
(
SELECT
        x.sql_id,
		COUNT(y.sql_id) AS num_of_rabat
FROM
(
SELECT *, 		
		CASE 	WHEN SUBSTR(item_sku,1,2) = '17' THEN 'TAM' /*a szemvizsgálatok miatt kell ez a feltétel*/
				ELSE item_sku 
		END AS product_item_sku
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) x 
LEFT JOIN
(
SELECT  sql_id,
		erp_id,
		item_quantity,
		item_net_value_in_currency,
        CASE 	WHEN LOCATE('RABAT-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT-',-1) /*a szemvizsgálatok miatt kell ez a feltétel*/
				WHEN LOCATE('RABAT_',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT_',-1)      
        END AS service_item_sku
FROM  INVOICES_00
WHERE item_sku LIKE 'RABAT_%' OR item_sku LIKE 'RABAT-%'
) y
ON x.erp_id = y.erp_id 
WHERE LOCATE(y.service_item_sku, x.product_item_sku) > 0
GROUP BY x.sql_id
) c
ON a.sql_id = c.sql_id
WHERE LOCATE(b.service_item_sku, a.product_item_sku) > 0
GROUP BY b.sql_id
) t2
WHERE t1.rabat_sql_id = t2.rabat_sql_id
  ) as A on C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

/*1.2. A RABAT_ sor törlése: csak azokat a RABAT_ sorokat kell törölni, amiknek van termék párjuk*/
DELETE FROM INVOICES_00
WHERE sql_id IN 
(
SELECT  
        b.sql_id
FROM
(
SELECT 	sql_id,
		erp_id,
		CASE 	WHEN SUBSTR(item_sku,1,2) = '17' THEN 'TAM' /*a szemvizsgálatok miatt kell ez a feltétel*/
				ELSE item_sku 
		END AS product_item_sku
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a LEFT JOIN
(
SELECT  sql_id,
		erp_id,
        CASE WHEN LOCATE('RABAT-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT-',-1)
        WHEN LOCATE('RABAT_',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT_',-1)      
        END AS service_item_sku
FROM  INVOICES_00
WHERE item_sku LIKE 'RABAT_%' OR item_sku LIKE 'RABAT-%'
) b
ON a.erp_id = b.erp_id 
WHERE LOCATE(b.service_item_sku, a.product_item_sku) > 0
);




/*2. Tétel értékkel EGYENÉRÉTKŰ kupon: */
/*2.1. A később törlendő RABAT sor megjelölése*/  
DROP TABLE IF EXISTS INVOICES_00g;
CREATE TABLE INVOICES_00g
SELECT 	x.sql_id,
		x.erp_id,
		x.item_type,
		x.group_id,
		x.item_net_value_in_currency,
		x.exchange_rate_of_currency,
		x.item_sku,
        y.rabat_sql_id
FROM INVOICES_00 AS x
 LEFT JOIN
(
SELECT
    DISTINCT b.*,
    CASE WHEN ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency) THEN 1 ELSE 0 END AS rabat_sql_id
FROM
(
SELECT erp_id, item_net_value_in_currency /*a kedvezmény tételek nélküli tétel-lista*/
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a INNER JOIN
(
SELECT  /*a kedvezmény tételek listája*/
		sql_id,
		erp_id,
		item_net_value_in_currency
FROM  INVOICES_00
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */
) b
ON a.erp_id = b.erp_id
WHERE ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency)
) y
ON x.sql_id = y.sql_id
;

ALTER TABLE INVOICES_00g ADD PRIMARY KEY (`sql_id`) USING BTREE;


/*2.2 A RABAT értékének a kivonása hozzá tartozó tételből*/ 
UPDATE
  INVOICES_00g AS C
  INNER JOIN (
      SELECT  
		a.sql_id,
        b.rabat_sql_id,
    0 AS item_net_value_in_currency
FROM
(
SELECT * /*a kedvezmény tételek nélküli tétel-lista*/
FROM INVOICES_00g
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a LEFT JOIN
(
SELECT  /*a kedvezmény tételek listája*/
		sql_id AS rabat_sql_id,
		erp_id,
		item_net_value_in_currency
FROM  INVOICES_00g
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */ 
) b
ON a.erp_id = b.erp_id
WHERE ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency)
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

/*2.3. A RABAT sor törlése*/
DELETE FROM INVOICES_00g WHERE rabat_sql_id = 1;



/*3. Egész rendeléshez tartozó kedvezmény tétel*/
UPDATE
  INVOICES_00g AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT * /*a eredeti (kedvezmény nélküli) tételek listája*/
FROM INVOICES_00g
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a,
(
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  INVOICES_00g
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */ 
GROUP BY erp_id
) b,
(
SELECT  /*az eredeti tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM INVOICES_00g
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
;

/*3.1. A maradék RABAT sorok törlése*/ 
DELETE FROM INVOICES_00
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'TEST', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */ 
;




UPDATE INVOICES_00 AS m
        LEFT JOIN
    INVOICES_00g AS s ON m.sql_id = s.sql_id
SET
    m.item_net_value_in_currency = s.item_net_value_in_currency
;