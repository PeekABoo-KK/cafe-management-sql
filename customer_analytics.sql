/* customer_analytics.sql
   Stored procedures for customer-related reports
*/

CREATE PROCEDURE SP_Top10LoyalCustomers AS
BEGIN
  SELECT TOP 10 C.CustomerID, C.CustomerName, COUNT(O.OrderID) AS TotalOrders
  FROM CUSTOMER C
  JOIN [ORDER] O ON O.CustomerID = C.CustomerID
  GROUP BY C.CustomerID, C.CustomerName
  ORDER BY TotalOrders DESC;
END;
GO

-- > Enables targeted loyalty rewards and personalized marketing




CREATE PROCEDURE SP_CustomerSegmentation AS
BEGIN
  SELECT C.CustomerID, C.CustomerName, SUM(O.MustPaid) AS TotalSpending,
    CASE 
      WHEN SUM(O.MustPaid) >= 5000000 THEN 'Platinum'
      WHEN SUM(O.MustPaid) >= 3000000 THEN 'Gold'
      WHEN SUM(O.MustPaid) >= 2000000 THEN 'VIP'
      ELSE 'Normal'
    END AS Segment
  FROM CUSTOMER C
  JOIN [ORDER] O ON C.CustomerID = O.CustomerID
  GROUP BY C.CustomerID, C.CustomerName
  ORDER BY TotalSpending DESC;
END;
GO

-- > Enables tiered loyalty programs and targeted promotions




CREATE PROCEDURE SP_OrderClassificationLastMonth AS
BEGIN
  SELECT
    CASE
      WHEN C.CustomerType = 'Anonymous' THEN 'Guest'
      WHEN O.OrderDate = C.JoinDate THEN 'New'
      ELSE 'Returning'
    END AS CustomerGroup,
    COUNT(O.OrderID) AS TotalOrders
  FROM [ORDER] O
  JOIN CUSTOMER C ON C.CustomerID = O.CustomerID
  WHERE O.OrderDate >= DATEADD(MONTH, -1, GETDATE())
  GROUP BY
    CASE
      WHEN C.CustomerType = 'Anonymous' THEN 'Guest'
      WHEN O.OrderDate = C.JoinDate THEN 'New'
      ELSE 'Returning'
    END;
END;
GO

-- > Reveals how well the business is retaining new customers




CREATE PROCEDURE SP_InactiveCustomersLastMonth AS
BEGIN
  SELECT C.CustomerID, C.CustomerName, MAX(O.OrderDate) AS LastOrderDate
  FROM CUSTOMER C
  JOIN [ORDER] O ON O.CustomerID = C.CustomerID
  GROUP BY C.CustomerID, C.CustomerName
  HAVING MAX(O.OrderDate) < DATEADD(MONTH, -1, GETDATE());
END;
GO

-- > Helps re-engage inactive customers via follow-up marketing



CREATE PROCEDURE SP_AnalyzePaymentMethods AS
BEGIN
  SELECT Method, COUNT(*) AS TotalPayments
  FROM PAYMENT
  GROUP BY Method
  ORDER BY TotalPayments DESC;
END;
GO

-- > Understands preferred payment channels for better service