DROP TABLE IF EXISTS trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE IF NOT EXISTS trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_07_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
LIMIT 0;

ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;

INSERT INTO trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_07_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id;
DROP TABLE IF EXISTS BASE_08_TABLE;
CREATE TABLE IF NOT EXISTS BASE_08_TABLE LIKE BASE_07_TABLE;
ALTER TABLE `BASE_08_TABLE` ADD `trx_rank` INT(10) NOT NULL DEFAULT 0;

INSERT INTO BASE_08_TABLE
SELECT DISTINCT b.*, e.trx_rank
FROM BASE_07_TABLE AS b LEFT JOIN 
trx_numbering AS e
ON (e.erp_invoice_id = b.erp_invoice_id AND e.user_id = b.user_id);
UPDATE BASE_08_TABLE SET buyer_email = NULL WHERE buyer_email is not NULL;
UPDATE BASE_08_TABLE SET billing_name = NULL WHERE billing_name is not NULL;
UPDATE BASE_08_TABLE SET billing_address = NULL WHERE billing_address is not NULL;
UPDATE BASE_08_TABLE SET shipping_name = NULL WHERE shipping_name is not NULL;
UPDATE BASE_08_TABLE SET shipping_address = NULL WHERE shipping_address is not NULL;
UPDATE BASE_08_TABLE SET shipping_phone = NULL WHERE shipping_phone is not NULL;
UPDATE BASE_08_TABLE SET shipping_name_clean = NULL WHERE shipping_name_clean is not NULL;
UPDATE BASE_08_TABLE SET related_email_clean = NULL WHERE related_email_clean is not NULL;