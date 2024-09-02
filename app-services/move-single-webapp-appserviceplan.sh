#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <source-resource-group> <web-app-name> <source-service-plan> <destination-service-plan-resource-group> <destination-service-plan>"
    exit 1
fi

# Variables from command-line arguments
subscriptionId="<subscriptionId>" #Set to subscriptionId
sourceResourceGroupName=$1
webAppName=$2
sourceServicePlanName=$3
destinationServicePlanResourceGroup=$4
destinationServicePlanName=$5

# Get the service plan ID of the destination service plan
destinationServicePlanId=$(az appservice plan show --name $destinationServicePlanName --resource-group $destinationServicePlanResourceGroup --query "id" -o tsv)

if [ -z "$destinationServicePlanId" ]; then
    echo "Destination service plan not found: $destinationServicePlanName in resource group: $destinationServicePlanResourceGroup"
    exit 1
fi

# Move the web app to the destination service plan
echo "Moving web app: $webAppName"
az webapp update --name $webAppName --resource-group $sourceResourceGroupName --set serverFarmId="$destinationServicePlanId"
echo "Moved $webAppName to $destinationServicePlanName in resource group $destinationServicePlanResourceGroup"