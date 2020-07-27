DROP TABLE IF EXISTS item_qty_by_CT2_pack;
CREATE TABLE IF NOT EXISTS item_qty_by_CT2_pack
SELECT
		order_erp_id,
		order_created,
		purchase_created,
		CT2_pack,
		SUM(order_item_qty) AS order_item_qty_by_purchase_dt
FROM BASE_TABLE_PRODUCT_SUPPLY
WHERE order_erp_id IS NOT NULL /* meg nem rendelt tételek kiszűrve */
AND purchase_erp_id <> '' /* be nem vételezett tételek kiszűrve */
GROUP BY order_erp_id, purchase_created, CT2_pack
ORDER BY order_erp_id, purchase_created, CT2_pack
;

ALTER TABLE item_qty_by_CT2_pack ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE item_qty_by_CT2_pack ADD INDEX (`order_erp_id`) USING BTREE;
ALTER TABLE item_qty_by_CT2_pack ADD INDEX (`purchase_created`) USING BTREE;
ALTER TABLE item_qty_by_CT2_pack ADD INDEX (`CT2_pack`) USING BTREE;
ALTER TABLE item_qty_by_CT2_pack ADD INDEX (`order_item_qty_by_purchase_dt`) USING BTREE;

/*running total*/
DROP TABLE IF EXISTS cum_item_qty_by_CT2_pack;
CREATE TABLE IF NOT EXISTS cum_item_qty_by_CT2_pack
SELECT 	c1.order_erp_id,
		c1.order_created,
		c1.purchase_created,
		c1.CT2_pack,
		c1.order_item_qty_by_purchase_dt,
		SUM(c2.order_item_qty_by_purchase_dt) AS cum_order_item_qty_by_purchase_dt
FROM item_qty_by_CT2_pack c1,  item_qty_by_CT2_pack c2
WHERE c1.purchase_created >= c2.purchase_created
AND c1.CT2_pack = c2.CT2_pack
AND c1.order_erp_id = c2.order_erp_id
GROUP BY c1.order_erp_id, c1.order_created, c1.purchase_created, c1.order_item_qty_by_purchase_dt, c1.CT2_pack
ORDER BY c1.purchase_created ASC
;


ALTER TABLE cum_item_qty_by_CT2_pack ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE cum_item_qty_by_CT2_pack ADD INDEX (`order_erp_id`) USING BTREE;
ALTER TABLE cum_item_qty_by_CT2_pack ADD INDEX (`purchase_created`) USING BTREE;
ALTER TABLE cum_item_qty_by_CT2_pack ADD INDEX (`CT2_pack`) USING BTREE;
ALTER TABLE cum_item_qty_by_CT2_pack ADD INDEX (`order_item_qty_by_purchase_dt`) USING BTREE;


DROP TABLE IF EXISTS sum_item_qty_by_CT2_pack;
CREATE TABLE IF NOT EXISTS sum_item_qty_by_CT2_pack
SELECT 	order_erp_id,
		CT2_pack,
        SUM(order_item_qty) AS sum_order_item_qty
FROM BASE_TABLE_PRODUCT_SUPPLY
WHERE order_erp_id IS NOT NULL /* meg nem rendelt tételek kiszűrve */
AND purchase_erp_id <> '' /* be nem vételezett tételek kiszűrve */
GROUP BY order_erp_id, CT2_pack
;


ALTER TABLE sum_item_qty_by_CT2_pack ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`);
ALTER TABLE sum_item_qty_by_CT2_pack ADD INDEX (`order_erp_id`) USING BTREE;
ALTER TABLE sum_item_qty_by_CT2_pack ADD INDEX (`CT2_pack`) USING BTREE;


DROP TABLE IF EXISTS SLT_by_fulfillment_perc_CT2_pack;
CREATE TABLE IF NOT EXISTS SLT_by_fulfillment_perc_CT2_pack
SELECT 
		t.CT2_pack,
		SUM(t.fifty_perc_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_fifty_perc_in_days,
		SUM(t.eighty_perc_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_eighty_perc_in_days,
		SUM(t.ninety_perc_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_ninety_perc_in_days,
		SUM(t.ninety_five_perc_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_ninety_five_perc_in_days,
		SUM(t.ninety_nine_perc_nine_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_ninety_nine_perc_nine_in_days,
		SUM(t.hundred_perc_days*t.sum_order_item_qty)/SUM(t.sum_order_item_qty) AS avg_hundred_perc_in_days
FROM
(
SELECT 	
		p.order_erp_id,
		p.CT2_pack,
		s.sum_order_item_qty,
        MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 0.5 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS fifty_perc_days,
		MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 0.8 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS eighty_perc_days,
		MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 0.9 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS ninety_perc_days,
		MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 0.95 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS ninety_five_perc_days,
		MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 0.99 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS ninety_nine_perc_nine_days,
		MIN(CASE WHEN p.cum_order_item_qty_by_purchase_dt/s.sum_order_item_qty >= 1 THEN DATEDIFF(p.purchase_created, p.order_created) ELSE NULL END) AS hundred_perc_days
FROM cum_item_qty_by_CT2_pack p
LEFT JOIN sum_item_qty_by_CT2_pack s
ON (p.order_erp_id = s.order_erp_id AND p.CT2_pack = s.CT2_pack)
GROUP BY p.order_erp_id, p.CT2_pack
) t
GROUP BY t.CT2_pack
;

