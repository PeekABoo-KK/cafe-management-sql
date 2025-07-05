/*====================================================================
  Project:      Coffee Shop Management System
  Description:  This SQL script defines the database schema for a small 
                coffee shop's management system. It supports core 
                operations including order processing, employee scheduling,
                customer management, payment tracking, and promotional campaigns.

  Author:       [An Nguyen]
  Created on:   [7/2/2025]
  Database:     Microsoft SQL Server

  Features:
    - Manage menu items (drinks)
    - Track customer information and types
    - Record employee data and shift schedules
    - Handle customer orders and order details
    - Apply and manage various types of promotions
    - Record and process payments
    - Support reporting for sales, customers, and operations
======================================================================*/

CREATE DATABASE CAFE_MANAGEMENT
USE CAFE_MANAGEMENT

/*============================================================
  I. CREATE SCHEMA
  This section defines the core database schema for the Coffee 
  Shop Management System. It includes tables for drinks, 
  customers, employees, orders, payments, shifts, and promotions.
=============================================================*/

---------------------------------------------------------
-- TABLE: DRINK
-- Stores drink menu items with their category and price
---------------------------------------------------------
CREATE TABLE DRINK(
	DrinkID VARCHAR(5) PRIMARY KEY,
	DrinkName VARCHAR(100),
	Price DECIMAL(10,2),
	Category VARCHAR(20)
);


---------------------------------------------------------
-- TABLE: CUSTOMER
-- Stores customer information and classification
---------------------------------------------------------
CREATE TABLE CUSTOMER(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerName VARCHAR(200) NULL,
	Phone VARCHAR(10) NULL,
	Email VARCHAR(100) NULL,
	CustomerType VARCHAR(20) DEFAULT 'Anonymous',
	JoinDate DATE DEFAULT GETDATE()
);


---------------------------------------------------------
-- TABLE: EMPLOYEE
-- Stores employee records
---------------------------------------------------------
CREATE TABLE EMPLOYEE(
	EmployeeID INT PRIMARY KEY,
	FullName VARCHAR(200),
	SsID VARCHAR(20) UNIQUE NOT NULL,
	Birthday DATE,
	Salary DECIMAL(10,2),
	Phone VARCHAR(15),
	Email VARCHAR(100),
);


---------------------------------------------------------
-- TABLE: SHIFT
-- Stores predefined shift patterns
---------------------------------------------------------
CREATE TABLE SHIFT(
	ShiftID VARCHAR(3) PRIMARY KEY,
	Weekday VARCHAR(10),
	StartTime TIME,
	EndTime TIME,
	Status VARCHAR(10)
);


---------------------------------------------------------
-- TABLE: PROMOTION
-- Base promotion details (no conditions)
---------------------------------------------------------
CREATE TABLE PROMOTION(
	PromotionID VARCHAR(5) PRIMARY KEY,
	Description VARCHAR(200),
	Discount DECIMAL(4,2)
);


---------------------------------------------------------
-- TABLE: ORDER
-- Stores orders placed by customers and handled by employees
---------------------------------------------------------
CREATE TABLE [ORDER](
	OrderID VARCHAR(12) PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    PromotionID VARCHAR(5) NULL,
	OrderDate DATE,
	OrderTime TIME,
	TotalValue DECIMAL(10,2),
	MustPaid DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
	FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID),
	FOREIGN KEY (PromotionID) REFERENCES PROMOTION(PromotionID)
);


---------------------------------------------------------
-- TABLE: ORDER_DETAIL
-- Line items for each order, with quantities and notes
---------------------------------------------------------
CREATE TABLE ORDER_DETAIL (
	OrderID VARCHAR(12),
	DrinkID VARCHAR(5),
	Quantity INT,
	Amount DECIMAL(10,2),
	Notes VARCHAR(100),
	PRIMARY KEY (OrderID, DrinkID),
	FOREIGN KEY (OrderID) REFERENCES [ORDER](OrderID),
	FOREIGN KEY (DrinkID) REFERENCES DRINK(DrinkID)
);


---------------------------------------------------------
-- TABLE: PAYMENT
-- Stores how each order was paid
---------------------------------------------------------
CREATE TABLE PAYMENT (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID VARCHAR(12),
    Method VARCHAR(50),
    AmountPaid DECIMAL(10,2),
    Change DECIMAL(10,2),
    PaidAt DATETIME,
    FOREIGN KEY (OrderID) REFERENCES [ORDER](OrderID)
);


