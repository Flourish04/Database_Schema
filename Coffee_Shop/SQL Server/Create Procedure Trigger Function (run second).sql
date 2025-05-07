USE TEST_BTL17;
CREATE OR ALTER PROCEDURE Add_account (
    @username VARCHAR(255),
    @password VARCHAR(255),
    @display_name NVARCHAR(255)
)
AS
BEGIN
    BEGIN TRY
        --DECLARE @seed INT;
        --SELECT @seed = MAX(id) FROM Accounts;
        --DBCC CHECKIDENT ('Accounts', RESEED, @seed);
        
        IF LEN(@username) = 0 OR LEN(@password) = 0 OR LEN(@display_name) = 0
        BEGIN
            PRINT 'Please fill out all fields (all fields are required)!';
			RETURN (1)
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Accounts WHERE username = @username)
            BEGIN
                INSERT INTO Accounts (username, password, display_name)
                VALUES (@username, @password, @display_name);
                PRINT 'Account added successfully!';
				RETURN (0);
            END
            ELSE
            BEGIN
                PRINT 'Username already exists!';
				RETURN (2)
            END
        END
    END TRY
    BEGIN CATCH
        PRINT 'Please fill out all fields (all fields are required)!';
		RETURN (1)
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Change_password(
	@username VARCHAR(255),
	@password VARCHAR(255),
	@new_password VARCHAR(255)
)
AS
BEGIN
	BEGIN TRY
		-- Check if any input is empty
		IF LEN(@username) = 0 OR LEN(@password) = 0 OR LEN(@new_password) = 0
        BEGIN
            PRINT 'Please fill out all fields (all fields are required)!';
			RETURN (1)
        END
		ELSE
		BEGIN
			DECLARE @old_password VARCHAR(255);
			SELECT @old_password = password FROM Accounts WHERE username = @username;
			IF @password != @old_password
			BEGIN
				PRINT 'Password incorrect!';
				RETURN (2)
			END
			ELSE IF @new_password = @old_password
			BEGIN
				PRINT 'The new password you entered is the same as your old password. Enter a different password!';
				RETURN (3)
			END
			ELSE
			BEGIN
				UPDATE Accounts
				SET password = @new_password WHERE username = @username;
				PRINT 'Password changed successfully!';
				RETURN (0)
			END
		END
	END TRY
	BEGIN CATCH
		PRINT 'Please fill out all fields (all fields are required)!';
		RETURN (1)
	END CATCH
END;
GO

CREATE OR ALTER PROCEDURE Delete_account(
    @username VARCHAR(255),
    @password VARCHAR(255)
)
AS
BEGIN
    -- Check if username or password is empty
    IF LEN(@username) = 0 OR LEN(@password) = 0
    BEGIN
        PRINT 'Please fill out all fields (all fields are required)!';
		RETURN (1)
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM Accounts WHERE username = @username)
	BEGIN
		PRINT 'Account does not exists!';
		RETURN (2)
	END
	ELSE
    BEGIN
        DECLARE @old_password VARCHAR(255);
        SELECT @old_password = password FROM Accounts WHERE username = @username;
        IF @password != @old_password
        BEGIN
            PRINT 'Password incorrect!';
			RETURN (3)
        END
        ELSE
        BEGIN
            -- Check if there are any orders in progress associated with this account
            IF NOT EXISTS (
                SELECT 1
                FROM (
                    SELECT a.username, o.state
                    FROM Orders o
                    INNER JOIN Online_orders onl ON o.id = onl.id
                    INNER JOIN Accounts a ON onl.account_id = a.id
                    WHERE a.username = @username AND o.state = 'in progress'
                    UNION
                    SELECT a.username, o.state
                    FROM Orders o
                    INNER JOIN Offline_orders offl ON o.id = offl.id
                    INNER JOIN Customers c ON offl.customer_id = c.id
                    INNER JOIN Accounts a ON c.account_id = a.id
                    WHERE a.username = @username AND o.state = 'in progress'
                ) AS Check_state
            )
            BEGIN
                DELETE FROM Accounts WHERE username = @username;
				PRINT 'Account deleted successfully!';
				RETURN (0)
            END
            ELSE
            BEGIN
                PRINT 'This account cannot be deleted because an order in progress is currently assigned to the account!';
				RETURN (4)
            END
        END
    END
