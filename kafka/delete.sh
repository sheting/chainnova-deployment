#!bin/bash

NAMESPACE="zk"

kubectl delete -f zk-statefulset.yaml
kubectl delete pvc $(kubectl get pvc -n $NAMESPACE | awk '{print $1}') -n $NAMESPACE

kubectl delete -f nfs-provisioner.yaml
