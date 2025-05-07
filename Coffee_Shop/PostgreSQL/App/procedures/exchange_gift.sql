CREATE OR REPLACE PROCEDURE exchange_gift(
    p_customer_id INT,
    p_gift_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_gift_points INT;
    v_total_cost INT;
    v_customer_points INT;
BEGIN
    -- Lock the customer row and fetch current points
    SELECT customer_point INTO v_customer_points
    FROM customers
    WHERE customer_id = p_customer_id
    FOR UPDATE;

    -- Fetch gift points and calculate total cost
    SELECT gift_point * p_quantity INTO v_gift_points
    FROM gifts
    WHERE gift_id = p_gift_id AND gift_state = 'available'
    FOR UPDATE;

    -- Calculate the total cost
    v_total_cost := v_gift_points;

    -- Check if the customer has enough points
    IF v_customer_points < v_total_cost THEN
        RAISE EXCEPTION 'Insufficient points. Required: %, Available: %', v_total_cost, v_customer_points;
    END IF;

    -- Deduct points from customer
    UPDATE customers
    SET customer_point = customer_point - v_total_cost
    WHERE customer_id = p_customer_id;

    -- Record exchange
    INSERT INTO exchanged_gifts (
        exchanged_gift_customer_id, 
        exchanged_gift_gift_id, 
        exchanged_gift_quantity
    ) VALUES (
        p_customer_id, 
        p_gift_id, 
        p_quantity
    );

    -- Notify successful completion
    RAISE NOTICE 'Gift exchange completed for customer ID %', p_customer_id;

EXCEPTION WHEN OTHERS THEN
    -- Handle errors
    RAISE EXCEPTION 'Error during gift exchange: %', SQLERRM;
END;
$$;

drop procedure exchange_gift;

select * from customers where customer_id  = 1;

CALL exchange_gift(
    p_customer_id => 1,
    p_gift_id => 1,
    p_quantity => 3
);
