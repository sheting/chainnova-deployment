#!/bin/bash

#set var
DIR=$1
if [[ "" == $DIR ]]; then
	echo "!!!Error: Missing para DIR."
	exit 1
fi
source create_func.sh

#namespace
echo "########################################"
echo "############# create namespace #########"
echo "########################################"
kubectl apply -f $DIR/namespace.yaml
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to create namespace."
    exit 1
fi

## create configmap
echo "########################################"
echo "############# create configmap #########"
echo "########################################"
create_configmap $DIR
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to create configmap."
    exit 1
fi

## create deployment, service, pv and pvc
echo "########################################"
echo "############# create component #########"
echo "########################################"
create_component $DIR
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to create component."
    exit 1
fi

exit 0
