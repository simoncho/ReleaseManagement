CREATE VIEW [dbo].[vw_Server_TagName]
AS
SELECT ES.Tags, s.Name AS ServerName, s.DnsName AS DNSName
	 , ISNULL(ISNULL(ISNULL(PARSENAME(s.Name,4),PARSENAME(s.Name,3)),PARSENAME(s.Name,2)), PARSENAME(s.Name,1)) AS HOSTNAME
	 , B.ELEMENT AS TagName
	 , E.NAME AS EnvironmentName
	 , s.Id AS ServerID
	 , e.Id AS EnvironmentId
  FROM [ReleaseManagement].[dbo].[server] s WITH(NOLOCK)
  LEFT OUTER JOIN [ReleaseManagement].[dbo].Environment_Server ES WITH(NOLOCK) ON ES.serverid = s.Id AND s.IsDeleted=0
  LEFT OUTER JOIN [ReleaseManagement].[dbo].Environment E WITH(NOLOCK) ON ES.EnvironmentId = E.Id
 OUTER APPLY [dbo].fn_Split(ES.Tags, ',') B
 WHERE S.IsDeleted = 0 AND S.StatusId=2