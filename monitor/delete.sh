#!/bin/bash 

_NAME_SPACE_="baas-mon"

#$1         config item
#return     value
get_config_value() {
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" ../config-template/common-config.yaml
}

REGISTRY_TYPE=$(get_config_value "Registry_type")
#components
source component_$REGISTRY_TYPE.sh


for EachComp in "${Component[@]}"
do
    echo "##### $EachComp #####"
    kubectl delete -f ./$EachComp.yaml --namespace $_NAME_SPACE_
    echo
done

kubectl delete namespace $_NAME_SPACE_
