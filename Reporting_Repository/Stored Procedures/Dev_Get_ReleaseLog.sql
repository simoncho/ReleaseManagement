
CREATE Procedure [dbo].[Dev_Get_ReleaseLog]
@ReleaseId INT
, @ReleaseStepId INT = NULL
as
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--DECLARE @releaseId int
	--Declare @TrialNumber smallint, @ReleaseStepId Int, @StageTypeName Varchar(255), @StatusName VARCHAR(255), @CreatedOn DATETIME

	DECLARE @hh_Diff_Timezone INT
	SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())

	SELECT TOP 1 @ReleaseStepId = RS.Id --as [ReleaseStepId]
	  FROM [ReleaseManagement].[dbo].ReleaseStep RS
	  JOIN [ReleaseManagement].[dbo].Stage S on S.Id = RS.StageId
	  --JOIN [ReleaseManagement].[dbo].StageType ST on ST.Id = RS.StageTypeId
	  JOIN dbo.vw_StageType_FOR_DevAll ST on ST.Id = RS.StageTypeId
	  JOIN [ReleaseManagement].[dbo].StageStepType SST on SST.Id = RS.StepTypeId
	  JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS on RSS.Id = RS.StatusId
	  --JOIN [ReleaseManagement].[dbo].ReleaseStepOwner RSO on RSO.Id = RS.Id
	 WHERE RS.ReleaseId = @releaseId
	   AND (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE RS.ID END) = (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE @ReleaseStepId END)
	   AND SST.NAME = 'Deploy' --Deploy
	   --AND (CASE WHEN @TrialNumber IS NULL THEN 1 ELSE TrialNumber END) = (CASE WHEN @TrialNumber IS NULL THEN 1 ELSE @TrialNumber END)	   
	 ORDER BY RS.ID DESC

	--SELECT @releaseId AS ReleaseStepId
	--	 , @CreatedOn AS CreatedOn
	--	 , @StageTypeName AS StageTypeName
	--	 , @TrialNumber AS TrialNumber
	--	 , @StatusName AS StatusName

	SELECT RS.Id as [ReleaseStepId]
		 --, MIL.Id as ManualIntervention
		 , ISNULL(MIL.Name, C.Name) AS ComponentName
		 , DATEADD(hh, @hh_Diff_Timezone, CDL.DateStarted) as [DateStarted]
		 --, CDL.DateEnded as [DateEnded]
		 , CONVERT(VARCHAR(10),(CDL.DateEnded - CDL.DateStarted), 108) as [Duration]
		 , DLS.Name as [StatusName]
		 , CDL.ServerName AS [ServerName]
		 , CASE WHEN LEN(CDL.ERROR)>0 THEN CONVERT(xml,'<?Q--'+CHAR(13)+CHAR(10)+ISNULL(CDL.Error, '')+'--?>') ELSE '' END  as [Error]
		 , CASE WHEN LEN(R1.Id)>0 THEN CONVERT(xml,'<?Q--'+CHAR(13)+CHAR(10)+CONVERT(NVARCHAR(MAX),R1.[BinaryData])+'--?>') ELSE '' END AS CustLog
		 , CONVERT(xml,'<?Q--'+CHAR(13)+CHAR(10)+REPLACE(CONVERT(VARCHAR(MAX),R2.[BinaryData]),CHAR(12),'')+'--?>') AS AutoLog
	  FROM [ReleaseManagement].[dbo].ReleaseStep RS
	  JOIN dbo.vw_StageType_FOR_DevAll ST on ST.Id = RS.StageTypeId
	  JOIN [ReleaseManagement].[dbo].DeploymentLog DL on DL.ReleaseStepId = RS.Id
	  JOIN [ReleaseManagement].[dbo].ComponentDeploymentLog CDL ON DL.Id = CDL.DeploymentLogId
	  LEFT JOIN [ReleaseManagement].[dbo].ReleaseComponent RC on RC.Id = CDL.ReleaseComponentId
	  LEFT JOIN [ReleaseManagement].[dbo].Component C on C.Id = RC.ComponentId
	  JOIN [ReleaseManagement].[dbo].DeploymentLogStatus DLS on DLS.Id = CDL.StatusId
	  LEFT JOIN [ReleaseManagement].[dbo].ManualInterventionLog MIL on MIL.Id = CDL.ManualInterventionLogId
	  LEFT JOIN [ReleaseManagement].[dbo].[Resource] R1 ON R1.Id = CDL.CustomInstallLogResourceId AND R1.Id>0
	  LEFT JOIN [ReleaseManagement].[dbo].[Resource] R2 ON R2.Id = CDL.AutoInstallLogResourceId AND R2.Id>0
	 WHERE RS.ReleaseId = @releaseId and RS.Id = @ReleaseStepId
	 ORDER BY ISNULL(CDL.DateStarted, GETUTCDATE()) DESC
END
