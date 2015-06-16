CREATE VIEW [dbo].[vw_StageType_FOR_DevAll]
AS
SELECT * 
  FROM [ReleaseManagement].[dbo].StageType WITH(NOLOCK)
 WHERE IsDeleted = 0
   AND (NAME LIKE 'Dev%' OR NAME LIKE 'INTEGRATION' OR NAME LIKE 'Beta%')