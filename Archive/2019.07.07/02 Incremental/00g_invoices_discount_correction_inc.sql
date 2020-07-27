/*GLS*/
UPDATE
  INVOICES_00 AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT /*a eredeti (kedvezmény nélküli) tételek listája*/
		sql_id, 
		erp_id, 
		item_net_value_in_currency 
FROM INVOICES_00
WHERE item_sku = 'GLS'
) a,
(
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  INVOICES_00
WHERE item_sku = 'RABAT_GLS'
GROUP BY erp_id
) b,
(
SELECT  /*az eredeti tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM INVOICES_00
WHERE item_sku = 'GLS'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
WHERE C.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*A maradék GLS sorok törlése*/ 
DELETE FROM INVOICES_00
WHERE item_sku = 'RABAT_GLS'
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*Szemvizsgálat kedvezmény*/
UPDATE
  INVOICES_00 AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT /*a eredeti (kedvezmény nélküli) tételek listája*/
		sql_id, 
		erp_id, 
		item_net_value_in_currency 
FROM INVOICES_00
WHERE SUBSTR(item_sku,1,2) = '17'
) a,
(
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  INVOICES_00
WHERE item_comment LIKE '%Szemvizsgálat vásárlási kedvezmény%'
GROUP BY erp_id
) b,
(
SELECT  /*az eredeti tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM INVOICES_00
WHERE SUBSTR(item_sku,1,2) = '17'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
WHERE C.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*A maradék Szemvizsgálat vásárlási kedvezmény sorok törlése*/ 
DELETE FROM INVOICES_00
WHERE item_comment LIKE '%Szemvizsgálat vásárlási kedvezmény%'
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;




/*LENCSE50*/
UPDATE
  INVOICES_00 AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT /*a eredeti (kedvezmény nélküli) tételek listája*/
		sql_id, 
		erp_id, 
		item_net_value_in_currency 
FROM INVOICES_00
WHERE SUBSTR(item_sku,1,3) = 'HO-'
) a,
(
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  INVOICES_00
WHERE item_comment LIKE '%LENCSE50%'
GROUP BY erp_id
) b,
(
SELECT  /*az eredeti tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM INVOICES_00
WHERE SUBSTR(item_sku,1,3) = 'HO-'
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
WHERE C.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*A maradék LENCSE50 sorok törlése*/ 
DELETE FROM INVOICES_00
WHERE item_comment LIKE '%LENCSE50%'
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;



/*1. A RABAT_xxxxxx típusú kupon sorok beolvasztása a tétel sorokba*/
DROP TABLE IF EXISTS aaa;
CREATE TABLE aaa
SELECT 	sql_id, /*a kedvezmény tételek nélküli tétel-lista*/
		erp_id,
		item_net_value_in_currency,
		CASE 	WHEN SUBSTR(item_sku,1,2) = '17' THEN 'TAM' /*a szemvizsgálatok miatt kell ez a feltétel*/
				ELSE item_sku
		END AS product_item_sku
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;

ALTER TABLE aaa ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE aaa ADD INDEX (`erp_id`) USING BTREE;
ALTER TABLE aaa ADD INDEX (`product_item_sku`) USING BTREE;


/*a RABAT_VAT elég szarul van elnevezve, mert alulvonásos, mint a RABAT_AOA6, de kategóriája a rendeléshez, és nem a tételhez kapcsolódó RABAT*/


DROP TABLE IF EXISTS bbb;
CREATE TABLE bbb
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		CASE WHEN item_sku = 'RABAT_VAT' THEN 'RABAT' ELSE item_sku END AS item_sku, /*a RABAT_VAT olyan, mint a RABAT, nem ide való*/
		SUM(item_net_value_in_currency) AS item_net_value_in_currency,
        CASE 	WHEN LOCATE('RABAT-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT-',-1) /*a szemvizsgálatok miatt kell ez a feltétel*/
				WHEN LOCATE('KUPON-',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'KUPON-',-1) /*a szemvizsgálatok miatt kell ez a feltétel*/
				WHEN LOCATE('RABAT_',item_sku) > 0 THEN SUBSTRING_INDEX(item_sku,'RABAT_',-1)
        END AS service_item_sku
FROM  INVOICES_00
WHERE (item_sku LIKE 'RABAT_%' OR item_sku = 'RABAT-TAM' OR item_sku = 'KUPON-TAM') 
AND item_net_value_in_currency < 0
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
GROUP BY erp_id, service_item_sku
;

ALTER TABLE bbb ADD INDEX (`erp_id`) USING BTREE;
ALTER TABLE bbb ADD INDEX (`service_item_sku`) USING BTREE;



DROP TABLE IF EXISTS ccc;
CREATE TABLE ccc
SELECT  a.sql_id,
		a.erp_id,
		a.item_net_value_in_currency,
        b.service_item_sku,
		b.item_net_value_in_currency AS rabat_item_net_value_in_currency
FROM
aaa AS a 
LEFT JOIN
bbb AS b
ON a.erp_id = b.erp_id
WHERE /* a feltétel azért kell, mert a BIOT3 benne van a BIOT387-ben helyesen, de helytelenül a BIOT300-ban is */
	CASE 	WHEN b.service_item_sku = 'BIOT3' THEN LOCATE(b.service_item_sku, REPLACE(a.product_item_sku,'BIOT300', NULL)) > 0
			ELSE LOCATE(b.service_item_sku, a.product_item_sku) > 0
	END
;


ALTER TABLE ccc ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE ccc ADD INDEX (`erp_id`) USING BTREE;
ALTER TABLE ccc ADD INDEX (`service_item_sku`) USING BTREE;



DROP TABLE IF EXISTS ddd;
CREATE TABLE ddd
SELECT 
		erp_id, 
		service_item_sku, 
		COUNT(sql_id) AS n
FROM ccc
GROUP BY erp_id, service_item_sku
;

ALTER TABLE ddd ADD INDEX (`erp_id`) USING BTREE;
ALTER TABLE ddd ADD INDEX (`service_item_sku`) USING BTREE;



DROP TABLE IF EXISTS eee;
CREATE TABLE eee
SELECT 
		ccc.erp_id,
		ccc.sql_id,		
		ccc.item_net_value_in_currency + ccc.rabat_item_net_value_in_currency/ddd.n AS item_net_value_in_currency /* rabat_item_net_value_in_currency = ennyi a kedvezmények összege; n = ennyi tételből kell levonni  */
FROM ccc
LEFT JOIN ddd
ON (ccc.erp_id = ddd.erp_id AND ccc.service_item_sku = ddd.service_item_sku)
;


ALTER TABLE eee ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE eee ADD INDEX (`erp_id`) USING BTREE;




UPDATE
INVOICES_00 AS u
LEFT JOIN eee r
ON r.sql_id = u.sql_id
SET
u.item_net_value_in_currency = r.item_net_value_in_currency
WHERE r.sql_id IS NOT NULL
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;



/*1.2. A RABAT_ sor törlése: csak azokat a RABAT_ sorokat kell törölni, amiknek van termék párjuk*/
DELETE FROM INVOICES_00 
USING INVOICES_00, bbb
WHERE bbb.erp_id = INVOICES_00.erp_id 
AND bbb.item_sku = INVOICES_00.item_sku
AND INVOICES_00.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*2. Tétel értékkel EGYENÉRÉTKŰ kupon: */
/*2.1. A később törlendő RABAT sor megjelölése*/  
DROP TABLE IF EXISTS INVOICES_rabat;
CREATE TABLE INVOICES_rabat
SELECT
    DISTINCT b.*,
    CASE WHEN ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency) THEN 'rabat' ELSE 'other' END AS rabat_sql_id
