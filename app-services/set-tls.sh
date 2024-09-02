#!/bin/bash

# Set these variables (leave them empty if not applicable)
SUBSCRIPTION_ID=$1
RESOURCE_GROUP=$2
APP_SERVICE_NAME=$3
REQUESTED_TLS=$4

# Check if a specific subscription is provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: You must provide a subscription ID."
    exit 1
fi

# Set the subscription
az account set --subscription $SUBSCRIPTION_ID

# Functions to update FTP state for a specific App Service
update_ftp_state_for_slot() {
    local rg=$1
    local app_name=$2
    local slot=$3
    local desired_tls_version=$4

    echo "Changing FTP state to FTPS Only for App Service: $app_name, Slot: $slot"
    az webapp config set --resource-group "$rg" --name "$app_name" --slot "$slot" --min-tls-version $desired_tls_version -o none
    echo " "
}

update_ftp_state() {
    local rg=$1
    local app_name=$2
        local desired_tls_version=$4
    
    echo "Changing FTP state to FTPS Only for App Service: $app_name, Slot: production"
    az webapp config set --resource-group "$rg" --name "$app_name" --min-tls-version $desired_tls_version -o none
    echo " "
    
    # Get all slots including the production slot
    slots=$(az webapp deployment slot list --resource-group "$rg" --name "$app_name" --query "[].name" -o tsv)
    #slots+=" PRODUCTION" # Adding production slot as it's not returned in the slot list

    for slot in $slots; do
        update_ftp_state_for_slot "$rg" "$app_name" "$slot" "$desired_tls_version"
    done
}

desired_tls_version="1.2"
case $REQUESTED_TLS in
  "1.2")
      echo "Setting TLS to version 1.2"
      desired_tls_version="1.2"
      ;;
  "1.3")
      echo "Setting TLS to version 1.3"
      desired_tls_version="1.3"
      ;;

  *)
    echo "UNKNOWN OR UNSUPPORTED TLS VERSION, FORCING TO 1.2"
    desired_tls_version="1.2"
    ;;
esac

# Case 1: Specific Resource Group and App Service Name provided
if [ -n "$RESOURCE_GROUP" ] && [ -n "$APP_SERVICE_NAME" ]; then
    update_ftp_state "$RESOURCE_GROUP" "$APP_SERVICE_NAME" "$desired_tls_version"

# Case 2: Only Resource Group provided
elif [ -n "$RESOURCE_GROUP" ]; then
    app_services=$(az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
    for app in $app_services; do
        update_ftp_state "$RESOURCE_GROUP" "$app" "$desired_tls_version"
    done

# Case 3: No Resource Group, apply to all App Services in the subscription
else
    app_services=$(az webapp list --query "[].{name:name,resourceGroup:resourceGroup}" -o tsv)
    while IFS=$'\t' read -r rg app_name; do
        update_ftp_state "$rg" "$app_name" "$desired_tls_version"
    done <<< "$app_services"
fi

echo "Script execution completed."