#!/bin/bash

# wait 30 seconds for SQL Server to start up
echo "Waiting for SQL Server to start"
sleep 30s

# Download the bacpac file from the Azure Blob Storage
echo "Downloading bacpac file from Azure Blob Storage"
bash /sql/download-latest.sh $ACCOUNT_NAME $ACCOUNT_KEY $CONTAINER_NAME /sql/backup.bacpac
backupJob=$?

if [ "$backupJob" -eq 0 ]
then
    echo "Successfully downloaded bacpac file from Azure Blob Storage!"
    echo "Enabling SQL Server authentication..."
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -d master -i /sql/enable-authentication.sql
    echo "SQL Server authentication enabled. Waiting for 10 seconds before importing the bacpac file..."
    sleep 10s

    # Import the bacpac file into the SQL Server
    /sql/sqlpackage/sqlpackage /a:import /sf:/sql/backup.bacpac /tsn:localhost,1433 /tdn:$DATABASE_NAME /tu:sa /tp:$MSSQL_SA_PASSWORD /ttsc:True 

    # Set up 4am CRON job to re-import the database
    echo "Setting up CRON job to re-import the database at 4am every day"
    echo "$CRON_SCHEDULE /bin/bash /sql/reimport-database.sh" | crontab -
    echo "CRON job set up successfully"
    exit 0
else
    echo "Failed to download bacpac file from Azure Blob Storage"
    exit 1
fi