
/*Hungary*/
DROP TABLE IF EXISTS KLAVIYO_USER_HU;
CREATE TABLE IF NOT EXISTS KLAVIYO_USER_HU
SELECT
		DATE_FORMAT(CURRENT_TIMESTAMP) AS `Timestamp`,
		primary_email AS `Person//Email`,
		first_name AS `Person//First Name`,
		last_name AS `Person//Last Name`,
		MAX(last_modified_date) AS `Person//last_purchase`,
		one_before_last_purchase AS `Person//one_before_last_purchase`,
		related_division AS `Person//related_division`,
		secondary_email AS `Person//secondary_email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		personal_name AS `Person//personal_name`,
		personal_address AS `Person//personal_address`,
		personal_zip_code AS `Person//personal_zip_code`,
		personal_city AS `Person//personal_city`,
		pickup_name AS `Person//pickup_name`,
		pickup_address AS `Person//pickup_address`,
		pickup_zip_code AS `Person//pickup_zip_code`,
		pickup_city AS `Person//pickup_city`,
		business_name AS `Person//Organization`,
		business_address AS `Person//business_address`,
		business_zip_code AS `Person//business_zip_code`,
		business_city AS `Person//business_city`,
		shipping_phone	AS `Person//Phone`,
		related_webshop AS `Person//related_webshop`,
		user_type AS `Person//user_type`,
		gender AS `Person//gender`,
		salutation AS `Person//salutation`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Person//gross_margin_wdisc_in_base_currency`,
		cohort_id AS `Person//cohort_id`,
		cohort_month_since AS `Person//cohort_month_since`,		
		user_cum_transactions AS `Person//user_cum_transactions`,
		user_cum_gross_revenue_in_base_currency AS `Person//user_cum_gross_revenue_in_base_currency`,
		repeat_buyer AS `Person//Repeat_buyer`,
		contact_lens_user AS `Person//contact_lens_user`,
		solution_user AS `Person//solution_user`,
		eye_drops_user AS `Person//eye_drops_user`,
		sunglass_user AS `Person//sunglass_user`,
		vitamin_user AS `Person//vitamin_user`,
		frames_user AS `Person//frames_user`,
		spectacles_user AS `Person//glass_lenses_user`,
		other_product_user AS `Person//other_product_user`,
		first_year_contact_lens_projected_boxes AS `Person//first_year_contact_lens_projected_boxes`,
		first_year_contact_lens_overuse_ratio AS `Person//first_year_contact_lens_overuse_ratio`,
		multi_user_account AS `Person//multi_user_account`,
		pwr_eye1 AS `Person//pwr_eye1`,
		pwr_eye2 AS `Person//pwr_eye2`,
		typical_lens_eye1_CT2 AS `Person//typical_lens_eye1_CT2`,
		typical_lens_eye2_CT2 AS `Person//typical_lens_eye2_CT2`,
		typical_solution_CT2 AS `Person//typical_solution_CT2`,
		typical_eye_drop_CT2 AS `Person//typical_eye_drop_CT2`,
		date_lenses_run_out AS `Person//Date_lenses_run_out`,
		contact_lens_last_purchase AS `Person//contact_lens_last_purchase`
FROM AGGR_USER_UNSANITIZED
WHERE primary_email NOT LIKE '%eoptikafiktiv%'
AND primary_email LIKE '%@%.%'
AND related_division = 'Optika - HU'
GROUP BY user_id
;


ALTER TABLE KLAVIYO_USER_HU ADD PRIMARY KEY (`Person//Email`) USING BTREE;







