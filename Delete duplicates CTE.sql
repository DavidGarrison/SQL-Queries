/* Delete Duplicate records */
WITH CTE
AS
(
SELECT COl1,Col2,
ROW_NUMBER() OVER(PARTITION BY COl1,Col2 ORDER BY Col1) AS DuplicateCount
FROM DuplicateRcordTable
)
DELETE
FROM CTE
WHERE DuplicateCount > 1
GO