CREATE Procedure [dbo].[DevOps_Get_ReleaseLog_Header]
@ReleaseId INT
, @ReleaseStepId Int = NULL
as
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--DECLARE @releaseId int
	Declare @TrialNumber SMALLINT, @StageTypeName Varchar(255), @StatusName VARCHAR(255), @CreatedOn DATETIME
	DECLARE @hh_Diff_Timezone INT
	SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())
	SELECT RS.Id as ReleaseStepId
		 , DATEADD(hh, @hh_Diff_Timezone, RS.CreatedOn) as CreatedOn
		 , ST.Name as StageTypeName
		 , RS.TrialNumber as [TrialNumber]
		 , SST.Name as [StatusName]
		 , @ReleaseId as ReleaseId
	  FROM [ReleaseManagement].[dbo].ReleaseStep RS
	  JOIN [ReleaseManagement].[dbo].Stage S on S.Id = RS.StageId
	  JOIN [ReleaseManagement].[dbo].StageType ST on ST.Id = RS.StageTypeId
	  JOIN [ReleaseManagement].[dbo].StageStepType SST on SST.Id = RS.StepTypeId
	  JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS on RSS.Id = RS.StatusId
	  --JOIN [ReleaseManagement].[dbo].ReleaseStepOwner RSO on RSO.Id = RS.Id
	WHERE RS.ReleaseId = @releaseId
	  -- AND (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE RS.ID END) = (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE @ReleaseStepId END)
	 ORDER BY RS.ID DESC
END
