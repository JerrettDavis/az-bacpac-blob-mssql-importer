#!/bin/bash

# Description: This script downloads the latest backup from an Azure Storage Account
# Usage: bash DownloadLatest.sh <storageAccountName> <storageAccountKey> <containerName> <localPath>

accountName=$1
accountKey=$2
containerName=$3
localPath=${4:-"./backup.bacpac"}

# Get the name of the latest blob
firstBlob=$(az storage blob list --account-key $accountKey --account-name $accountName -c $containerName --query "[?properties.lastModified!=null]|[?ends_with(name, '.bacpac')]|[0].name" -o tsv)

# Check if $firstBlob is not null (i.e., there are blobs found)
if [ -n "$firstBlob" ]; then
    az storage blob download --account-key $accountKey --account-name $accountName -c $containerName --name $firstBlob --file $localPath --output none
    exit 0
else
    exit 1
fi