--
-- Function to classify customers by age
--

CREATE OR REPLACE FUNCTION classify_customers_by_age(input_birthdate DATE)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    customer_age INT;
BEGIN
    -- Handle NULL input
    IF input_birthdate IS NULL THEN
        RETURN 'Unknown';
    END IF;

    -- Calculate age
    customer_age := DATE_PART('year', AGE(CURRENT_DATE, input_birthdate))::INT;

    -- Return classification based on age
    RETURN CASE
        WHEN customer_age < 18 THEN 'Teenager'
        WHEN customer_age < 30 THEN 'Young Adult'
        WHEN customer_age < 50 THEN 'Adult'
        ELSE 'Senior'
    END;
END $$;

SELECT *, classify_customers_by_age(customer_birthdate) FROM classify_customers_by_spending() LIMIT 10;

select * from employees;

-- Test 
EXPLAIN ANALYZE
SELECT 
    *,
    DATE_PART('year', AGE(CURRENT_DATE, customer_birthdate))::INT AS customer_age, -- Calculate age
    CASE 
        WHEN DATE_PART('year', AGE(CURRENT_DATE, customer_birthdate))::INT < 18 THEN 'Teenager'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, customer_birthdate))::INT < 30 THEN 'Young Adult'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, customer_birthdate))::INT < 50 THEN 'Adult'
        ELSE 'Senior'
    END AS class -- Classify based on age
FROM 
    customers;