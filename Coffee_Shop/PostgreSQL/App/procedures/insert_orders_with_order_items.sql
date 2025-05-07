CREATE OR REPLACE PROCEDURE insert_orders_with_order_items(
    p_order_table_id INT,
    p_order_department_id INT,
    p_order_employee_id INT,
    p_order_customer_id INT,
    p_order_total_quantity INT, -- New parameter for total quantity
    p_order_total_price DECIMAL(10, 2), -- New parameter for total price
    p_order_items JSONB -- JSONB containing an array of {product_id, quantity, price, discount}
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id INT;
    v_item JSONB;
    v_product_id INT;
    v_quantity INT;
    v_price DECIMAL(10, 2);
    v_discount SMALLINT;
BEGIN
    -- Validate inputs
    IF p_order_items IS NULL OR jsonb_array_length(p_order_items) = 0 THEN
        RAISE EXCEPTION 'Order must include at least one item.';
    END IF;

    IF p_order_total_quantity IS NULL OR p_order_total_quantity <= 0 THEN
        RAISE EXCEPTION 'Total quantity must be greater than zero.';
    END IF;

    IF p_order_total_price IS NULL OR p_order_total_price <= 0 THEN
        RAISE EXCEPTION 'Total price must be greater than zero.';
    END IF;

    -- Insert the order
    INSERT INTO orders (
        order_transaction_date,
        order_transaction_time,
        order_table_id,
        order_department_id,
        order_employee_id,
        order_customer_id,
        order_total_quantity,
        order_total_price
    ) VALUES (
        CURRENT_DATE,
        CURRENT_TIME,
        p_order_table_id,
        p_order_department_id,
        p_order_employee_id,
        p_order_customer_id,
        p_order_total_quantity,
        p_order_total_price
    )
    RETURNING order_id INTO v_order_id;

    -- Insert each order item
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_order_items) LOOP
        -- Extract product details from JSONB
        v_product_id := (v_item->>'product_id')::INT;
        v_quantity := (v_item->>'quantity')::INT;
        v_price := (v_item->>'price')::DECIMAL;
        v_discount := (v_item->>'discount')::SMALLINT;

        -- Insert into order_items
        INSERT INTO order_items (
            order_item_order_id,
            order_item_product_id,
            order_item_price,
            order_item_quantity,
            order_item_discount
        ) VALUES (
            v_order_id,
            v_product_id,
            v_price,
            v_quantity,
            v_discount
        );
    END LOOP;

    -- Notify success
    RAISE NOTICE 'Order % created successfully with total quantity % and total price %.', v_order_id, p_order_total_quantity, p_order_total_price;

END;
$$;

CALL insert_order_with_items(
    p_order_table_id := 1,
    p_order_department_id := 2,
    p_order_employee_id := 10,
    p_order_customer_id := 20,
    p_order_total_quantity := 5, -- Total quantity passed in
    p_order_total_price := 100.50, -- Total price passed in
    p_order_items := '[
        {"product_id": 101, "quantity": 2, "price": 20.50, "discount": 10},
        {"product_id": 102, "quantity": 3, "price": 15.00, "discount": 5}
    ]'::JSONB
);

