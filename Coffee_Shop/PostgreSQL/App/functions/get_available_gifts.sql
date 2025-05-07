--
-- Shows the gifts a customer can exchange based on their available points
--

CREATE OR REPLACE FUNCTION get_available_gifts(input_customer_id INT)
RETURNS TABLE (
    gift_id INT,
    gift_name VARCHAR,
    gift_point INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
	SELECT 
	    g.gift_id, 
	    g.gift_name, 
	    g.gift_point
	FROM 
	    gifts g
	WHERE 
	    g.gift_point <= (SELECT customer_point FROM customers WHERE customer_id = 1) -- Gift points must not exceed customer points
	    AND g.gift_state = 'available'; -- Only available gifts are included 
END $$;

-- drop function get_available_gifts;

SELECT * FROM get_available_gifts(3);

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
SELECT 
    g.gift_id, 
    g.gift_name, 
    g.gift_point
FROM 
    gifts g
WHERE 
    g.gift_point <= (SELECT customer_point FROM customers WHERE customer_id = 1) -- Gift points must not exceed customer points
    AND g.gift_state = 'available'; -- Only available gifts are included
