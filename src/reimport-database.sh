#!/bin/bash

echo "Downloading bacpac file from Azure Blob Storage"
bash /sql/download-latest.sh $ACCOUNT_NAME $ACCOUNT_KEY $CONTAINER_NAME /sql/backup.bacpac
backupJob=$?
if [ "$backupJob" -eq 0 ]
then
    echo "Successfully downloaded bacpac file from Azure Blob Storage!"
    echo "Kill all connections to the database"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -d master -i /sql/kill-all-connections.sql
    databaseName=$DATABASE_NAME
    existingDatabaseName="${databaseName}_$(date +%s)"
    echo "Renaming existing database to $existingDatabaseName"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -d master -Q "ALTER DATABASE $databaseName MODIFY NAME = $existingDatabaseName;"
    echo "Renamed existing database to $existingDatabaseName"
    echo "Importing bacpac file into the SQL Server"
    /sql/sqlpackage/sqlpackage /a:import /sf:/sql/backup.bacpac /tsn:localhost,1433 /tdn:$DATABASE_NAME /tu:sa /tp:$MSSQL_SA_PASSWORD /ttsc:True 
else
    echo "Failed to download bacpac file from Azure Blob Storage"
    exit 1
fi
