--
-- Shifts
--

CREATE INDEX shifts_time_idx ON shifts (shift_start_time, shift_end_time);

--
-- Departments
--

CREATE INDEX departments_role_idx ON departments (department_role, department_name);

--
-- Employees
--

CREATE INDEX employees_department_position_idx ON employees (employee_department_id, employee_position);

CREATE INDEX employees_department_name_idx ON employees (employee_department_id, employee_first_name, employee_last_name);


--
-- Schedules
--

CREATE INDEX schedules_date_idx ON schedules (schedule_date);

--
-- Tables
--

CREATE INDEX tables_chair_quantity_idx ON tables (table_chair_quantity);

--
-- Customers
--

CREATE INDEX customers_point_idx ON customers (customer_point);

CREATE INDEX customers_birthdate_idx ON customers (customer_birthdate);

--
-- Gifts
--

CREATE INDEX gifts_point_state_idx ON gifts (gift_point, gift_state) INCLUDE (gift_name);

--
-- Exchanged_gifts
--

CREATE INDEX exchanged_gifts_date_idx ON exchanged_gifts (exchanged_gift_date) INCLUDE (exchanged_gift_quantity);

--
-- Orders
--

CREATE INDEX orders_date_time_idx ON orders (order_transaction_date, order_transaction_time) INCLUDE (order_total_price);

CREATE INDEX orders_date_department_idx ON orders (order_transaction_date, order_department_id) INCLUDE (order_total_price);

CREATE INDEX orders_department_table_idx ON orders (order_department_id, order_table_id);

CREATE INDEX orders_employee_idx ON orders (order_employee_id);

--
-- Products
--

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX products_name_trgm_idx ON products USING gin (product_name gin_trgm_ops);

CREATE INDEX products_category_name_idx ON products (product_category,product_name);

CREATE INDEX products_rating_idx ON products (product_rating);

CREATE INDEX products_state_idx ON products (product_state);

--
-- Order_items
--

CREATE INDEX order_items_price_quantity_idx ON order_items (order_item_price, order_item_quantity);

CREATE INDEX order_items_order_price_idx ON order_items (order_item_order_id) INCLUDE (order_item_price);

--
-- Reviews
--

CREATE INDEX reviews_date_idx ON reviews (review_date);

CREATE INDEX review_score_idx ON reviews (review_score);