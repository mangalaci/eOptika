/*A szemüveglencse réteg tételek beolvasztása a szemüveglencse tételekbe*/
DROP TABLE IF EXISTS INVOICES_00e_aux;
CREATE TABLE IF NOT EXISTS INVOICES_00e_aux
SELECT 	a.erp_id, 
	a.sql_id, 
	SUM(a.item_net_value_in_currency) + COALESCE(b.service_item_net_value_in_currency,0) AS item_net_value_in_currency, /*lencse + réteg*/
	SUM(a.item_net_sale_price_in_base_currency) + COALESCE(b.service_item_net_sale_price_in_base_currency,0) AS item_net_sale_price_in_base_currency /*lencse + réteg*/
FROM INVOICES_00_inc a
LEFT JOIN
(
SELECT 	m.erp_id, 
		SUM(m.item_net_value_in_currency)/s.num_of_trx AS service_item_net_value_in_currency,
		SUM(m.item_net_sale_price_in_base_currency)/s.num_of_trx AS service_item_net_sale_price_in_base_currency
FROM INVOICES_00_inc m
LEFT JOIN
(
SELECT 	/*a szemüveglencse tételek száma rétegek nélkül*/
		erp_id, 
		COUNT(erp_id) AS num_of_trx
FROM INVOICES_00_inc
WHERE product_group = 'Lenses for spectacles'
AND item_type = 'T'
GROUP BY erp_id
) s
ON m.erp_id = s.erp_id
WHERE m.product_group = 'Lenses for spectacles'
AND m.item_type = 'S'
GROUP BY m.erp_id
) b
ON a.erp_id = b.erp_id
WHERE a.product_group = 'Lenses for spectacles'
AND a.item_type = 'T'
GROUP BY a.erp_id, a.sql_id
;

ALTER TABLE INVOICES_00e_aux ADD PRIMARY KEY (`sql_id`) USING BTREE;
ALTER TABLE INVOICES_00e_aux ADD INDEX `item_net_value_in_currency` (`item_net_value_in_currency`) USING BTREE;
ALTER TABLE INVOICES_00e_aux ADD INDEX `item_net_sale_price_in_base_currency` (`item_net_sale_price_in_base_currency`) USING BTREE;


UPDATE
INVOICES_00_inc AS m
LEFT JOIN INVOICES_00e_aux AS s 
ON m.sql_id = s.sql_id
SET m.item_net_value_in_currency = CASE
        WHEN s.sql_id IS NOT NULL THEN s.item_net_value_in_currency
        ELSE m.item_net_value_in_currency
    END,
	m.item_net_sale_price_in_base_currency = CASE
        WHEN s.sql_id IS NOT NULL THEN s.item_net_sale_price_in_base_currency
        ELSE m.item_net_sale_price_in_base_currency
    END
;

/*réteg tételek eltávolítása*/	
DELETE FROM INVOICES_00_inc
WHERE product_group = 'Lenses for spectacles'
AND item_type = 'S'
;


UPDATE
INVOICES_002_inc AS m
LEFT JOIN INVOICES_00e_aux AS s 
ON m.sql_id = s.sql_id
SET m.item_net_value_in_currency = CASE
        WHEN s.sql_id IS NOT NULL THEN s.item_net_value_in_currency
        ELSE m.item_net_value_in_currency
    END,
	m.item_net_sale_price_in_base_currency = CASE
        WHEN s.sql_id IS NOT NULL THEN s.item_net_sale_price_in_base_currency
        ELSE m.item_net_sale_price_in_base_currency
    END
;

/*réteg tételek eltávolítása*/	
DELETE FROM INVOICES_002_inc
WHERE product_group = 'Lenses for spectacles'
AND item_type = 'S'
;
