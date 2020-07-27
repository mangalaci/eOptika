

UPDATE
BASE_00i_TABLE_inc AS b
LEFT JOIN IN_LVCR_item AS i 
ON b.CT2_pack = i.Description
SET
b.LVCR_item_flg = CASE WHEN i.Description IS NOT NULL THEN 1 ELSE 0 END
;



UPDATE
BASE_00i_TABLE_inc AS b
LEFT JOIN IN_GDPR_opt_out AS i 
ON b.buyer_email = i.email
SET
b.GDPR_status = i.GDPR_status
;





/* supplier_name: BEGIN*/
ALTER TABLE BASE_00i_TABLE_inc ADD INDEX `CT1_sku` (`CT1_sku`) USING BTREE;

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
BASE_00i_TABLE_inc b
LEFT JOIN erp_supplier_name e
ON b.erp_invoice_id = e.invoice_reference AND b.CT1_SKU = e.sku
SET
	b.supplier_name = e.supplier_name
;
/* supplier_name: END*/






/*hiányzó related_webshop kitöltése: BEGIN*/
UPDATE
BASE_00i_TABLE_inc
SET
	related_webshop = CASE WHEN (source_of_trx = 'offline' AND related_webshop = '') THEN 'offline' ELSE related_webshop END,
	related_webshop = CASE WHEN (source_of_trx = 'online' AND related_webshop = '') THEN 'Other' ELSE related_webshop END,
	related_webshop = CASE WHEN (related_webshop = 'eoptika.hu') THEN 'eOptika.hu' ELSE related_webshop END
;
/*hiányzó related_webshop kitöltése: END*/






/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, full_name, gender kitöltése:   START */

/*first_name, full_name egyelőre csak a initialban működik*/

/*gender*/

UPDATE
BASE_00i_TABLE_inc AS c
LEFT JOIN IN_gender AS g 
ON g.first_name = c.first_name
SET
c.gender = g.gender
WHERE g.first_name IS NOT NULL
;



/*   HIBAJAVÍTÖ MODUL: hiányzó first_name, full_name, gender kitöltése:   END */





/*   bonus_rate */
UPDATE
BASE_00i_TABLE_inc AS b
left join IN_sales_performance s
on  b.CT2_pack = s.CT2_pack
set b.bonus_rate = s.color
where b.product_group in ('Contact lenses', 'Contact lens cleaners', 'Eye drops', 'Others');


UPDATE
BASE_00i_TABLE_inc AS b
LEFT JOIN IN_sales_performance s
ON  b.CT1_sku = s.CT2_pack
SET b.bonus_rate = s.color
where b.product_group in ('Sunglasses', 'Spectacles', 'Lenses for spectacles', 'Frames');
;