/*SERBIA*/
DROP TABLE IF EXISTS KLAVIYO_USER_RS;
CREATE TABLE IF NOT EXISTS KLAVIYO_USER_RS
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		primary_email AS `Person//Email`,
		first_name AS `Person//First Name`,
		last_name AS `Person//Last Name`,
		MAX(last_modified_date) AS `Person//last_purchase`,
		one_before_last_purchase AS `Person//one_before_last_purchase`,
		related_division AS `Person//related_division`,
		secondary_email AS `Person//secondary_email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		personal_name AS `Person//personal_name`,
		personal_address AS `Person//personal_address`,
		personal_zip_code AS `Person//personal_zip_code`,
		personal_city AS `Person//personal_city`,
		pickup_name AS `Person//pickup_name`,
		pickup_address AS `Person//pickup_address`,
		pickup_zip_code AS `Person//pickup_zip_code`,
		pickup_city AS `Person//pickup_city`,
		business_name AS `Person//Organization`,
		business_address AS `Person//business_address`,
		business_zip_code AS `Person//business_zip_code`,
		business_city AS `Person//business_city`,
		shipping_phone	AS `Person//Phone`,
		related_webshop AS `Person//related_webshop`,
		user_type AS `Person//user_type`,
		gender AS `Person//gender`,
		salutation AS `Person//salutation`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Person//gross_margin_wdisc_in_base_currency`,
		cohort_id AS `Person//cohort_id`,
		cohort_month_since AS `Person//cohort_month_since`,		
		user_cum_transactions AS `Person//user_cum_transactions`,
		user_cum_gross_revenue_in_base_currency AS `Person//user_cum_gross_revenue_in_base_currency`,
		repeat_buyer AS `Person//Repeat_buyer`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Person//contact_lens_user`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Person//solution_user`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Person//eye_drops_user`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Person//sunglass_user`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Person//vitamin_user`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Person//frames_user`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Person//glass_lenses_user`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Person//other_product_user`,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS `Person//first_year_contact_lens_projected_boxes`,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS `Person//first_year_contact_lens_overuse_ratio`,
		multi_user_account AS `Person//multi_user_account`,
		pwr_eye1 AS `Person//pwr_eye1`,
		pwr_eye2 AS `Person//pwr_eye2`,
		typical_lens_1 AS `Person//typical_lens_1`,
		typical_lens_2 AS `Person//typical_lens_2`,
		typical_solution AS `Person//typical_solution`,
		typical_eye_drop AS `Person//typical_eye_drop`,
		date_lenses_run_out AS `Person//Date_lenses_run_out`,
		contact_lens_last_purchase AS `Person//contact_lens_last_purchase`
FROM BASE_08_TABLE
WHERE origin = 'invoices'
AND primary_email NOT LIKE '%eoptikafiktiv%'
AND primary_email LIKE '%@%.%'
AND related_division = 'Optika - RS'
GROUP BY user_id
ORDER BY created
;


ALTER TABLE KLAVIYO_USER_RS ADD PRIMARY KEY (`Person//Email`) USING BTREE;


/*ITALY*/
DROP TABLE IF EXISTS KLAVIYO_USER_IT;
CREATE TABLE IF NOT EXISTS KLAVIYO_USER_IT
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		primary_email AS `Person//Email`,
		first_name AS `Person//First Name`,
		last_name AS `Person//Last Name`,
		MAX(last_modified_date) AS `Person//last_purchase`,
		one_before_last_purchase AS `Person//one_before_last_purchase`,
		related_division AS `Person//related_division`,
		secondary_email AS `Person//secondary_email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		personal_name AS `Person//personal_name`,
		personal_address AS `Person//personal_address`,
		personal_zip_code AS `Person//personal_zip_code`,
		personal_city AS `Person//personal_city`,
		pickup_name AS `Person//pickup_name`,
		pickup_address AS `Person//pickup_address`,
		pickup_zip_code AS `Person//pickup_zip_code`,
		pickup_city AS `Person//pickup_city`,
		business_name AS `Person//Organization`,
		business_address AS `Person//business_address`,
		business_zip_code AS `Person//business_zip_code`,
		business_city AS `Person//business_city`,
		shipping_phone	AS `Person//Phone`,
		related_webshop AS `Person//related_webshop`,
		user_type AS `Person//user_type`,
		gender AS `Person//gender`,
		salutation AS `Person//salutation`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Person//gross_margin_wdisc_in_base_currency`,
		cohort_id AS `Person//cohort_id`,
		cohort_month_since AS `Person//cohort_month_since`,		
		user_cum_transactions AS `Person//user_cum_transactions`,
		user_cum_gross_revenue_in_base_currency AS `Person//user_cum_gross_revenue_in_base_currency`,
		repeat_buyer AS `Person//Repeat_buyer`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Person//contact_lens_user`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Person//solution_user`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Person//eye_drops_user`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Person//sunglass_user`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Person//vitamin_user`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Person//frames_user`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Person//glass_lenses_user`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Person//other_product_user`,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS `Person//first_year_contact_lens_projected_boxes`,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS `Person//first_year_contact_lens_overuse_ratio`,
		multi_user_account AS `Person//multi_user_account`,
		pwr_eye1 AS `Person//pwr_eye1`,
		pwr_eye2 AS `Person//pwr_eye2`,
		typical_lens_1 AS `Person//typical_lens_1`,
		typical_lens_2 AS `Person//typical_lens_2`,
		typical_solution AS `Person//typical_solution`,
		typical_eye_drop AS `Person//typical_eye_drop`,
		date_lenses_run_out AS `Person//Date_lenses_run_out`,
		contact_lens_last_purchase AS `Person//contact_lens_last_purchase`
