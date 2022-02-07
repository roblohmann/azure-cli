#!/bin/bash

#see https://docs.microsoft.com/nl-nl/cli/azure/network/dns/record-set/cname?view=azure-cli-latest for documentation

if [ "$1" = "" ]; then
    echo "No DNS-record name provided!"
    exit 1
fi

if [ "$2" != "" ]; then
    $TTL=$2
fi

if [ "$3" = "" ]; then
    echo "No resource group provided!"
    exit 1
fi

if [ "$4" = "" ]; then
    echo "No Zone-name provided!"
    exit 1
fi

DNS_RECORD_NAME="$1"
TTL=30
RESOURCE_GROUP= "$3"
ZONE="$4"
IPV4_ADDRESS="$5"
IPV6_ADDRESS="$6"

echo $DNS_RECORD_NAME
echo $TTL
echo $RESOURCE_GROUP
echo $ZONE

echo "Creating DNS-record.."
# obv CNAME
echo 'az network dns record-set cname create --name ' + $DNS_RECORD_NAME + '--resource-group ' + $RESOURCE_GROUP + '--ttl' + $TTL '--zone-name' + $ZONE
#az network dns record-set cname create --name $DNS_RECORD_NAME --resource-group $RESOURCE_GROUP --ttl $TTL --zone-name $ZONE

# obv A (ipv4)
echo 'az network dns record-set a add-record -a' + $IPV4_ADDRESS + '--resource-group' + $RESOURCE_GROUP + '--ttl' + $TTL + '--record-set-name' + $DNS_RECORD_NAME + '--zone-name' + $ZONE
#az network dns record-set a create --name $DNS_RECORD_NAME --resource-group $RESOURCE_GROUP --ttl $TTL --zone-name $ZONE

# obv AAAA (ipv6)
echo 'az network dns record-set aaaa add-record -a' + $IPV6_ADDRESS + '--resource-group' + $RESOURCE_GROUP + '--ttl' + $TTL + '--record-set-name' + $DNS_RECORD_NAME + '--zone-name' + $ZONE
#az network dns record-set aaaa add-record -g $RESOURCE_GROUP -z $DNS_RECORD_NAME -n $ZONE -a $IP4_ADDRESS
echo "Creating DNS-record, DONE!"