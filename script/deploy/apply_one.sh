#!/bin/bash

START=$(date +"%s")

export RELATIVE_PATH="../../.."

echo "Component: $1"
echo "****** load component para file ******"
cd ../utils/
source ./load_compoment_para.sh $1
if [ $? != 0 ]; then
    echo "!!!Error: Load Component Para file failed."
    exit 1
fi
cd - &> /dev/null

echo "$KUBECONFIG"
cat $KUBECONFIG

echo "kubectl get namespace:"
kubectl get namespace

#namespace
echo "########################################"
echo "############# create namespace #########"
echo "########################################"
kubectl apply -f $RELATIVE_PATH/$_YAML_PATH/namespace.yaml
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to create namespace."
    exit 1
fi

echo
echo "#########################################"
echo "##### deploy image with apply yaml"
echo "#########################################"
#kubectl delete -f $RELATIVE_PATH/$_YAML_PATH/$_YAML_NAME
kubectl apply -f $RELATIVE_PATH/$_YAML_PATH/$_YAML_NAME --record=true
# &> /build_image.log
if [ $? != 0 ]; then
    echo "!!!Error: deploy apply image failed."
    exit 1
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START))) "
exit 0
