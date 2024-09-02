#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <source-resource-group> <destination-resource-group> <source-service-plan> <destination-service-plan>"
    exit 1
fi

echo "all params supplie, starting.."

# Variables from command-line arguments
subscriptionId=$1
sourceResourceGroupName=$2
destinationResourceGroupName=$3
sourceServicePlanName=$4
destinationServicePlanName=$5

# Get the list of web apps in the source service plan
echo "Getting webapps to move"
webapps=$(az webapp list --query "[?appServicePlanId=='/subscriptions/$subscriptionId/resourceGroups/$sourceResourceGroupName/providers/Microsoft.Web/serverfarms/$sourceServicePlanName'].name" -o tsv)
echo "Getting webapps done"

# Loop through the web apps and move each one to the destination service plan
for webapp in $webapps; do
    echo "Moving web app: $webapp"
    az webapp update --name $webapp --resource-group $sourceResourceGroupName --set serverFarmId="/subscriptions/$subscriptionId/resourceGroups/$destinationResourceGroupName/providers/Microsoft.Web/serverfarms/$destinationServicePlanName"
    echo "Moved $webapp to $destinationServicePlanName in resource group $destinationResourceGroupName"
done