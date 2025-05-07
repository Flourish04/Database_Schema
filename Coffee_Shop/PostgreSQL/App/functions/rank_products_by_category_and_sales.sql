--
-- Function to rank product based on total quantity sold of a department / all departments by time
--

CREATE OR REPLACE FUNCTION rank_products_by_category_and_sales(
    start_date DATE,                -- Start of the date range
    end_date DATE,                  -- End of the date range
    department_id INT DEFAULT NULL  -- Optional parameter: if NULL, calculate for all departments
)
RETURNS TABLE (
    product_category VARCHAR,
    product_name VARCHAR,
    total_quantity_sold BIGINT,
    order_department_id INT,
    product_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH ProductSales AS (
        SELECT 
            p.product_category,           
            p.product_name,
            SUM(oi.order_item_quantity) AS total_quantity_sold,
            o.order_department_id
        FROM 
            products p
        JOIN 
            order_items oi ON p.product_id = oi.order_item_product_id
        JOIN 
            orders o ON oi.order_item_order_id = o.order_id
        WHERE 
            o.order_transaction_date BETWEEN start_date AND end_date  
            AND (o.order_department_id = department_id OR department_id IS NULL)  -- Filter by department or include all
            AND p.product_state = 'available'  -- Filter only available products
        GROUP BY 
            p.product_category, p.product_name, o.order_department_id
    ),
    RankedProductSales AS (
        SELECT 
            ps.product_category,           
            ps.product_name,
            ps.order_department_id,
            ps.total_quantity_sold,
            RANK() OVER (
                PARTITION BY ps.product_category, ps.order_department_id 
                ORDER BY ps.total_quantity_sold DESC
            ) AS product_rank  -- Calculate rank within each category and department
        FROM 
            ProductSales ps
    )
    -- Select all rankings for products
    SELECT 
        ps.product_category,         
        ps.product_name,
        ps.total_quantity_sold,
        ps.order_department_id,
        ps.product_rank
    FROM 
        RankedProductSales ps
    ORDER BY 
        ps.product_category, ps.order_department_id, ps.product_rank; 

END $$;


-- drop function rank_products_by_category_and_sales;

SELECT * FROM rank_products_by_category_and_sales('2023-01-01', '2023-01-31', 1);
SELECT * FROM rank_products_by_category_and_sales('2023-01-01', '2023-01-31', 1) WHERE product_rank = 1; -- Best seller by category

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
WITH ProductSales AS (
	SELECT 
		p.product_category,           
		p.product_name,
		SUM(oi.order_item_quantity) AS total_quantity_sold,
		o.order_department_id
		FROM 
            products p
        JOIN 
            order_items oi ON p.product_id = oi.order_item_product_id
        JOIN 
            orders o ON oi.order_item_order_id = o.order_id
	WHERE 
		o.order_transaction_date BETWEEN '2023-01-01' AND '2023-03-01' 
		AND (o.order_department_id = 1 OR 1 IS NULL)  -- Filter by department or include all
		AND p.product_state = 'available'  -- Filter only available products
	GROUP BY 
		p.product_category, p.product_name, o.order_department_id
),
RankedProductSales AS (
	SELECT 
		ps.product_category,           
		ps.product_name,
		ps.order_department_id,
		ps.total_quantity_sold,
		RANK() OVER (
			PARTITION BY ps.product_category, ps.order_department_id 
			ORDER BY ps.total_quantity_sold DESC
		) AS product_rank  -- Calculate rank within each category and department
	FROM 
		ProductSales ps
)
-- Select all rankings for products
SELECT 
	ps.product_category,         
	ps.product_name,
	ps.total_quantity_sold,
	ps.order_department_id,
	ps.product_rank
FROM 
	RankedProductSales ps
ORDER BY 
	ps.product_category, ps.order_department_id, ps.product_rank;