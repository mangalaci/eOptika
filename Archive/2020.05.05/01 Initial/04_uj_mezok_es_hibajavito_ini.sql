
UPDATE
BASE_03_TABLE AS b
LEFT JOIN IN_LVCR_item AS i 
ON b.CT2_pack = i.Description
SET
b.LVCR_item_flg = CASE WHEN i.Description IS NOT NULL THEN 1 ELSE 0 END
;


UPDATE
BASE_03_TABLE AS b
LEFT JOIN IN_GDPR_opt_out AS i 
ON b.buyer_email = i.email
SET
b.GDPR_status = i.GDPR_status
;



/* supplier_name: BEGIN*/
ALTER TABLE BASE_03_TABLE ADD INDEX `CT1_sku` (`CT1_sku`) USING BTREE;

DROP TABLE IF EXISTS erp_supplier_name;
CREATE TABLE IF NOT EXISTS erp_supplier_name
SELECT e.invoice_reference, e.purchase_reference, e.sku, p.supplier_name
FROM erp_purchase_prices e
LEFT JOIN purchases p
ON e.sku = p.item_sku AND e.purchase_reference = p.erp_id
;


ALTER TABLE erp_supplier_name ADD INDEX `invoice_reference` (`invoice_reference`) USING BTREE;
ALTER TABLE erp_supplier_name ADD INDEX `sku` (`sku`) USING BTREE;



UPDATE
BASE_03_TABLE b
LEFT JOIN erp_supplier_name e
ON b.erp_invoice_id = e.invoice_reference AND b.CT1_SKU = e.sku
SET
	b.supplier_name = e.supplier_name
;
/* supplier_name: END*/



/*hiányzó related_webshop kitöltése: BEGIN*/
UPDATE
BASE_03_TABLE
SET
	related_webshop = CASE WHEN (source_of_trx = 'offline' AND related_webshop = '') THEN 'offline' ELSE related_webshop END,
	related_webshop = CASE WHEN (source_of_trx = 'online' AND related_webshop = '') THEN 'Other' ELSE related_webshop END,
	related_webshop = CASE WHEN (related_webshop = 'eoptika.hu') THEN 'eOptika.hu' ELSE related_webshop END
;
/*hiányzó related_webshop kitöltése: END*/


/* EXPERIMENT mező hozzáadása : START */


/* 'CL-THX10W' kapott, és beváltotta */
UPDATE BASE_03_TABLE m
LEFT JOIN
(
SELECT user_id, created
FROM `BASE_03_TABLE` 
WHERE origin = 'invoices'
AND CT1_SKU = 'CL-THX10W'
AND trx_rank = 1
) s
ON m.user_id = s.user_id 
SET m.experiment = CASE WHEN s.user_id IS NOT NULL THEN 'CL-THX10W-YES' ELSE NULL END
WHERE m.origin = 'invoices' 
AND m.related_division = 'Optika - HU' 
AND m.coupon_code = 'THX10W' 
AND m.trx_rank = 2
;

/* 'CL-THX10W' kapott, de nem váltotta be */
UPDATE BASE_03_TABLE m
LEFT JOIN
(
SELECT user_id, created
FROM `BASE_03_TABLE` 
WHERE origin = 'invoices'
AND CT1_SKU = 'CL-THX10W'
AND trx_rank = 1
) s
ON m.user_id = s.user_id 
SET m.experiment = CASE WHEN s.user_id IS NOT NULL THEN 'CL-THX10W-NO' ELSE NULL END
WHERE m.origin = 'invoices' 
AND m.related_division = 'Optika - HU' 
AND m.coupon_code IS NULL
AND m.trx_rank = 2
;

/* EXPERIMENT mező hozzáadása: END */





/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   START */

DROP TABLE IF EXISTS missing_gender;
CREATE TABLE IF NOT EXISTS `missing_gender`
SELECT DISTINCT buyer_email 
FROM BASE_03_TABLE 
WHERE gender = 'missing'
;



ALTER TABLE missing_gender ADD PRIMARY KEY (`buyer_email`) USING BTREE;


/*first_name*/
DROP TABLE IF EXISTS best_first_name;
CREATE TABLE IF NOT EXISTS best_first_name
SELECT j.buyer_email, j.first_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT buyer_email, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT buyer_email, first_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) t
GROUP BY buyer_email
) i,

(

SELECT a.*
FROM
(
SELECT buyer_email, first_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) a,

(
SELECT buyer_email, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email
) b
WHERE (a.buyer_email = b.buyer_email AND a.gender = b.gender)

) j
WHERE (i.buyer_email = j.buyer_email AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_first_name ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE best_first_name CHANGE `first_name` `first_name` VARCHAR(100);
ALTER TABLE best_first_name ADD INDEX `first_name` (`first_name`) USING BTREE;



UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_first_name AS n ON b.buyer_email = n.buyer_email
SET
b.first_name = n.first_name
WHERE n.buyer_email IS NOT NULL
;



/*full_name*/
DROP TABLE IF EXISTS best_full_name;
CREATE TABLE IF NOT EXISTS best_full_name
SELECT j.buyer_email, j.full_name
FROM
/* a leggyakrabban előforduló név kiválasztása */
(
SELECT buyer_email, MAX(name_occurance) AS max_name_occurance
FROM
(
SELECT buyer_email, full_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) t
GROUP BY buyer_email
) i,

(

SELECT a.*
FROM
(
SELECT buyer_email, full_name, gender, COUNT(DISTINCT erp_invoice_id) AS name_occurance
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email, gender
) a,

(
SELECT buyer_email, MIN(gender) AS gender
FROM BASE_03_TABLE
WHERE buyer_email <> ''
AND buyer_email IN
(
SELECT DISTINCT buyer_email 
FROM missing_gender
)
GROUP BY buyer_email
) b
WHERE (a.buyer_email = b.buyer_email AND a.gender = b.gender)

) j
WHERE (i.buyer_email = j.buyer_email AND j.name_occurance = i.max_name_occurance)
;


ALTER TABLE best_full_name ADD PRIMARY KEY (`buyer_email`) USING BTREE;
ALTER TABLE best_full_name CHANGE `full_name` `full_name` VARCHAR(100);
ALTER TABLE best_full_name ADD INDEX `full_name` (`full_name`) USING BTREE;


UPDATE
BASE_03_TABLE AS b
LEFT JOIN best_full_name AS n ON b.buyer_email = n.buyer_email
SET
b.full_name = n.full_name
WHERE (n.buyer_email IS NOT NULL AND b.buyer_email LIKE '%@%')
;

/*gender*/

UPDATE
BASE_03_TABLE AS c
LEFT JOIN IN_gender AS g 
ON g.first_name = c.first_name
SET
c.gender = g.gender
WHERE g.first_name IS NOT NULL
;



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, last_name, full_name, gender kitöltése   END */





/*   bonus_rate */
UPDATE
BASE_03_TABLE AS b
left join IN_sales_performance s
on  b.CT2_pack = s.CT2_pack
set b.bonus_rate = s.color
where b.product_group in ('Contact lenses', 'Contact lens cleaners', 'Eye drops', 'Others');


UPDATE
BASE_03_TABLE AS b
LEFT JOIN IN_sales_performance s
ON  b.CT1_sku = s.CT2_pack
SET b.bonus_rate = s.color
where b.product_group in ('Sunglasses', 'Spectacles', 'Lenses for spectacles', 'Frames');
;
