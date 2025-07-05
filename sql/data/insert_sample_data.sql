/*============================================================
  IV. INSERT SAMPLE DATA
  This section provides sample data for key tables to simulate 
  a realistic working environment. The inserted records allow 
  for testing queries, verifying constraints, and demonstrating 
  business logic such as promotions, staffing, and payments.
=============================================================*/

--1. Insert sample data into DRINK (30 items)
INSERT INTO DRINK (DrinkID, DrinkName, Price, Category) VALUES
('DR001', 'Espresso', 30000, 'Coffee'),
('DR002', 'Americano', 28000, 'Coffee'),
('DR003', 'Cappuccino', 35000, 'Coffee'),
('DR004', 'Latte', 35000, 'Coffee'),
('DR005', 'Mocha', 38000, 'Coffee'),
('DR006', 'Caramel Macchiato', 40000, 'Coffee'),
('DR007', 'Jasmine Green Tea', 25000, 'Tea'),
('DR008', 'Black Milk Tea', 27000, 'Tea'),
('DR009', 'Matcha Latte', 32000, 'Tea'),
('DR010', 'Oolong Tea', 26000, 'Tea'),
('DR011', 'Thai Milk Tea', 29000, 'Tea'),
('DR012', 'Peach Tea', 25000, 'Tea'),
('DR013', 'Orange Juice', 28000, 'Juice'),
('DR014', 'Lemon Juice', 27000, 'Juice'),
('DR015', 'Watermelon Juice', 30000, 'Juice'),
('DR016', 'Pineapple Juice', 28000, 'Juice'),
('DR017', 'Apple Juice', 26000, 'Juice'),
('DR018', 'Carrot Juice', 25000, 'Juice'),
('DR019', 'Strawberry Smoothie', 35000, 'Smoothie'),
('DR020', 'Mango Smoothie', 36000, 'Smoothie'),
('DR021', 'Blueberry Smoothie', 37000, 'Smoothie'),
('DR022', 'Avocado Smoothie', 40000, 'Smoothie'),
('DR023', 'Chocolate Smoothie', 38000, 'Smoothie'),
('DR024', 'Banana Smoothie', 35000, 'Smoothie'),
('DR025', 'Lime Soda', 25000, 'Soda'),
('DR026', 'Blue Ocean Soda', 26000, 'Soda'),
('DR027', 'Strawberry Soda', 27000, 'Soda'),
('DR028', 'Passionfruit Soda', 28000, 'Soda'),
('DR029', 'Kiwi Soda', 26000, 'Soda'),
('DR030', 'Cola Lemon Soda', 25000, 'Soda');



--2. Use WHILE LOOP to generate 500 records of customers
DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    DECLARE @Name NVARCHAR(100) = CONCAT('Customer_', @i);
    DECLARE @Phone VARCHAR(10) = RIGHT('0' + CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR), 10);
    DECLARE @Email VARCHAR(100) = CONCAT('customer', @i, '@mail.com');
    DECLARE @Type VARCHAR(20) = 
        CASE 
            WHEN @i % 15 = 0 THEN 'Gold'
            WHEN @i % 5 = 0 THEN 'Silver'
            WHEN @i % 3 = 0 THEN 'Regular'
            ELSE 'Anonymous'
        END;
    DECLARE @JoinDate DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 730, GETDATE()); -- trong vòng 2 năm trở lại

    INSERT INTO CUSTOMER (CustomerName, Phone, Email, CustomerType, JoinDate)
    VALUES (@Name, @Phone, @Email, @Type, @JoinDate);

    SET @i = @i + 1;
END;



--3. Use WHILE LOOP to generate 2500 records of orders
DECLARE @i INT = 1;
WHILE @i <= 2500
BEGIN
    DECLARE @OrderID VARCHAR(12) = FORMAT(@i, 'O00000');
    DECLARE @CustomerID INT = ABS(CHECKSUM(NEWID())) % 500 + 1;
    DECLARE @EmployeeID INT = ABS(CHECKSUM(NEWID())) % 8 + 1;
    DECLARE @PromoID VARCHAR(5) = 
        CASE WHEN @i % 5 = 0 THEN CONCAT('O00', CAST((@i % 6) + 1 AS VARCHAR)) ELSE NULL END;
    DECLARE @OrderDate DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 180, GETDATE());
    DECLARE @OrderTime TIME = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 900, '07:00');
    DECLARE @TotalValue DECIMAL(10,2) = (ABS(CHECKSUM(NEWID())) % 200000 + 30000);
    DECLARE @Discount DECIMAL(4,2) = CASE WHEN @PromoID IS NOT NULL THEN 0.1 ELSE 0 END;
    DECLARE @MustPaid DECIMAL(10,2) = @TotalValue * (1 - @Discount);

    INSERT INTO [ORDER] (OrderID, CustomerID, EmployeeID, PromotionID, OrderDate, OrderTime, TotalValue, MustPaid)
    VALUES (@OrderID, @CustomerID, @EmployeeID, @PromoID, @OrderDate, @OrderTime, @TotalValue, @MustPaid);

    SET @i += 1;