END;
GO

CREATE OR ALTER TRIGGER Update_orders_quantity_insert
ON Order_details
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @quantity INT;
	DECLARE @order_id INT;
	SELECT @quantity = quantity, @order_id = order_id FROM inserted;
	UPDATE Orders
	SET total_quantity = total_quantity + @quantity
	WHERE id = @order_id;
END;
GO

CREATE OR ALTER TRIGGER Update_orders_quantity_delete
ON Order_details
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @quantity INT;
	DECLARE @order_id INT;
	SELECT @quantity = quantity, @order_id = order_id FROM deleted;
	UPDATE Orders
	SET total_quantity = total_quantity - @quantity
	WHERE id = @order_id;
END;
GO

CREATE OR ALTER TRIGGER Update_orders_quantity_update
ON Order_details
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @old_quantity INT;
	DECLARE @new_quantity INT;
	DECLARE @order_id INT;
	SELECT @old_quantity = quantity, @order_id = order_id FROM deleted;
	SELECT @new_quantity = quantity FROM inserted;
	UPDATE Orders
	SET total_quantity = total_quantity + (@new_quantity - @old_quantity)
	WHERE id = @order_id;
END;
GO

CREATE OR ALTER TRIGGER Update_orders_details_cost_insert
ON Order_details
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @order_id INT;
	DECLARE @product_id INT;
	DECLARE @quantity INT;
	DECLARE @discount DECIMAL (3,2);
	DECLARE @list_price INT;
	SELECT @order_id = order_id, @product_id = i.product_id, @quantity = i.quantity, @discount = discount, @list_price = list_price
	FROM inserted i
	INNER JOIN Products P
	ON i.product_id = P.id;
	UPDATE Order_details
	SET cost = (@list_price - ROUND((@list_price * @discount),0)) * @quantity
	WHERE order_id = @order_id AND product_id = @product_id;
END;
GO

CREATE OR ALTER TRIGGER Update_orders_cost_update
ON Order_details
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @order_id INT;
	DECLARE @new_cost INT;
	DECLARE @old_cost INT;
	SELECT @order_id = order_id, @new_cost = cost FROM inserted;
	SELECT @old_cost = cost FROM deleted;
	UPDATE Orders
	SET total_cost = total_cost + (@new_cost - @old_cost)
	WHERE id = @order_id;
END;
GO

CREATE OR ALTER TRIGGER Update_orders_cost_delete
ON Order_details
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @order_id INT;
	DECLARE @cost INT;
	SELECT @order_id = order_id, @cost = cost FROM deleted;
	UPDATE Orders
	SET total_cost = total_cost - @cost
	WHERE id = @order_id;
END;
GO

CREATE OR ALTER TRIGGER Update_accounts_point_update
ON Orders
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @state CHAR(12);
	DECLARE @old_state CHAR(12);
	DECLARE @type VARCHAR(7);
	DECLARE @order_id INT;
	DECLARE @account_id INT;
	DECLARE @point INT;
	SELECT @order_id = id, @state = state, @type = type FROM inserted;
	SELECT @old_state = state FROM deleted;
	IF @state = 'finished' AND @state != @old_state
	BEGIN
		SELECT @point = ROUND(total_cost * 5 / 100,0) FROM Orders WHERE id = @order_id;
		IF @type = 'online'
		BEGIN
			SELECT @account_id = onl.account_id
			FROM Orders o
			INNER JOIN Online_orders onl ON o.id = onl.id
			WHERE o.id = @order_id;
			UPDATE Accounts
			SET point = point + @point
			WHERE id = @account_id;
		END
		ELSE
		BEGIN
			SELECT @account_id = c.account_id
			FROM Orders o
			INNER JOIN Offline_orders offl ON o.id = offl.id
			INNER JOIN Customers c ON offl.customer_id = c.id
			WHERE o.id = @order_id;
			UPDATE Accounts
			SET point = point + @point
			WHERE id =@account_id;
		END
	END