---------------------------------------------------------
-- TABLE: EMPLOYEE_SHIFT
-- Maps employees to the shifts they work
---------------------------------------------------------
CREATE TABLE EMPLOYEE_SHIFT (
	EmployeeID INT,
	ShiftID VARCHAR(3),
	PRIMARY KEY (EmployeeID, ShiftID),
	FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID),
	FOREIGN KEY (ShiftID) REFERENCES SHIFT(ShiftID)
);


---------------------------------------------------------
-- TABLE: PROMOTION_DRINK
-- Specifies which drinks are included in specific promotions
---------------------------------------------------------
CREATE TABLE PROMOTION_DRINK (
	PromotionID VARCHAR(5),
	DrinkID VARCHAR(5),
	StartDate DATE,
	EndDate DATE,
	PRIMARY KEY (PromotionID, DrinkID),
	FOREIGN KEY (PromotionID) REFERENCES PROMOTION(PromotionID),
	FOREIGN KEY (DrinkID) REFERENCES DRINK(DrinkID)
);


---------------------------------------------------------
-- TABLE: PROMOTION_CUSTOMER
-- Links promotions to customer types
---------------------------------------------------------
CREATE TABLE PROMOTION_CUSTOMER (
	PromotionID VARCHAR(5),
	CustomerType VARCHAR(20),
	PRIMARY KEY (PromotionID, CustomerType),
	FOREIGN KEY (PromotionID) REFERENCES PROMOTION(PromotionID)
)


---------------------------------------------------------
-- TABLE: PROMOTION_ORDER
-- Defines rules for order-based promotions
---------------------------------------------------------
CREATE TABLE PROMOTION_ORDER (
	PromotionID VARCHAR(5) PRIMARY KEY,
	MinOrderAmount INT NULL,
	MinTotalItems INT NULL,
	StartDate DATE,
	EndDate DATE,
	FOREIGN KEY (PromotionID) REFERENCES PROMOTION(PromotionID)
);




/*============================================================
  II. ADD SIMPLE CONSTRAINTS
  This section applies CHECK constraints and column-level rules 
  to validate data formats, enforce value ranges, and maintain 
  basic logical consistency (e.g., valid phone numbers, 
  price > 0, dates not in the future).
=============================================================*/

--CONSTRAINTS ON DRINK RELATION
-- 1. Check format of DrinkID 
ALTER TABLE DRINK
ADD CONSTRAINT CHK_DrinkID_Format CHECK (DrinkID LIKE 'DR___');

-- 2. Price must be greater than 0
ALTER TABLE DRINK
ADD CONSTRAINT CHK_Drink_Price CHECK (Price > 0);

-- 3. Category must be one of specific values
ALTER TABLE DRINK
ADD CONSTRAINT CHK_Drink_Category CHECK (
    Category IN ('Coffee', 'Tea', 'Juice', 'Smoothie', 'Soda')
);




