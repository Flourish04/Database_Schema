CREATE DATABASE TEST_BTL17;
USE TEST_BTL17;

CREATE TABLE Departments(
id INT PRIMARY KEY IDENTITY(1,1),
name NVARCHAR(50),
email VARCHAR(255),
phone_number CHAR(11),
location NVARCHAR(255),
image VARBINARY(MAX)
);

CREATE TABLE Employees(
id INT PRIMARY KEY IDENTITY(1,1),
last_name NVARCHAR(50),
first_name NVARCHAR(25),
birthday DATE,
gender CHAR(6) CHECK (gender in ('female','male')),
cccd CHAR(12) UNIQUE,
email VARCHAR(255),
start_date DATE,
location NVARCHAR(255),
position VARCHAR(25),
type CHAR(8) CHECK( type in ('Fulltime','Parttime')),
super_id INT, -- FOREIGN KEY
department_id INT, -- FOREIGN KEY
CONSTRAINT super_id_fk FOREIGN KEY(super_id) REFERENCES Employees(id),
CONSTRAINT department_id_fk FOREIGN KEY(department_id) REFERENCES Departments(id)
ON DELETE SET NULL
);

CREATE TABLE Parttime_employees(
id INT PRIMARY KEY,
hourly_pay INT CHECK(hourly_pay >=0) DEFAULT 24000,
working_hour INT CHECK(working_hour >=0) DEFAULT 0,
CONSTRAINT parttime_id_fk FOREIGN KEY(id) REFERENCES Employees(id)
ON DELETE CASCADE
);

CREATE TABLE Fulltime_employees(
id INT PRIMARY KEY,
salary INT CHECK(salary >=0) DEFAULT 6000000,
salary_coefficient INT DEFAULT 1,
CONSTRAINT fulltime_id_fk FOREIGN KEY(id) REFERENCES Employees(id)
ON DELETE CASCADE
);

CREATE TABLE Drivers(
id INT PRIMARY KEY,
license CHAR(12) UNIQUE,
CONSTRAINT driver_id_fk FOREIGN KEY(id) REFERENCES Employees(id)
ON DELETE CASCADE
);

CREATE TABLE Shifts(
id INT PRIMARY KEY IDENTITY(1,1),
date DATE,
start_time TIME,
end_time TIME	
);

CREATE TABLE Register_shifts(
employee_id INT NOT NULL, --FOREIGN KEY
shift_id INT NOT NULL, -- FOREIGN KEY
CONSTRAINT register_shift_pk PRIMARY KEY(employee_id,shift_id),
CONSTRAINT shift_emp_fk FOREIGN KEY(employee_id) REFERENCES Employees(id),
CONSTRAINT shift_fk FOREIGN KEY(shift_id) REFERENCES Shifts(id)
ON DELETE CASCADE
);

CREATE TABLE Tables(
id INT NOT NULL,
department_id INT NOT NULL,
chair_number INT,
note NVARCHAR(255),
state CHAR(6) CHECK (state in ('active','inactive')) DEFAULT 'active',
CONSTRAINT table_pk PRIMARY KEY(id,department_id),
CONSTRAINT dep_table_fk FOREIGN KEY(department_id) REFERENCES Departments(id)
ON DELETE CASCADE
);

CREATE TABLE Accounts(
id INT PRIMARY KEY IDENTITY(1,1),
username VARCHAR(255) UNIQUE NOT NULL,
password VARCHAR(255) NOT NULL,
display_name NVARCHAR(255) NOT NULL,
role CHAR(5) CHECK(role IN ('admin','user')) DEFAULT 'user',
point INT DEFAULT 0
);

CREATE TABLE Customers(
id INT PRIMARY KEY IDENTITY(1,1),
account_id INT NOT NULL, -- FOREIGN KEY
last_name NVARCHAR(50),
first_name NVARCHAR(25),
gender CHAR(6) CHECK (gender in ('female','male')),
locations NVARCHAR(255),
phone_number CHAR(10),
CONSTRAINT account_customer_fk FOREIGN KEY(account_id) REFERENCES Accounts(id)
ON DELETE CASCADE
);

CREATE TABLE Gifts(
id INT PRIMARY KEY IDENTITY(1,1),
name NVARCHAR(255),
quantity INT CHECK(quantity >= 0) DEFAULT 0,
point INT CHECK(point >= 0),
image VARBINARY(MAX)
);

CREATE TABLE Orders(
id INT IDENTITY(1,1) PRIMARY KEY,
start_time DATETIME,
end_time DATETIME,
total_cost INT DEFAULT 0,
total_quantity INT DEFAULT 0,
state CHAR(12) CHECK (state in ('in progress','finished')) DEFAULT 'in progress',
employee_id INT NOT NULL, -- FOREIGN KEY
type VARCHAR(7) CHECK(type in ('online','offline')) NOT NULL,
CONSTRAINT employeee_order_fk FOREIGN KEY(employee_id) REFERENCES Employees(id)
);

CREATE TABLE Online_orders(
id INT NOT NULL PRIMARY KEY, -- FOREIGN KEY
delivery_address NVARCHAR(255) NOT NULL,
delivery_charges INT NOT NULL DEFAULT 0,
account_id INT DEFAULT 0 -- FOREIGN KEY
CONSTRAINT account_order_fk FOREIGN KEY(account_id) REFERENCES Accounts(id)
ON DELETE SET DEFAULT,
CONSTRAINT online_id_fk FOREIGN KEY(id) REFERENCES Orders(id)
ON DELETE CASCADE
);

