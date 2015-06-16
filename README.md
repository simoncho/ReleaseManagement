# ReleaseManagement

This is ReleaseManagement based on Reporting service.<br>
I'm running on our company without anyproblem.<br>
Please use it as own your risk.<br>
Free license for testing, update, modification and distribute.<br>
This version is working up to releaseManagement 12.0.31101.0.

#Contents
##Reporting Service
###[Developer] : Reporting service project
Designed by Developer roles.<br>
Please modified one of the view "[dbo].[vw_StageType_FOR_DevAll]".<br>
Developer can see the stage up to this view's result.<br>
###[DevOps] : Reporting service project
Designed by DevOps roles.<br>
Doesn't have limitation for permission.<br>

##[Reporting_Repository] : Database project
This is small database for store all related tables, procedures and e.t.c.<br>
DB_Owner permission required.<br>
Note : Backup and extra maintenance are your resposibility. For me, no maintenance need. All the source is in the TFS.<br>
This database do not growing. Simple recovery mode is fine.<br>

#Term
$TFS_Server : TFS database servername<br>
$TFS_Database : TFS database name

#Step for installation
1.Setup Reporting service.<br>
2.Deploy [Developer] and [DevOps] to the reporting service server.<br>
3.Create empty database [Reporting_Repository] on same DB server of ReleaseManagement.<br>
4.Create linked server to TFS_Server with read permission<br>
Note : If you using same DB server as ReleaseManagement, skip this part. Please just add read access permission.
5.Create SQL user with below permission<br>
Reporting_Repository : DB_Owner<br>
ReleaseManagement : DB_Datareader<br>
TFS_Database : DB_datareader<br>
6.Update 2 data sources on Reporting server.
AllDev_Report_RepositoryDS : Update it use SQL authentication.<br>
DevOps_Report_RepositoryDS : Update it use SQL authentication.

#Example screen shot.
Please check those 2 files.

_Readme_EX)ScreenShot_Dev_All_InReleaseDeployLog.jpg
_Readme_EX)ScreenShot_Dev_All_TFSInRelease_DeploySummary.jpg
