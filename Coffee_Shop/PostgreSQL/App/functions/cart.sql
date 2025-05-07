


select * from tables where table_department_id = 2
select * from employees where employee_department_id = 2 and employee_position = 'Cashier'
select customer_id from customers where customer_phone_number = '079-5759-610' 
select product_id, product_unit_price, product_discount, (products.product_unit_price* (1-product_discount)) as Real 
from products where  product_state = 'available'  limit 1
select * from products limit 1
SELECT * FROM orders where order_table_id = -1
select * from order_items
limit 100
select * from exchanged_gifts limit 100
select * from customers
 
order by customer_id desc
limit 1


select * from departments


-- test --
select * from orders 
order by  order_id desc 
limit 1

-- Show Order cua khach van lai ---
select * from orders where order_customer_id is null

select table_id from tables  where table_department_id = 2
select * from gifts limit 100
select * from exchanged_gifts limit 100
select * from gifts

select * from customers where customer_phone_number = '079-5759-610'
-------------------------------------------------------------------------------------
select * from products

---- Function Check Phone----
CREATE OR REPLACE FUNCTION check_customer_phone(phone_number varchar(10))
RETURNS TABLE (
    customer_point integer,
    error_message text
) AS $$
DECLARE
    normalized_phone_number varchar(12);
BEGIN
   
    IF LENGTH(phone_number) = 10 THEN
        -- Format the phone number as '079-5759-610'
        normalized_phone_number := REGEXP_REPLACE(phone_number, '(\d{3})(\d{4})(\d{3})', '\1-\2-\3');
    ELSE
        -- Return -1 as customer_point and an error message if input length is incorrect
        RETURN QUERY SELECT -1, 'Input phone number length is incorrect' AS error_message;
		Return;
    END IF;

    -- Check if the phone number exists and retrieve the customer_point
    IF EXISTS (SELECT 1 FROM customers WHERE customer_phone_number = normalized_phone_number) THEN
        RETURN QUERY SELECT customers.customer_point, NULL AS error_message
        FROM customers
        WHERE customer_phone_number = normalized_phone_number;
    ELSE
        -- Return -1 as customer_point and an error message if the phone number is not found
        RETURN QUERY SELECT -1, 'Phone number not found' AS error_message;
    END IF;
END;
$$ LANGUAGE plpgsql;


--Test--

SELECT * FROM check_customer_phone('3403558057');


-----------------------------------------------------------------------------------------------------------





--- Function to change gift -----
CREATE OR REPLACE FUNCTION exchange_gift(phone_number varchar(10), gift_id integer, gift_point integer, quantity integer)
RETURNS TABLE (
    status integer,
    mess text
) AS $$
DECLARE
    normalized_phone_number varchar(12);
	cus_id integer;
	cus_point integer;
BEGIN
   
    IF LENGTH(phone_number) = 10 THEN
        -- Format the phone number as '079-5759-610'
        normalized_phone_number := REGEXP_REPLACE(phone_number, '(\d{3})(\d{4})(\d{3})', '\1-\2-\3');
    ELSE
        -- Return 400 as status and an error message if input length is incorrect
        RETURN QUERY SELECT 400, 'Input phone number length is incorrect' AS mess;
		Return;
    END IF;

    -- Check if the phone number exists 
    IF EXISTS (SELECT 1 FROM customers WHERE customer_phone_number = normalized_phone_number) THEN

		-- Find cus_id, cus_point by phone_number
		SELECT customer_id , customer_point into cus_id, cus_point
        FROM customers
        WHERE customer_phone_number = normalized_phone_number;

		-- Check if cus enough point
		if (cus_point >= quantity * gift_point) then
		
			--insert into gift_order table ---
			insert into exchanged_gifts (exchanged_gift_customer_id, exchanged_gift_gift_id, exchanged_gift_quantity)
			values (cus_id,  gift_id, quantity);

			--update new cus_point ---
			update customers
			set customer_point = customer_point - quantity * gift_point
			where customer_id = cus_id;

			-- Return 200 as status and exchange gift sucessfully!!!
			RETURN QUERY SELECT 200, 'Customer exchanged gift sucessfully!!!' AS mess;

		--- Not enough point
		else
		    -- Return 400 as status and an error message if not enough point
			RETURN QUERY SELECT 400, 'Customer not enough point!!!' AS mess;
		end if;
		
    -- Phone numer don't exists	
    ELSE
        -- Return 400 as status and an error message if the phone number is not found
        RETURN QUERY SELECT 400, 'Phone number not found' AS mess;
    END IF;
END;
$$ LANGUAGE plpgsql;



--Test Function --

select customer_id ,customer_name, customer_phone_number, customer_point from customers where customer_phone_number = '340-3558-056';

select * from exchange_gift('3403558056', 11, 110, 1)

select * from exchanged_gifts order by exchanged_gift_date desc;


--------------------------------------------------------------------------
--gift-order--
select * from exchanged_gifts where exchanged_gift_customer_id = 423727
--gift--
select * from gifts
limit 1
--cus update point--
update customers
set customer_point = 0
where customer_id = 423727;
--cus select --
select * from customers
ORDER BY customer_id  desc LIMIT 1
-------------------------------------------------






-----CartItem-----