--CONSTRAINTS ON CUSTOMER RELATION
--1. Phone number must include 10 digits
ALTER TABLE CUSTOMER
ADD CONSTRAINT CHK_Cus_Phone_Num CHECK (Phone IS NULL OR Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

--2. CustomerType must be one of specific values
ALTER TABLE CUSTOMER
ADD CONSTRAINT CHK_Customer_Type CHECK (CustomerType IN ('Anonymous', 'Regular', 'Silver', 'Gold'));

--3. JoinDate must not be in the future
ALTER TABLE CUSTOMER
ADD CONSTRAINT CHK_Join_Date CHECK (JoinDate <= GETDATE());




--CONSTRAINTS ON EMPLOYEE RELATION 
--1. Phone number must include 10 digits
ALTER TABLE EMPLOYEE
ADD CONSTRAINT CHK_Emp_Phone_Num CHECK (Phone IS NULL OR Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

--2. The age must be equal or greater than 18
ALTER TABLE EMPLOYEE
ADD CONSTRAINT CHK_Emp_Enough_18 CHECK (DATEDIFF(DAY, Birthday, GETDATE()) >= 6570);

--3. Salary must not be negative
ALTER TABLE EMPLOYEE
ADD CONSTRAINT CHK_Emp_Salary CHECK (Salary > 0);

--4. SsID must has 12 digits
ALTER TABLE EMPLOYEE
ADD CONSTRAINT CHK_Emp_SsID_Format CHECK (SsID LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');




--CONSTRAINTS ON SHIFT RELATION 
--1. Check ShiftID's format
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_ShiftID_Format CHECK (ShiftID LIKE '[A-Z][A-Z][1-3]');

--2. Weekday must be in the specific values
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_Valid_Weekday CHECK (Weekday IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 
													'Friday', 'Saturday', 'Sunday'));

--3. The first shift of each day starts at 7:00 and ends at 12:00
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_Valid_1st_Shift CHECK 
((ShiftID LIKE '[A-Z][A-Z]1') AND StartTime = '7:00:00' AND EndTime = '12:00:00');

--4. The second shift of each day starts at 12:00 and ends at 17:00
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_Valid_2nd_Shift CHECK 
((ShiftID LIKE '[A-Z][A-Z]2') AND StartTime = '12:00:00' AND EndTime = '17:00:00');

--5. The third shift of each day starts at 17:00 and ends at 22:00
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_Valid_3rd_Shift CHECK
((ShiftID LIKE '[A-Z][A-Z]3') AND StartTime = '17:00:00' AND EndTime = '22:00:00');


--6. Status of a shift must be in predifined values
ALTER TABLE SHIFT
ADD CONSTRAINT CHK_Valid_Status CHECK (Status IN ('Missing', 'Enough', 'Over'));




--CONSTRAINTS ON PROMOTION RELATION
--1. Check format of promotionID
ALTER TABLE PROMOTION
ADD CONSTRAINT CHK_PromotionID_Format CHECK ((PromotionID LIKE 'D[0-9][0-9][0-9]')
										  OR (PromotionID LIKE 'C[0-9][0-9][0-9]')
										  OR (PromotionID LIKE 'O[0-9][0-9][0-9]'));

--2. Discount must greater than 0 and lesser than 40%
ALTER TABLE PROMOTION
ADD CONSTRAINT CHK_Promotion_Discount CHECK (Discount > 0.00 AND Discount < 0.40);




--CONSTRAINTS ON PAYMENT RELATION
-- 1. AmountPaid must be greater than or equal to 0
ALTER TABLE PAYMENT
ADD CONSTRAINT CHK_Payment_Amount_Positive CHECK (AmountPaid >= 0.00);

-- 2. Change must be greater than or equal to 0
ALTER TABLE PAYMENT
ADD CONSTRAINT CHK_Payment_Change_Positive CHECK (Change >= 0.00);

-- 4. PaidAt (payment timestamp) must not be in the future
ALTER TABLE PAYMENT
ADD CONSTRAINT CHK_Payment_Timestamp CHECK (PaidAt <= GETDATE());

-- 5. Method must be one of predefined values
ALTER TABLE PAYMENT
ADD CONSTRAINT CHK_Payment_Method CHECK (Method IN ('Cash', 'Credit Card', 'Mobile Payment', 'Bank Transfer'));




--CONSTRAINTS ON ORDER RELATION
-- 1. TotalValue must greater than 0
ALTER TABLE [ORDER]
ADD CONSTRAINT CHK_Order_Total_Positive CHECK(TotalValue > 0.00);


-- 2. OrderDate must not be in the future
ALTER TABLE [ORDER]
ADD CONSTRAINT CHK_Order_Date_Valid CHECK (OrderDate <= GETDATE());

-- 3. OrderTime must be between 07:00 and 22:00 (business hours)
ALTER TABLE [ORDER]
ADD CONSTRAINT CHK_Order_Business_Hours CHECK (OrderTime >= '07:00:00' AND OrderTime <= '22:00:00');

--4. Check OrderID format
ALTER TABLE [ORDER]
ADD CONSTRAINT CHK_OrderID_Format CHECK (OrderID LIKE 'ORD%');




--CONSTRAINTS ON  PROMOTION_DRINK RELATION
-- 1. StartDate must not  be after EndDate
ALTER TABLE PROMOTION_DRINK
ADD CONSTRAINT CHK_PromoDrink_DateRange CHECK (StartDate <= EndDate);




--CONSTRAINTS ON PROMOTION_ORDER RELATION
--1. MinOrderAmount must greater than 0 if there is any 
ALTER TABLE PROMOTION_ORDER
ADD CONSTRAINT CHK_PromoOrder_MinAmount CHECK (MinOrderAmount IS NULL OR MinOrderAmount > 0.00);

--2. MinOrderItems must greater than 0 if there is any 
ALTER TABLE PROMOTION_ORDER
ADD CONSTRAINT CHK_PromoOrder_MinItems CHECK (MinTotalItems IS NULL OR MinTotalItems > 0);

--3. StartDate must not be after EndDate
ALTER TABLE PROMOTION_ORDER
ADD CONSTRAINT CHK_PromoOrder_DateRange CHECK (StartDate <= EndDate);





