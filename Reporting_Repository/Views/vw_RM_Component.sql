CREATE VIEW [dbo].[vw_RM_Component]
AS

SELECT c.Id AS ComponentId
	 , c.Name AS ComponentName
	 , c.PackageLocation
	 , c.FileExtensionFilter
	 , c.Command
	 , DT.Name AS ToolName
	 , c.Arguments
	 , c.Timeout
	 , cat.Name AS ComponentType
	 , VR.Name AS ReplacementMode
	 , AV.Name AS TemplateName
	 , RP.NAME AS Path
	 , AVSA.TagName AS TagName
	 , e.Name AS EnvironmentName
	 , SUBSTRING(S.HOSTNAME, 1, LEN(S.HOSTNAME)-1) AS ServerList
  FROM [ReleaseManagement].[dbo].[ApplicationVersion] AV WITH(NOLOCK)
  JOIN [ReleaseManagement].[dbo].ReleasePath RP WITH(NOLOCK) ON AV.ReleasePathId = RP.Id
  JOIN [ReleaseManagement].[dbo].[ApplicationVersionStage] AVS WITH(NOLOCK) ON AV.id = AVS.ApplicationVersionId AND AV.IsDeleted = 0 AND av.statusid=2
  JOIN [ReleaseManagement].[dbo].[ApplicationVersionStageActivity] AVSA WITH(NOLOCK) ON AVS.id = AVSA.ApplicationVersionStageId
  JOIN [ReleaseManagement].dbo.Stage st WITH(NOLOCK) ON avs.StageId = st.Id AND st.IsDeleted=0
  JOIN [ReleaseManagement].dbo.Environment e WITH(NOLOCK) ON st.EnvironmentId = e.Id AND e.IsDeleted =0
  JOIN [ReleaseManagement].[dbo].[Component] C WITH(NOLOCK) ON AVSA.ComponentId = C.Id
  JOIN [ReleaseManagement].[dbo].VariableReplacementMode VR WITH(NOLOCK) ON C.VariableReplacementModeId = VR.Id
  JOIN [ReleaseManagement].[dbo].[ComponentActionType] CAT WITH(NOLOCK) ON c.ActionTypeId = cat.Id
  LEFT OUTER JOIN [ReleaseManagement].[dbo].[DeployerTool] DT WITH(NOLOCK) ON C.[DeployerToolId] = DT.Id
  LEFT OUTER JOIN [ReleaseManagement].[dbo].[server] S1 ON AVSA.ServerId= s1.Id AND s1.id>0
 OUTER APPLY (
				SELECT DISTINCT HOSTNAME+','
				  FROM [dbo].vw_Server_TagName S 
				 WHERE E.Id = S.EnvironmentId 
				   AND (CASE
							WHEN AVSA.ServerId>0 THEN CONVERT(VARCHAR(255), AVSA.ServerId)
							WHEN avsa.TagName>='' THEN avsa.TagName
							ELSE '0'
						END)
					 = (CASE
							WHEN AVSA.ServerId>0 THEN CONVERT(VARCHAR(255), s.Serverid)
							WHEN avsa.TagName>='' THEN s.TagName
							ELSE '1'
						END)
			     ORDER BY 1
				   FOR XML PATH('')
			  ) S(HOSTNAME)
WHERE 1=1