END;



--4. Use WHILE LOOP to generate 5000 records of orders' details
DECLARE @i INT = 1;
DECLARE @OrderIndex INT = 1;
WHILE @i <= 5000
BEGIN
    DECLARE @OrderID VARCHAR(12) = FORMAT(@OrderIndex, 'O00000');
    DECLARE @DrinkID VARCHAR(5) = CONCAT('D', RIGHT('00' + CAST(ABS(CHECKSUM(NEWID())) % 30 + 1 AS VARCHAR), 3));
    DECLARE @Qty INT = ABS(CHECKSUM(NEWID())) % 5 + 1;
    DECLARE @Price INT = ABS(CHECKSUM(NEWID())) % 50000 + 15000;
    DECLARE @Amount INT = @Qty * @Price;
    DECLARE @Notes NVARCHAR(100) = 
        CASE (@i % 4)
            WHEN 0 THEN N'No sugar'
            WHEN 1 THEN N'Less ice'
            WHEN 2 THEN N'Extra shot'
            ELSE N''
        END;

    INSERT INTO ORDER_DETAIL (OrderID, DrinkID, Quantity, Amount, Notes)
    VALUES (@OrderID, @DrinkID, @Qty, @Amount, @Notes);

    IF @i % 2 = 0 SET @OrderIndex += 1;
    SET @i += 1;
END;



--5. Use WHILE LOOP to generate 2500 records of payments.
DECLARE @i INT = 1;
WHILE @i <= 2500
BEGIN
    DECLARE @OrderID VARCHAR(12) = FORMAT(@i, 'O00000');
    DECLARE @Method VARCHAR(10) = 
        CASE (@i % 4)
            WHEN 0 THEN 'Cash'
            WHEN 1 THEN 'Momo'
            WHEN 2 THEN 'Visa'
            ELSE 'ZaloPay'
        END;
    DECLARE @MustPaid DECIMAL(10,2) = (SELECT MustPaid FROM [ORDER] WHERE OrderID = @OrderID);
    DECLARE @AmountPaid DECIMAL(10,2) = @MustPaid + (ABS(CHECKSUM(NEWID())) % 20000);
    DECLARE @Change DECIMAL(10,2) = @AmountPaid - @MustPaid;
    DECLARE @PaidAt DATETIME = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 180, GETDATE());

    INSERT INTO PAYMENT (OrderID, Method, AmountPaid, Change, PaidAt)
    VALUES (@OrderID, @Method, @AmountPaid, @Change, @PaidAt);

    SET @i += 1;
END;



--6. Insert sample data into EMPLOYEE (8 employees)
INSERT INTO EMPLOYEE (EmployeeID, FullName, SsID, Birthday, Salary, Phone, Email) VALUES
(1, 'Nguyen Van An', '1234567890', '2000-01-10', 5000000, '0901234567', 'a.nguyen@coffee.com'),
(2, 'Tran Bich Thu', '2345678901', '1998-07-22', 6000000, '0902345678', 'b.tran@coffee.com'),
(3, 'Le Trong Chinh', '3456789012', '2002-05-15', 85000000, '0903456789', 'c.le@coffee.com'),
(4, 'Pham Thi Diep', '4567890123', '2005-12-30', 4900000, '0904567890', 'd.pham@coffee.com'),
(5, 'Hoang Anh Minh', '5678901234', '1999-08-09', 7000000, '0905678901', 'e.hoang@coffee.com'),
(6, 'Vu Thi Nhu Y', '6789012345', '2001-03-18', 5890000, '0906789012', 'f.vu@coffee.com'),
(7, 'Do Trong Hop', '7890123456', '2004-11-25', 6170000, '0907890123', 'g.do@coffee.com'),
(8, 'Bui Huong Thuy', '8901234567', '2003-06-14', 8800000, '0908901234', 'h.bui@coffee.com');



