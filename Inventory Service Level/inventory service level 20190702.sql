
/* ezt csak először kell futtatni:

DROP TABLE IF EXISTS inventory_service_level;
CREATE TABLE IF NOT EXISTS inventory_service_level
SELECT 
	YEAR(i.processed) AS order_year, 
	MONTH(i.processed) AS order_month, 
	DAY(i.processed) AS order_day_in_month,
	i.item_SKU AS CT1_SKU,
    a.CT1_SKU_name,
    a.CT2_pack,
	a.CT3_product,
	a.CT4_product_brand,
	a.CT5_manufacturer,
	NULL AS supplier,
	a.product_group,
	a.lens_type,
	a.wear_duration,
	a.is_color,
	i.related_division,
	i.related_warehouse,
	ROUND(SUM(i.item_quantity),0) AS Ordered,
	ROUND(SUM(CASE WHEN i.quantity_booked >= i.quantity_billed THEN i.quantity_booked ELSE i.quantity_billed END),0) AS Reserved,
	ROUND(SUM(CASE WHEN i.quantity_booked >= i.quantity_billed THEN i.quantity_booked ELSE i.quantity_billed END)/SUM(i.item_quantity),2) AS service_level,
	COUNT(DISTINCT i.related_email) AS Users,
	COUNT(DISTINCT i.erp_id) AS Transactions
FROM incoming_orders i
LEFT JOIN ab_cikkto_full AS a
ON i.item_sku = a.CT1_SKU
WHERE i.deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
AND LOWER(i.deletion_comment) NOT LIKE '%dupl%'
AND LOWER(i.deletion_comment) NOT LIKE '%teszt%'

AND i.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND i.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)

AND	i.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
AND i.item_group_name <> 'Szállítási díjak'

AND i.item_type = 'T'

AND YEAR(i.processed) = YEAR(CURRENT_DATE)
AND  MONTH(i.processed) = MONTH(CURRENT_DATE)
AND  DAY(i.processed) = DAY(DATE_ADD(CURRENT_DATE, INTERVAL -1 DAY))
AND i.is_deleted = 'no'
AND i.item_quantity > 0
GROUP BY order_year, order_month, order_day_in_month, CT1_SKU, CT1_SKU_name
;



ALTER TABLE inventory_service_level ADD INDEX (`CT1_SKU`) USING BTREE;
ALTER TABLE inventory_service_level ADD INDEX (`related_warehouse`) USING BTREE;


ALTER TABLE inventory_service_level ADD buffer_level INT(10);


update inventory_service_level i
left join ab_cikkto_full a
on i.CT1_SKU = a.CT1_SKU
set i.CT1_SKU_name = a.CT1_SKU_name
where i.CT1_SKU_name <> a.CT1_SKU_name
; 

*/


INSERT INTO inventory_service_level
SELECT 
	YEAR(i.processed) AS order_year, 
	MONTH(i.processed) AS order_month, 
	DAY(i.processed) AS order_day_in_month,
	i.item_SKU AS CT1_SKU,
    a.CT1_SKU_name,
    a.CT2_pack,
	a.CT3_product,
	a.CT4_product_brand,
	a.CT5_manufacturer,
	NULL AS supplier,
	a.product_group,
	a.lens_type,
	a.wear_duration,
	a.is_color,
	i.related_division,
	i.related_warehouse,
	ROUND(SUM(i.item_quantity),0) AS Ordered,
	ROUND(SUM(CASE WHEN i.quantity_booked >= i.quantity_billed THEN i.quantity_booked ELSE i.quantity_billed END),0) AS Reserved,
	ROUND(SUM(CASE WHEN i.quantity_booked >= i.quantity_billed THEN i.quantity_booked ELSE i.quantity_billed END)/SUM(i.item_quantity),2) AS service_level,
	COUNT(DISTINCT i.related_email) AS Users,
	COUNT(DISTINCT i.erp_id) AS Transactions,
	CASE 	WHEN i.related_warehouse = 'Teréz körút 41.' THEN z.`001_terez_korut_41`
			WHEN i.related_warehouse = 'Teréz körút 50.' THEN z.`010_terez_korut_50`
			WHEN i.related_warehouse = 'Cloud Fulfilment' THEN z.`015_cloud_fulfilment`
			WHEN i.related_warehouse = 'Pueblo Torrequebrada' THEN z.`017_pueblo_torrequebrada`
			WHEN i.related_warehouse = 'iOttica.it Magazzino Amalfi' THEN z.`020_iotticait_magazzino_amalfi`
	END as buffer_level
FROM incoming_orders i
LEFT JOIN ab_cikkto_full AS a
ON i.item_sku = a.CT1_SKU
LEFT JOIN (SELECT DATE(MAX(processed)) AS max_processed FROM incoming_orders) AS m
ON 1 = 1
LEFT JOIN zoho_inventory_min_stock z
ON i.item_sku = z.sku
WHERE i.deletion_comment NOT IN ('Automatikus törlés módosítás miatt', '5) Egyéb: 2x')
AND LOWER(i.deletion_comment) NOT LIKE '%dupl%'
AND LOWER(i.deletion_comment) NOT LIKE '%teszt%'
AND i.related_email NOT IN (SELECT DISTINCT related_email FROM IN_test_users)
AND i.billing_name NOT IN (SELECT DISTINCT billing_name FROM IN_test_users)
AND	i.item_SKU NOT IN ('GHW', 'MCO', 'MCONS', 'MDISPLAY', 'GROWWW', 'szallitas', 'Személyes átvétel')
AND i.item_group_name <> 'Szállítási díjak'
AND i.item_type = 'T'
AND DATE(i.processed) = m.max_processed
AND i.is_deleted = 'no'
AND i.item_quantity > 0
GROUP BY order_year, order_month, order_day_in_month, a.CT1_SKU, a.CT1_SKU_name
;