-- Khach vang lai -- NULL

--Khi khong co id_customer---
insert into orders (order_table_id, order_department_id, order_employee_id, order_total_quantity, order_total_price)
values (1, 2, 35, 12, 60)

--Khi co id_customer ---
insert into orders  (order_table_id, order_department_id, order_employee_id, order_customer_id, order_total_quantity, order_total_price)
values (1, 2, 35, 423727, 12, 60 )



---Test---
select * from customers where customer_id = 423727
select * from orders where order_customer_id = 423727
select * from order_items where order_item_order_id = 3000014
select * from orders where order_customer_id is NULL



--- Vs phonenumber = 0 => Khach van lai => luu trong table orders vs cus_id la NULL ----
----Function order item ----
CREATE OR REPLACE FUNCTION handle_checkout(
	phone_number varchar(10), 
	department_id integer,
	employee_id integer, 
	table_id integer, 
	quality_total integer,
	price_total numeric(10,2),
	cart_items JSONB
)
RETURNS TABLE (
    status integer,
    mess text
) AS $$
DECLARE
    normalized_phone_number varchar(12);
	cus_id integer;
	new_bill_id integer;
BEGIN

    ---- Insert Bill Khach van lai -------
	----- cus_id in table orders se NULL ----
	IF (phone_number = '0') then
		insert into orders (order_table_id, order_department_id, order_employee_id, order_total_quantity, order_total_price)
		values (table_id, department_id, employee_id, quality_total, price_total)
		returning order_id into new_bill_id;

		---Insert each order ----
		INSERT INTO order_items (order_item_order_id,order_item_product_id, order_item_price, order_item_quantity, order_item_discount)
        SELECT 
        	new_bill_id,
        	(item->>'productId')::integer,
        	(item->>'price')::numeric(10, 2),
        	(item->>'quantity')::integer,
        	(item->>'discount')::smallint
        FROM jsonb_array_elements(cart_items) AS item;
		-- Return 200 as status and message sucessfull!!! 
        RETURN QUERY SELECT 200, 'Successfull Payment!!!' AS mess;
		Return;	
	End If;

	---- Handle Form phonenumber -------
    IF LENGTH(phone_number) = 10 THEN
        -- Format the phone number as '079-5759-610'
        normalized_phone_number := REGEXP_REPLACE(phone_number, '(\d{3})(\d{4})(\d{3})', '\1-\2-\3');
    ELSE
        -- Return 400 as status and an error message if input length is incorrect
        RETURN QUERY SELECT 400, 'Input phone number length is incorrect' AS mess;
		Return;
    END IF;

    -- Check if the phone number exists 
    IF EXISTS (SELECT 1 FROM customers WHERE customer_phone_number = normalized_phone_number) THEN

		-- Find cus_id, cus_point by phone_number
		SELECT customer_id into cus_id
        FROM customers
        WHERE customer_phone_number = normalized_phone_number;

		-- Insert Bill khach co cus_id ----
		insert into orders  (order_table_id, order_department_id, order_employee_id, order_customer_id, order_total_quantity, order_total_price)
        values (table_id, department_id, employee_id,cus_id ,quality_total, price_total)
		returning order_id into new_bill_id;

		--- Insert each item to order_items ---
		INSERT INTO order_items (order_item_order_id,order_item_product_id, order_item_price, order_item_quantity, order_item_discount)
        SELECT 
        	new_bill_id,
        	(item->>'productId')::integer,
        	(item->>'price')::numeric(10, 2),
        	(item->>'quantity')::integer,
        	(item->>'discount')::smallint
        FROM jsonb_array_elements(cart_items) AS item;
		-- Return 200 as status and message sucessfull!!! 
        RETURN QUERY SELECT 200, 'Successfull Payment!!!' AS mess;
		
    -- Phone numer don't exists	
    ELSE
        -- Return 400 as status and an error message if the phone number is not found
        RETURN QUERY SELECT 400, 'Phone number not found' AS mess;
    END IF;
END;
$$ LANGUAGE plpgsql;

--- Test tren backend boi co cart[] ----


SELECT * FROM handle_checkout(
    '0',              -- phone_number (khách vãng lai)
    1,                -- department_id
    8,               -- employee_id
    5,                -- table_id
    2,                -- quality_total
    28.80,           -- price_total
    '[{"productId": 1, "price": 14.40, "quantity": 1, "discount": 0}, 
      {"productId": 2, "price": 14.40, "quantity": 1, "discount": 0}]'::JSONB -- cart_items
);

SELECT * FROM handle_checkout(
    '0900234351',     -- phone_number (tồn tại trong bảng customers)
    1,                -- department_id
    8,               -- employee_id
    5,                -- table_id
    2,                -- quality_total
    28.80,           -- price_total
    '[{"productId": 1, "price": 14.40, "quantity": 1, "discount": 0}, 
      {"productId": 2, "price": 14.40, "quantity": 1, "discount": 0}]'::JSONB -- cart_items
);

select customer_phone_number, customer_name, customer_point from customers where customer_phone_number = '090-0234-351';

select * from products order by 1;
select * from employees where employee_department_id = 1 and employee_position = 'Cashier';

select * from orders order by 1 desc;



select * from order_items where order_item_order_id = 3000002;