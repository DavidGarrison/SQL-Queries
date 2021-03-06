WITH Months AS
(
SELECT CAST('01/01/15' AS DATETIME) AS Month
UNION ALL  
SELECT DATEADD(Month,-1, Month) FROM Months  
WHERE Month > '01/01/13' 
)

Select * from Months
Order by Month
OPTION (MAXRECURSION 1000)