FROM
(
SELECT 	sql_id,		/*a kedvezmény tételek nélküli tétel-lista*/
		erp_id,
		item_net_value_in_currency 
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
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
;

ALTER TABLE INVOICES_rabat ADD PRIMARY KEY (`sql_id`) USING BTREE;


DROP TABLE IF EXISTS INVOICES_product;
CREATE TABLE INVOICES_product
SELECT
    DISTINCT a.*,
    CASE WHEN ABS(a.item_net_value_in_currency) = ABS(b.item_net_value_in_currency) THEN 'product' ELSE 'other' END AS rabat_sql_id
FROM
(
SELECT 	sql_id,		/*a kedvezmény tételek nélküli tétel-lista*/
		erp_id,
		item_net_value_in_currency 
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
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
;

ALTER TABLE INVOICES_product ADD PRIMARY KEY (`sql_id`) USING BTREE;



/*2.2 A RABAT értékének a kivonása hozzá tartozó tételből*/ 
DROP TABLE IF EXISTS INVOICES_00g;
CREATE TABLE INVOICES_00g
SELECT 	p.erp_id, 
		p.sql_id, 
		(p.item_net_value_in_currency + r.sum_rabat_net_value/n.num_of_product) AS item_net_value_in_currency
FROM INVOICES_product p
LEFT JOIN
(
SELECT 	erp_id,
		SUM(item_net_value_in_currency) AS sum_rabat_net_value
FROM INVOICES_rabat
GROUP BY erp_id
) r
ON p.erp_id = r.erp_id
LEFT JOIN
(
SELECT 	erp_id,
		COUNT(sql_id) AS num_of_product
FROM INVOICES_product
GROUP BY erp_id
) n
ON p.erp_id = n.erp_id
;


ALTER TABLE INVOICES_00g ADD PRIMARY KEY (`sql_id`) USING BTREE;


UPDATE
INVOICES_00 AS u
LEFT JOIN INVOICES_00g r
ON r.sql_id = u.sql_id
SET
u.item_net_value_in_currency = r.item_net_value_in_currency
WHERE r.sql_id IS NOT NULL
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;



/*2.3. A RABAT sor törlése*/
DELETE FROM INVOICES_00 
USING INVOICES_00, INVOICES_rabat 
WHERE INVOICES_rabat.sql_id = INVOICES_00.sql_id
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;



/*3. Egész rendeléshez tartozó kedvezmény tétel*/
UPDATE
  INVOICES_00 AS C
  INNER JOIN (
SELECT
    a.sql_id,
    COALESCE((a.item_net_value_in_currency + b.rabat_item_net_value_in_currency*a.item_net_value_in_currency/c.sum_item_net_value_in_currency),0) AS item_net_value_in_currency
FROM
(
SELECT * /*a eredeti (kedvezmény nélküli) tételek listája*/
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
) a,
(
SELECT  /*a kedvezmény tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS rabat_item_net_value_in_currency
FROM  INVOICES_00
WHERE item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */ 
GROUP BY erp_id
) b,
(
SELECT  /*az eredeti tételek szummája*/
		erp_id,
		SUM(item_net_value_in_currency) AS sum_item_net_value_in_currency
FROM INVOICES_00
WHERE item_sku NOT IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
AND group_id NOT IN (139)
GROUP BY erp_id
) c
WHERE a.erp_id = b.erp_id
AND a.erp_id = c.erp_id
  ) AS A ON C.sql_id = A.sql_id
SET C.item_net_value_in_currency = A.item_net_value_in_currency
WHERE C.new_entry = 1 /*csak az uj sorokat update-eljük*/
;


/*3.1. A maradék RABAT sorok törlése*/ 
DELETE FROM INVOICES_00
WHERE (item_sku IN ('VOUCHER5000', 'VOUCHER10000', 'KUPON', 'KUPONKOD', 'RABAT', '0', 'TEST', 'SZEPSZEMEK', 'RABAT_OTHER', 'RABAT_VAT', 'RABAT-TAM') /* ez a lista a régi kedvezményeket kezeli (néhányuk group_id = 220) */
OR group_id IN (139)) /* ezen a kódon minden jövőbeni kedvezmény is bekerül */ 
AND new_entry = 1 /*csak az uj sorokat update-eljük*/
;
