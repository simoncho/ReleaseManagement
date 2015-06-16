CREATE Procedure [dbo].[Dev_Get_ReleasePath]
AS
SELECT * 
  FROM (
	SELECT ID, NAME
	  FROM [ReleaseManagement].dbo.ReleasePath WITH(NOLOCK)
	 WHERE IsDeleted=0
	 Union all
	SELECT 0, 'All'
	) A
 ORDER BY CASE WHEN NAME ='All' THEN NULL ELSE NAME END