FROM BASE_08_TABLE
WHERE origin = 'invoices'
AND primary_email NOT LIKE '%eoptikafiktiv%'
AND primary_email LIKE '%@%.%'
AND related_division = 'Optika - IT'
GROUP BY user_id
ORDER BY created
;


ALTER TABLE KLAVIYO_USER_IT ADD PRIMARY KEY (`Person//Email`) USING BTREE;



/*UK*/
DROP TABLE IF EXISTS KLAVIYO_USER_UK;
CREATE TABLE IF NOT EXISTS KLAVIYO_USER_UK
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		primary_email AS `Person//Email`,
		first_name AS `Person//First Name`,
		last_name AS `Person//Last Name`,
		MAX(last_modified_date) AS `Person//last_purchase`,
		one_before_last_purchase AS `Person//one_before_last_purchase`,
		related_division AS `Person//related_division`,
		secondary_email AS `Person//secondary_email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		personal_name AS `Person//personal_name`,
		personal_address AS `Person//personal_address`,
		personal_zip_code AS `Person//personal_zip_code`,
		personal_city AS `Person//personal_city`,
		pickup_name AS `Person//pickup_name`,
		pickup_address AS `Person//pickup_address`,
		pickup_zip_code AS `Person//pickup_zip_code`,
		pickup_city AS `Person//pickup_city`,
		business_name AS `Person//Organization`,
		business_address AS `Person//business_address`,
		business_zip_code AS `Person//business_zip_code`,
		business_city AS `Person//business_city`,
		shipping_phone	AS `Person//Phone`,
		related_webshop AS `Person//related_webshop`,
		user_type AS `Person//user_type`,
		gender AS `Person//gender`,
		salutation AS `Person//salutation`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Person//gross_margin_wdisc_in_base_currency`,
		cohort_id AS `Person//cohort_id`,
		cohort_month_since AS `Person//cohort_month_since`,		
		user_cum_transactions AS `Person//user_cum_transactions`,
		user_cum_gross_revenue_in_base_currency AS `Person//user_cum_gross_revenue_in_base_currency`,
		repeat_buyer AS `Person//Repeat_buyer`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Person//contact_lens_user`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Person//solution_user`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Person//eye_drops_user`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Person//sunglass_user`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Person//vitamin_user`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Person//frames_user`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Person//glass_lenses_user`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Person//other_product_user`,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS `Person//first_year_contact_lens_projected_boxes`,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS `Person//first_year_contact_lens_overuse_ratio`,
		multi_user_account AS `Person//multi_user_account`,
		pwr_eye1 AS `Person//pwr_eye1`,
		pwr_eye2 AS `Person//pwr_eye2`,
		typical_lens_1 AS `Person//typical_lens_1`,
		typical_lens_2 AS `Person//typical_lens_2`,
		typical_solution AS `Person//typical_solution`,
		typical_eye_drop AS `Person//typical_eye_drop`,
		date_lenses_run_out AS `Person//Date_lenses_run_out`,
		contact_lens_last_purchase AS `Person//contact_lens_last_purchase`
FROM BASE_08_TABLE
WHERE origin = 'invoices'
AND primary_email NOT LIKE '%eoptikafiktiv%'
AND primary_email LIKE '%@%.%'
AND related_division = 'Optika - UK'
GROUP BY user_id
ORDER BY created
;


ALTER TABLE KLAVIYO_USER_UK ADD PRIMARY KEY (`Person//Email`) USING BTREE;



