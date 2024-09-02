#!/bin/bash

#https://pixelrobots.co.uk/2020/02/purge-container-images-from-azure-container-registry-acr-on-demand-or-on-a-schedule/
#https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auto-purge

# Variables from command-line arguments
SUBSCRIPTION_ID=$1
REGISTRY_NAME=$2
TASK_NAME=$3

# Set the subscription
az account set --subscription $SUBSCRIPTION_ID

PURGE_CMD="acr purge --filter '.*:^((?!latest).)*$' --ago 40d --keep 10 --untagged --concurrency 3"

az acr task create --name $TASK_NAME \
  --cmd "$PURGE_CMD" \
  --schedule "30 6 * * *" \
  --registry $REGISTRY_NAME \
  --context /dev/null