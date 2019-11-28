#!/bin/bash 


#$1         config item
#return     value
get_config_value() {
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" ../config-template/common-config.yaml
}

REGISTRY_TYPE=$(get_config_value "Registry_type")
#components
source component_$REGISTRY_TYPE.sh


#Find prometheus deploy node name

#deploy to the middle node
#NODE_NAME_LIST=( $(kubectl get node | grep "Ready" | cut -d ' ' -f 1) )
#MiddleIndex=$[${#NODE_NAME_LIST[@]} / 2]
#NODE_NAME_DEPLOY=${NODE_NAME_LIST[$MiddleIndex]}
#echo "Deploy prometheus to node $[$MiddleIndex + 1]($NODE_NAME_DEPLOY) of ${#NODE_NAME_LIST[@]}"

#deploy to the kube-dns node
NODE_NAME_DEPLOY=$(kubectl get pod -n kube-system -o wide | grep -E "^kube-dns-" | awk '{print $7}')
if [[ $NODE_NAME_DEPLOY == "" ]]; then
    echo "Error: Can't find the specified node."
    exit 1
fi
echo "Deploy prometheus & alertmanager to node ($NODE_NAME_DEPLOY)"
sed "s/##HOSTNAME##/$NODE_NAME_DEPLOY/g" prometheus-deployment.yaml   > prometheus-deployment-replace.yaml
sed "s/##HOSTNAME##/$NODE_NAME_DEPLOY/g" alertmanager-deployment.yaml > alertmanager-deployment-replace.yaml

#Namespace
_NAME_SPACE_="baas-mon"
kubectl create namespace $_NAME_SPACE_

#Component
for EachComp in "${Component[@]}"
do
    echo "##### $EachComp #####"
    kubectl create -f ./$EachComp.yaml --namespace $_NAME_SPACE_
    echo
    #sleep 1
done

rm prometheus-deployment-replace.yaml
rm alertmanager-deployment-replace.yaml
