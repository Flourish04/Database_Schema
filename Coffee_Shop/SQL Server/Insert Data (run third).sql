USE TEST_BTL17;
SET DATEFORMAT dmy;
GO

-- INSERT DATA INTO Departments
INSERT INTO Departments
SELECT N'Tây Nguyên 1', 'taynguyen1@gmail.com', '0929331124',N'KTX khu A', BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO

INSERT INTO Departments
SELECT N'Tây Nguyên 2', 'taynguyen2@gmail.com', '1111111111',N'KTX khu B', BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature2.png', Single_Blob) as Employee;
GO

INSERT INTO Departments
SELECT N'Tây Nguyên 3', 'taynguyen3@gmail.com', '0927831124',N'KTX khu B', BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO

-- INSERT DATA INTO Employees
ALTER TABLE Employees NOCHECK CONSTRAINT ALL; 
GO
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Nguyễn', N'Văn', '15-02-2000', 'male', '123456789011', 'nguyen.van@example.com', '2023-01-01', N'Thủ Đức', 'Manager', 'Fulltime', NULL, 1);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Trần Thị', N'Thu', '10-05-2001', 'female', '098765432111', 'tran.thithu@example.com', '2023-01-15', N'Hồ Chí Minh', 'Staff', 'Parttime', 1, 1);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Lê', N'Minh', '20-11-2002', 'male', '567890123411', 'le.minh@example.com', '2023-02-01', N'Bình Dương', 'Driver', 'Parttime', 2, 1);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Phạm Thị', N'Hương', '15-07-2003', 'female', '432109876511', 'pham.thihong@example.com', '2023-02-15', N'Thủ Đức', 'Staff', 'Fulltime', 2, 1);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Hoàng', N'Văn', '12-03-2000', 'male', '135792468011', 'hoang.van@example.com', '2023-03-01', N'Hồ Chí Minh', 'Manager', 'Fulltime', NULL, 2);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Vũ Thị', N'Hương', '25-06-2001', 'female', '864209753111', 'vu.thihuong@example.com', '2023-03-15', N'Thủ Đức', 'Staff', 'Parttime', 5, 2);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Đặng', N'Minh', '05-09-2002', 'male', '246801357911', 'dang.minh@example.com', '2023-04-01', N'Bình Dương', 'Driver', 'Fulltime', 6, 2);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Bùi Thị', N'Mai', '18-12-2003', 'female', '975310864211', 'bui.thimai@example.com', '2023-04-15', N'Hồ Chí Minh', 'Staff', 'Parttime', 6, 2);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Ngô Thị', N'Trang', '20-08-2000', 'female', '012345678911', 'ngo.thitrang@example.com', '2023-05-01',N'Hồ Chí Minh',  'Manager', 'Fulltime', NULL, 3);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Hồ', N'Văn', '05-01-2001', 'male', '987654321011', 'ho.van@example.com', '2023-05-15',N'Thủ Đức', 'Staff', 'Parttime', 10, 3);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Trương Thị', N'Anh', '10-06-2002', 'female', '543210987611', 'truong.thianh@example.com', '2023-06-01', N'Bình Dương', 'Staff', 'Fulltime', 11, 3);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Lý', N'Minh', '25-09-2003', 'male', '678905432111', 'ly.minh@example.com', '2023-06-15', N'Thủ Đức', 'Driver', 'Parttime', 11, 3);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Đỗ', N'Văn', '12-04-2000', 'male', '321098765411', 'do.van@example.com', '2023-07-01', N'Hồ Chí Minh', 'Manager', 'Fulltime', NULL, 4);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Nguyễn Thị', N'Hằng', '25-07-2001', 'female', '765432109811', 'nguyen.thihang@example.com', '2023-07-15', N'Thủ Đức', 'Staff', 'Parttime', 14, 4);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Lê', N'Minh', '05-10-2002', 'male', '210987654311', 'le.minh@example.com', '2023-08-01', N'Bình Dương', 'Driver', 'Fulltime', 15, 4);
INSERT INTO Employees(last_name, first_name, birthday, gender, cccd, email, start_date, location, position, type, super_id, department_id)  
VALUES (N'Phạm Thị', N'Hương', '18-01-2003', 'female', '654321098711', 'pham.thihuong@example.com', '2023-08-15', N'Hồ Chí Minh', 'Staff', 'Parttime', 15, 4);
GO
ALTER TABLE Employees CHECK CONSTRAINT ALL; 
GO

-- INSERT DATA INTO Employee_phones
INSERT INTO Employee_phones
VALUES
(1,'2109876543'),
(1,'6543210987'),
(2,'7654321098'),
(2,'1098765411'),
(3,'4321098711'),
(3,'680135791');
GO

-- INSERT DATA INTO Drivers
INSERT INTO Drivers(id, license)
VALUES 
(3,'056809210000'),
(7,'492315730000'),
(12,'721899480000'),
(15,'183472590000');
GO

