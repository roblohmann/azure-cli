#!/bin/bash

if [ "$1" = "" ]; then
    echo "No name for AKS-cluster provided!"
    exit 1
fi

if [ "$2" = "" ]; then
    echo "No resource-group for AKS-cluster provided!"
    exit 1
fi

AKS_CLUSTER_NAME=$1
AKS_CLUSTER_RG=$2

echo 'starting cluster ' + $AKS_CLUSTER_NAME
az aks stop --name $AKS_CLUSTER_NAME --resource-group $AKS_CLUSTER_RG
echo 'starting cluster ' + $AKS_CLUSTER_NAME + ' - DONE'