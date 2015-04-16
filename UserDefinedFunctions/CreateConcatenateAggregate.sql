CREATE AGGREGATE [dbo].[Concatenate]
(@value [nvarchar](4000), @delimiter [nvarchar](4000), @maxCharactersPerSegment [int], @sortPrecedence [int])
RETURNS[nvarchar](4000)
EXTERNAL NAME [UserDefinedFunctions].[Concatenate]
GO

