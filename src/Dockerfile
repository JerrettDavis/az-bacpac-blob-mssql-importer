FROM mcr.microsoft.com/mssql/server:2022-CU11-ubuntu-22.04


ARG ACCOUNT_NAME
ENV ACCOUNT_NAME=$ACCOUNT_NAME
ARG ACCOUNT_KEY
ENV ACCOUNT_KEY=$ACCOUNT_KEY
ARG CONTAINER_NAME
ENV CONTAINER_NAME=$CONTAINER_NAME

ARG CRON_SCHEDULE="0 4 * * *"
ENV CRON_SCHEDULE=$CRON_SCHEDULE

ARG DATABASE_NAME=MyDatabase
ENV DATABASE_NAME=$DATABASE_NAME
ENV MSSQL_SA_PASSWORD=yourStrong(!)Password
ENV ACCEPT_EULA=Y
ENV MSSQL_PID=Developer

COPY . /sql
WORKDIR /sql

# Root needed for apt-get install, switch to mssql after
USER root

RUN mkdir /home/mssql && chown mssql /home/mssql && \
    chmod +x /sql/initialize-database-and-jobs.sh && \
    chmod +x /sql/entrypoint.sh && \
    chmod +x /sql/download-latest.sh

# Install Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip cron wget apt-transport-https \ 
    software-properties-common ca-certificates curl \
    apt-transport-https lsb-release gnupg && \
    rm -rf /var/lib/apt/lists/*

# Install SQLPackage for Linux and make it executable
RUN wget -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux \
    && unzip -qq sqlpackage.zip -d /sql/sqlpackage \
    && chmod +x /sql/sqlpackage/sqlpackage \
    && rm sqlpackage.zip

# Install az cli
RUN mkdir -p /etc/apt/keyrings && \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg && \
    AZ_DIST=$(lsb_release -cs) && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" | \
    tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install azure-cli && \
    rm -rf /var/lib/apt/lists/*

RUN chown -R mssql:mssql /sql

# Switch back to mssql user
USER mssql

EXPOSE 1433

CMD /bin/bash ./entrypoint.sh