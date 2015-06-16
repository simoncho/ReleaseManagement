
DELETE FROM [Reporting_repository].[dbo].[syscode]
GO

INSERT INTO [Reporting_repository].[dbo].[syscode]
SELECT 1,'InProgress','BuildStatus', NULL UNION all
SELECT 2,'Succeeded','BuildStatus', NULL UNION all
SELECT 4,'Partially','Succeeded	BuildStatus', NULL UNION all
SELECT 8,'Failed','BuildStatus', NULL UNION all
SELECT 16,'Stopped','BuildStatus', NULL UNION all
SELECT 1,'Succeeded','CompilationStatus', NULL UNION all
SELECT 2,'Failed','CompilationStatus', NULL