CREATE PROCEDURE [dbo].[DevOps_TagName_Serverlist]
@TagName VARCHAR(255) =''
, @ServerName VARCHAR(255)=''
, @EnvironmentName VARCHAR(255)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [Tags]
		 , [TagName]
		 , [ServerName]
		 , [DNSName]
		 , [HOSTNAME]
		 , [EnvironmentName]
		 , [ServerID]
		 , [EnvironmentId]
	 FROM [dbo].[vw_Server_TagName]
	WHERE (CASE WHEN @TagName='' THEN '1' ELSE TagName END)
		  LIKE (CASE WHEN @TagName='' THEN '1' ELSE '%'+@TagName+'%' END)
	  AND (CASE WHEN @EnvironmentName='' THEN '1' ELSE EnvironmentName END)
		  = (CASE WHEN @EnvironmentName='' THEN '1' ELSE +@EnvironmentName END)
			 
	  AND (CASE WHEN @ServerName='' THEN '1' ELSE ServerName END)
		  LIKE (CASE WHEN @ServerName='' THEN '1' ELSE '%'+@ServerName+'%' END)
	ORDER BY 1
END

