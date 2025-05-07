-- Postgres Table Creation Script
--

--
-- Table structure for table departments
--

CREATE TABLE shifts(
	shift_id SERIAL NOT NULL PRIMARY KEY,
	shift_start_time TIME NOT NULL,
	shift_end_time TIME NOT NULL,
	CHECK (shift_end_time > shift_start_time)
);

--
-- Table structure for table departments
--

CREATE TABLE departments(
	department_id SERIAL NOT NULL PRIMARY KEY,
	department_name VARCHAR(50) NOT NULL,
	department_username VARCHAR(255) NOT NULL UNIQUE,
	department_password VARCHAR(255) NOT NULL CHECK (LENGTH(department_password) >= 6),
	department_location VARCHAR(255) NOT NULL,
	department_email VARCHAR(255) NOT NULL CHECK (department_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
	department_phone_number CHAR(12) NOT NULL CHECK (department_phone_number ~ '^\d{3}-\d{4}-\d{3}$'),
	department_role VARCHAR(20) NOT NULL CHECK (department_role IN ('admin','system')) DEFAULT 'system'
);

--
-- Table structure for table employees
--

CREATE TABLE employees(
	employee_id SERIAL NOT NULL PRIMARY KEY,
	employee_department_id INT NOT NULL,
	employee_first_name VARCHAR(50) NOT NULL,
	employee_last_name VARCHAR(50) NOT NULL,
	employee_position VARCHAR(25),
	employee_start_date DATE,
	employee_phone_number CHAR(12) NOT NULL CHECK (employee_phone_number ~ '^\d{3}-\d{4}-\d{3}$'),
	employee_salary INT CHECK (employee_salary > 0),
	CONSTRAINT employee_department_id_fk FOREIGN KEY (employee_department_id) REFERENCES departments (department_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

--
-- Table structure for table schedules
--

CREATE TABLE schedules(
	schedule_shift_id INT NOT NULL,
	schedule_employee_id INT NOT NULL,
	schedule_date DATE NOT NULL,
	CONSTRAINT schedule_shift_id_fk FOREIGN KEY (schedule_shift_id) REFERENCES shifts (shift_id)
		ON DELETE CASCADE,
	CONSTRAINT schedule_employee_id_fk FOREIGN KEY (schedule_employee_id) REFERENCES employees (employee_id)
		ON DELETE CASCADE,
	CONSTRAINT schedule_pk PRIMARY KEY (schedule_shift_id, schedule_employee_id, schedule_date)
);

--
-- Table structure for table tables 
--

CREATE TABLE tables(
	table_department_id INT NOT NULL,
	table_id INT NOT NULL,
	table_chair_quantity INT CHECK (table_chair_quantity >= 0),
	table_note VARCHAR(255),
	CONSTRAINT table_department_id_fk FOREIGN KEY (table_department_id) REFERENCES departments (department_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT table_pk PRIMARY KEY (table_id, table_department_id)
);

--
-- Table structure for table customers
--

CREATE TABLE customers(
	customer_id SERIAL NOT NULL PRIMARY KEY,
	customer_name VARCHAR(255) NOT NULL,
	customer_username VARCHAR(255) NOT NULL UNIQUE,
	customer_password VARCHAR(255) NOT NULL,
	customer_customer_since DATE DEFAULT CURRENT_DATE,
	customer_birthdate DATE,
	customer_gender CHAR(1) CHECK (customer_gender IN ('M','F')),
	customer_address VARCHAR(255),
	customer_phone_number CHAR(12) NOT NULL UNIQUE CHECK (customer_phone_number ~ '^\d{3}-\d{4}-\d{3}$'),
	customer_point INT CHECK (customer_point >= 0) DEFAULT 0
);

--
-- Table structure for table gifts
--

CREATE TABLE gifts(
	gift_id SERIAL NOT NULL PRIMARY KEY,
	gift_name VARCHAR(255) NOT NULL,
	gift_point INT NOT NULL CHECK (gift_point > 0),
	gift_state VARCHAR(15) CHECK (gift_state IN ('available', 'unavailable', 'deleted')) DEFAULT 'available',
	gift_image VARCHAR(255)
);

--
-- Table structure for table exchanged_gifts
--

CREATE TABLE exchanged_gifts(
	exchanged_gift_customer_id INT NOT NULL,
	exchanged_gift_gift_id INT NOT NULL,
	exchanged_gift_quantity INT NOT NULL CHECK (exchanged_gift_quantity > 0),
	exchanged_gift_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT exchanged_gift_customer_id_fk FOREIGN KEY (exchanged_gift_customer_id) REFERENCES customers (customer_id)
		ON DELETE CASCADE,
	CONSTRAINT exchanged_gift_gift_id_fk FOREIGN KEY (exchanged_gift_gift_id) REFERENCES gifts (gift_id)
		ON UPDATE CASCADE,
	CONSTRAINT exchanged_gift_pk PRIMARY KEY (exchanged_gift_customer_id, exchanged_gift_gift_id, exchanged_gift_date)
);

--
-- Table structure for table orders
--

CREATE TABLE orders(
	order_id SERIAL NOT NULL PRIMARY KEY,
	order_transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
	order_transaction_time TIME NOT NULL DEFAULT CURRENT_TIME,
	order_table_id INT,
	order_department_id INT NOT NULL,
	order_employee_id INT,
	order_customer_id INT,
	order_total_quantity INT CHECK (order_total_quantity >= 0),
	order_total_price DECIMAL(10,2) CHECK (order_total_price >= 0),
	CONSTRAINT order_table_fk FOREIGN KEY (order_table_id, order_department_id) REFERENCES tables (table_id, table_department_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	CONSTRAINT order_customer_id_fk FOREIGN KEY (order_customer_id) REFERENCES customers (customer_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	CONSTRAINT order_employee_id_fk FOREIGN KEY (order_employee_id) REFERENCES employees (employee_id)
		ON DELETE SET NULL
);

--
-- Table structure for table products
-- 

CREATE TABLE products(
	product_id SERIAL NOT NULL PRIMARY KEY,
	product_category VARCHAR(50) NOT NULL,
	product_type VARCHAR(50) NOT NULL,
	product_name VARCHAR(255) NOT NULL,
	product_description VARCHAR(255),
	product_rating DECIMAL(3,2) CHECK (product_rating BETWEEN 0 AND 10),
	product_unit_price DECIMAL(10,2) NOT NULL CHECK (product_unit_price > 0),
	product_image BYTEA,
	product_discount SMALLINT CHECK (product_discount BETWEEN 0 AND 100) DEFAULT 0,
	product_state VARCHAR(15) CHECK (product_state IN ('available', 'unavailable', 'deleted')) DEFAULT 'available'
);

--
-- Table structure for table order_items
--

CREATE TABLE order_items(
	order_item_order_id INT NOT NULL,
	order_item_product_id INT NOT NULL,
	order_item_price DECIMAL(10,2) NOT NULL,
	order_item_quantity INT NOT NULL,
	order_item_discount SMALLINT CHECK (order_item_discount BETWEEN 0 AND 100) DEFAULT 0,
	CONSTRAINT order_item_order_id_fk FOREIGN KEY (order_item_order_id) REFERENCES orders (order_id)
		ON DELETE CASCADE,
	CONSTRAINT order_item_product_id_fk FOREIGN KEY (order_item_product_id) REFERENCES products (product_id)
		ON UPDATE CASCADE,
	CONSTRAINT order_item_pk PRIMARY KEY (order_item_order_id, order_item_product_id)
);

--
-- Table structure for table reviews
--

CREATE TABLE reviews(
	review_product_id INT NOT NULL,
	review_customer_id INT NOT NULL,
	review_score DECIMAL(3,1) NOT NULL CHECK (review_score BETWEEN 0 AND 10) DEFAULT 10,
	review_comment VARCHAR(255),
	review_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT review_product_id_fk FOREIGN KEY (review_product_id) REFERENCES products (product_id)
		ON DELETE CASCADE, 
	CONSTRAINT review_customer_id_fk FOREIGN KEY (review_customer_id) REFERENCES customers (customer_id)
		ON DELETE CASCADE,
	CONSTRAINT review_pk PRIMARY KEY (review_product_id, review_customer_id, review_date)
);

-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;