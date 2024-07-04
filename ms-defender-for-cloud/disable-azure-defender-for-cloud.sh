#!/bin/bash

# Function to disable Microsoft Defender for Cloud for a subscription
disable_defender_for_subscription() {
    local subscription_name=$1
    
    echo "Fetching subscription ID for: $subscription_name"
    
    # Get the subscription ID based on the subscription name
    subscription_id=$(az account list --query "[?name=='$subscription_name'].id" -o tsv)
    
    if [ -z "$subscription_id" ]; then
        echo "Subscription ID for $subscription_name not found. Skipping..."
        return
    fi
    
    echo "Disabling Microsoft Defender for Cloud on subscription: $subscription_name ($subscription_id)"

    # Set the subscription context
    az account set --subscription "$subscription_id"
    
    # Disable specific plans
    #plans=("VirtualMachines" "SqlServers" "AppServices" "StorageAccounts" "KeyVaults" "containers")
     plans=("VirtualMachines" "SqlServers" "AppServices" "StorageAccounts" "KeyVaults" "Api" "Containers" "Arm" "OpenSourceRelationalDatabases" "CosmosDbs" "CloudPosture" "SqlServerVirtualMachines")
    for plan in "${plans[@]}"; do
        az security pricing create --name "$plan" --tier "Free" --subscription "$subscription_id"
    done

    echo "Microsoft Defender for Cloud disabled on subscription: $subscription_name ($subscription_id)"
}

# Check if at least one subscription name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <subscription_name1> [<subscription_name2> ...]"
    exit 1
fi

# Loop through each subscription name provided as an argument
for subscription_name in "$@"; do
    disable_defender_for_subscription "$subscription_name"
done