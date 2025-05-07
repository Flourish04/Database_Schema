--
-- Calculate total revenue of a department / all departments by time
--

CREATE OR REPLACE FUNCTION calculate_total_revenue(
    start_date DATE,                  -- Start date for the range
    end_date DATE,                    -- End date for the range
    input_department_id INT DEFAULT NULL  -- Optional department filter; NULL means calculate for all departments
)
RETURNS TABLE (
    order_department_id INT,
    department_name VARCHAR,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Return the total revenue with department names for the specified department or all departments
    RETURN QUERY
    SELECT 
        o.order_department_id,
        d.department_name,                               
        ROUND(SUM(o.order_total_price)::NUMERIC, 2) AS total_revenue  -- Calculate total revenue
    FROM 
        orders o
    JOIN 
        departments d ON o.order_department_id = d.department_id  -- Join to get department names
    WHERE 
        o.order_transaction_date BETWEEN start_date AND end_date  
        AND (o.order_department_id = input_department_id OR input_department_id IS NULL)  -- Filter by department or include all
    GROUP BY 
        o.order_department_id, d.department_name       
    ORDER BY 
        total_revenue DESC;                    
END $$;


-- drop function calculate_total_revenue;

SELECT * FROM calculate_total_revenue('2023-01-01', '2023-01-31', 1);
SELECT * FROM calculate_total_revenue('2023-01-01', '2023-01-31', 2);
SELECT * FROM calculate_total_revenue('2023-01-01', '2023-01-31', 3);
SELECT * FROM calculate_total_revenue('2023-01-01', '2023-01-31', NULL);

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
	o.order_department_id,
	d.department_name,                          
	ROUND(SUM(o.order_total_price)::NUMERIC, 2) AS total_revenue  -- Calculate total revenue
FROM 
	orders o
JOIN 
	departments d ON o.order_department_id = d.department_id  -- Join to get department names
WHERE 
	o.order_transaction_date BETWEEN '2023-01-01' AND '2023-03-01'  
	AND (o.order_department_id = 1 OR 1 IS NULL)  -- Filter by department or include all
GROUP BY 
	o.order_department_id, d.department_name        
ORDER BY 
	total_revenue DESC;                            