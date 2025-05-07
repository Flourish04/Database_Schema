--
-- Function to classify customers by spending
--

CREATE OR REPLACE FUNCTION classify_customers_by_spending()
RETURNS TABLE (
    customer_id INT,
    customer_name VARCHAR,
    customer_username VARCHAR,
    customer_birthdate DATE,
    customer_point INT,
    total_spending NUMERIC,
    spending_class TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_username,
        c.customer_birthdate,
        c.customer_point,
        COALESCE(SUM(o.order_total_price), 0) AS total_spending, -- Handle NULL spending
        CASE
            WHEN COALESCE(SUM(o.order_total_price), 0) < 500 THEN 'Bronze'
            WHEN COALESCE(SUM(o.order_total_price), 0) < 2000 THEN 'Silver'
            WHEN COALESCE(SUM(o.order_total_price), 0) < 5000 THEN 'Gold'
            ELSE 'Platinum'
        END AS spending_class
    FROM 
        customers c
    LEFT JOIN 
        orders o ON c.customer_id = o.order_customer_id -- Use LEFT JOIN to include customers with no orders
    GROUP BY 
        c.customer_id, c.customer_name, c.customer_username, c.customer_birthdate, c.customer_point
    ORDER BY 
        total_spending DESC;  -- Order by the highest total spending
END $$;

-- drop function classify_customers_by_spending;

SELECT * FROM classify_customers_by_spending() LIMIT 10;

-- Test

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
	c.customer_id,
	c.customer_name,
	c.customer_username,
	c.customer_birthdate,
	c.customer_point,
	COALESCE(SUM(o.order_total_price), 0) AS total_spending, -- Handle NULL spending
	CASE
		WHEN COALESCE(SUM(o.order_total_price), 0) < 500 THEN 'Bronze'
		WHEN COALESCE(SUM(o.order_total_price), 0) < 2000 THEN 'Silver'
		WHEN COALESCE(SUM(o.order_total_price), 0) < 5000 THEN 'Gold'
		ELSE 'Platinum'
	END AS spending_class
FROM 
	customers c
LEFT JOIN 
	orders o ON c.customer_id = o.order_customer_id -- Use LEFT JOIN to include customers with no orders
GROUP BY 
	c.customer_id, c.customer_name, c.customer_username, c.customer_birthdate, c.customer_point
ORDER BY 
	total_spending DESC;  -- Order by the highest total spending
