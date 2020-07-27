DROP TABLE BASE_09_TABLE
;

CREATE TABLE BASE_09_TABLE
SELECT * FROM BASE_08_TABLE
;

UPDATE BASE_09_TABLE
SET buyer_email = NULL
WHERE buyer_email is not NULL
;


UPDATE BASE_09_TABLE
SET billing_name = NULL
WHERE billing_name is not NULL
;

UPDATE BASE_09_TABLE
SET billing_address = NULL
WHERE billing_address is not NULL
;

UPDATE BASE_09_TABLE
SET shipping_name = NULL
WHERE shipping_name is not NULL
;

UPDATE BASE_09_TABLE
SET shipping_address = NULL
WHERE shipping_address is not NULL
;

UPDATE BASE_09_TABLE
SET shipping_phone = NULL
WHERE shipping_phone is not NULL
;

UPDATE BASE_09_TABLE
SET shipping_name_clean = NULL
WHERE shipping_name_clean is not NULL
;

UPDATE BASE_09_TABLE
SET related_email_clean = NULL
WHERE related_email_clean is not NULL
;