#!/bin/bash
if [ "$1" = "" ]; then
    echo "AppConfigurationName is mandatory!"
    exit 1
fi

APPCONFIGURATION_NAME="$1"

list () {
    echo "You chose list";
}

create(){
    echo "You chose create";
}

ACTION='Please choose an action to perform: '
options=("List" "Create" "Update" "Delete" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "List")
            list ;;
        "Create")
            create ;;
        "Update")
            update ;;
        "Delete")
            echo "you chose choice $REPLY which is $opt"
            ;;            
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done