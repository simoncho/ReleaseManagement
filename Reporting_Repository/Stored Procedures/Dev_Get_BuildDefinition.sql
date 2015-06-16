CREATE PROCEDURE [dbo].[Dev_Get_BuildDefinition]
@DefinitionId Int
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT REPLACE(REPLACE(REPLACE([DefinitionName],'"','-'),'>','_'),'\','') AS DefinitionName
		 , DropLocation
		 , LastGoodBuildLabel
		 --, LastSystemQueueId
		 --, LastSystemBuildStartTime
		 , REPLACE(CONVERT(XML, ProcessParameters).value('
					declare default element namespace "clr-namespace:System.Collections.Generic;assembly=mscorlib";
					declare namespace mtbwa="clr-namespace:Microsoft.TeamFoundation.Build.Workflow.Activities;assembly=Microsoft.TeamFoundation.Build.Workflow";
					/Dictionary[1]/mtbwa:BuildSettings[1]/@ProjectsToBuild[1]','varchar(max)'),',',CHAR(13) + CHAR(10)) as SlnLocation
	  FROM [$(TFS_Server)].[$(TFS_Database)].dbo.tbl_BuildDefinition WITH(NOLOCK)
	 WHERE GroupId IN (2,3) AND DefinitionId = @DefinitionId
END
