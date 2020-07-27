/* a megtalált városneveket update-eljük az alaptáblában */


DROP PROCEDURE IF EXISTS CityUpdate;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS CityUpdate(table_name VARCHAR(64), address_type VARCHAR(32))
BEGIN

  IF address_type = 'shipping' THEN

	SET @SQL := CONCAT('UPDATE INVOICES_00 AS m
LEFT JOIN ',table_name,' AS e
ON (m.shipping_city = e.shipping_city AND m.shipping_zip_code = e.shipping_zip_code)
SET
    m.shipping_city_standardized = e.shipping_city_standardized
WHERE e.shipping_city_standardized IS NOT NULL');


  ELSEIF address_type = 'billing' THEN

    SET @SQL := CONCAT('UPDATE INVOICES_00 AS m
LEFT JOIN ',table_name,' AS e
ON (m.billing_city = e.billing_city AND m.billing_zip_code = e.billing_zip_code)
SET
    m.billing_city_standardized = e.billing_city_standardized
WHERE e.billing_city_standardized IS NOT NULL');
  
  END IF;

  PREPARE stmt FROM @SQL;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  
END
//
DELIMITER ;





DROP FUNCTION IF EXISTS jaro_winkler_similarity;

DELIMITER //
CREATE  FUNCTION `jaro_winkler_similarity`(
in1 varchar(255),
in2 varchar(255)
) RETURNS float
DETERMINISTIC
BEGIN
#finestra:= search window, curString:= scanning cursor for the original string, curSub:= scanning cursor for the compared string
declare finestra, curString, curSub, maxSub, trasposizioni, prefixlen, maxPrefix int;
declare char1, char2 char(1);
declare common1, common2, old1, old2 varchar(255);
declare trovato boolean;
declare returnValue, jaro float;
set maxPrefix=6; #from the original jaro - winkler algorithm
set common1="";
set common2="";
set finestra=(length(in1)+length(in2)-abs(length(in1)-length(in2))) DIV 4
+ ((length(in1)+length(in2)-abs(length(in1)-length(in2)))/2) mod 2;
set old1=in1;
set old2=in2;

#calculating common letters vectors
set curString=1;
while curString<=length(in1) and (curString<=(length(in2)+finestra)) do
set curSub=curstring-finestra;
if (curSub)<1 then
set curSub=1;
end if;
set maxSub=curstring+finestra;
if (maxSub)>length(in2) then
set maxSub=length(in2);
end if;
set trovato = false;
while curSub<=maxSub and trovato=false do
if substr(in1,curString,1)=substr(in2,curSub,1) then
set common1 = concat(common1,substr(in1,curString,1));
set in2 = concat(substr(in2,1,curSub-1),concat("0",substr(in2,curSub+1,length(in2)-curSub+1)));
set trovato=true;
end if;
set curSub=curSub+1;
end while;
set curString=curString+1;
end while;
#back to the original string
set in2=old2;
set curString=1;
while curString<=length(in2) and (curString<=(length(in1)+finestra)) do
set curSub=curstring-finestra;
if (curSub)<1 then
set curSub=1;
end if;
set maxSub=curstring+finestra;
if (maxSub)>length(in1) then
set maxSub=length(in1);
end if;
set trovato = false;
while curSub<=maxSub and trovato=false do
if substr(in2,curString,1)=substr(in1,curSub,1) then
set common2 = concat(common2,substr(in2,curString,1));
set in1 = concat(substr(in1,1,curSub-1),concat("0",substr(in1,curSub+1,length(in1)-curSub+1)));
set trovato=true;
end if;
set curSub=curSub+1;
end while;
set curString=curString+1;
end while;
#back to the original string
set in1=old1;

#calculating jaro metric
if length(common1)<>length(common2)
then set jaro=0;
elseif length(common1)=0 or length(common2)=0
then set jaro=0;
else
#calcolo la distanza di winkler
#passo 1: calcolo le trasposizioni
set trasposizioni=0;
set curString=1;
while curString<=length(common1) do
if(substr(common1,curString,1)<>substr(common2,curString,1)) then
set trasposizioni=trasposizioni+1;
end if;
set curString=curString+1;
end while;
set jaro=
(
length(common1)/length(in1)+
length(common2)/length(in2)+
(length(common1)-trasposizioni/2)/length(common1)
)/3;

end if; #end if for jaro metric

#calculating common prefix for winkler metric
set prefixlen=0;
while (substring(in1,prefixlen+1,1)=substring(in2,prefixlen+1,1)) and (prefixlen<6) do
set prefixlen= prefixlen+1;
end while;


#calculate jaro-winkler metric
return jaro+(prefixlen*0.1*(1-jaro));
END;
 //
DELIMITER ;



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

		SET clean_field = CASE 	WHEN firstNumber(orig_field) > 2000 
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




DROP PROCEDURE IF EXISTS run_all_time;

DELIMITER //

CREATE PROCEDURE run_all_time()
BEGIN

    IF DAYOFWEEK(CURRENT_DATE) = 4 
		THEN SELECT 1 FROM DUAL; 
		ELSE SELECT 0 FROM DUAL;
	END IF;
 

END;
//
DELIMITER ;




DROP PROCEDURE IF EXISTS szoras;

DELIMITER $$
 
CREATE PROCEDURE szoras(IN n INT, IN p VARCHAR(200), IN w VARCHAR(200), OUT szum FLOAT)
BEGIN
 
 DECLARE v_finished INTEGER DEFAULT 0;
		DECLARE v_item FLOAT DEFAULT 0;
 
 -- declare cursor for items
 DEClARE item_cursor CURSOR FOR 
 SELECT
	ROUND(SUM(t.item_quantity)/n,2) AS avg_items_sold_n_days
 FROM (SELECT *, STR_TO_DATE(CONCAT(order_year, '-',LPAD(order_month,2,'0'), '-', order_day_in_month),'%Y-%m-%d') AS order_date FROM BASE_03_TABLE) t
 WHERE (t.origin = 'invoices' OR (t.origin = 'orders' AND t.is_canceled = 'no'))
 AND t.item_quantity > 0
 AND DATEDIFF(CURDATE(), t.order_date) <= n
 AND CT1_sku = p
 AND related_warehouse = w
 GROUP BY
		t.related_warehouse,
		t.CT1_sku
;


 -- declare NOT FOUND handler
 DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET v_finished = 1;
 
 OPEN item_cursor;
 
 get_item: LOOP
 
 FETCH item_cursor INTO v_item;
 
 IF v_finished = 1 THEN 
 LEAVE get_item;
 END IF;
 
 -- build item list
 SET szum = szum+(1000-v_item);
 
 END LOOP get_item;
 
 CLOSE item_cursor;
 
END;
$$
 
DELIMITER ;


CALL szoras(30, 'AOA386-0250', 'Teréz körút 41.', @szum);

SELECT @szum;
