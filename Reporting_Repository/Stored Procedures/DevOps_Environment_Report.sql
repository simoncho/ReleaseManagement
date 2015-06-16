CREATE Procedure [dbo].[DevOps_Environment_Report]
@Environment varchar(255) = ''
, @TechType varchar(255) = ''
, @Status varchar(255) = ''
, @IsClone varchar(255) = ''
, @ServerName varchar(255) = ''
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT S.Id
     , S.Name
     , S.DnsName
     , S.IPAddress
     , (CASE S.IPAddressType WHEN 1 THEN 'Server' ELSE 'Gateway' END) AS IPType
     , SS.Name as Status
     , S.IsCloned
     , (CASE S.TransferFileOverHTTP WHEN 1 THEN 'http(s)' ELSE 'UNC' END) AS FileAccess
     , STC_NAME AS TechType
	 , EV.Environment
	 , DS.Name AS [DeployerStatus]
	 , D.Error AS [DeployerMSG]
	 , D.[Version] AS [Deployer]
	 , S.Description
	 , u.DisplayName as OwnerName
	 , S.CreatedOn
     , S.ModifiedOn
	 , d.Version
  FROM [ReleaseManagement].[dbo].[Server] S
  JOIN [ReleaseManagement].[dbo].[ServerStatus] SS
    ON S.StatusId = SS.Id
  LEFT JOIN [ReleaseManagement].dbo.Deployer D on D.ServerId = S.Id
  LEFT JOIN [ReleaseManagement].dbo.DeployerStatus DS on DS.Id = D.StatusId
  LEFT JOIN [ReleaseManagement].[dbo].[User] U ON U.[Id] = S.[OwnerId]
  OUTER APPLY (SELECT STUFF((SELECT ', '+ ISNULL(TC.Name,'')
							   FROM [ReleaseManagement].[dbo].[Server_TechnologyCategory] STC
							   JOIN [ReleaseManagement].[dbo].[TechnologyCategory] TC ON STC.TechnologyCategoryId = TC.Id AND TC.IsDeleted = 0
							  WHERE STC.ServerId = S.Id
							    FOR XML PATH('')), 1, 1, '') AS STC_NAME
			   ) STC
  OUTER APPLY (SELECT STUFF((SELECT ', ' + E.Name
							   FROM [ReleaseManagement].dbo.Environment E
							   JOIN [ReleaseManagement].dbo.Environment_Server ES
							     ON ES.EnvironmentId = E.Id AND ES.ServerId = S.Id
								AND E.StatusId=2 AND E.IsDeleted = 0
							  ORDER BY E.Name
								FOR XML PATH('')), 1 , 1, '') AS Environment 
              ) EV
 WHERE S.IsDeleted=0 AND S.Id>0
   AND CASE WHEN @Environment>'' THEN EV.Environment ELSE '1' END LIKE CASE WHEN @Environment>'' THEN '%'+@Environment+'%' ELSE '1' END 
   AND CASE WHEN @TechType>'' THEN STC_NAME ELSE '1' END LIKE CASE WHEN @TechType>'' THEN '%'+@TechType+'%' ELSE '1' END 
   AND CASE WHEN @Status>'' THEN SS.Name ELSE '1' END = CASE WHEN @Status>'' THEN @Status ELSE '1' END 
   AND CASE WHEN @IsClone>'' THEN IsCloned ELSE 1 END = CASE WHEN @IsClone>'' THEN @IsClone ELSE 1 END 
   AND CASE WHEN @ServerName>'' THEN S.NAME ELSE '1' END LIKE CASE WHEN @ServerName>'' THEN '%'+@ServerName+'%' ELSE '1' END 
END
