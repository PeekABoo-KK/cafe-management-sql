/*============================================================
  III. ADD TRIGGERS / APP LOGIC / STORED PROCEDURES
  This section handles advanced business rules that cannot be 
  enforced by simple constraints. These include customer type 
  upgrades, order total calculations, promotion application, 
  and shift staffing evaluations — implemented via triggers 
  or external application logic.
=============================================================*/



--1. When a customer gives their information “Name and Phone, (Email)” for the first time, CustomerType is updated to “Regular”.
CREATE TRIGGER TRG_UpdateCusTypeToReg 
ON CUSTOMER 
AFTER INSERT 
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE C
	SET C.CustomerType = 'Regular'
	FROM CUSTOMER C
	JOIN inserted i ON C.CustomerID = i.CustomerID
	WHERE
		i.CustomerName IS NOT NULL
		AND i.Phone IS NOT NULL

END;

--2. When the number of orders of 1 customer is greater than 12, CustomerType is updated to Silver
CREATE TRIGGER TRG_UpdateCusTypeToSilver 
ON [ORDER]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON

	UPDATE C
	SET C.CustomerType = 'Silver'
	FROM CUSTOMER C
	WHERE C.CustomerType <> 'Silver'
		AND(
			SELECT COUNT(*)
			FROM [ORDER] O
			WHERE O.CustomerID = C.CustomerID
		) >= 13;
END;


--3. When the number of orders of 1 customer is greater than 20, CustomerType is updated to Gold
CREATE TRIGGER TRG_UpdateCusTypeToGold 
ON [ORDER]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON

	UPDATE C
	SET C.CustomerType = 'Gold'
	FROM CUSTOMER C
	WHERE C.CustomerType <> 'Gold'
		AND(
			SELECT COUNT(*)
			FROM [ORDER] O
			WHERE O.CustomerID = C.CustomerID
		) > 20
END;


--4.If the number of employees in one shift is lesser than 2, Status updated to “Missing”
--  If the number of employees in one shift is greater than 5, Status updated to “Over”
-- ELse, Status is updated to "Enough"

CREATE TRIGGER TRG_Update_Missing_Shift 
ON EMPLOYEE_SHIFT
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
	SET NOCOUNT ON;

	-- Identify affected ShiftIDs
	DECLARE @AffectedShifts TABLE (ShiftID VARCHAR(5));

	INSERT INTO @AffectedShifts(ShiftID)
	SELECT DISTINCT ShiftID FROM inserted
	UNION 
	SELECT DISTINCT ShiftID FROM deleted;

	-- For each affected shift, recalculate status
	UPDATE S
	SET S.Status = 
		CASE
			WHEN ES.EmpCount < 2 THEN 'Missing'
			WHEN ES.EmpCount > 5 THEN 'Over'
			WHEN ES.EmpCount BETWEEN 2 AND 5 THEN 'Enough'
		END
	FROM [SHIFT] S
	JOIN @AffectedShifts A ON A.ShiftID = S.ShiftID
	JOIN (
		SELECT ShiftID, COUNT(*) AS EmpCount
		FROM EMPLOYEE_SHIFT
		GROUP BY ShiftID
	) ES ON ES.ShiftID = S.ShiftID

	PRINT 'Shift statuses updated based on employee count.'
END;



--5. Automatically insert the amount of each line in ORDER_DETAIL must equal to the Price of the drink x Quantity
CREATE TRIGGER TRG_Amount_Each_Item 
ON ORDER_DETAIL
INSTEAD OF INSERT
AS 
BEGIN
	INSERT INTO ORDER_DETAIL(OrderID, DrinkID, Quantity, Amount, Notes)
	SELECT
		i.OrderID,
		i.DrinkID, 
		i.Quantity,
		D.Price * i.Quantity,
		i.Notes
	FROM inserted i
	JOIN DRINK D ON D.DrinkID = i.DrinkID
END; 


--6. Automatically insert Total Value of an order must equal the sum of each line amount in ORDER_DETAIL
CREATE TRIGGER TRG_Update_TotalValue
ON ORDER_DETAIL
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedOrders TABLE (OrderID VARCHAR(12));

    INSERT INTO @AffectedOrders(OrderID)
    SELECT DISTINCT OrderID FROM inserted
    UNION
    SELECT DISTINCT OrderID FROM deleted;

	UPDATE O
	SET O.TotalValue = (
		SELECT SUM(Amount)
		FROM ORDER_DETAIL OD
		WHERE OD.OrderID = O.OrderID
	)
	FROM [Order] O
	JOIN @AffectedOrders A ON A.OrderID = O.OrderID

	PRINT 'TotalValue of orders updated based on ORDER_DETAIL.'
