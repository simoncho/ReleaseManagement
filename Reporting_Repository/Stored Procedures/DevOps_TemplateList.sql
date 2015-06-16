
CREATE Procedure [dbo].[DevOps_TemplateList]
@Template VARCHAR(255) = 'All'
, @BuildDefinition VARCHAR(255)  = 'All'
, @IsActive VARCHAR(255) = 'Active'
, @ReleasePath VARCHAR(255) = 'All'
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
	SELECT AV.NAME AS Template, AV.BuildDefinition, AVS.Name as IsActive, RP.Name AS RepleasePath, AV.CreatedOn, AV.ModifiedOn, U.DisplayName AS CreatedBy, U2.DisplayName AS ModifiedBy
	  from [ReleaseManagement].[dbo].[ApplicationVersion] AV
	  JOIN [ReleaseManagement].[dbo].[ApplicationVersionStatus] AVS
		ON AV.StatusId = AVS.Id
	  JOIN [ReleaseManagement].[dbo].[ReleasePath] RP
		ON AV.ReleasePathId = RP.Id
	  JOIN [ReleaseManagement].[dbo].[User] U
		ON AV.CreatedById = U.Id
	  LEFT OUTER JOIN [ReleaseManagement].[dbo].[User] U2
		ON AV.ModifiedById = U2.Id
	 WHERE AV.IsDeleted=0
	   AND CASE WHEN @Template ='ALL' THEN @Template ELSE AV.Name END
		 = CASE WHEN @Template ='ALL' THEN @Template ELSE @Template END
	   AND CASE WHEN @BuildDefinition ='ALL' THEN @BuildDefinition ELSE AV.BuildDefinition END
		 = CASE WHEN @BuildDefinition ='ALL' THEN @BuildDefinition ELSE @BuildDefinition END
	   AND CASE WHEN @IsActive ='ALL' THEN @IsActive ELSE AVS.Name END
		 = CASE WHEN @IsActive ='ALL' THEN @IsActive ELSE @IsActive END
	   AND CASE WHEN @ReleasePath ='ALL' THEN @ReleasePath ELSE RP.Name END
		 = CASE WHEN @ReleasePath ='ALL' THEN @ReleasePath ELSE @ReleasePath END
	 ORDER BY AV.Name
END

