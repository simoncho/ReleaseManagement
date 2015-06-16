CREATE PROCEDURE [dbo].[Dev_Get_BuildSchedule]
@DefinitionName VARCHAR(255) = ''
, @TriggerType VARCHAR(255) = ''
, @SolutionName VARCHAR(500) = ''
, @GroupId INT = 3 -- 2: Developer 3:DevOps
AS
BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @hh_Diff_Timezone INT
SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())

SELECT BD.[DefinitionId]
     , REPLACE(REPLACE(REPLACE(BD.[DefinitionName],'"','-'),'>','_'),'\','') AS DefinitionName
     , S0.code_name AS TriggerType
	 , DATEADD(hh, @hh_Diff_Timezone, B1.StartTime) AS Build_StartTime
	 , DATEADD(hh, @hh_Diff_Timezone, B1.FinishTime) AS Build_FinishTime
	 , DATEDIFF(mi, B1.StartTime, B1.FinishTime) as Latest_Build_duration_min
	 , B1.[code_name] AS LatestBuildStatus
	 , REPLACE(REPLACE(REPLACE(B1.BuildNumber,'"','-'),'>','_'),'\','') AS LatestBuildNo
	 , B1.Quality
	 , B1.DisplayName AS QueuedBy
	 , s.TimeZoneId
	 
	 -- TFS Deploytime bug in case of DaylightSaving
	 , DATEADD(hh, @hh_Diff_Timezone, DATEADD(SS, S.ScheduleTime, CONVERT(VARCHAR(8), GETDATE(), 112))) AS AutoBuildTime
	
	 , (CASE S0.code_name WHEN 'Manual' THEN '' ELSE
		 'Daily '+ (CASE Weekday1 WHEN 0 THEN 'Sun(N),' ELSE '' END)
				 + (CASE Weekday2 WHEN 0 THEN 'Mon(N),' ELSE '' END)
				 + (CASE Weekday3 WHEN 0 THEN 'Tue(N),' ELSE '' END)
				 + (CASE Weekday4 WHEN 0 THEN 'Wed(N),' ELSE '' END)
				 + (CASE Weekday5 WHEN 0 THEN 'Thu(N),' ELSE '' END)
				 + (CASE Weekday6 WHEN 0 THEN 'Fri(N),' ELSE '' END)
				 + (CASE Weekday7 WHEN 0 THEN 'Sat(N),' ELSE '' END)
	   END)
	   AS AutoBuildWeekDay
	 , REPLACE(CONVERT(VARCHAR(MAX), CONVERT(XML, ProcessParameters).value('
				declare default element namespace "clr-namespace:System.Collections.Generic;assembly=mscorlib";
				declare namespace mtbwa="clr-namespace:Microsoft.TeamFoundation.Build.Workflow.Activities;assembly=Microsoft.TeamFoundation.Build.Workflow";
				/Dictionary[1]/mtbwa:BuildSettings[1]/@ProjectsToBuild[1]','varchar(max)')
			  ),',',char(13)+char(10))
	   AS SolutionList

  FROM [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildDefinition] BD
  LEFT OUTER JOIN [dbo].[syscode] S0 ON BD.TriggerType = S0.code_no  AND S0.[code_group] = 'TriggerType'
  CROSS APPLY (SELECT TOP 1 B.StartTime, B.FinishTime, B.BuildNumber, BQ.Quality, B.PartitionId, ISNULL(S1.code_name, CONVERT(VARCHAR(255), B.BuildStatus)) AS code_name, AO.DisplayName
				 FROM [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_Build] B WITH(NOLOCK)
				 JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildQueue] Q WITH(NOLOCK)ON B.BuildId = Q.BuildId AND B.PartitionId = Q.PartitionId
				 JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[ADObjects] AO WITH(NOLOCK) ON Q.RequestedBy = AO.TeamFoundationId AND B.PartitionId = AO.PartitionId
				 LEFT OUTER JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildQuality] BQ WITH(NOLOCK) ON BQ.QualityId = B.QualityId AND B.PartitionId = BQ.PartitionId
				 LEFT OUTER JOIN [dbo].[syscode] S1 ON B.BuildStatus = S1.[code_no] AND S1.[code_group] = 'BuildStatus'
				WHERE B.DefinitionId = BD.DefinitionId 
				  AND B.Deleted =0 
				  AND B.PartitionId=BD.PartitionId 
				  --AND B.StartTime > DATEADD(hh, @hh_Diff_Timezone, @StartDate)
				ORDER BY B.BUILDID DESC) B1
  LEFT OUTER JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_Schedule] S ON BD.PartitionId = S.PartitionId AND BD.DefinitionId = S.DefinitionId AND S0.code_name IN ('Scheduled', 'Scheduled_EvenNoChange')
  
 WHERE BD.GroupId = @GroupId
   AND BD.QueueStatus != 2
   AND (CASE WHEN @DefinitionName!='' THEN REPLACE(REPLACE(REPLACE(BD.[DefinitionName],'"','-'),'>','_'),'\','') ELSE 'ALL' END)
	   LIKE (CASE WHEN @DefinitionName!='' THEN '%'+@DefinitionName+'%' ELSE 'ALL' END) 
   AND (CASE WHEN @TriggerType!='' THEN s0.code_name ELSE 'ALL' END)
	   = (CASE WHEN @TriggerType!='' THEN @TriggerType ELSE 'ALL' END) 
   AND (CASE WHEN @SolutionName!='' THEN CONVERT(VARCHAR(MAX), ProcessParameters) ELSE 'ALL' END)
	   LIKE (CASE WHEN @SolutionName!='' THEN '%'+@SolutionName+'%' ELSE 'ALL' END) 

 ORDER BY B1.StartTime DESC
END