END;



--7. Automatically applies the highest-value promotion (by customer type, order, or drink)  
-- to each order after insert/update, based on eligibility and discount value.
CREATE TRIGGER TRG_Apply_Highest_Promotion
ON [ORDER]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AffectedOrders TABLE (OrderID VARCHAR(12), CustomerID INT, OrderDate DATE, OrderTime TIME, TotalValue DECIMAL(10,2));

	-- Get affected orders
	INSERT INTO @AffectedOrders(OrderID, CustomerID, OrderDate, TotalValue)
	SELECT OrderID, CustomerID, OrderDate, TotalValue
	FROM inserted;

	--Update each order with the best promotion
	UPDATE O
	SET O.PromotionID = Best.PromotionID
	FROM [ORDER] O 
	JOIN @AffectedOrders A ON O.OrderID = A.OrderID

	OUTER APPLY ( 
		SELECT TOP 1 P.PromotionID
		FROM PROMOTION P 

		--Promotion by customer type
		LEFT JOIN PROMOTION_CUSTOMER PC ON PC.PromotionID = P.PromotionID

		--Promotion by order
		LEFT JOIN PROMOTION_ORDER PO ON PO.PromotionID = P.PromotionID

		--Promotion by drinks
		LEFT JOIN PROMOTION_DRINK PD ON PD.PromotionID = P.PromotionID
		LEFT JOIN ORDER_DETAIL OD ON OD.OrderID = A.OrderID AND OD.DrinkID = PD.DrinkID

		WHERE
			-- PROMOTION_CUSTOMER condition
			(PC.CustomerType = (SELECT CustomerType FROM CUSTOMER WHERE CustomerID = A.CustomerID))

			-- OR PROMOTION_ORDER condition
			OR (
				(PO.MinOrderAmount IS NULL OR A.TotalValue >= PO.MinOrderAmount)
				 OR (
						PO.MinTotalItems IS NOT NULL AND
						(SELECT SUM(Quantity) FROM ORDER_DETAIL WHERE OrderID = A.OrderID) >= PO.MinTotalItems
					)
				AND A.OrderDate BETWEEN ISNULL(PO.StartDate, '1900-01-01') AND ISNULL(PO.EndDate, '2100-01-01')
			)

			-- OR PROMOTION_DRINK condition
			OR (
				PD.DrinkID IS NOT NULL
				AND A.OrderDate BETWEEN ISNULL(PD.StartDate, '1900-01-01') AND ISNULL(PD.EndDate, '2100-01-01')
			)

		ORDER BY P.Discount DESC  -- Choose highest discount
	)Best
	WHERE O.PromotionID IS NULL -- Only update if no promotion manually set

	PRINT 'Highest applicable promotion (customer/order/drink) applied to order(s).';
END;


--8. MustPaid of an order is equal to TotalValue – discount x TotalValue(if there is an applied promotion)
CREATE TRIGGER TRG_MustPaid_Amount 
ON [ORDER]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE O
	SET O.MustPaid = (
		CASE	
			WHEN P.Discount IS NOT NULL THEN O.TotalValue * (1 - P.Discount)
			ELSE O.TotalValue
		END
	)
	FROM [ORDER] O
	JOIN inserted i ON i.OrderID = O.OrderID
	LEFT JOIN PROMOTION P ON P.PromotionID = i.PromotionID

	PRINT 'MustPaid value updated based on TotalValue and applicable discount.'
END;


--9. AmountPaid in PAYMENT which is the amount of money that customers paid must equal or greater than MustPaid values in ORDER.
-- If data is valid, insert it and count Change by (AmountPaid - MustPaid)
CREATE TRIGGER TRG_Prevent_AmountPaidLesserThenMustPaid_AutoInsertChange
ON PAYMENT
INSTEAD OF INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
		SELECT *
		FROM inserted i 
		JOIN [ORDER] O ON O.OrderID = i.OrderID
		WHERE i.AmountPaid < O.MustPaid
	)
	
	BEGIN
		RAISERROR ('AmountPaid cannot be less than MustPaid.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;

	    -- If valid, insert the data
	INSERT INTO PAYMENT (OrderID, Method, AmountPaid, Change, PaidAt)
	SELECT
		i.OrderID, 
		i.Method,
		i.AmountPaid,
		i.AmountPaid - O.MustPaid,
		i.PaidAt
	FROM inserted i
	JOIN [ORDER] O ON i.OrderID = O.OrderID
END;



