Declare
@DB_name VARCHAR(255),
@table_name VARCHAR(255),
@backup_table_name_ext VARCHAR(255)

set @DB_name = '<YourDatabaseName>' 
set @table_name = '<YourTableNameToBeBackuped>'

set  @backup_table_name_ext = REPLACE(CONVERT(varchar, GETDATE(),102),'.','')

EXEC('SELECT * INTO ['+@DB_name+'].[dbo].['+@table_name+'_backup_' + @backup_table_name_ext + '] FROM ['+@DB_name+'].[dbo].['+@table_name+']')
