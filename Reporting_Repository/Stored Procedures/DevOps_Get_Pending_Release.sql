CREATE Procedure [dbo].[DevOps_Get_Pending_Release]
@Diff_Hour INT = 2
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	DECLARE @hh_Diff_Timezone INT
	SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())

	SELECT R.Id AS ReleaseId
		 , R.Name AS ReleaseName
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, @hh_Diff_Timezone, r.CreatedOn), 121),'') CreatedOn
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, @hh_Diff_Timezone, r.ModifiedOn), 121),'') AS LastUpdate
		 , datediff(mi, r.createdon, GETUTCDATE()) AS Duration_Min
		 , ST.Name AS TargetStage
		 , RS.Name As Status
		 , Step.ServerName
		 , Step.ComponentName
		 , Step.StatusName AS StepStatus
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, @hh_Diff_Timezone, Step.DateStarted), 121),'') AS StepStartDate
		 , datediff(mi, Step.DateStarted, GETUTCDATE()) AS StepDuration_Min
		 --, *
	  FROM [ReleaseManagement].[dbo].[Release] R
	  JOIN [ReleaseManagement].[dbo].[ReleaseStatus] RS
		ON R.StatusId = RS.Id
	  JOIN [ReleaseManagement].[dbo].Stage S
		ON R.TargetStageId = S.Id
	  JOIN [ReleaseManagement].[dbo].StageType ST
		ON S.StageTypeId = ST.Id
	OUTER APPLY (SELECT TOP 1 st.Name as StageTypeName, RSS.Name AS StepStatus, RS.ModifiedOn AS StepLastUpdate, RS.StageId
					  , ISNULL(MIL.Name, C.Name) AS ComponentName
					  , CDL.DateStarted as [DateStarted]
					  , DLS.Name as [StatusName]
					  , CDL.ServerName AS [ServerName]
						FROM [ReleaseManagement].[dbo].ReleaseStep RS
						JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS ON RS.StatusId = RSS.Id
						JOIN [ReleaseManagement].[dbo].Stage S ON RS.StageId = S.Id
						JOIN [ReleaseManagement].[dbo].StageType ST ON S.StageTypeId = ST.Id
						JOIN [ReleaseManagement].[dbo].DeploymentLog DL on DL.ReleaseStepId = RS.Id
						JOIN [ReleaseManagement].[dbo].ComponentDeploymentLog CDL ON DL.Id = CDL.DeploymentLogId
						LEFT JOIN [ReleaseManagement].[dbo].ReleaseComponent RC on RC.Id = CDL.ReleaseComponentId
						LEFT JOIN [ReleaseManagement].[dbo].Component C on C.Id = RC.ComponentId
						JOIN [ReleaseManagement].[dbo].DeploymentLogStatus DLS on DLS.Id = CDL.StatusId
						LEFT JOIN [ReleaseManagement].[dbo].ManualInterventionLog MIL on MIL.Id = CDL.ManualInterventionLogId
					   WHERE RS.ReleaseId = R.Id
					   ORDER BY ISNULL(CDL.DateStarted, GETUTCDATE()) DESC
					  ) AS Step

	 WHERE RS.Name IN ('Draft','In Progress','Stopped')
	   AND R.TargetStageId = ISNULL(Step.StageId, R.TargetStageId)
	   AND datediff(HH, r.createdon, GETUTCDATE()) >= @Diff_Hour
END