-- INSERT DATA INTO Shifts
INSERT INTO Shifts(date, start_time, end_time)
VALUES
('29-04-2024','6:30','9:30'),
('29-04-2024','10:00','13:00'),
('29-04-2024','13:30','16:30'),
('29-04-2024','17:00','20:00'),
('29-04-2024','20:30','22:30'),
('30-04-2024','6:30','9:30'),
('30-04-2024','10:00','13:00'),
('30-04-2024','13:30','16:30'),
('30-04-2024','17:00','20:00'),
('30-04-2024','20:30','22:30'),
('01-05-2024','6:30','9:30'),
('01-05-2024','10:00','13:00'),
('01-05-2024','13:30','16:30'),
('01-05-2024','17:00','20:00'),
('01-05-2024','20:30','22:30');
GO

-- INSERT INTO Register_shifts
INSERT INTO Register_shifts
VALUES (1,1);
INSERT INTO Register_shifts
VALUES (1,2);
INSERT INTO Register_shifts
VALUES (3,1);
INSERT INTO Register_shifts
VALUES (3,3);
INSERT INTO Register_shifts
VALUES (6,5);
INSERT INTO Register_shifts
VALUES (6,7);
INSERT INTO Register_shifts
VALUES (8,9);
INSERT INTO Register_shifts
VALUES (8,10);
INSERT INTO Register_shifts
VALUES (10,11);
INSERT INTO Register_shifts
VALUES (12,7);
INSERT INTO Register_shifts
VALUES (14,6);
INSERT INTO Register_shifts
VALUES (16,1);
GO

-- INSERT DATA INTO Tables
INSERT INTO Tables(id, department_id, chair_number, note)
VALUES 
(1,1,1,N'Bàn có ghế ngồi cao'),
(2,1,2,NULL),
(3,1,3,N'Bàn ngoài trời'),
(4,1,4,N'Bàn dành cho gia đình'),
(1,2,1,N'Bàn có ghê ngồi thấp'),
(2,2,2,N'Bàn có ổ điện'),
(3,2,3,NULL),
(4,2,4,N'Bàn đôi'),
(1,3,1,N'Bàn có ghế ngồi cao'),
(2,3,2,N'Bàn chữ nhật'),
(3,3,3,N'Bàn tròn'),
(4,3,4,NULL);
GO

-- INSERT DATA INTO Accounts
SET IDENTITY_INSERT Accounts ON; 
GO
INSERT INTO Accounts(id,username, password, display_name) VALUES
		(0,'Anonymous','123456','Anonymous'); 
GO
SET IDENTITY_INSERT Accounts OFF; 
GO
INSERT INTO Accounts(username, password, display_name,role)
VALUES ('Admin','123456','Admin','admin');
GO
EXEC Add_account 'Hung','123456', N'Lương Hưng';
GO
EXEC Add_account 'Nguyen','123456', N'Khôi Nguyên';
GO
EXEC Add_account 'Thai','123456', N'Tài Thái';
GO
EXEC Add_account 'Hiep','123456', N'Tường Hiệp';
GO
EXEC Add_account 'Loc','123456', N'Xuân Lộc';
GO

-- INSERT DATA INTO Customers
SET IDENTITY_INSERT Customers ON; 
GO
INSERT INTO Customers(id,account_id, last_name, first_name, gender, locations, phone_number) 
VALUES
(0,0,'Anonymous','Anonymous','male',NULL,NULL); 
GO
SET IDENTITY_INSERT Customers OFF; 
GO

INSERT INTO Customers(account_id, last_name, first_name, gender, locations, phone_number) 
VALUES
(1,N'Admin',N'Admin','male',NULL,NULL),
(2,N'Lương',N'Hưng','male',N'Bách khoa','0000000000'),
(3,N'Khôi',N'Nguyên','male',N'Bách khoa','0000000001'),
(4,N'Tài',N'Thái','male',N'Bách khoa','0000000002'),
(5,N'Tường',N'Hiệp','male',N'Bách khoa','0000000003'),
(6,N'Xuân',N'Lộc','male',N'Bách khoa', '0000000004');
GO

-- INSERT DATA INTO Gifts
INSERT INTO Gifts
SELECT N'Cà phê Tây Nguyên1 500g', 10, 25000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Gifts
SELECT N'Cà phê Tây Nguyên2 500g', 8, 50000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Gifts
SELECT N'Cà phê Tây Nguyên3 500g', 6, 75000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Gifts
SELECT N'Cà phê Tây Nguyên4 500g', 4, 100000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Gifts
SELECT N'Cà phê Tây Nguyên5 500g', 3, 125000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Gifts
SELECT N'Ly Tây Nguyên giữ nhiệt', 2, 150000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO

