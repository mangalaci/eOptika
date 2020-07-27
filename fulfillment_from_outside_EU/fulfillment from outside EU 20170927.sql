DROP TABLE IF EXISTS fulfillment_from_outside_EU_01;
CREATE TABLE IF NOT EXISTS fulfillment_from_outside_EU_01
SELECT DISTINCT 
		buyer_email, 
		repeat_buyer,
        user_type,
CASE WHEN (buyer_email LIKE '%@%alcon%.%' OR buyer_email LIKE '%@%coopervision%.%' OR buyer_email LIKE '%@%bausch%.%' OR buyer_email LIKE '%@%jnj%.%' OR buyer_email LIKE '%@%valeant%.%' OR buyer_email LIKE '%@mpx.hu')
	THEN 'disallowed'
	ELSE 
		CASE	WHEN user_type IN ('B2C', 'Private Insurance') AND repeat_buyer = 'repeat'
				THEN 'allowed'  		
                ELSE 'disallowed'
         END
END		 AS fulfillment_from_outside_EU,
CASE 
		WHEN user_type = 'B2B2C'				THEN 1
		WHEN user_type = 'B2B'					THEN 2
		WHEN user_type = 'Private insurance' 	THEN 3
		WHEN user_type = 'B2C' 					THEN 4
		ELSE user_type
END AS user_type_rank
FROM BASE_09_TABLE
WHERE buyer_email LIKE '%@%'
;

ALTER TABLE fulfillment_from_outside_EU_01 ADD PRIMARY KEY (buyer_email, user_type);




DROP TABLE IF EXISTS min_user_type_rank;
CREATE TABLE IF NOT EXISTS min_user_type_rank
SELECT 	buyer_email, 
		MIN(user_type_rank) AS min_user_type_rank

FROM fulfillment_from_outside_EU_01
GROUP BY buyer_email
;

ALTER TABLE min_user_type_rank ADD PRIMARY KEY (buyer_email, min_user_type_rank);


DROP TABLE IF EXISTS fulfillment_from_outside_EU;
CREATE TABLE IF NOT EXISTS fulfillment_from_outside_EU
SELECT a.buyer_email, a.fulfillment_from_outside_EU
FROM fulfillment_from_outside_EU_01 a, min_user_type_rank b
WHERE a.buyer_email = b.buyer_email
AND a.user_type_rank = b.min_user_type_rank
;

ALTER TABLE fulfillment_from_outside_EU ADD PRIMARY KEY (buyer_email);


_____________________________________________________
WHERE buyer_email LIKE '%@%jnj%.%'
WHERE buyer_email = 'zsszogi@gmail.com'



SELECT 	*
FROM fulfillment_from_outside_EU_01
WHERE buyer_email = 'reka.ka.lorincz@gmail.com'
;


SELECT buyer_email
FROM fulfillment_from_outside_EU
GROUP BY buyer_email
HAVING COUNT(buyer_email) > 1
;