/*Croatia*/
DROP TABLE IF EXISTS KLAVIYO_USER_HR;
CREATE TABLE IF NOT EXISTS KLAVIYO_USER_HR
SELECT
		CURRENT_TIMESTAMP AS `Timestamp`,
		primary_email AS `Person//Email`,
		first_name AS `Person//First Name`,
		last_name AS `Person//Last Name`,
		MAX(last_modified_date) AS `Person//last_purchase`,
		one_before_last_purchase AS `Person//one_before_last_purchase`,
		related_division AS `Person//related_division`,
		secondary_email AS `Person//secondary_email`,
		billing_country_standardized AS `Person//billing_country_standardized`,
		shipping_country_standardized AS `Person//shipping_country_standardized`,
		personal_name AS `Person//personal_name`,
		personal_address AS `Person//personal_address`,
		personal_zip_code AS `Person//personal_zip_code`,
		personal_city AS `Person//personal_city`,
		pickup_name AS `Person//pickup_name`,
		pickup_address AS `Person//pickup_address`,
		pickup_zip_code AS `Person//pickup_zip_code`,
		pickup_city AS `Person//pickup_city`,
		business_name AS `Person//Organization`,
		business_address AS `Person//business_address`,
		business_zip_code AS `Person//business_zip_code`,
		business_city AS `Person//business_city`,
		shipping_phone	AS `Person//Phone`,
		related_webshop AS `Person//related_webshop`,
		user_type AS `Person//user_type`,
		gender AS `Person//gender`,
		salutation AS `Person//salutation`,
		ROUND(SUM(gross_margin_wdisc_in_base_currency),0) AS `Person//gross_margin_wdisc_in_base_currency`,
		cohort_id AS `Person//cohort_id`,
		cohort_month_since AS `Person//cohort_month_since`,		
		user_cum_transactions AS `Person//user_cum_transactions`,
		user_cum_gross_revenue_in_base_currency AS `Person//user_cum_gross_revenue_in_base_currency`,
		repeat_buyer AS `Person//Repeat_buyer`,
		MAX(CASE WHEN product_group  = 'Contact lenses' THEN 1 ELSE 0 END) AS `Person//contact_lens_user`,
		MAX(CASE WHEN product_group  = 'Contact lens cleaners' THEN 1 ELSE 0 END) AS `Person//solution_user`,
		MAX(CASE WHEN product_group  = 'Eye drops' THEN 1 ELSE 0 END) AS `Person//eye_drops_user`,
		MAX(CASE WHEN product_group  = 'Sunglasses' THEN 1 ELSE 0 END) AS `Person//sunglass_user`,
		MAX(CASE WHEN product_group  = 'Vitamins' THEN 1 ELSE 0 END) AS `Person//vitamin_user`,
		MAX(CASE WHEN product_group  = 'Frames' THEN 1 ELSE 0 END) AS `Person//frames_user`,
		MAX(CASE WHEN product_group  = 'Glass lenses' THEN 1 ELSE 0 END) AS `Person//glass_lenses_user`,
		MAX(CASE WHEN product_group  = 'Others' THEN 1 ELSE 0 END) AS `Person//other_product_user`,
		ROUND(2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)), 2) AS `Person//first_year_contact_lens_projected_boxes`,
		ROUND(((SUM(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group = 'Contact lenses' THEN item_quantity ELSE 0 END ELSE 0 END)) / (2 * (360 / AVG(CASE WHEN DATEDIFF(created, STR_TO_DATE(CONCAT(LEFT(cohort_id, 4), '-', RIGHT(cohort_id, 2), '-01'), '%Y-%m-%d'))  < 360 THEN CASE WHEN product_group  = 'Contact lenses' THEN wear_days END END)))), 2) AS `Person//first_year_contact_lens_overuse_ratio`,
		multi_user_account AS `Person//multi_user_account`,
		pwr_eye1 AS `Person//pwr_eye1`,
		pwr_eye2 AS `Person//pwr_eye2`,
		typical_lens_1 AS `Person//typical_lens_1`,
		typical_lens_2 AS `Person//typical_lens_2`,
		typical_solution AS `Person//typical_solution`,
		typical_eye_drop AS `Person//typical_eye_drop`,
		date_lenses_run_out AS `Person//Date_lenses_run_out`,
		contact_lens_last_purchase AS `Person//contact_lens_last_purchase`
FROM BASE_08_TABLE
WHERE origin = 'invoices'
AND primary_email NOT LIKE '%eoptikafiktiv%'
AND primary_email LIKE '%@%.%'
AND related_division = 'Optika - HR'
GROUP BY user_id
ORDER BY created
;


ALTER TABLE KLAVIYO_USER_HR ADD PRIMARY KEY (`Person//Email`) USING BTREE;


