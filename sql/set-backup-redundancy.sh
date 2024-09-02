#!/bin/bash

function set_backup_redundancy
{
    local server_name=$1
    local server_resource_group=$2
    local backup_redundancy=$3
    
    local redundancy="Local"

    if [ $backup_redundancy == 'zone'  ]
    then
        redundancy="Zone"
    fi

    if [ $backup_redundancy == 'global' ]
    then
        redundancy="Geo"
    fi

    #for databaseName in databasesOnServer
    for name in $(az sql db list --server $server_name --resource-group $server_resource_group --subscription '<subscription-name>' | jq -r '. [] .name')
    do
        if [ "${name}" == 'master' ]
        then
          echo 'Ignoring master'
        else
          echo "Updating database $name, in group $server_resource_group, setting backup redundancy to $redundancy"
          az sql db update -g $server_resource_group -s $server_name -n $name --backup-storage-redundancy $redundancy --subscription '<subscription-name>'
        fi
        
    done

    echo "DONE - All databases where updated"
}


while getopts :s:r:g: option 
do
  case "${option}" in
    s) 
      SERVER_NAME=${OPTARG}
      ;;
    g)
      SERVER_RESOURCE_GROUP=${OPTARG}
      ;;
    r) 
      BACKUP_REDUNDANCY=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
esac
done

if [ "${SERVER_NAME}" == '' ]
then
  echo "no parameter -s supplied"
  exit;
fi

if [ "${SERVER_RESOURCE_GROUP}" == '' ]
then
  echo "no parameter -g supplied"
  exit;
fi

if [ "${BACKUP_REDUNDANCY}" == '' ]
then
  echo "no parameter -r supplied. Must be one of these lokaal/globaal/zone"
  exit;
fi

set_backup_redundancy "$SERVER_NAME" "$SERVER_RESOURCE_GROUP" "$BACKUP_REDUNDANCY"