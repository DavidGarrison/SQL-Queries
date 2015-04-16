SELECT e.Attributes.value('(Attributes/@searchTerm)[1]', 'nvarchar(100)') query
  FROM [telemetry].[Events] e

