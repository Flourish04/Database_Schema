--
-- Function to get the gift ranking based on how frequently they were exchanged
--

CREATE OR REPLACE FUNCTION get_gift_rankings(
    start_date DATE,                -- Start of the date range
    end_date DATE                   -- End of the date range
)
RETURNS TABLE (
    gift_id INT,
    gift_name VARCHAR,
    total_quantity BIGINT,
    gift_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.gift_id,
        g.gift_name,
        SUM(eg.exchanged_gift_quantity) AS total_quantity,  -- Total quantity exchanged
        RANK() OVER (
            ORDER BY SUM(eg.exchanged_gift_quantity) DESC   -- Rank by total quantity in descending order
        ) AS gift_rank
    FROM 
        exchanged_gifts eg
    JOIN 
        gifts g ON eg.exchanged_gift_gift_id = g.gift_id   
    WHERE 
        eg.exchanged_gift_date BETWEEN start_date AND end_date -- Filter by date range
        AND g.gift_state = 'available'                        -- Include only gifts with state 'available'
    GROUP BY 
        g.gift_id, g.gift_name                              
    ORDER BY 
        gift_rank;                                          -- Order by rank
END $$;


SELECT * FROM get_gift_rankings('2023-01-01', '2023-12-31');

-- Test 
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
	g.gift_id,
	g.gift_name,
	SUM(eg.exchanged_gift_quantity) AS total_quantity,  -- Total quantity exchanged
	RANK() OVER (
		ORDER BY SUM(eg.exchanged_gift_quantity) DESC   -- Rank by total quantity in descending order
	) AS gift_rank
FROM 
	exchanged_gifts eg
JOIN 
	gifts g ON eg.exchanged_gift_gift_id = g.gift_id    
WHERE 
	eg.exchanged_gift_date BETWEEN '2023-01-01' AND '2023-03-01' -- Filter by date range
	AND g.gift_state = 'available'                        -- Include only gifts with state 'available'
GROUP BY 
	g.gift_id, g.gift_name                              
ORDER BY 
	gift_rank;                                          -- Order by rank