--
-- Function to rank employee hours_worked of a department / all departments by time
--

CREATE OR REPLACE FUNCTION get_employee_rankings(
    start_date DATE,
    end_date DATE,
    input_department_id INT DEFAULT NULL  -- Filter by department; NULL means all departments
)
RETURNS TABLE (
    employee_id INT,
    employee_name TEXT,
    department_id INT,
    department_name VARCHAR,
    total_hours_worked NUMERIC,
    total_shifts BIGINT,
    employee_rank BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH ranked_employees AS (
        SELECT 
            e.employee_id,                                      
            e.employee_first_name || ' ' || e.employee_last_name AS emp_name,
            e.employee_department_id AS dept_id,               
            d.department_name AS dept_name,
            ROUND(SUM(EXTRACT(EPOCH FROM (sh.shift_end_time - sh.shift_start_time)) / 3600)::NUMERIC, 0) AS hours_worked, -- Calculate total hours worked by the employee
            COUNT(s.schedule_shift_id) AS shifts_worked, -- Count the total number of shifts worked by the employee
            RANK() OVER ( -- Calculate the rank of the employee based on hours and shifts
                ORDER BY 
                    SUM(EXTRACT(EPOCH FROM (sh.shift_end_time - sh.shift_start_time)) / 3600) DESC, -- Rank by hours worked
                    COUNT(s.schedule_shift_id) DESC -- Break ties using the number of shifts worked
            ) AS emp_rank
        FROM 
            schedules s
        JOIN 
            employees e ON s.schedule_employee_id = e.employee_id
        JOIN 
            shifts sh ON s.schedule_shift_id = sh.shift_id
        LEFT JOIN 
            departments d ON e.employee_department_id = d.department_id
        WHERE 
            s.schedule_date BETWEEN start_date AND end_date
            AND (e.employee_department_id = input_department_id OR input_department_id IS NULL) -- Filter by department if specified, otherwise include all departments
        GROUP BY 
            e.employee_id, e.employee_first_name, e.employee_last_name, e.employee_department_id, d.department_name
    )
    SELECT 
        ranked_employees.employee_id,
        emp_name AS employee_name,
        dept_id AS department_id,
        dept_name AS department_name,
        hours_worked AS total_hours_worked,
        shifts_worked AS total_shifts,
        emp_rank AS employee_rank
    FROM 
        ranked_employees
    ORDER BY 
        employee_rank; -- Sort by rank
END $$;

SELECT * FROM get_employee_rankings('2023-01-01', '2024-01-31', NULL);
SELECT * FROM get_employee_rankings('2023-01-01', '2024-01-31', 1) WHERE employee_rank = 1; -- GET the hardest-working employees

-- Test 

SET enable_indexscan = OFF;
SET enabbitle_mapscan = OFF;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
WITH ranked_employees AS (
	SELECT 
		e.employee_id,                                     
		e.employee_first_name || ' ' || e.employee_last_name AS emp_name,
		e.employee_department_id AS dept_id,               
		d.department_name AS dept_name,
		ROUND(SUM(EXTRACT(EPOCH FROM (sh.shift_end_time - sh.shift_start_time)) / 3600)::NUMERIC, 0) AS hours_worked, -- Calculate total hours worked by the employee
		COUNT(s.schedule_shift_id) AS shifts_worked,  -- Count the total number of shifts worked by the employee
		RANK() OVER ( -- Calculate the rank of the employee based on hours and shifts
			ORDER BY 
				SUM(EXTRACT(EPOCH FROM (sh.shift_end_time - sh.shift_start_time)) / 3600) DESC, -- Rank by hours worked
				COUNT(s.schedule_shift_id) DESC  -- Break ties using the number of shifts worked
		) AS emp_rank
	FROM 
		schedules s
	JOIN 
		employees e ON s.schedule_employee_id = e.employee_id
	JOIN 
		shifts sh ON s.schedule_shift_id = sh.shift_id
	LEFT JOIN 
		departments d ON e.employee_department_id = d.department_id
	WHERE 
		s.schedule_date BETWEEN '2023-01-01' AND '2023-06-01'
		AND (e.employee_department_id = 1 OR 1 IS NULL)
	GROUP BY 
		e.employee_id, e.employee_first_name, e.employee_last_name, e.employee_department_id, d.department_name
)
SELECT 
	ranked_employees.employee_id,
	emp_name AS employee_name,
	dept_id AS department_id,
	dept_name AS department_name,
	hours_worked AS total_hours_worked,
	shifts_worked AS total_shifts,
	emp_rank AS employee_rank
FROM 
	ranked_employees
ORDER BY 
	employee_rank; -- Sort by rank