-- 7. Insert sample data into SHIFT (21 shifts: 7 days * 3 shifts)
INSERT INTO SHIFT (ShiftID, Weekday, StartTime, EndTime, Status) VALUES
('MO1', 'Monday', '07:00:00', '12:00:00', 'Enough'),
('MO2', 'Monday', '12:00:00', '17:00:00', 'Enough'),
('MO3', 'Monday', '17:00:00', '22:00:00', 'Enough'),
('TU1', 'Tuesday', '07:00:00', '12:00:00', 'Enough'),
('TU2', 'Tuesday', '12:00:00', '17:00:00', 'Enough'),
('TU3', 'Tuesday', '17:00:00', '22:00:00', 'Enough'),
('WE1', 'Wednesday', '07:00:00', '12:00:00', 'Enough'),
('WE2', 'Wednesday', '12:00:00', '17:00:00', 'Enough'),
('WE3', 'Wednesday', '17:00:00', '22:00:00', 'Enough'),
('TH1', 'Thursday', '07:00:00', '12:00:00', 'Enough'),
('TH2', 'Thursday', '12:00:00', '17:00:00', 'Enough'),
('TH3', 'Thursday', '17:00:00', '22:00:00', 'Enough'),
('FR1', 'Friday', '07:00:00', '12:00:00', 'Enough'),
('FR2', 'Friday', '12:00:00', '17:00:00', 'Enough'),
('FR3', 'Friday', '17:00:00', '22:00:00', 'Enough'),
('SA1', 'Saturday', '07:00:00', '12:00:00', 'Enough'),
('SA2', 'Saturday', '12:00:00', '17:00:00', 'Enough'),
('SA3', 'Saturday', '17:00:00', '22:00:00', 'Enough'),
('SU1', 'Sunday', '07:00:00', '12:00:00', 'Enough'),
('SU2', 'Sunday', '12:00:00', '17:00:00', 'Enough'),
('SU3', 'Sunday', '17:00:00', '22:00:00', 'Enough');



--8. Insert sample data into PROMOTION (13 promotions: order-based, customer-based, drink-based)
('O001', 'Order discount over 100k', 0.10),
('O002', 'Order discount over 200k', 0.15),
('O003', 'Order discount for >5 items', 0.12),
('C001', 'Silver customer discount', 0.10),
('C002', 'Gold customer discount', 0.15),
('C003', 'Loyalty promo for regulars', 0.08),
('D001', '50% off Mango Smoothie', 0.50),
('D002', '30% off all Sodas', 0.30),
('D003', '20% off Tea menu', 0.20),
('O004', 'Morning combo discount', 0.10),
('O005', 'Happy hour discount', 0.12),
('D004', 'Buy 1 get 1 Smoothie', 0.40),
('O006', 'Late night orders discount', 0.15);



--9. Insert sample data into PROMOTION_ORDER: Promotions by order amount/time/item count
INSERT INTO PROMOTION_ORDER (PromotionID, MinOrderAmount, MinTotalItems, StartDate, EndDate, StartHour, EndHour) VALUES
('O001', 100000, NULL, '2025-07-01', '2025-12-31', NULL, NULL),
('O002', 200000, NULL, '2025-07-01', '2025-12-31', NULL, NULL),
('O003', NULL, 5, '2025-07-01', '2025-12-31', NULL, NULL),
('O004', NULL, NULL, '2025-07-01', '2025-12-31', '07:00:00', '11:00:00'),
('O005', NULL, NULL, '2025-07-01', '2025-12-31', '14:00:00', '17:00:00'),
('O006', NULL, NULL, '2025-07-01', '2025-12-31', '20:00:00', '22:00:00');



--10. Insert sample data into PROMOTION_CUSTOMER: Promotions by customer type
INSERT INTO PROMOTION_CUSTOMER (PromotionID, CustomerType) VALUES
('C001', 'Silver'),
('C002', 'Gold'),
('C003', 'Regular');



--11. Insert sample data into PROMOTION_DRINK
INSERT INTO PROMOTION_DRINK (PromotionID, DrinkID, StartDate, EndDate) VALUES
('D001', 'D020', '2025-07-01', '2025-07-31'),
('D002', 'D025', '2025-07-01', '2025-08-15'),
('D002', 'D026', '2025-07-01', '2025-08-15'),
('D002', 'D027', '2025-07-01', '2025-08-15'),
('D003', 'D007', '2025-07-01', '2025-09-01'), 
('D003', 'D008', '2025-07-01', '2025-09-01'),
('D004', 'D019', '2025-07-01', '2025-08-31'),
('D004', 'D024', '2025-07-01', '2025-08-31');