
DELETE FROM [Reporting_repository].[dbo].[NUM]
GO

INSERT INTO [Reporting_repository].[dbo].[NUM] WITH(TABLOCK)
SELECT TOP 10000 ROW_NUMBER() OVER (ORDER BY GETDATE())
  FROM sys.columns a
  CROSS JOIN sys.columns b
  CROSS JOIN sys.columns c
GO