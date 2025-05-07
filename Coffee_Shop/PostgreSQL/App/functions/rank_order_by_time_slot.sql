--
-- Function to rank the time_slot by total orders of a department / all departments by time
--

CREATE OR REPLACE FUNCTION rank_order_by_time_slot(
    start_date DATE,                   -- Start date for the range
    end_date DATE,                     -- End date for the range
    input_department_id INT DEFAULT NULL  -- Optional: Filter by department; NULL means calculate for all departments
)
RETURNS TABLE (
    time_slot TEXT,                    -- Time slot (e.g., '00:00:00 - 02:00:00')
    order_department_id INT,           
    department_name VARCHAR,           
    total_orders BIGINT,               
    rank_in_time_slot BIGINT           
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH TimeSlotOrders AS (
        SELECT 
            o.order_department_id,
            d.department_name,                                   
            FLOOR(EXTRACT(HOUR FROM o.order_transaction_time) / 2) AS time_slot_group,  -- Group by 2-hour slots
            COUNT(o.order_id) AS total_orders                     
        FROM 
            orders o
        JOIN 
            departments d ON o.order_department_id = d.department_id  -- Join to get department name
        WHERE 
            o.order_transaction_date BETWEEN start_date AND end_date  
            AND (input_department_id IS NULL OR o.order_department_id = input_department_id)  -- Filter by department (if provided)
        GROUP BY 
            o.order_department_id, d.department_name, 
            FLOOR(EXTRACT(HOUR FROM o.order_transaction_time) / 2)  -- Group by 2-hour time slot and department
    ),
    RankedTimeSlots AS (
        SELECT 
            tso.order_department_id,
            tso.department_name,
            tso.time_slot_group, 
            tso.total_orders,
            RANK() OVER (
                PARTITION BY tso.order_department_id ORDER BY tso.total_orders DESC  -- Rank by number of orders within department
            ) AS rank_in_time_slot
        FROM 
            TimeSlotOrders tso
    )
    -- Convert the time slot group into a readable time range and return the ranked time slots
    SELECT 
        CASE 
            WHEN rts.time_slot_group = 0 THEN '00:00:00 - 02:00:00'
            WHEN rts.time_slot_group = 1 THEN '02:00:00 - 04:00:00'
            WHEN rts.time_slot_group = 2 THEN '04:00:00 - 06:00:00'
            WHEN rts.time_slot_group = 3 THEN '06:00:00 - 08:00:00'
            WHEN rts.time_slot_group = 4 THEN '08:00:00 - 10:00:00'
            WHEN rts.time_slot_group = 5 THEN '10:00:00 - 12:00:00'
            WHEN rts.time_slot_group = 6 THEN '12:00:00 - 14:00:00'
            WHEN rts.time_slot_group = 7 THEN '14:00:00 - 16:00:00'
            WHEN rts.time_slot_group = 8 THEN '16:00:00 - 18:00:00'
            WHEN rts.time_slot_group = 9 THEN '18:00:00 - 20:00:00'
            WHEN rts.time_slot_group = 10 THEN '20:00:00 - 22:00:00'
            WHEN rts.time_slot_group = 11 THEN '22:00:00 - 00:00:00'
        END AS time_slot,
        rts.order_department_id,
        rts.department_name,                                   
        rts.total_orders,
        rts.rank_in_time_slot
    FROM 
        RankedTimeSlots rts
    ORDER BY 
        rts.rank_in_time_slot;
END $$;

-- drop function rank_order_by_time_slot;
SELECT * FROM rank_order_by_time_slot('2023-01-01', '2023-06-30', 1);

-- Test

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
WITH TimeSlotOrders AS (
	SELECT 
		o.order_department_id,
		d.department_name,                                  
		FLOOR(EXTRACT(HOUR FROM o.order_transaction_time) / 2) AS time_slot_group,  -- Group by 2-hour slots
		COUNT(o.order_id) AS total_orders                     
	FROM 
		orders o
	JOIN 
		departments d ON o.order_department_id = d.department_id  -- Join to get department name
	WHERE 
		o.order_transaction_date BETWEEN '2023-01-01' AND '2023-03-01'  
		AND (1 IS NULL OR o.order_department_id = 1)  -- Filter by department (if provided)
	GROUP BY 
		o.order_department_id, d.department_name, 
		FLOOR(EXTRACT(HOUR FROM o.order_transaction_time) / 2)  -- Group by 2-hour time slot and department
),
RankedTimeSlots AS (
	SELECT 
		tso.order_department_id,
		tso.department_name,
		tso.time_slot_group, 
		tso.total_orders,
		RANK() OVER (
			PARTITION BY tso.order_department_id ORDER BY tso.total_orders DESC  -- Rank by number of orders within department
		) AS rank_in_time_slot
	FROM 
		TimeSlotOrders tso
)
-- Convert the time slot group into a readable time range and return the ranked time slots
SELECT 
	CASE 
		WHEN rts.time_slot_group = 0 THEN '00:00:00 - 02:00:00'
		WHEN rts.time_slot_group = 1 THEN '02:00:00 - 04:00:00'
		WHEN rts.time_slot_group = 2 THEN '04:00:00 - 06:00:00'
		WHEN rts.time_slot_group = 3 THEN '06:00:00 - 08:00:00'
		WHEN rts.time_slot_group = 4 THEN '08:00:00 - 10:00:00'
		WHEN rts.time_slot_group = 5 THEN '10:00:00 - 12:00:00'
		WHEN rts.time_slot_group = 6 THEN '12:00:00 - 14:00:00'
		WHEN rts.time_slot_group = 7 THEN '14:00:00 - 16:00:00'
		WHEN rts.time_slot_group = 8 THEN '16:00:00 - 18:00:00'
		WHEN rts.time_slot_group = 9 THEN '18:00:00 - 20:00:00'
		WHEN rts.time_slot_group = 10 THEN '20:00:00 - 22:00:00'
		WHEN rts.time_slot_group = 11 THEN '22:00:00 - 00:00:00'
	END AS time_slot,
	rts.order_department_id,
	rts.department_name,                                  
	rts.total_orders,
	rts.rank_in_time_slot
FROM 
	RankedTimeSlots rts
ORDER BY 
	rts.rank_in_time_slot;