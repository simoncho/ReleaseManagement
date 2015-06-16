
CREATE Procedure [dbo].[DevOps_Get_Release]
@BuildDefinition varchar(255) = 'INT'
, @Build varchar(255) = ''
, @Period varchar(255) = '1 Day'
, @Status varchar(255) = 'Released'
, @ReleasePath varchar(255) = 'Standard Release Path'
as
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--DECLARE @BuildDefinition varchar(255) = 'INT'
	--	  , @Build varchar(255) = 'All'
	--	  , @Period varchar(255) = '7 Days'
	--	  , @Status varchar(255) = 'Released'
	DECLARE @StartDate DATETIME
    DECLARE @hh_Diff_Timezone INT
	SET @hh_Diff_Timezone = DATEDIFF(hh, GETUTCDATE(), GETDATE())

	SET @Build = ISNULL(@Build,'')
	SET @BuildDefinition = ISNULL(@BuildDefinition,'')
	
	SET @StartDate = DATEADD(DD, -1, GETUTCDATE())

	IF @Period = '12 Hours'
		SET @StartDate = DATEADD(HH, -12, GETUTCDATE())
	ELSE IF @Period = '1 Day'
		SET @StartDate = DATEADD(DD, -1, GETUTCDATE())
	ELSE IF @Period = '7 Days'
		SET @StartDate = DATEADD(DD, -7, GETUTCDATE())
	ELSE IF @Period = '14 Days'
		SET @StartDate = DATEADD(DD, -14, GETUTCDATE())
	ELSE IF @Period = '30 Days'
		SET @StartDate = DATEADD(DD, -30, GETUTCDATE())
	
	SELECT R.Id AS ReleaseID
		 , r.Name
		 , r.BuildDefinition
		 , r.Build
		 , DATEADD(hh, @hh_Diff_Timezone, r.CreatedOn) AS CreatedOn
		 , DATEADD(hh, @hh_Diff_Timezone, r.ModifiedOn) AS LastUpdate
		 , Convert(VARCHAR(255), R.ModifiedOn - R.CreatedOn, 108) AS Duration
		 , RS.Name AS Status
		 , RP.Name AS RepleasePath
		 , ST.Name AS TargetStage
		 , CurrentStage.StageTypeName AS CurrentStage
		 , CurrentStage.StepStatus AS CurrentStageStatus
	  FROM [ReleaseManagement].[dbo].Release R
	  JOIN [ReleaseManagement].[dbo].ReleaseStatus RS
		ON R.StatusId = RS.Id
	  JOIN [ReleaseManagement].[dbo].ReleasePath RP 
	    ON R.ReleasePathId = RP.Id
	 CROSS APPLY (SELECT TOP 1 st.Name as StageTypeName, RSS.Name AS StepStatus, RS.ModifiedOn AS StepLastUpdate
					FROM [ReleaseManagement].[dbo].ReleaseStep RS
					JOIN [ReleaseManagement].[dbo].ReleaseStepStatus RSS ON RS.StatusId = RSS.Id
					JOIN [ReleaseManagement].[dbo].Stage S ON RS.StageId = S.Id
					JOIN [ReleaseManagement].[dbo].StageType ST ON S.StageTypeId = ST.Id
				   WHERE RS.ReleaseId = R.Id
				   ORDER BY RS.Id DESC
				  ) AS CurrentStage
	  JOIN [ReleaseManagement].[dbo].Stage S
	    ON R.TargetStageId = S.Id
	  JOIN [ReleaseManagement].[dbo].StageType ST
	    ON S.StageTypeId = ST.Id
	 WHERE 1=1 --(CASE WHEN @NAME = 'ALL' THEN '1' ELSE R.Name END) LIKE '%'+(CASE WHEN @NAME = 'ALL' THEN '1' ELSE @NAME END)+'%'
	   AND (CASE WHEN @BuildDefinition = '' THEN '1' ELSE r.BuildDefinition END) LIKE '%'+(CASE WHEN @BuildDefinition = '' THEN '1' ELSE @BuildDefinition END)+'%'
	   AND (CASE WHEN @Build = '' THEN '1' ELSE r.Build END) LIKE '%'+(CASE WHEN @Build = '' THEN '1' ELSE @Build END)+'%'
	   AND (CASE WHEN @Status = '' THEN '1' ELSE RS.Name END) = (CASE WHEN @Status = '' THEN '1' ELSE @Status END)
	   AND R.ModifiedOn > @StartDate
	   AND (CASE WHEN @ReleasePath = '' THEN '1' ELSE RP.Name END) = (CASE WHEN @ReleasePath = '' THEN '1' ELSE @ReleasePath END)
	 ORDER BY r.ModifiedOn DESC
END

