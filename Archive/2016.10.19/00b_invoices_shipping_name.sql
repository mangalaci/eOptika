DROP TABLE IF EXISTS INVOICES_00b;
CREATE TABLE IF NOT EXISTS INVOICES_00b LIKE INVOICES_00a;
ALTER TABLE `INVOICES_00b` ADD `billing_city_clean` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `shipping_method2` VARCHAR(100) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `payment_method` VARCHAR(255) NOT NULL;
ALTER TABLE `INVOICES_00b` ADD `item_net_purchase_price_in_base_currency2` FLOAT;

INSERT INTO INVOICES_00b
SELECT
		 *,
/*név kinyerése shipping_name-ből*/
/*			TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(shipping_name_trim), '(', ''), '  ', ' '), 'dr.', ''), ')', ''), ',', ''), 'â', 'á'), '.', '')) AS shipping_name_clean, */
/*le kell szedni az ékezetes betűket a település nevéről, mert sok az elírás*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(billing_city,'á','a'),'é','e'),'í','i'),'ó','o'),'ú','u'),'ő','ö'),'ű','ü') AS billing_city_clean,
			
CASE WHEN shipping_method = 'Személyes átvétel' THEN 'Pickup in person'	
	 ELSE shipping_method
END AS shipping_method2,

CASE WHEN billing_method = 'Utánvét' THEN 'Cash on delivery'
	 WHEN billing_method = 'Készpénz' THEN 'Cash'
	 WHEN billing_method = 'Bankkártya' THEN 'Bank card (POS)'
	 WHEN billing_method = 'PayPal' THEN 'PayPal'
	 WHEN billing_method = 'Átutalás' THEN 'Bank transfer'
	 WHEN billing_method = 'Online fizetés' THEN 'Online payment'
	 WHEN billing_method = 'Kupon' THEN 'Coupon'
	 WHEN billing_method = 'Bankkártya POS' THEN 'Bank card (POS)'
	 ELSE billing_method
END AS payment_method,

CASE 	WHEN created >= '2013-01-01' /*2013-01-01 után a purchasing price-t kell venni*/
		THEN item_net_purchase_price_in_base_currency
		/*2013-01-01 előtt a clearing price-t kell venni*/
		ELSE item_net_clearing_price_in_base_currency
END AS item_net_purchase_price_in_base_currency2

FROM  INVOICES_00a
;


ALTER TABLE INVOICES_00b
  DROP COLUMN shipping_method,
  DROP COLUMN billing_method,
  DROP COLUMN item_net_clearing_price_in_base_currency,
  DROP COLUMN item_net_purchase_price_in_base_currency
;


ALTER TABLE INVOICES_00b CHANGE `shipping_method2` `shipping_method` VARCHAR(100);
ALTER TABLE INVOICES_00b CHANGE `item_net_purchase_price_in_base_currency2` `item_net_purchase_price_in_base_currency` FLOAT;
ALTER TABLE INVOICES_00b ADD INDEX `billing_city_clean` (`billing_city_clean`) USING BTREE;