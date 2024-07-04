#!/bin/bash

# Function to enable Microsoft Defender for Cloud for a subscription
enable_defender_for_subscription() {
    local subscription_name=$1
    
    echo "Fetching subscription ID for: $subscription_name"
    
    # Get the subscription ID based on the subscription name
    subscription_id=$(az account list --query "[?name=='$subscription_name'].id" -o tsv)
    
    if [ -z "$subscription_id" ]; then
        echo "Subscription ID for $subscription_name not found. Skipping..."
        return
    fi
    
    echo "Enabling Microsoft Defender for Cloud on subscription: $subscription_name ($subscription_id)"

    # Set the subscription context
    az account set --subscription "$subscription_id"

    # Enable Microsoft Defender for Cloud, enable auto provisioning to automatically add new resources to defender
    az security auto-provisioning-setting update --auto-provision "On" --subscription "$subscription_id" --name "default"

    # Enable specific plans
    plans=("VirtualMachines" "SqlServers" "AppServices" "StorageAccounts" "KeyVaults" "Api" "Containers" "Arm" "OpenSourceRelationalDatabases" "CosmosDbs" "CloudPosture" "SqlServerVirtualMachines")
    for plan in "${plans[@]}"; do
        if [ "$plan" == "StorageAccounts" ]; then
            echo "Enabling Microsoft Defender for Storage Accounts with subplan"
            az security pricing create --name "$plan" --tier "Standard" --subscription "$subscription_id" --subplan "DefenderForStorageV2"
        elif [ "$plan" == "KeyVaults" ]; then
            echo "Enabling Microsoft Defender for Keyvault with subplan"
            az security pricing create --name "$plan" --tier "Standard" --subscription "$subscription_id" --subplan "PerKeyVault"
        elif [ "$plan" == "Api" ]; then
            echo "Disabling Microsoft Defender for Api"
            az security pricing create --name "$plan" --tier "Free" --subscription "$subscription_id"
        elif [ "$plan" == "Arm" ]; then
            echo "Enabling Microsoft Defender for Arm with a subplan"
            az security pricing create --name "$plan" --tier "Standard" --subscription "$subscription_id" --subplan "PerSubscription"
        elif [ "$plan" == "SqlServerVirtualMachines" ]; then
            echo "Disabling Microsoft Defender for SqlServerVirtualMachines"
            az security pricing create --name "$plan" --tier "Free" --subscription "$subscription_id"
        # elif [ "$plan" == "Containers" ]; then
        #     echo "Enabling Microsoft Defender for Containers with Azure Policy for Kubernetes"
        #     az security pricing create --name "$plan" --tier "Standard" --subscription "$subscription_id"
        #
        #     # List AKS clusters in the subscription
        #     aks_clusters=$(az aks list --query "[].{name:name, resourceGroup:resourceGroup}" -o tsv)
        #     if [ -z "$aks_clusters" ]; then
        #         echo "No AKS clusters found in subscription: $subscription_name ($subscription_id)"
        #     else
        #         # Enable Azure Policy add-on for each AKS cluster
        #         echo "$aks_clusters" | while read -r cluster_name cluster_rg; do
        #             echo "Enabling Azure Policy for Kubernetes on cluster: $cluster_name in resource group: $cluster_rg"
        #             az aks enable-addons --addons azure-policy --resource-group "$cluster_rg" --name "$cluster_name"
        #         done
        #     fi
        else
            az security pricing create --name "$plan" --tier "Standard" --subscription "$subscription_id"
        fi
    done

    echo "Microsoft Defender for Cloud enabled on subscription: $subscription_name"
}

# Check if at least one subscription name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <subscription_name1> [<subscription_name2> ...]"
    exit 1
fi

# Loop through each subscription name provided as an argument
for subscription_name in "$@"; do
    enable_defender_for_subscription "$subscription_name"
done