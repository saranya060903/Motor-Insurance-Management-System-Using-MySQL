create database policy;
use policy;

CREATE TABLE make_list(
    make_id INT PRIMARY KEY,
    make_desc VARCHAR(50) NOT NULL,
    make_status VARCHAR(20) NOT NULL,
    make_added_on DATE,
    make_added_by VARCHAR(50)
);

CREATE TABLE model_list(
    model_id INT PRIMARY KEY,
    model_desc VARCHAR(200) NOT NULL,
    make_id INT,
    model_status VARCHAR(20),
    added_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    added_by VARCHAR(50),
    CONSTRAINT fk_model_make FOREIGN KEY(make_id) REFERENCES make_list(make_id)
);

CREATE TABLE motor_city(
    city_id INT PRIMARY KEY,
    city_name VARCHAR(30) UNIQUE,
    state_name VARCHAR(50)
);

CREATE TABLE motor_bodytype(
    body_id INT PRIMARY KEY,
    body_desc VARCHAR(100),
    body_status VARCHAR(50),
    added_on DATE,
    added_by VARCHAR(30) NOT NULL
);

CREATE TABLE category_type(
    cat_id INT PRIMARY KEY,
    cat_desc VARCHAR(30),
    cat_description VARCHAR(100),
    added_on DATE,
    added_by VARCHAR(100)
);

CREATE TABLE motor_color(
    color_id INT PRIMARY KEY,
    color_name VARCHAR(20) UNIQUE,
    model_id INT,
    added_on INT,
    added_by VARCHAR(40) NOT NULL,
    CONSTRAINT fk_color_model FOREIGN KEY(model_id) REFERENCES model_list(model_id)
);

CREATE TABLE motor_configuration (
    config_id INT PRIMARY KEY,
    make_id INT NOT NULL,
    model_id INT NOT NULL,
    cat_id INT NOT NULL,
    body_id INT,
    color_id INT,
    city_name VARCHAR(30),
    price DECIMAL(10,2),
    available_stock INT DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_on DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_make FOREIGN KEY (make_id) REFERENCES make_list(make_id),
    CONSTRAINT fk_model FOREIGN KEY (model_id) REFERENCES model_list(model_id),
    CONSTRAINT fk_cat FOREIGN KEY (cat_id) REFERENCES category_type(cat_id),
    CONSTRAINT fk_body FOREIGN KEY (body_id) REFERENCES motor_bodytype(body_id),
    CONSTRAINT fk_color FOREIGN KEY (color_id) REFERENCES motor_color(color_id),
    CONSTRAINT fk_city FOREIGN KEY (city_name) REFERENCES motor_city(city_name)
);

CREATE TABLE personal_information(
    user_id INT PRIMARY KEY,
    user_type VARCHAR(50),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    gender VARCHAR(10),
    dob DATE NOT NULL,
    email VARCHAR(100) NOT NULL,
    marital_status INT,
    education VARCHAR(30),
    phone BIGINT NOT NULL,
    address_1 VARCHAR(300),
    permanent_address VARCHAR(300),
    city_name VARCHAR(30),
    status_update VARCHAR(30),
    added_on DATE,
    added_by VARCHAR(40),
    FOREIGN KEY (city_name) REFERENCES motor_city(city_name)
);

CREATE TABLE login_user(
    login_id INT PRIMARY KEY,
    login_password VARCHAR(20),
    user_id INT,
    user_type VARCHAR(30),
    status_update VARCHAR(20),
    added_on DATE,
    added_by VARCHAR(50),
    FOREIGN KEY(user_id) REFERENCES personal_information(user_id)
);

CREATE TABLE broker_information(
    broker_id INT PRIMARY KEY,
    broker_name VARCHAR(30),
    broker_organisation_name VARCHAR(100),
    contact_info VARCHAR(200),
    status_update VARCHAR(50),
    added_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    added_by VARCHAR(30)
);

CREATE TABLE coverage_master(
    coverage_id INT PRIMARY KEY,
    coverage_type VARCHAR(100),
    coverage_desc VARCHAR(200)
);

CREATE TABLE quote_information(
    quote_id INT PRIMARY KEY,
    user_id INT,
    coverage_id INT,
    quote_date DATETIME,
    status_update VARCHAR(20),
    FOREIGN KEY(user_id) REFERENCES personal_information(user_id),
    FOREIGN KEY(coverage_id) REFERENCES coverage_master(coverage_id)
);

CREATE TABLE premium_rate_calculation (
    rate_id INT PRIMARY KEY,
    coverage_id INT,
    premium_rate DECIMAL(10,2),
    effective_from DATE,
    FOREIGN KEY (coverage_id) REFERENCES coverage_master(coverage_id)
);

CREATE TABLE premium (
    premium_id INT PRIMARY KEY,
    quote_id INT,
    rate_id INT,
    premium_amount DECIMAL(10,2),
    calc_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quote_id) REFERENCES quote_information(quote_id),
    FOREIGN KEY (rate_id) REFERENCES premium_rate_calculation(rate_id)
);

CREATE TABLE broker_commission (
    commission_id INT PRIMARY KEY,
    coverage_id INT,
    commission_percent DECIMAL(5,2),
    FOREIGN KEY (coverage_id) REFERENCES coverage_master(coverage_id)
);

CREATE TABLE agent_application (
    app_id INT PRIMARY KEY,
    user_id INT,
    quote_id INT,
    submitted_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES personal_information(user_id),
    FOREIGN KEY (quote_id) REFERENCES quote_information(quote_id)
);

CREATE TABLE policy_master (
    policy_id INT PRIMARY KEY,
    app_id INT,
    policy_start DATE,
    policy_end DATE,
    debit_credit_note VARCHAR(50),
    FOREIGN KEY (app_id) REFERENCES agent_application(app_id)
);

CREATE TABLE payment_details (
    payment_id INT PRIMARY KEY,
    policy_id INT,
    payment_mode VARCHAR(20),
    amount DECIMAL(10,2),
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (policy_id) REFERENCES policy_master(policy_id)
);

CREATE TABLE debit_credit_note (
    note_id INT PRIMARY KEY,
    policy_id INT NOT NULL,
    note_type VARCHAR(10) CHECK(note_type IN ('Debit','Credit')),
    note_amount DECIMAL(10,2) NOT NULL,
    issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(policy_id) REFERENCES policy_master(policy_id) ON DELETE CASCADE ON UPDATE CASCADE
);