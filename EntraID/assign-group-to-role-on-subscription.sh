#!/bin/bash

# Variables
GROUP_NAME="<group-name-OR-group-id>"  # Replace with the Entra ID (Azure AD) group name or object ID
ROLE_NAME="<desired-role-name>"

# Get the Azure AD group ID
GROUP_ID=$(az ad group show --group "$GROUP_NAME" --query "id" --output tsv)

# Ensure the group exists
if [ -z "$GROUP_ID" ]; then
    echo "Group '$GROUP_NAME' not found!"
    exit 1
fi

# Loop through all subscriptions
SUBSCRIPTIONS=$(az account list --query "[].id" --output tsv)

for SUBSCRIPTION in $SUBSCRIPTIONS; do
    echo "Assigning role '$ROLE_NAME' to group '$GROUP_NAME' on subscription '$SUBSCRIPTION'..."

    # Set the current subscription
    az account set --subscription "$SUBSCRIPTION"

    # Assign the role to the group for the current subscription
    #az role assignment create --assignee "$GROUP_ID" --role "$ROLE_NAME" --scope "/subscriptions/$SUBSCRIPTION"
    az role assignment create --assignee "$GROUP_ID" --role "$ROLE_NAME" --scope "/subscriptions/$SUBSCRIPTION"
    
    if [ $? -eq 0 ]; then
        echo "Successfully assigned role '$ROLE_NAME' to group '$GROUP_NAME' on subscription '$SUBSCRIPTION'."
    else
        echo "Failed to assign role on subscription '$SUBSCRIPTION'."
    fi
done