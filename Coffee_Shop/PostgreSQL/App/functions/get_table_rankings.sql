--
-- Function to rank tables based on usage_count
--

CREATE OR REPLACE FUNCTION get_table_rankings(
    start_date DATE,
    end_date DATE,
    input_department_id INT
)
RETURNS TABLE (
    department_id INT,
    department_name VARCHAR,
    table_id INT,
    chair_quantity INT,
    usage_count BIGINT,
    table_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.department_id,
        d.department_name,
        o.order_table_id,
        t.table_chair_quantity, 
        COUNT(o.order_id) AS usage_count,
        RANK() OVER (
            PARTITION BY d.department_id 
            ORDER BY COUNT(o.order_id) DESC
        ) AS table_rank
    FROM 
        orders o
    JOIN 
        departments d ON o.order_department_id = d.department_id
    JOIN 
        tables t ON o.order_table_id = t.table_id AND o.order_department_id = t.table_department_id
    WHERE 
        o.order_transaction_date BETWEEN start_date AND end_date
        AND o.order_department_id = input_department_id
        AND o.order_table_id IS NOT NULL  -- Exclude NULL table_id values
    GROUP BY 
        d.department_id, d.department_name, o.order_table_id, t.table_chair_quantity
    ORDER BY 
        table_rank;
END $$;


SELECT * FROM get_table_rankings('2023-01-01', '2023-06-30', 1);

-- Test

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
	d.department_id,
	d.department_name,
	o.order_table_id,
	t.table_chair_quantity, -- Include chair quantity
	COUNT(o.order_id) AS usage_count,
	RANK() OVER (
		PARTITION BY d.department_id 
		ORDER BY COUNT(o.order_id) DESC
	) AS table_rank
FROM 
	orders o
JOIN 
	departments d ON o.order_department_id = d.department_id
JOIN 
	tables t ON o.order_table_id = t.table_id AND o.order_department_id = t.table_department_id
WHERE 
	o.order_transaction_date BETWEEN '2023-01-01' AND '2023-06-01'
	AND o.order_department_id = 1
	AND o.order_table_id IS NOT NULL  -- Exclude NULL table_id values
GROUP BY 
	d.department_id, d.department_name, o.order_table_id, t.table_chair_quantity
ORDER BY 
	table_rank;