-- INSERT DATA INTO Products
INSERT INTO Products(name,type,list_price,image)
SELECT N'Cà phê đá', N'Cà phê', 15000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Cà phê sữa', N'Cà phê', 25000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Trà đào', N'Trà', 25000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Trà vải', N'Trà', 25000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Trà chanh giã tay', N'Trà', 20000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Trà sữa truyền thống', N'Trà sữa', 25000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO
INSERT INTO Products(name,type,list_price,image)
SELECT N'Trà sữa ô long', N'Trà sữa', 30000, BulkColumn
FROM Openrowset(Bulk 'C:\Users\PLH\OneDrive\Pictures\PHP docs\Test_feature.png', Single_Blob) as Employee;
GO

-- INSERT DATA INTO Transportations
INSERT INTO Transportations
VALUES
('ABC12345','Future','Yellow'),
('ABC62545','Air Blade','Blue'),
('XYZ12235','SH','Red'),
('ABY13345','SYM','Yellow'),
('ABC33333','Cub','Green');
GO

-- INSERT DATA INTO Vouchers
INSERT INTO Vouchers(discount, start_time, end_time, min_value, max_discount, type,quantity,customer_id)
VALUES
(0.25,'30-04-2024 5:00','01-05-2024 23:00', 100000, 100000,N'giảm theo đơn hàng',2,2),
(0.50,'30-04-2024 5:00','01-05-2024 23:00', 100000, 200000,N'giảm theo đơn hàng',2,3),
(0.30,'30-04-2024 5:00','01-05-2024 23:00', 100000, 100000,N'giảm theo đơn hàng',2,4),
(0.20,'30-04-2024 5:00','01-05-2024 23:00', 100000, 300000,N'giảm theo đơn hàng',2,5),
(0.75,'30-04-2024 5:00','01-05-2024 23:00', 500000, 500000,N'giảm theo đơn hàng',2,6);
GO

-- INSERT DATA INTO Orders
INSERT INTO Orders(start_time,employee_id,type)
VALUES
(GETDATE(),1,'online'),
(GETDATE(),2,'offline'),
(GETDATE(),3,'online'),
(GETDATE(),4,'offline'),
(GETDATE(),5,'online'),
(GETDATE(),1,'online');
GO

-- INSERT DATA INTO Offline_orders
INSERT INTO Offline_orders(id, table_id, department_id, customer_id, request)
VALUES
(2,1,1,2,N'Mượn gạc tàn thuốc'),
(4,3,1,3,N'Trang trí thêm hoa');
GO

-- INSERT DATA INTO Online_orders
INSERT INTO Online_orders(id, delivery_address, delivery_charges, account_id)
VALUES 
(1,N'KTX khu A',10000,4),
(3,N'KTX khu B',15000,5),
(5,N'BCON Miền Đông',2000,6),
(6,N'KTX khu A',10000,2);
GO

-- INSERT DATA INTO Order_details
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (1,1,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (1,2,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (1,3,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (1,4,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (2,1,2);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (2,2,2);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (2,3,2);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (2,4,2);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (3,1,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (3,2,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (3,3,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (3,4,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (4,1,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (4,2,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (4,3,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (4,4,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (5,1,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (5,2,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (5,3,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (5,4,1);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (6,2,10);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (6,5,10);
GO
INSERT INTO Order_details(order_id, product_id, quantity)
VALUES (6,7,10);
GO

-- INSERT DATA INTO Reviews
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,1,N'Rất ngon',5);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,2,N'Sản phẩm hơi ít topping',4);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,3,NULL,3);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,4,NULL,2);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,5,N'Quá dở',1);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (1,6,N'Không thể chấp nhận được',0);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,1,N'Rất ngon',5);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,3,N'Sản phẩm hơi ít topping',4);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,4,NULL,3);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,2,NULL,2);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,6,N'Quá dở',1);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (2,5,N'Không thể chấp nhận được',0);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,6,N'Rất ngon',5);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,1,N'Sản phẩm hơi ít topping',4);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,5,NULL,3);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,3,NULL,2);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,4,N'Quá dở',1);
GO
INSERT INTO Reviews(customer_id, product_id, comment, score)
VALUES (3,2,N'Không thể chấp nhận được',0);
GO
SELECT * FROM Products;
-- INSERT DATA INTO Delivery
INSERT INTO Delivery(driver_id, order_id, license_plate, delivery_time)
VALUES
(3,1,'ABC12345','1:00'),
(15,3,'ABC33333','1:30'),
(7,5,'ABC62545','0:30'),
(12,6,'XYZ12235','1:00');
GO

-- INSERT DATA INTO Redeem_vouchers
INSERT INTO Redeem_vouchers(order_id, voucher_id)
VALUES (1,1);
GO
INSERT INTO Redeem_vouchers(order_id, voucher_id)
VALUES (2,2);
GO
INSERT INTO Redeem_vouchers(order_id, voucher_id)
VALUES (3,3);
GO
INSERT INTO Redeem_vouchers(order_id, voucher_id)
VALUES (4,4);
GO
INSERT INTO Redeem_vouchers(order_id, voucher_id)
VALUES (5,5);
GO

