#!/bin/bash

kubectl delete -f es-clean-cronjob.yaml

kubectl delete -f kibana.yaml

kubectl delete -f logstash.yaml

kubectl delete -f logstash-configmap-conf.yaml

kubectl delete -f filebeat-daemonset.yaml

kubectl delete -f filebeat-configmap.yaml

kubectl delete -f es-statefulSet.yaml

kubectl delete pvc $(kubectl get pvc -n $NAMESPACE | awk '{print $1}') -n $NAMESPACE

kubectl delete -f namespace.yaml
