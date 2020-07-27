DROP FUNCTION IF EXISTS firstNumber;

DELIMITER //
CREATE FUNCTION firstNumber(s TEXT)
    RETURNS TEXT
    COMMENT 'Returns the first integer found in a string'
    DETERMINISTIC
    BEGIN

    DECLARE token TEXT DEFAULT '';
    DECLARE len INTEGER DEFAULT 0;
    DECLARE ind INTEGER DEFAULT 0;
    DECLARE thisChar CHAR(1) DEFAULT ' ';

    SET len = CHAR_LENGTH(s);
    SET ind = 1;
    WHILE ind <= len DO
        SET thisChar = SUBSTRING(s, ind, 1);
        IF (ORD(thisChar) >= 48 AND ORD(thisChar) <= 57) THEN
            SET token = CONCAT(token, thisChar);
        ELSEIF token <> '' THEN
            SET ind = len + 1;
        END IF;
        SET ind = ind + 1;
    END WHILE;

    IF token = '' THEN
        RETURN '';
    END IF;

    RETURN token;

    END //
DELIMITER ;

/*
https://stackoverflow.com/questions/9395178/how-to-find-the-first-number-in-a-text-field-using-a-mysql-query
*/


SELECT CASE WHEN length(firstnumber(foo)) > 3 THEN firstnumber(foo) ELSE '' END AS result
FROM `t` WHERE 1

/*	
https://stackoverflow.com/questions/12094232/return-numbers-from-the-middle-of-a-string-with-irregular-format/49632068#49632068	
*/
	
	

DROP FUNCTION IF EXISTS numerical_code_replace;

DELIMITER //

CREATE FUNCTION numerical_code_replace(orig_field VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN

    DECLARE clean_field VARCHAR(255);

		SET clean_field = CASE 	WHEN firstNumber(orig_field) > 999 
								THEN REPLACE(orig_field,firstNumber(orig_field),'')
								ELSE orig_field END;
	
 RETURN (clean_field);

END;
//
DELIMITER ;





DROP FUNCTION IF EXISTS CAP_FIRST;

DELIMITER //

CREATE FUNCTION CAP_FIRST (input VARCHAR(255))

RETURNS VARCHAR(255)

DETERMINISTIC

BEGIN
	DECLARE len INT;
	DECLARE i INT;

	SET len   = CHAR_LENGTH(input);
	SET input = LOWER(input);
	SET i = 0;

	WHILE (i < len) DO
		IF (MID(input,i,1) IN (' ') OR i = 0) THEN
			IF (i < len) THEN
				SET input = CONCAT(
					LEFT(input,i),
					UPPER(MID(input,i + 1,1)),
					RIGHT(input,len - i - 1)
				);
			END IF;
		END IF;
		SET i = i + 1;
	END WHILE;

	RETURN input;
END;
//
DELIMITER ;

/*
http://joezack.com/2008/10/20/mysql-capitalize-function/
*/





DROP FUNCTION IF EXISTS special_char_replace;

DELIMITER //

CREATE FUNCTION special_char_replace(text VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN

    DECLARE clean_text VARCHAR(255);
 
 SET clean_text = 
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(text,'á','a'),'é','e'),'í','i'),'ó','o'),'ő','o'),'ö','o'),'ú','u'),'ü','u'),'ű','u'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ő','O'),'Ö','O'),'Ú','U'),'Ü','U'),'Ű','U')
;
 RETURN (clean_text);

END;
//
DELIMITER ;




/*stored procedure for filling date gaps (weekends, holidays) in exchange rate time-series*/
DROP PROCEDURE IF EXISTS FillDateGap;

DELIMITER //

CREATE PROCEDURE FillDateGap()
BEGIN

DECLARE CurrDate date;
DECLARE VALUE decimal(6,2);
DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
SELECT DATEDIFF(max(DATE),min(DATE))+1 FROM exchange_rates_ext INTO n;
 
SET @CurrDate = (select min(Date) from exchange_rates_ext);
SET @VALUE = (select EUR from exchange_rates_ext where Date = @CurrDate);
SET i=0;

WHILE i<n DO 
  SET @CurrDate = ADDDATE(@CurrDate, INTERVAL 1 DAY);
  IF EXISTS (SELECT Date FROM exchange_rates_ext WHERE Date = @CurrDate) THEN
	SET @VALUE = (select EUR from exchange_rates_ext where Date = @CurrDate);
    SET i = i + 1;
  ELSE
    INSERT INTO exchange_rates_ext (Date, EUR) VALUES (@CurrDate, @VALUE);
    SET i = i + 1;
  END IF;
END WHILE;

END;
//
DELIMITER ;


/*stored procedure for typical product*/
DROP PROCEDURE IF EXISTS TypicalProduct;

DELIMITER //
CREATE PROCEDURE TypicalProduct(table_name VARCHAR(64), which_eye VARCHAR(32), group_by VARCHAR(32), product_group VARCHAR(32))
BEGIN
  SET @SQL := CONCAT('DROP TABLE IF EXISTS ', table_name);
  PREPARE stmt FROM @SQL;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  
  SET @SQL := CONCAT('CREATE TABLE ',table_name,' SELECT 	a.user_id,
		CASE 	WHEN b.typical_lens_last_360_days IS NULL THEN COALESCE(a.typical_lens_all_time,b.typical_lens_last_360_days)
				ELSE b.typical_lens_last_360_days
				END AS ',table_name,'
FROM
(
SELECT 	user_id, ',group_by,' AS typical_lens_all_time
FROM
(
SELECT 	user_id, ',group_by,', COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = ''invoices''
AND product_group  = ',product_group,'
AND CASE WHEN product_group = ''Contact lenses'' THEN lens_pwr = ',which_eye,' ELSE 1=1 END
GROUP BY user_id, ',group_by,'	
ORDER BY COUNT(*) DESC
) z
GROUP BY user_id
) a
LEFT JOIN
(
SELECT 	user_id, ',group_by,' AS typical_lens_last_360_days
FROM
(
SELECT 	user_id, ',group_by,', COUNT(*) AS num_of_purchase
FROM BASE_03_TABLE	
WHERE origin = ''invoices''
AND product_group  = ',product_group,'
AND created BETWEEN DATE_SUB(contact_lens_last_purchase, INTERVAL 360 DAY) AND contact_lens_last_purchase
AND CASE WHEN product_group = ''Contact lenses'' THEN lens_pwr = ',which_eye,' ELSE 1=1 END
GROUP BY user_id, ',group_by,'	
ORDER BY 3 DESC
) z
GROUP BY user_id
) b
ON a.user_id = b.user_id');
  PREPARE stmt FROM @SQL;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
    
END;
//
DELIMITER ;

