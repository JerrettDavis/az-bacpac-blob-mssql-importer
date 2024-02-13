-- kill all connections to the database
DECLARE @killCommand NVARCHAR(MAX) = '';

SELECT @killCommand = @killCommand + 'KILL ' + CAST(spid AS VARCHAR) + ';' 
FROM sys.sysprocesses 
WHERE dbid > 4;

EXEC sp_executesql @killCommand;