END;
GO

CREATE OR ALTER TRIGGER Update_orders_endtime
ON Orders
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @state CHAR(12);
	DECLARE @old_state CHAR(12);
	DECLARE @order_id INT;
	SELECT @order_id = id, @state = state FROM inserted;
	SELECT @old_state = state FROM deleted;
	IF @state = 'finished' AND @state != @old_state
	BEGIN
		UPDATE Orders
		SET end_time = GETDATE()
		WHERE id = @order_id;
	END
END;
GO

CREATE OR ALTER TRIGGER Update_rating
ON Reviews
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @product_id INT;
	DECLARE @rating DECIMAL(3,2);
	SELECT @product_id = product_id FROM inserted;
	SELECT @rating = ROUND(AVG(CONVERT(DECIMAL(3,2), score)), 2) FROM Reviews WHERE product_id = @product_id;
	UPDATE Products
	SET rating = @rating
	WHERE id = @product_id;
END;
GO

CREATE OR ALTER TRIGGER Update_rating_delete
ON Reviews
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @product_id INT;
	DECLARE @rating DECIMAL(3,2);
	SELECT @product_id = product_id FROM deleted;
	SELECT @rating = ROUND(AVG(CONVERT(DECIMAL(3,2), score)), 2) FROM Reviews WHERE product_id = @product_id;
	UPDATE Products
	SET rating = @rating
	WHERE id = @product_id;
END;
GO

CREATE OR ALTER TRIGGER Insert_employee
ON Employees
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @employee_type CHAR(8);
	DECLARE @employee_id INT;
	SELECT @employee_id = id, @employee_type = type FROM inserted;
	IF @employee_type = 'Fulltime'
	BEGIN
		INSERT INTO Fulltime_employees(id) VALUES(@employee_id);
	END
	ELSE
	BEGIN
		INSERT INTO Parttime_employees(id) VALUES(@employee_id);
	END
END;
GO

CREATE OR ALTER TRIGGER Update_Parttime_hour
ON Register_shifts
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @employee_id INT;
	DECLARE @shift_id INT;
	DECLARE @working_hour INT;
	DECLARE @employee_type CHAR(8);
	SELECT @employee_id = employee_id, @shift_id = shift_id FROM inserted;
	SELECT @employee_type = type FROM Employees WHERE id = @employee_id;
	IF @employee_type = 'Parttime'
	BEGIN
		SELECT @working_hour = DATEDIFF(HOUR, start_time, end_time) FROM Shifts WHERE id = @shift_id;
		UPDATE Parttime_employees
		SET working_hour = working_hour + @working_hour
		WHERE id = @employee_id;
	END
END;
GO

CREATE OR ALTER TRIGGER Update_point_after_exchange
ON Exchange_gifts
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @account_id INT;
	DECLARE @point INT;
	DECLARE @gift_id INT;
	DECLARE @quantity INT;
	SELECT @account_id = i.account_id, @point = G.point * i.quantity, @gift_id = gift_id, @quantity = i.quantity
	FROM inserted i
	INNER JOIN Gifts G
	ON i.gift_id = G.id;
	UPDATE Accounts
	SET point = point - @point
	WHERE id = @account_id;
	UPDATE Gifts
	SET quantity = quantity - @quantity
	WHERE id = @gift_id;
END;
GO

