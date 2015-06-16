CREATE Procedure [dbo].[Dev_Get_AutoRefresh_Value]
@ReleaseId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT TOP 1 (CASE WHEN SST.Id = 5 THEN 0 ELSE 30 END) AS AutoRefresh -- SST.id=5 : Validate Deployment, 0:Disable.
	  FROM [ReleaseManagement].[dbo].ReleaseStep RS
	  JOIN [ReleaseManagement].[dbo].Stage S on S.Id = RS.StageId
	  --JOIN [ReleaseManagement].[dbo].StageType ST on ST.Id = RS.StageTypeId
	  JOIN dbo.vw_StageType_FOR_DevAll ST on ST.Id = RS.StageTypeId
	  JOIN [ReleaseManagement].[dbo].StageStepType SST on SST.Id = RS.StepTypeId
	  JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS on RSS.Id = RS.StatusId
	  --JOIN [ReleaseManagement].[dbo].ReleaseStepOwner RSO on RSO.Id = RS.Id
	 WHERE RS.ReleaseId = @releaseId
	  -- AND (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE RS.ID END) = (CASE WHEN @ReleaseStepId IS NULL THEN 1 ELSE @ReleaseStepId END)
	 ORDER BY RS.ID DESC
END

