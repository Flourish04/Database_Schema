--
-- Function to get the products ranking based on total revenue
--

CREATE OR REPLACE FUNCTION rank_products_by_revenue(
    start_date DATE,                -- Start of the date range
    end_date DATE,                  -- End of the date range
    input_department_id INT DEFAULT NULL  -- Optional parameter: if NULL, calculate for all departments
)
RETURNS TABLE (
    product_id INT,
    product_category VARCHAR,
    product_name VARCHAR,
    total_revenue NUMERIC,
    order_department_id INT,
    product_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH ProductRevenue AS (
        SELECT 
            p.product_id,
            p.product_category,
            p.product_name,
            o.order_department_id,
            SUM(oi.order_item_price) AS total_revenue  -- Aggregate based on order_item_price
        FROM 
            products p
        JOIN 
            order_items oi ON p.product_id = oi.order_item_product_id
        JOIN 
            orders o ON oi.order_item_order_id = o.order_id
        WHERE 
            o.order_transaction_date BETWEEN start_date AND end_date  
            AND (o.order_department_id = input_department_id OR input_department_id IS NULL)  -- Filter by department or include all
            AND p.product_state = 'available'  -- Include only products with state 'available'
        GROUP BY 
            p.product_id, p.product_category, p.product_name, o.order_department_id 
    ),
    RankedProductRevenue AS (
        SELECT 
            pr.product_id,
            pr.product_category,
            pr.product_name,
            pr.order_department_id,
            pr.total_revenue,
            RANK() OVER (
                PARTITION BY pr.order_department_id  -- Rank by department if specified
                ORDER BY pr.total_revenue DESC
            ) AS product_rank  -- Rank products by total revenue within each department
        FROM 
            ProductRevenue pr
    )
    -- Select all rankings for products
    SELECT 
        pr.product_id,
        pr.product_category,
        pr.product_name,
        pr.total_revenue,
        pr.order_department_id,
        pr.product_rank
    FROM 
        RankedProductRevenue pr
    ORDER BY 
        pr.order_department_id, pr.product_rank;  -- Order by department and rank

END $$;

-- drop function calculate_product_revenue_rankings;

SELECT * FROM rank_products_by_revenue('2023-01-01', '2023-06-30', 1) where product_rank = 1;

-- Test

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
WITH ProductRevenue AS (
	SELECT 
		p.product_id,
		p.product_category,
		p.product_name,
		o.order_department_id,
		SUM(oi.order_item_price) AS total_revenue  -- Aggregate based on order_item_price
	FROM 
		products p
	JOIN 
		order_items oi ON p.product_id = oi.order_item_product_id
	JOIN 
		orders o ON oi.order_item_order_id = o.order_id
	WHERE 
		o.order_transaction_date BETWEEN '2023-01-01' AND '2023-03-01'
		AND (o.order_department_id = 1 OR 1 IS NULL)  -- Filter by department or include all
		AND p.product_state = 'available'  -- Include only products with state 'available'
	GROUP BY 
		p.product_id, p.product_category, p.product_name, o.order_department_id 
),
RankedProductRevenue AS (
	SELECT 
		pr.product_id,
		pr.product_category,
		pr.product_name,
		pr.order_department_id,
		pr.total_revenue,
		RANK() OVER (
			PARTITION BY pr.order_department_id  -- Rank by department if specified
			ORDER BY pr.total_revenue DESC
		) AS product_rank  -- Rank products by total revenue within each department
	FROM 
		ProductRevenue pr
)
-- Select all rankings for products
SELECT 
	pr.product_id,
	pr.product_category,
	pr.product_name,
	pr.total_revenue,
	pr.order_department_id,
	pr.product_rank
FROM 
	RankedProductRevenue pr
ORDER BY 
	pr.order_department_id, pr.product_rank;  -- Order by department and rank