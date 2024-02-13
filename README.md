# Dockerized Daily-Refreshing Local Database Mirror from Azure Blob Storage

This Docker container is designed to automatically download the latest database backup in a `bacpac` format from an Azure Blob Storage container and import it into
the included local, dockerized MSSQL Server instance. 

On the first run, the container will attempt to connect to an Azure Blob Storage account. It will try to locate the most recently uploaded file in a blob container. 
If the script locates a file, it will download it to `/sql/backup.bacpac`. Once the backup file is successfully downloaded, the script will perform an 
import operation using Microsoft's [SqlPackage](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage?view=sql-server-ver16).

After the import operation is completed, the startup script will setup a configurable cron job, preconfigured to run daily at 4am. The cron
job runs a script that kills all active database server connections, renames the existing restored database to include the day's date, and
performs a new download-restore process similar to the one at the startup. 



## Tech Stack

- [Docker](https://www.docker.com/)
- [Microsoft SQL Server](https://hub.docker.com/_/microsoft-mssql-server)
- [Microsoft SqlPackage](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage?view=sql-server-ver16)
- [Microsoft Azure Cli](https://learn.microsoft.com/en-us/cli/azure/)


## Usage/Examples

Since this image is based off Microsoft's [SQL Server Docker image](https://hub.docker.com/_/microsoft-mssql-server), it inherits and exposes the same environment variables. For comprehensive documentation on the SQL Server configuration, please refer to their documentation. 

This docker introduces the following new options, configured via environment variable:
- `ACCOUNT_NAME` - The Azure Blob Storage Account Name
- `ACCOUNT_KEY` - The Azure Blob Storage Account Shared Key
- `CONTAINER_NAME` - The name of the Azure Blob Storage container 
- `CRON_SCHEDULE` - The cron schedule to use for the periodic database refresh
- `DATABASE_NAME` - The name to use for the local database when importing the bacpac

The following `docker run` command will download and instantiate a new instance of the docker container and configure it with some default settings. You must substitute your own Azure Blob Storage credentials in the commmand.

```
docker run  -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=yourStrong(!)Password" \
            -e "ACCOUNT_NAME=<YOUR_AZURE_STORAGE_ACCOUNT>" \
            -e "ACCOUNT_KEY=<YOUR_AZURE_STORAGE_KEY>"\
            -e "CONTAINER_NAME=<YOUR_AZURE_STORAGE_CONTAINER_NAME>" \
            -e "DATABASE_NAME=MyDatabase \
            -p 1433:1433 --name sqlserver -it jdhproductions/az-bacpac-blob-mssql-importer:latest  
```