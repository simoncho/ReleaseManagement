CREATE Procedure [dbo].[Dev_Get_DeploySummary]
@DefinitionName varchar(255) =''
, @Period varchar(255) = '7 Days'
AS
BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StartDate DATETIME
DECLARE @hh_Diff_Timezone INT
SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())

SET @DefinitionName = ISNULL(@DefinitionName,'')
SET @DefinitionName = REPLACE(REPLACE(REPLACE(@DefinitionName,'-','"'),'_','>'),'','')
	
SET @StartDate = DATEADD(DD, -1, GETUTCDATE())

IF @Period = '12 Hours'
	SET @StartDate = DATEADD(HH, -12, GETUTCDATE())
ELSE IF @Period = '1 Day'
	SET @StartDate = DATEADD(DD, -1, GETUTCDATE())
ELSE IF @Period = '7 Days'
	SET @StartDate = DATEADD(DD, -7, GETUTCDATE())
ELSE IF @Period = '15 Days'
	SET @StartDate = DATEADD(DD, -15, GETUTCDATE())
ELSE IF @Period = '1 Month'
	SET @StartDate = DATEADD(MM, -1, GETUTCDATE())

;WITH InReleaseBuildStatus as (
	SELECT R.Id AS ReleaseID
		 --, r.Name AS InRelease_Template
		 , r.BuildDefinition as InRelease_Template
		 , r.Build
		 , r.CreatedOn AS CreatedOn
		 , r.ModifiedOn AS LastUpdate
		 , Convert(VARCHAR(255), R.ModifiedOn - R.CreatedOn, 108) AS Duration
		 , U.DisplayName AS CreatedBy
		 , RS.Name AS Status
		 , RP.Name AS ReleasePath
		 , ST.Name AS TargetStage
		 , CurrentStage.StageTypeName AS CurrentStage
		 , CurrentStage.StepStatus AS CurrentStageStatus
		 , CurrentStage.StageStepTypeName AS Approval
	  FROM [ReleaseManagement].[dbo].Release R
	  JOIN [ReleaseManagement].[dbo].ReleaseStatus RS
		ON R.StatusId = RS.Id
	  JOIN [ReleaseManagement].[dbo].ReleasePath RP 
	    ON R.ReleasePathId = RP.Id
	 CROSS APPLY (SELECT TOP 1 st.Name as StageTypeName, RSS.Name AS StepStatus, RS.ModifiedOn AS StepLastUpdate, SST.Name AS StageStepTypeName
					FROM [ReleaseManagement].[dbo].ReleaseStep RS
					JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS ON RS.StatusId = RSS.Id
					JOIN [ReleaseManagement].[dbo].Stage S ON RS.StageId = S.Id
					JOIN [ReleaseManagement].[dbo].StageType ST ON S.StageTypeId = ST.Id
					JOIN [ReleaseManagement].[dbo].StageStepType SST on SST.Id = RS.StepTypeId
				   WHERE RS.ReleaseId = R.Id
				   ORDER BY RS.Id DESC
				  ) AS CurrentStage
	  JOIN [ReleaseManagement].[dbo].Stage S
	    ON R.TargetStageId = S.Id
	  JOIN [ReleaseManagement].[dbo].StageType ST
	    ON S.StageTypeId = ST.Id
	  LEFT OUTER JOIN [ReleaseManagement].[dbo].[User] U ON R.CreatedById = U.Id
	 WHERE 1=1 
	 ----(CASE WHEN @NAME = 'ALL' THEN '1' ELSE R.Name END) LIKE '%'+(CASE WHEN @NAME = 'ALL' THEN '1' ELSE @NAME END)+'%'
	 --  AND (CASE WHEN @BuildDefinition = '' THEN '1' ELSE r.BuildDefinition END) LIKE '%'+(CASE WHEN @BuildDefinition = '' THEN '1' ELSE @BuildDefinition END)+'%'
	 --  AND (CASE WHEN @Build = '' THEN '1' ELSE r.Build END) LIKE '%'+(CASE WHEN @Build = '' THEN '1' ELSE @Build END)+'%'
	 --  AND (CASE WHEN @Status = '' THEN '1' ELSE RS.Name END) = (CASE WHEN @Status = '' THEN '1' ELSE @Status END)
	   AND R.ModifiedOn > @StartDate
	 --  AND (CASE WHEN @ReleasePath = '' THEN '1' ELSE RP.Name END) = (CASE WHEN @ReleasePath = '' THEN '1' ELSE @ReleasePath END)
	 --ORDER BY r.ModifiedOn DESC
)
SELECT BD.[DefinitionId]
     , REPLACE(REPLACE(REPLACE(BD.[DefinitionName],'"','-'),'>','_'),'\','') AS DefinitionName
     , S0.code_name AS TriggerType
	 , DATEADD(hh, @hh_Diff_Timezone, B1.StartTime) AS StartTime
	 , DATEADD(hh, @hh_Diff_Timezone, B1.FinishTime) AS FinishTime
	 , DATEDIFF(mi, B1.StartTime, B1.FinishTime) as duration_min
	 , B1.[code_name] AS BuildStatus
	 , REPLACE(REPLACE(REPLACE(B1.BuildNumber,'"','-'),'>','_'),'\','') AS BuildNo
	 , B1.Quality
	 , B1.DisplayName AS QueuedBy
	 --, BD.DropLocation
	 --, REPLACE(B1.DropLocation, B1.DropLocationRoot, '') as DropLocation
	 --, REPLACE(B1.LogLocation, B1.DropLocationRoot, '') as LogLocation
	 --, B2.StartTime AS LastGoodBuild_Starttime
	 --, REPLACE(REPLACE(REPLACE(B2.BuildNumber,'"','-'),'>','_'),'\','') AS LastGoodBuild_No
	 , InRelease.ReleaseID
	 , InRelease.InRelease_Template
	 , DATEADD(hh, @hh_Diff_Timezone, InRelease.CreatedOn) AS CreatedOn
	 , DATEADD(hh, @hh_Diff_Timezone, InRelease.LastUpdate) AS LastUpdate
	 , InRelease.Duration
	 , InRelease.Status
	 , InRelease.ReleasePath
	 , InRelease.CurrentStage
	 , InRelease.TargetStage
	 , InRelease.Approval
	 , InRelease.CreatedBy
  FROM [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildDefinition] BD WITH(NOLOCK)
  LEFT OUTER JOIN [dbo].[syscode] S0 ON BD.TriggerType = S0.code_no  AND S0.[code_group] = 'TriggerType'

  --LastBuild
  CROSS APPLY (SELECT TOP 1 B.StartTime, B.FinishTime, B.BuildNumber, BQ.Quality, B.PartitionId, ISNULL(S1.code_name, CONVERT(VARCHAR(255), B.BuildStatus)) AS code_name, AO.DisplayName
				 FROM [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_Build] B WITH(NOLOCK)
				 JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildQueue] Q WITH(NOLOCK)ON B.BuildId = Q.BuildId AND B.PartitionId = Q.PartitionId
				 JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[ADObjects] AO WITH(NOLOCK) ON Q.RequestedBy = AO.TeamFoundationId AND B.PartitionId = AO.PartitionId
				 LEFT OUTER JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_BuildQuality] BQ WITH(NOLOCK) ON BQ.QualityId = B.QualityId
				 LEFT OUTER JOIN [dbo].[syscode] S1 ON B.BuildStatus = S1.[code_no] AND S1.[code_group] = 'BuildStatus'
				WHERE B.DefinitionId = BD.DefinitionId 
				  AND B.Deleted =0 
				  AND B.PartitionId=BD.PartitionId 
				  AND B.StartTime > DATEADD(hh, @hh_Diff_Timezone, @StartDate)
				ORDER BY B.BUILDID DESC) B1
  --LEFT OUTER JOIN [$(TFS_Server)].[$(TFS_Database)].[dbo].[tbl_Build] B2 WITH(NOLOCK) on BD.LastGoodBuildUri = B2.BuildUri AND B1.PartitionId=BD.PartitionId
  OUTER APPLY (SELECT TOP 1 * 
				 FROM InReleaseBuildStatus 
				WHERE Build = REPLACE(REPLACE(REPLACE(B1.BuildNumber,'"','-'),'>','_'),'\','') --AND ReleasePath = 'Dev0 Release Path'
				ORDER BY ReleaseID DESC, LastUpdate DESC) InRelease
 WHERE BD.GroupId in (2, 3) AND BD.PartitionId=1
   --AND DefinitionName not like '%Dev2%'
   AND DefinitionName not like '%gated%'
   AND DefinitionName not like '%(test)%'
   AND DefinitionName != 'NuGet DealerCenter'
   AND (CASE WHEN @DefinitionName = '' THEN '1' ELSE BD.[DefinitionName] END) LIKE '%'+(CASE WHEN @DefinitionName = '' THEN '1' ELSE @DefinitionName END)+'%'
 ORDER BY B1.StartTime DESC

END
