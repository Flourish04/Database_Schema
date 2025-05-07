-- DIMENSION TABLE INDEXING

-- dim_department
CREATE INDEX idx_department_name ON dim_department(name);
select * from fact_orders;

-- dim_employee
CREATE INDEX idx_employee_department ON dim_employee(departmentID);
CREATE INDEX idx_employee_name ON dim_employee(name);
CREATE INDEX idx_employee_position ON dim_employee(position);

-- dim_customers
CREATE INDEX idx_customers_phone ON dim_customers(phone_number);
CREATE INDEX idx_customers_dob ON dim_customers(dob);
CREATE INDEX idx_customers_point ON dim_customers(point);

-- dim_gift
CREATE INDEX idx_gift_state ON dim_gift(state);
CREATE INDEX idx_gift_point ON dim_gift(state);

-- dim_product
CREATE INDEX idx_product_category ON dim_product(category);
CREATE INDEX idx_product_state ON dim_product(state);
CREATE INDEX idx_product_name ON dim_product(name);

-- dim_date
CREATE INDEX idx_dim_date_year_month ON dim_date (year, month);
CREATE INDEX idx_dim_date_year_quarter ON dim_date (year, quarter);

-- FACT TABLE INDEXING

-- fact_gift_exchange
CREATE INDEX idx_gift_exchange_customer ON fact_gift_exchange(customerID);
CREATE INDEX idx_gift_exchange_date ON fact_gift_exchange(dateID);

-- fact_orders
CREATE INDEX idx_orders_customer ON fact_orders(customerID);
CREATE INDEX idx_orders_employee ON fact_orders(employeeID);
CREATE INDEX idx_orders_date ON fact_orders(dateID);
CREATE INDEX idx_orders_time ON fact_orders(transactionTime);

-- fact_order_details
CREATE INDEX idx_order_details_product ON fact_order_details(productID);

-- fact_review
CREATE INDEX idx_review_customer ON fact_review(customerID);
CREATE INDEX idx_review_date ON fact_review(dateID);
