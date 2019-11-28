#!/bin/bash

DIR=$1

if [[ "" == $DIR ]]; then
    echo "!!!Error: Missing para DIR."
    exit 1
fi
source deploy_public_func.sh

REGISTRY_TYPE=$(get_config_value "Registry_type")
#components
source $DIR/component_$REGISTRY_TYPE.sh

for EachComp in "${Component[@]}"
do
    echo -e "\n##### $EachComp #####"
    if [[ $EachComp =~ "pv" && !($EachComp =~ "pvc") ]]; then
        status=$(kubectl get pv | grep $EachComp | awk '{print $5}')
        while [[ "$status" != "Available" && "$status" != ""  ]]; do
            status=$(kubectl get pv | grep $EachComp | awk '{print $5}')
        done
        echo $(kubectl get pv | grep $EachComp | awk '{print $5}')
#       echo $(kubectl get po --all-namespaces | grep recy)
    fi
    kubectl delete -f ./$DIR/$EachComp.yaml
done

#namespace
echo -e "\n##### namespace #####"
kubectl delete -f ./$DIR/namespace.yaml
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to delete $_NAME_SPACE_."
    exit 1
fi

exit 0
