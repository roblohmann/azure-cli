#!/bin/bash

#https://pixelrobots.co.uk/2020/02/purge-container-images-from-azure-container-registry-acr-on-demand-or-on-a-schedule/
#https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auto-purge

# Variables from command-line arguments
SUBSCRIPTION_ID=$1
REGISTRY_NAME=$2

# Set the subscription
az account set --subscription $SUBSCRIPTION_ID

#WERKEND
PURGE_CMD="acr purge --filter '.*:^((?!latest).)*$' --ago 30d --keep 10 --untagged --concurrency 3"

az acr run \
  --cmd "$PURGE_CMD" \
  --registry $REGISTRY_NAME \
  /dev/null