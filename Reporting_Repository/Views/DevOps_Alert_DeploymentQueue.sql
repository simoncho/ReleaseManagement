CREATE VIEW [dbo].[DevOps_Alert_DeploymentQueue]
AS
SELECT *
  FROM [ReleaseManagement].[dbo].[DeploymentQueue]
 WHERE CreatedOn <= DATEADD(HH, -12, GETUTCDATE())