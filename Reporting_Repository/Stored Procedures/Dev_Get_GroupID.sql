CREATE PROCEDURE Dev_Get_GroupID
AS
SELECT GroupID, P.ProjectName
  FROM [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildGroup] G WITH(NOLOCK)
  JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_Project] P WITH(NOLOCK)
    ON G.TeamProject = P.ProjectUri AND g.PartitionId = p.PartitionId