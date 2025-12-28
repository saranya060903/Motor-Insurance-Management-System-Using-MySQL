select*from make_list;

select*from motor_city;

select*from motor_bodytype;

select*from category_type;
rollback;


select*from motor_color;

select*from personal_information;

select*from login_user;

select*from broker_information;

select*from coverage_master;

select*from quote_information;

select*from premium;

select*from debit_credit_note;

select
mc.make_desc, 
    mdl.model_desc, 
    COUNT(mot.config_id) AS total_configurations,
    AVG(mot.price) AS avg_price,
    (SELECT AVG(p.premium_amount) 
     FROM premium p 
     WHERE p.quote_id IN 
         (SELECT q.quote_id FROM quote_information q 
          WHERE q.user_id = 1)
    ) AS avg_user_premium
FROM motor_configuration mot
JOIN make_list mc ON mot.make_id = mc.make_id
JOIN model_list mdl ON mot.model_id = mdl.model_id
JOIN motor_color clr ON mot.color_id = clr.color_id
WHERE mot.price > (0.5 * (SELECT MAX(price) FROM motor_configuration WHERE cat_id = mot.cat_id))
GROUP BY mc.make_desc, mdl.model_desc
HAVING AVG(mot.price) > 500000
ORDER BY avg_price DESC
LIMIT 10 OFFSET 3;

SELECT 
    make_id, make_desc, make_added_on AS ADDED_ON
FROM
    make_list;


SELECT 
    config_id, city_name, price, price + 20000
FROM
    motor_configuration
WHERE
    City_name NOT IN ('chennai','ERODE');
    
    SELECT 
    COVERAGE_ID, PREMIUM_RATE
FROM
    PREMIUM_RATE_CALCULATION
WHERE
    PREMIUM_RATE NOT between 5500 AND 8000 ;

SELECT FIRST_NAME, EDUCATION, CITY_NAME, USER_ID, GENDER
FROM PERSONAL_INFORMATION
WHERE FIRST_NAME LIKE 'S%'
  order by FIRST_NAME ASC
  limit 5
  offset 3;
  
SELECT PERSONAL_INFORMATION
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'POLICY';


  CREATE TABLE INFORMATION AS 
  select*FROM PERSONAL_INFORMATION;
  
  select*FROM INFORMATION;
  
  SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'POLICY';

SELECT 
    *
FROM
    PREMIUM_RATE_CALCULATION;

SELECT 
    AVG(PREMIUM_RATE), MAX(PREMIUM_RATE)
FROM
    PREMIUM_RATE_CALCULATION;
  
   
  select*FROM MOTOR_CONFIGURATION;
  
 SELECT 
    CITY_NAME,
    AVG(PRICE) AS AVG_PRICE
FROM MOTOR_CONFIGURATION
GROUP BY CITY_NAME
HAVING MAX(CAT_ID) = 3;

SELECT 
    mc.make_desc AS make,
    ml.model_desc AS model,
    clr.color_name AS color,
    mb.body_desc AS body_type,
    cfg.city_name,
    cfg.price,
    cfg.available_stock
FROM motor_configuration cfg
JOIN make_list mc ON cfg.make_id = mc.make_id
JOIN model_list ml ON cfg.model_id = ml.model_id
JOIN motor_color clr ON cfg.color_id = clr.color_id
JOIN motor_bodytype mb ON cfg.body_id = mb.body_id
ORDER BY cfg.price DESC;

SELECT 
    user_id,
    first_name,
    email,
    city_name
FROM personal_information
WHERE user_id IN (
    SELECT user_id
    FROM quote_information
    WHERE coverage_id = (
        SELECT coverage_id
        FROM coverage_master
        WHERE coverage_type = 'Vehicle'
    )
);

DELIMITER $$

CREATE PROCEDURE get_customers_by_city(IN p_city VARCHAR(30))
BEGIN
    SELECT 
        user_id,
        CONCAT(first_name,' ',last_name) AS customer_name,
        email,
        phone,
        city_name
    FROM personal_information
    WHERE city_name = p_city;
END $$

DELIMITER ;

CALL get_customers_by_city('chennai');

DELIMITER $$

CREATE FUNCTION calculate_age(p_dob DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
END $$

DELIMITER ;

SELECT user_id, calculate_age(dob) AS age, CITY_NAME
FROM personal_information;

DELIMITER //

CREATE TRIGGER trg_quote_default_status
BEFORE INSERT ON quote_information
FOR EACH ROW
BEGIN
    IF NEW.status_update IS NULL THEN
        SET NEW.status_update = 'Pending';
    END IF;
END //

DELIMITER ;

DELIMITER $$

CREATE TABLE premium_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    premium_id INT,
    quote_id INT,
    old_premium_amount DECIMAL(10,2),
    old_calc_date DATE,
    updated_on DATETIME
);


DELIMITER $$

CREATE TRIGGER trg_premium_backup_before_update
BEFORE UPDATE ON premium
FOR EACH ROW
BEGIN
    INSERT INTO premium_history
    (
        premium_id,
        quote_id,
        old_premium_amount,
        old_calc_date,
        updated_on
    )
    VALUES
    (
        OLD.premium_id,
        OLD.quote_id,
        OLD.premium_amount,
        OLD.calc_date,
        NOW()
    );
END $$

DELIMITER ;

UPDATE premium
SET premium_amount = 5500
WHERE premium_id = 1;

SELECT * FROM premium_history;

CREATE VIEW vw_customer_details AS
SELECT 
    user_id,
    CONCAT(first_name,' ',last_name) AS customer_name,
    email,
    city_name
FROM personal_information;

SELECT * FROM vw_customer_details;

SELECT *
FROM personal_information
WHERE city_name = 'Chennai';

EXPLAIN
SELECT *
FROM personal_information
WHERE city_name = 'Chennai';

CREATE VIEW vw_customer_premium_summary AS
SELECT DISTINCT
    p.user_id AS customer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS customer_name,
    c.coverage_type AS coverage,
    COUNT(q.quote_id) AS total_quotes,
    SUM(pr.premium_amount) AS total_premium
FROM personal_information p
JOIN quote_information q ON p.user_id = q.user_id
JOIN coverage_master c ON q.coverage_id = c.coverage_id
JOIN premium pr ON q.quote_id = pr.quote_id
WHERE
    p.city_name LIKE 'C%'
    AND p.email IS NOT NULL
    AND pr.premium_amount BETWEEN 1000 AND 10000
    AND q.coverage_id IN (
        SELECT coverage_id
        FROM coverage_master
        WHERE coverage_type LIKE '%Vehicle%'
    )
GROUP BY
    p.user_id, p.first_name, p.last_name, c.coverage_type
HAVING
    COUNT(q.quote_id) >= 1;
    
    SELECT * FROM vw_customer_premium_summary;




