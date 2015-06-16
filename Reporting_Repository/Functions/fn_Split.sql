-- =============================================
-- Author:		Simon Cho
-- Create date: 5/27/2014
-- Description:	Split @str based on @splitValue and return as Table.
-- Requirement : dbo.num table should has serial number. Check permission as well for Ad hoc query.
-- Known issue : len(@str) should less than max(num) on dbo.num. Currently, it has 100,000.
/*
IF OBJECT_ID('dbo.NUM') IS NOT NULL
	DROP TABLE NUM

CREATE TABLE NUM
(N int)

CREATE UNIQUE CLUSTERED INDEX CL_NUM ON NUM(N)

INSERT INTO NUM WITH(TABLOCK) (N)
SELECT TOP (100000) ROW_NUMBER() OVER (ORDER BY GETDATE()) AS N
	FROM master.dbo.spt_values A WITH(NOLOCK)
	CROSS JOIN master.dbo.spt_values B WITH(NOLOCK)
*/
-- =============================================
CREATE FUNCTION [dbo].[fn_Split](@str varchar(max), @splitValue char(1)=',')
RETURNS TABLE 
AS
RETURN 
(
	SELECT N-LEN(REPLACE(LEFT(@str, N), @splitValue, '')) + 1 AS POS
		 , SUBSTRING(@str, N, CHARINDEX(@splitValue, @str+@splitValue, N) - N) AS ELEMENT
	  FROM dbo.NUM
	 WHERE N <= LEN(@str) AND SUBSTRING(','+@str, N, 1)= @splitValue
)
;
