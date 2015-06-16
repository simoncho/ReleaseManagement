CREATE VIEW [dbo].[DevOps_Alert_InstancesTable]
AS
SELECT A.ID, A.SurrogateInstanceId, A.SurrogateIdentityId, A.CreationTime, A.LastUpdated, A.BlockingBookmarks, A.ExecutionStatus
  FROM [ReleaseManagement].[System.Activities.DurableInstancing].[InstancesTable] A
  --LEFT OUTER JOIN [InRelease].[System.Activities.DurableInstancing].[RunnableInstancesTable] B
  --  ON A.SurrogateInstanceId = B.SurrogateInstanceId
  -- AND A.SurrogateIdentityId = B.SurrogateIdentityId
 WHERE A.CreationTime <= DATEADD(HH, -12, GETUTCDATE())
   AND BlockingBookmarks NOT LIKE '%Manual Intervention%'