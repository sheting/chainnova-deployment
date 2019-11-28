#!/bin/bash

NAMESPACE="flink"

kubectl delete -f flink-TaskManagers.yaml

kubectl delete -f flink-JobManagers.yaml

kubectl delete -f flink-JobManagers-configmap.yaml

kubectl delete -f flink-externalsvc.yaml

kubectl delete pvc $(kubectl get pvc -n $NAMESPACE | awk '{print $1}') -n $NAMESPACE

kubectl delete namespace $NAMESPACE