CREATE TABLE Offline_orders(
id INT NOT NULL PRIMARY KEY, -- FOREIGN KEY
table_id  INT, -- FOREIGN KEY,
department_id INT, -- FOREIGN KEY
customer_id INT DEFAULT 0, --FOREIGN KEY
request NVARCHAR(255),
CONSTRAINT offline_id_fk FOREIGN KEY(id) REFERENCES Orders(id)
ON DELETE CASCADE,
CONSTRAINT table_order_fk FOREIGN KEY(table_id,department_id) REFERENCES Tables(id,department_id),
CONSTRAINT off_customer_order_fk FOREIGN KEY(customer_id) REFERENCES Customers(id)
ON DELETE SET DEFAULT
);

CREATE TABLE Vouchers(
id INT PRIMARY KEY IDENTITY(1,1),
discount decimal(3,2) CHECK(discount <= 1 AND discount >= 0),
start_time DATETIME,
end_time DATETIME,
min_value INT,
max_discount INT,
type NVARCHAR (25),
quantity INT CHECK(quantity >= 0),
customer_id INT, -- FOREIGN KEY
state VARCHAR(15) CHECK(state in('in progress','finished')) default 'in progress',
CONSTRAINT customer_voucher_fk FOREIGN KEY(customer_id) REFERENCES Customers(id)
ON DELETE CASCADE
);

CREATE TABLE Redeem_vouchers(
order_id INT NOT NULL, -- FOREIGN KEY
voucher_id INT NOT NULL, -- FOREIGN KEY
CONSTRAINT redeem_voucher_pk PRIMARY KEY(order_id,voucher_id),
CONSTRAINT order_redeem_fk FOREIGN KEY(order_id) REFERENCES Orders(id),
CONSTRAINT voucher_redeem_fk FOREIGN KEY(voucher_id) REFERENCES Vouchers(id)
ON DELETE CASCADE
);

CREATE TABLE Products (
id INT PRIMARY KEY IDENTITY(1,1),
name NVARCHAR(255),
type NVARCHAR(50),
list_price INT CHECK(list_price >= 0),
discount DECIMAL(3,2) DEFAULT 0.00 CHECK (discount <= 1 and discount >= 0),
state CHAR(11) CHECK (state IN ('available','unavailable')) DEFAULT 'available',
image VARBINARY(MAX), 
rating decimal (3,2) CHECK(rating between 0 and 5)
);

CREATE TABLE Transportations(
license_plate CHAR(8) PRIMARY KEY,
type VARCHAR(25),
color VARCHAR(25)
);

CREATE TABLE Order_details(
order_id INT NOT NULL, -- FOREIGN KEY
product_id INT NOT NULL, -- FOREIGN KEY
quantity INT CHECK(quantity > 0),
cost INT DEFAULT 0, 
CONSTRAINT order_details_pk PRIMARY KEY(order_id,product_id),
CONSTRAINT order_details_fk FOREIGN KEY (order_id) REFERENCES Orders(id)
ON DELETE CASCADE,
CONSTRAINT product_order_fk FOREIGN KEY(product_id) REFERENCES Products(id)
);

CREATE TABLE Exchange_gifts(
account_id INT DEFAULT 0, -- FOREIGN KEY 
gift_id INT NOT NULL, -- FOREIGN KEY
exchange_time DATETIME NOT NULL,
quantity INT CHECK(quantity > 0),
CONSTRAINT exchange_gift_pk PRIMARY KEY(account_id,gift_id,exchange_time),
CONSTRAINT account_exchange_fk FOREIGN KEY(account_id) REFERENCES Accounts(id)
ON DELETE SET DEFAULT,
CONSTRAINT gift_exchange_fk FOREIGN KEY(gift_id) REFERENCES Gifts(id)
ON DELETE CASCADE
);

CREATE TABLE Reviews(
customer_id INT DEFAULT 0, -- FOREIGN KEY
product_id INT NOT NULL, -- FOREIGN KEY
comment NVARCHAR(255),
score INT CHECK (score between 0 and 5) DEFAULT 5,
CONSTRAINT review_pk PRIMARY KEY(customer_id,product_id),
CONSTRAINT customer_review_fk FOREIGN KEY(customer_id) REFERENCES Customers(id)
ON DELETE SET DEFAULT,
CONSTRAINT product_review_fk FOREIGN KEY(product_id) REFERENCES Products(id)
ON DELETE CASCADE,
);

CREATE TABLE Delivery(
driver_id INT NOT NULL, -- FOREIGN KEY
order_id INT NOT NULL PRIMARY KEY, -- FOREIGN KEY
license_plate CHAR(8) NOT NULL, -- FOREIGN KEY
delivery_time TIME,
CONSTRAINT driver_delivery_fk FOREIGN KEY(driver_id) REFERENCES Drivers(id),
CONSTRAINT order_delivery_fk FOREIGN KEY(order_id) REFERENCES Online_orders(id)
ON DELETE CASCADE,
CONSTRAINT license_delivery_fk FOREIGN KEY(license_plate) REFERENCES Transportations(license_plate)
ON UPDATE CASCADE
);

CREATE TABLE Employee_phones(
id INT NOT NULL, -- FOREIGN KEY
phone_number char(10),
CONSTRAINT employee_phone_pk PRIMARY KEY(id,phone_number),
CONSTRAINT employee_phone_fk FOREIGN KEY(id) REFERENCES Employees(id)
ON DELETE CASCADE
);
