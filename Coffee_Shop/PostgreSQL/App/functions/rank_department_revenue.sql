--
-- Function to rank total revenue of a department / all departments by time (day, week, month, year)
--

CREATE OR REPLACE FUNCTION rank_department_revenue(
    start_date DATE,                -- Start of the date range
    end_date DATE,                  -- End of the date range
    time_format TEXT DEFAULT 'day' -- Time granularity ('day', 'week', 'month', 'year')
)
RETURNS TABLE (
    period DATE,
    order_department_id INT,
    department_name VARCHAR,
    total_revenue NUMERIC,
    revenue_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Dynamically build and return the query based on the time_format
    IF time_format = 'day' THEN
        RETURN QUERY
            WITH DepartmentRevenue AS (
                SELECT 
                    DATE_TRUNC('day', o.order_transaction_date)::DATE AS period,  -- Truncate to day
                    o.order_department_id,
                    d.department_name,                                         
                    ROUND(SUM(o.order_total_price)::NUMERIC,2) AS total_revenue
                FROM 
                    orders o
                JOIN 
                    departments d ON o.order_department_id = d.department_id  -- Join to get department name
                WHERE 
                    o.order_transaction_date BETWEEN start_date AND end_date
                GROUP BY 
                    DATE_TRUNC('day', o.order_transaction_date), o.order_department_id, d.department_name
            )
            SELECT 
                dr.period,
                dr.order_department_id,
                dr.department_name,
                dr.total_revenue,
                RANK() OVER (PARTITION BY dr.period ORDER BY dr.total_revenue DESC) AS revenue_rank
            FROM 
                DepartmentRevenue dr
            ORDER BY 
                dr.period, revenue_rank;

    ELSIF time_format = 'week' THEN
        RETURN QUERY
            WITH DepartmentRevenue AS (
                SELECT 
                    DATE_TRUNC('week', o.order_transaction_date)::DATE AS period,  -- Truncate to week
                    o.order_department_id,
                    d.department_name,                                         
                    ROUND(SUM(o.order_total_price)::NUMERIC,2) AS total_revenue
                FROM 
                    orders o
                JOIN 
                    departments d ON o.order_department_id = d.department_id  -- Join to get department name
                WHERE 
                    o.order_transaction_date BETWEEN start_date AND end_date
                GROUP BY 
                    DATE_TRUNC('week', o.order_transaction_date), o.order_department_id, d.department_name
            )
            SELECT 
                dr.period,
                dr.order_department_id,
                dr.department_name,
                dr.total_revenue,
                RANK() OVER (PARTITION BY dr.period ORDER BY dr.total_revenue DESC) AS revenue_rank
            FROM 
                DepartmentRevenue dr
            ORDER BY 
                dr.period, revenue_rank;

    ELSIF time_format = 'month' THEN
        RETURN QUERY
            WITH DepartmentRevenue AS (
                SELECT 
                    DATE_TRUNC('month', o.order_transaction_date)::DATE AS period,  -- Truncate to month
                    o.order_department_id,
                    d.department_name,                                         
                    ROUND(SUM(o.order_total_price)::NUMERIC,2) AS total_revenue
                FROM 
                    orders o
                JOIN 
                    departments d ON o.order_department_id = d.department_id  -- Join to get department name
                WHERE 
                    o.order_transaction_date BETWEEN start_date AND end_date
                GROUP BY 
                    DATE_TRUNC('month', o.order_transaction_date), o.order_department_id, d.department_name
            )
            SELECT 
                dr.period,
                dr.order_department_id,
                dr.department_name,
                dr.total_revenue,
                RANK() OVER (PARTITION BY dr.period ORDER BY dr.total_revenue DESC) AS revenue_rank
            FROM 
                DepartmentRevenue dr
            ORDER BY 
                dr.period, revenue_rank;

    ELSIF time_format = 'year' THEN
        RETURN QUERY
            WITH DepartmentRevenue AS (
                SELECT 
                    DATE_TRUNC('year', o.order_transaction_date)::DATE AS period,  -- Truncate to year
                    o.order_department_id,
                    d.department_name,                                        
                    ROUND(SUM(o.order_total_price)::NUMERIC,2) AS total_revenue
                FROM 
                    orders o
                JOIN 
                    departments d ON o.order_department_id = d.department_id  -- Join to get department name
                WHERE 
                    o.order_transaction_date BETWEEN start_date AND end_date
                GROUP BY 
                    DATE_TRUNC('year', o.order_transaction_date), o.order_department_id, d.department_name
            )
            SELECT 
                dr.period,
                dr.order_department_id,
                dr.department_name,
                dr.total_revenue,
                RANK() OVER (PARTITION BY dr.period ORDER BY dr.total_revenue DESC) AS revenue_rank
            FROM 
                DepartmentRevenue dr
            ORDER BY 
                dr.period, revenue_rank;

    ELSE
        -- Raise an error if the time_format is invalid
        RAISE EXCEPTION 'Invalid time_format: %. Must be ''day'', ''week'', ''month'', or ''year''.', time_format;
    END IF;

END $$;


-- drop function rank_department_revenue;

SELECT * FROM rank_department_revenue('2023-01-01', '2024-01-01', 'month');

-- test

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
WITH DepartmentRevenue AS (
	SELECT 
		DATE_TRUNC('week', o.order_transaction_date)::DATE AS period,  -- Truncate to day
		o.order_department_id,
		d.department_name,                                       
		ROUND(SUM(o.order_total_price)::NUMERIC,2) AS total_revenue
	FROM 
		orders o
	JOIN 
		departments d ON o.order_department_id = d.department_id  -- Join to get department name
	WHERE 
		o.order_transaction_date BETWEEN '2023-01-01' AND '2023-03-01'
	GROUP BY 
		DATE_TRUNC('week', o.order_transaction_date), o.order_department_id, d.department_name
)
SELECT 
	dr.period,
	dr.order_department_id,
	dr.department_name,
	dr.total_revenue,
	RANK() OVER (PARTITION BY dr.period ORDER BY dr.total_revenue DESC) AS revenue_rank
FROM 
	DepartmentRevenue dr
ORDER BY 
	dr.period, revenue_rank;