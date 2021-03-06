-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[prc_LoadGTAData]	@FolderName	VARCHAR(2048),
											@FileName	VARCHAR(2048)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	DECLARE	@ProductGroup	VARCHAR(255)
	DECLARE	@ReportingCountry	VARCHAR(255)
	DECLARE	@PartnerCountry	VARCHAR(255)
	DECLARE	@Unit	VARCHAR(255)
	DECLARE	@Year	INT
	DECLARE	@Month	INT
	DECLARE	@Value	INT
	DECLARE	@Quantity	INT
	DECLARE	@HeaderString	VARCHAR(2048)
	DECLARE	@FieldList	TABLE (
		[FieldName]	VARCHAR(255),
		[OrderNum]	INT)
	DECLARE	@ImportRow	VARCHAR(2048)

	DECLARE	@RecordCounter	INT

	DECLARE	ImportCursor CURSOR FOR
	SELECT	[Line]
	FROM	[dbo].[uftReadfileAsTable](@FolderName,@FileName)
	WHERE	[Line] NOT LIKE 'Product Group%'

	OPEN	ImportCursor
	FETCH NEXT FROM ImportCursor INTO @ImportRow

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET	@RecordCounter = 0
			WHILE @RecordCounter < 8
				BEGIN
					SET @RecordCounter = @RecordCounter + 1	

					IF	@RecordCounter = 1 BEGIN SELECT @ProductGroup = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 2 BEGIN SELECT @ReportingCountry = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 3 BEGIN SELECT @PartnerCountry = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 4 BEGIN SELECT @Unit = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 5 BEGIN SELECT @Year = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 6 BEGIN SELECT @Month = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 7 BEGIN SELECT @Value = LEFT(@ImportRow, CHARINDEX(CHAR(9),@ImportRow) - 1) END
					IF	@RecordCounter = 8 BEGIN SELECT @Quantity = @ImportRow END

					SELECT	@ImportRow = RIGHT(@ImportRow, LEN(@ImportRow) - CHARINDEX(CHAR(9),@ImportRow))
				END

			-- This is for the case of duplicate spreadsheets
			DELETE FROM	[dbo].[raw_GTAExport]
			WHERE	REPLACE([ProductGroup], '"', '') = REPLACE(@ProductGroup, '"', '')
			AND		REPLACE([ReportingCountry], '"', '') = REPLACE(@ReportingCountry, '"', '')
			AND		REPLACE([PartnerCountry], '"', '') = REPLACE(@PartnerCountry, '"', '')
			AND		[Year] = @Year
			AND		[Month] = @Month
			
			INSERT INTO	[dbo].[raw_GTAExport] ([ProductGroup], [ReportingCountry], [PartnerCountry]
					, [Unit], [Year], [Month], [Value], [Quantity])
			SELECT	@ProductGroup, @ReportingCountry, @PartnerCountry
					, @Unit, @Year, @Month
					, @Value, @Quantity
			
			FETCH NEXT FROM ImportCursor INTO @ImportRow
		END

	UPDATE	[dbo].[raw_GTAExport] 
	SET [PartnerCountry] = REPLACE([PartnerCountry], '"', ''),
		[ReportingCountry] = REPLACE([ReportingCountry], '"', ''),
		[Unit] = REPLACE([Unit], '"', ''),
		[ProductGroup] = REPLACE([ProductGroup], '"', '')
	CLOSE		ImportCursor
	DEALLOCATE	ImportCursor

	--SELECT	* from raw_GTAExport
	--ORDER BY	[ProductGroup], [ReportingCountry], [PartnerCountry]
	
END



