--
-- Display order bill
--

CREATE OR REPLACE FUNCTION display_order_bill(o_id INT)
RETURNS TABLE (
    department_name VARCHAR,
    department_location VARCHAR,
	table_id INT,
    order_id INT,
    order_transaction_date DATE,
    order_transaction_time TIME,
    order_employee_id INT,
    product_name VARCHAR,
    order_item_quantity INT,
    product_discount TEXT, -- Discount displayed as a percentage
    order_item_price NUMERIC, -- Price of the item in the order
    order_total_price NUMERIC -- Total price of the entire order
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.department_name,
        d.department_location,
		o.order_table_id,
        o.order_id,
        o.order_transaction_date,
        o.order_transaction_time,
        o.order_employee_id,
        p.product_name,
        oi.order_item_quantity,
        CONCAT(oi.order_item_discount, '%') AS product_discount, -- Format discount as percentage
        oi.order_item_price::NUMERIC, -- Price of the item in the order
        o.order_total_price::NUMERIC -- Total price of the entire order
    FROM 
        orders o
    JOIN 
        departments d ON o.order_department_id = d.department_id    
    JOIN 
        order_items oi ON o.order_id = oi.order_item_order_id        
    JOIN 
        products p ON oi.order_item_product_id = p.product_id      
    WHERE 
        o.order_id = o_id; -- Filter by the specific order ID
END $$;

-- drop function display_order_bill;

select * from display_order_bill(1985990);

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
	d.department_name,
	d.department_location,
	o.order_id,
	o.order_transaction_date,
	o.order_transaction_time,
	o.order_employee_id,
	p.product_name,
	oi.order_item_quantity,
	CONCAT(p.product_discount, '%') AS product_discount,  -- Format discount as percentage
	oi.order_item_price::NUMERIC,                         -- Price of the item in the order
	o.order_total_price::NUMERIC                          -- Total price of the entire order
FROM 
	orders o
JOIN 
	departments d ON o.order_department_id = d.department_id    
JOIN 
	order_items oi ON o.order_id = oi.order_item_order_id        
JOIN 
	products p ON oi.order_item_product_id = p.product_id      
WHERE 
	o.order_id = 1;   -- Filter by the specific order ID
