CREATE VIEW [dbo].[DevOps_Alert_Pending_Release_2hours]
AS
	SELECT R.Id AS ReleaseId
		 , R.Name AS ReleaseName
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), GETDATE()), r.CreatedOn), 121),'') CreatedOn
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), GETDATE()), r.ModifiedOn), 121),'') AS LastUpdate
		 , DATEDIFF(mi, r.createdon, GETUTCDATE()) AS Duration_Min
		 , ST.Name AS TargetStage
		 , RS.Name AS Status
		 , Step.ServerName
		 , Step.ComponentName
		 , Step.StatusName AS StepStatus
		 , ISNULL(CONVERT(VARCHAR(255), DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), GETDATE()), Step.DateStarted), 121),'') AS StepStartDate
		 , DATEDIFF(mi, Step.DateStarted, GETUTCDATE()) AS StepDuration_Min
		 --, *
	  FROM [ReleaseManagement].[dbo].[Release] R WITH(NOLOCK)
	  JOIN [ReleaseManagement].[dbo].[ReleaseStatus] RS WITH(NOLOCK)
		ON R.StatusId = RS.Id
	  JOIN [ReleaseManagement].[dbo].Stage S WITH(NOLOCK)
		ON R.TargetStageId = S.Id
	  JOIN [ReleaseManagement].[dbo].StageType ST WITH(NOLOCK)
		ON S.StageTypeId = ST.Id
	OUTER APPLY (SELECT TOP 1 st.Name AS StageTypeName, RSS.Name AS StepStatus, RS.ModifiedOn AS StepLastUpdate, RS.StageId
					  , ISNULL(MIL.Name, C.Name) AS ComponentName
					  , CDL.DateStarted AS [DateStarted]
					  , DLS.Name AS [StatusName]
					  , CDL.ServerName AS [ServerName]
						FROM [ReleaseManagement].[dbo].ReleaseStep RS WITH(NOLOCK)
						JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS WITH(NOLOCK) ON RS.StatusId = RSS.Id
						JOIN [ReleaseManagement].[dbo].Stage S WITH(NOLOCK) ON RS.StageId = S.Id
						JOIN [ReleaseManagement].[dbo].StageType ST WITH(NOLOCK) ON S.StageTypeId = ST.Id
						JOIN [ReleaseManagement].[dbo].DeploymentLog DL WITH(NOLOCK) ON DL.ReleaseStepId = RS.Id
						JOIN [ReleaseManagement].[dbo].ComponentDeploymentLog CDL WITH(NOLOCK) ON DL.Id = CDL.DeploymentLogId
						LEFT JOIN [ReleaseManagement].[dbo].ReleaseComponent RC WITH(NOLOCK) ON RC.Id = CDL.ReleaseComponentId
						LEFT JOIN [ReleaseManagement].[dbo].Component C WITH(NOLOCK) ON C.Id = RC.ComponentId
						JOIN [ReleaseManagement].[dbo].DeploymentLogStatus DLS WITH(NOLOCK) ON DLS.Id = CDL.StatusId
						LEFT JOIN [ReleaseManagement].[dbo].ManualInterventionLog MIL WITH(NOLOCK) ON MIL.Id = CDL.ManualInterventionLogId
					   WHERE RS.ReleaseId = R.Id
					   ORDER BY ISNULL(CDL.DateStarted, GETUTCDATE()) DESC
					  ) AS Step

	 WHERE RS.Name IN ('Draft','In Progress','Stopped')
	   AND R.TargetStageId = ISNULL(Step.StageId, R.TargetStageId)
	   AND R.createdon <= DATEADD(HH, 2*-1, GETUTCDATE())