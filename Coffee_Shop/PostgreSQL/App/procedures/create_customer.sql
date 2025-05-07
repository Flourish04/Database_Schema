CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE PROCEDURE create_customer(
    p_customer_name VARCHAR,
    p_customer_username VARCHAR,
    p_customer_password VARCHAR,
	p_customer_phone_number CHAR(12),
    p_customer_birthdate DATE DEFAULT NULL,
    p_customer_gender CHAR(1) DEFAULT NULL,
    p_customer_address VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check for mandatory parameters
    IF p_customer_name IS NULL THEN
        RAISE EXCEPTION 'Customer name is required.';
    END IF;

    IF p_customer_username IS NULL THEN
        RAISE EXCEPTION 'Customer username is required.';
    END IF;

    -- Combined password validation
    IF p_customer_password IS NULL OR LENGTH(p_customer_password) < 6 THEN
        RAISE EXCEPTION 'Password must be at least 6 characters long';
    END IF;

    IF p_customer_phone_number IS NULL THEN
        RAISE EXCEPTION 'Customer phone number is required.';
    END IF;

    -- Validate gender if provided
    IF p_customer_gender IS NOT NULL AND p_customer_gender NOT IN ('M', 'F') THEN
        RAISE EXCEPTION 'Invalid gender. Must be ''M'' or ''F''.';
    END IF;

    -- Validate phone number format
    IF p_customer_phone_number !~ '^\d{3}-\d{4}-\d{3}$' THEN
        RAISE EXCEPTION 'Invalid phone number format. Must be in the format XXX-XXXX-XXX.';
    END IF;

    -- Check for unique username
    IF EXISTS (SELECT 1 FROM customers WHERE customer_username = p_customer_username) THEN
        RAISE EXCEPTION 'A customer with this username already exists.';
    END IF;

    -- Check for unique phone number
    IF EXISTS (SELECT 1 FROM customers WHERE customer_phone_number = p_customer_phone_number) THEN
        RAISE EXCEPTION 'A customer with this phone number already exists.';
    END IF;

    -- Attempt to insert the new customer
    BEGIN
        INSERT INTO customers (
            customer_name, 
            customer_username, 
            customer_password, 
            customer_birthdate, 
            customer_gender, 
            customer_address, 
            customer_phone_number
        )
        VALUES (
            p_customer_name,
            p_customer_username,
            crypt(p_customer_password, gen_salt('bf')), -- Encrypt the password
            p_customer_birthdate,
            p_customer_gender,
            p_customer_address,
            p_customer_phone_number
        );

        -- Notify success
        RAISE NOTICE 'Customer % created successfully.', p_customer_name;
    EXCEPTION 
        WHEN others THEN
            RAISE EXCEPTION 'An unexpected error occurred: %', SQLERRM;
    END;

END $$;


-- FULL INPUT PARAMETER

CALL create_customer(
    p_customer_name => 'hung',
    p_customer_username => 'hung',
    p_customer_password => 'securepassword',
    p_customer_birthdate => '2004-11-16',
    p_customer_gender => 'M',
    p_customer_address => 'ktx khu A',
    p_customer_phone_number => '090-0234-351'
);

select * from customers order by 1 desc;
-- USING DEFAULT PARAMETER
CALL create_customer(
    p_customer_name => 'Jane Doe2',
    p_customer_username => 'janedoe4562',
    p_customer_password => 'securepassword',
    p_customer_phone_number => '234-5678-901' -- Other fields use defaults
);

SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), MAX(customer_id)) FROM customers;

EXPLAIN ANALYZE
SELECT 
    customer_id,
    customer_name,
    customer_username
FROM 
    customers
WHERE 
    customer_username = 'hung'
    AND customer_password = crypt('securepassword', customer_password);
