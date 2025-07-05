/* employee_and_shift.sql
   Stored procedures for employee and shift related reports
*/

CREATE PROCEDURE SP_EmployeesWithHighestSales AS
BEGIN
  SELECT E.EmployeeID, E.FullName, COUNT(O.OrderID) AS TotalSales
  FROM EMPLOYEE E
  JOIN [ORDER] O ON O.EmployeeID = E.EmployeeID
  GROUP BY E.EmployeeID, E.FullName
  HAVING COUNT(O.OrderID) >= ALL (
    SELECT COUNT(O2.OrderID)
    FROM [ORDER] O2
    GROUP BY O2.EmployeeID
  );
END;
GO

--> Recognizes top-performing staff for incentives or performance reviews



CREATE PROCEDURE SP_EmployeeShiftCountSalary AS
BEGIN
  SELECT E.EmployeeID, E.FullName, COUNT(ES.ShiftID) AS TotalShifts, E.Salary
  FROM EMPLOYEE E
  JOIN EMPLOYEE_SHIFT ES ON E.EmployeeID = ES.EmployeeID
  GROUP BY E.EmployeeID, E.FullName, E.Salary;
END;
GO

-- > Monitors employee workload and compares it to compensation



CREATE PROCEDURE SP_PeakOrderTime AS
BEGIN
  SELECT DATEPART(HOUR, OrderTime) AS HourOfDay, 
         COUNT(*) * 1.0 / COUNT(DISTINCT OrderDate) AS AvgOrdersPerDay
  FROM [ORDER] O
  GROUP BY DATEPART(HOUR, OrderTime)
  ORDER BY AvgOrdersPerDay DESC;
END;
GO

-- > Supports staff scheduling and shift optimization
