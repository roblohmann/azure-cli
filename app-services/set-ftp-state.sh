#!/bin/bash

# Set these variables (leave them empty if not applicable)
SUBSCRIPTION_ID=$1
RESOURCE_GROUP=$2
APP_SERVICE_NAME=$3

# Check if a specific subscription is provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: You must provide a subscription ID."
    exit 1
fi

# Set the subscription
az account set --subscription $SUBSCRIPTION_ID

# Function to update FTP state for a specific App Service
update_ftp_state() {
    local rg=$1
    local app_name=$2

    # Get all slots including the production slot
    slots=$(az webapp deployment slot list --resource-group "$rg" --name "$app_name" --query "[].name" -o tsv)
    slots+=" production" # Adding production slot as it's not returned in the slot list

    for slot in $slots; do
        # Get the current FTP state
        FTP_STATE=$(az webapp config show --resource-group "$rg" --name "$app_name" --slot "$slot" --query "ftpsState" -o tsv)

        echo "App Service: $app_name, Slot: $slot, Current FTP State: $FTP_STATE"

        # Check if FTP is allowed
        if [ "$FTP_STATE" == "AllAllowed" ]; then
            # Change to FTPS Only
            echo "Changing FTP state to FTPS Only for App Service: $app_name, Slot: $slot"
            az webapp config set --resource-group "$rg" --name "$app_name" --slot "$slot" --ftps-state FtpsOnly
        else
            echo "No changes needed for App Service: $app_name, Slot: $slot"
        fi
    done
}

# Case 1: Specific Resource Group and App Service Name provided
if [ -n "$RESOURCE_GROUP" ] && [ -n "$APP_SERVICE_NAME" ]; then
    update_ftp_state "$RESOURCE_GROUP" "$APP_SERVICE_NAME"

# Case 2: Only Resource Group provided
elif [ -n "$RESOURCE_GROUP" ]; then
    app_services=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
    for app in $app_services; do
        update_ftp_state "$RESOURCE_GROUP" "$app"
    done

# Case 3: No Resource Group, apply to all App Services in the subscription
else
    app_services=$(az webapp list --query "[].{name:name,resourceGroup:resourceGroup}" -o tsv)
    while IFS=$'\t' read -r rg app_name; do
        update_ftp_state "$rg" "$app_name"
    done <<< "$app_services"
fi

echo "Script execution completed."
