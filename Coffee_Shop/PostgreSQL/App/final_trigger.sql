--
-- Trigger calculate product_rating
--

CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- If DELETE, use OLD.review_product_id, else use NEW.review_product_id
    IF (TG_OP = 'DELETE') THEN
        -- Recalculate the average rating for the product after a DELETE
        UPDATE products
        SET product_rating = (
            SELECT AVG(review_score)
            FROM reviews
            WHERE review_product_id = OLD.review_product_id
        )
        WHERE product_id = OLD.review_product_id;
    ELSE
        -- Recalculate the average rating for the product after an INSERT/UPDATE
        UPDATE products
        SET product_rating = (
            SELECT AVG(review_score)
            FROM reviews
            WHERE review_product_id = NEW.review_product_id
        )
        WHERE product_id = NEW.review_product_id;
    END IF;

    RETURN NULL; -- Trigger functions should return NULL
END;
$$;

CREATE TRIGGER recalculate_product_rating
AFTER INSERT OR UPDATE OR DELETE
ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_product_rating();

--
-- Trigger to calculate customer point after orders
--

CREATE OR REPLACE FUNCTION update_customer_points_after_order_done()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if order_customer_id is NOT NULL
    IF NEW.order_customer_id IS NOT NULL THEN
        -- Calculate points based on order_total_price (1 point per $5 spent)
        UPDATE customers
        SET customer_point = customer_point + FLOOR(NEW.order_total_price / 5)
        WHERE customer_id = NEW.order_customer_id;
    END IF;

    -- Return the new row (trigger functions must return NEW for AFTER triggers)
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER increase_customer_points
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_customer_points_after_order_done();

--
-- Trigger to handle deletion on Table tables
--

CREATE OR REPLACE FUNCTION reassign_orders_to_fallback()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET order_table_id = NULL
    WHERE order_table_id = OLD.table_id
      AND order_department_id = OLD.table_department_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reassign_orders_trigger
BEFORE DELETE ON tables
FOR EACH ROW
EXECUTE FUNCTION reassign_orders_to_fallback();