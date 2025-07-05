/* sales_and_revenue.sql
   Stored procedures for sales and revenue analysis
*/

CREATE PROCEDURE SP_TotalSalesByDay AS
BEGIN
  SELECT OrderDate, SUM(MustPaid) AS DailyIncome
  FROM [ORDER]
  GROUP BY OrderDate
  ORDER BY OrderDate;
END;
GO

-->  Helps managers track revenue trends and identify high/low performance days



CREATE PROCEDURE SP_Top5BestSellingDrinks AS
BEGIN
  SELECT TOP 5 D.DrinkName, SUM(OD.Quantity) AS TotalSold
  FROM ORDER_DETAIL OD
  JOIN DRINK D ON D.DrinkID = OD.DrinkID
  GROUP BY D.DrinkName
  ORDER BY TotalSold DESC;
END;
GO

-- > Identifies popular drinks to prioritize inventory and marketing




CREATE PROCEDURE SP_DrinksUnderperformingLast30Days AS
BEGIN
  SELECT D.DrinkID, D.DrinkName, ISNULL(SUM(OD.Quantity), 0) AS SoldQuantity
  FROM DRINK D
  LEFT JOIN ORDER_DETAIL OD ON OD.DrinkID = D.DrinkID
  LEFT JOIN [ORDER] O ON O.OrderID = OD.OrderID
    AND O.OrderDate >= DATEADD(DAY, -30, GETDATE())
  GROUP BY D.DrinkID, D.DrinkName
  HAVING ISNULL(SUM(OD.Quantity), 0) <= 5;
END;
GO

-- > Identifies underperforming items for removal or promotion




CREATE PROCEDURE SP_RevenueByCategoryLastMonth AS
BEGIN
  SELECT D.Category, SUM(OD.Amount) AS CategoryRevenue
  FROM ORDER_DETAIL OD
  JOIN [ORDER] O ON O.OrderID = OD.OrderID
  JOIN DRINK D ON D.DrinkID = OD.DrinkID
  WHERE
    O.OrderDate >= DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    AND O.OrderDate < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  GROUP BY D.Category;
END;
GO

-- > Helps plan pricing strategies and category-level promotions




CREATE PROCEDURE SP_RevenueTrendByMonth AS
BEGIN
  SELECT FORMAT(OrderDate, 'yyyy-MM') AS Month, SUM(MustPaid) AS Revenue
  FROM [ORDER]
  GROUP BY FORMAT(OrderDate, 'yyyy-MM')
  ORDER BY Month;
END;
GO

-- > Tracks business growth and seasonal trends



CREATE PROCEDURE SP_LowSellingDrinks AS
BEGIN
SELECT D.DrinkID, D.DrinkName, ISNULL(SUM(OD.Quantity), 0) AS SoldQuantity
FROM DRINK D
LEFT JOIN ORDER_DETAIL OD ON OD.DrinkID = D. DrinkID
LEFT JOIN [ORDER] O ON O.OrderID = OD.OrderID
	AND O.OrderDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY D.DrinkID, D.DrinkName
HAVING ISNULL(SUM(OD.Quantity), 0) <= 5;
END;
GO

-- > Identifies underperforming items for removal or promotion



CREATE PROCEDURE SP_PromotionUsageRateLastMonth AS
BEGIN
  SELECT COUNT(CASE WHEN PromotionID IS NOT NULL THEN 1 END) * 1.0 / COUNT(*) AS PromoUsageRate
  FROM [ORDER]
  WHERE OrderDate >= DATEADD(MONTH, -1, GETDATE());
END;
GO

-- > Evaluates how attractive promotions being applied are 



CREATE PROCEDURE SP_PromotionEffectiveness AS
BEGIN
SELECT P.PromotionID, P.Description, PD.StartDate, D.DrinkName,
		--Total sales before promotion applied
		ISNULL((
			SELECT SUM(OD.Quantity)
			FROM ORDER_DETAIL OD
			JOIN [ORDER] O ON O.OrderID =OD.OrderID
			WHERE OD.DrinkID = PD.DrinkID AND O.OrderDate < PD.StartDate
		), 0) AS QuantitySoldBefore,

		--Total sales after promotion applied
		ISNUL((
			SELECT
			FROM ORDER_DETAIL OD
			JOIN [ORDER] O ON O.OrderID = OD.OrderID
			WHERE OD.DrinkID = PD.DrinkID AND O.OrderDate >= PD.StartDate
		), 0) AS QuantitySoldAfter

FROM PROMOTION_DRINK PD
JOIN PROMOTION P ON P.PromotionID = PD.PromotionID
JOIN DRINK D ON D.DrinkID = PD.DrinkID
ORDER BY PD.PromotionID, D.DrinkName;
END;
GO

-- > Measures how promotions affect product performance and sales volume