CREATE OR ALTER PROCEDURE Ex_gifts(
	@account_id INT,
	@gift_id INT,
	@quantity INT
)
AS
BEGIN
	DECLARE @account_point INT;
	DECLARE @gift_quantity INT;
	DECLARE @total_ex_point INT;
	SELECT @account_point = point FROM Accounts WHERE id = @account_id;
	SELECT @gift_quantity = quantity, @total_ex_point = @quantity * point FROM Gifts WHERE id = @gift_id;
	IF (@account_point < @total_ex_point OR @quantity > @gift_quantity)
	BEGIN
		PRINT 'You cannot exchange gift!';
		RETURN (1)
	END
	ELSE
	BEGIN
		INSERT INTO Exchange_gifts(account_id, gift_id, quantity,exchange_time)
		VALUES (@account_id,@gift_id,@quantity,GETDATE());
		PRINT 'Gift exchanged successfully!';
		RETURN (0)
	END
END;
GO

CREATE OR ALTER PROCEDURE Available_gift(
	@username VARCHAR(255)
)
AS
BEGIN
	DECLARE @account_point INT;
	SELECT @account_point = point 
	FROM Accounts
	WHERE username = @username;
	SELECT name, quantity, point, image
	FROM Gifts 
	WHERE point <= @account_point AND quantity > 0
	ORDER BY point DESC;
END;
GO

CREATE OR ALTER PROCEDURE Best_seller_by_date(
    @start_date DATETIME,
    @end_date DATETIME
)
AS 
BEGIN
    WITH BestSellers AS (
        SELECT
            p.type,
            p.name AS best_selling_product,
            SUM(od.quantity) AS total_quantity_sold,
            ROW_NUMBER() OVER (PARTITION BY p.type ORDER BY SUM(od.quantity) DESC) AS rn
        FROM
            Products p
            INNER JOIN Order_details od ON p.id = od.product_id
            INNER JOIN Orders o ON od.order_id = o.id
        WHERE
            o.state = 'finished'
            AND o.start_time >= @start_date
            AND o.end_time <= @end_date
        GROUP BY
            p.type,
            p.name
    )
    SELECT
        type,
        best_selling_product,
        total_quantity_sold
    FROM
        BestSellers
    WHERE
        rn = 1;
END;
GO

CREATE OR ALTER FUNCTION Product_classified (
	@productID INT
)
RETURNS VARCHAR(50)
AS 
BEGIN
	DECLARE @classified varchar(10);
	DECLARE @rating int;
	SELECT @rating = rating
	FROM Products
	WHERE id = @productID;
	IF (@rating >= 0 and @rating < 3) 
	BEGIN 
		SET @classified = 'Bad';
	END
	ELSE IF ( @rating >=3 and @rating < 4) 
	BEGIN 
		SET @classified = 'Average';
	END
	ELSE IF ( @rating >=4 and @rating <= 4.5) 
	BEGIN 
		SET @classified = 'Good';
	END
	ELSE IF (@rating > 4.5 AND @rating <=5) 
	BEGIN 
		SET @classified = 'Excellent';
	END
	ELSE
	BEGIN
		SET @classified = 'Not rating';
	END
	RETURN @classified
END;
GO

CREATE OR ALTER FUNCTION CalculateTotalProfitByDate(
	@start_date DATETIME, 
	@end_date DATETIME
)
RETURNS INT
AS 
BEGIN
	DECLARE @total_profit INT;
	DECLARE @current_profit INT;
	DECLARE orders_cursor CURSOR FOR
	SELECT total_cost
	FROM Orders
	WHERE start_time >= @start_date AND end_time <= @end_date AND state = 'finished';
	
	IF @start_date > @end_date 
	BEGIN 
		SET @total_profit = NULL; 
	END
	ELSE
	BEGIN
		SET @total_profit = 0;
		OPEN orders_cursor;
		FETCH NEXT FROM orders_cursor INTO @current_profit;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @total_profit = @total_profit + @current_profit;
			FETCH NEXT FROM orders_cursor INTO @current_profit;
		END
	END
	CLOSE orders_cursor;
	DEALLOCATE orders_cursor;
	RETURN @total_profit
END;
GO
