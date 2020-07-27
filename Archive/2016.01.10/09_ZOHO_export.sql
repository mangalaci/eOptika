DROP TABLE trx_numbering;

SET @prev := null;
SET @cnt := 1;

CREATE TABLE trx_numbering
SELECT t.user_id, t.erp_invoice_id, IF(@prev <> t.user_id, @cnt := 1, @cnt := @cnt + 1) AS trx_rank, @prev := t.user_id
FROM (SELECT DISTINCT user_id, erp_invoice_id FROM BASE_08_TABLE ORDER BY user_id, erp_invoice_id ) as t
ORDER BY t.user_id
;

ALTER TABLE trx_numbering ADD INDEX `user_id` (`user_id`) USING BTREE;
ALTER TABLE trx_numbering ADD INDEX `erp_invoice_id` (`erp_invoice_id`) USING BTREE;


DROP TABLE BASE_09_TABLE
;
CREATE TABLE BASE_09_TABLE
SELECT DISTINCT b.*, 
				e.trx_rank
FROM BASE_08_TABLE AS b LEFT JOIN 
trx_numbering AS e
ON (e.erp_invoice_id = b.erp_invoice_id AND e.user_id = b.user_id)
;

DROP TABLE BASE_10_TABLE
;
CREATE TABLE BASE_10_TABLE
SELECT *,
    CASE WHEN MAX(trx_rank) > 1 THEN 'repeat' ELSE '1-time' END num_of_purch
FROM BASE_09_TABLE
GROUP BY user_id
;


UPDATE BASE_10_TABLE
SET buyer_email = NULL
WHERE buyer_email is not NULL
;


UPDATE BASE_10_TABLE
SET billing_name = NULL
WHERE billing_name is not NULL
;

UPDATE BASE_10_TABLE
SET billing_address = NULL
WHERE billing_address is not NULL
;

UPDATE BASE_10_TABLE
SET shipping_name = NULL
WHERE shipping_name is not NULL
;

UPDATE BASE_10_TABLE
SET shipping_address = NULL
WHERE shipping_address is not NULL
;

UPDATE BASE_10_TABLE
SET shipping_phone = NULL
WHERE shipping_phone is not NULL
;

UPDATE BASE_10_TABLE
SET shipping_name_clean = NULL
WHERE shipping_name_clean is not NULL
;

UPDATE BASE_10_TABLE
SET related_email_clean = NULL
WHERE related_email_clean is not NULL
;