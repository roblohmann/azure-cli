#!/bin/bash
if [ "$1" = "" ]; then
    echo "No servername provided!"
    exit 1
fi

if [ "$2" = "" ]; then
    echo "No admin password provided!"
    exit 1
fi

SERVER_NAME="$1"
ADMIN_USERNAME=myuser
ADMIN_PASSWORD="$2"
RESOURCE_GROUP=whatever-you-like

echo $SERVER_NAME
echo $ADMIN_PASSWORD

echo 'Creating server'
az sql server create -l westeurope -g $RESOURCE_GROUP -n $SERVER_NAME -u $ADMIN_USERNAME -p "$ADMIN_PASSWORD"

echo 'Adding firewall rules'
#Enable the line below and modify to your needs to add a firewall rule to the server on creation.
#az sql server firewall-rule create -g $RESOURCE_GROUP -s $SERVER_NAME -n '<name-for-the-firewall-rule>' --start-ip-address 1.2.3.4 --end-ip-address 1.2.3.4

#All Azure services
az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $SERVER_NAME -n 'All Azure Services' --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

echo 'Assinging AD user'
az sql server ad-admin create --object-id '<Id-OfTheUserOrADGroup>' -s $SERVER_NAME -g $RESOURCE_GROUP -u '<NameOfTheUserOrGroupToShow>'
