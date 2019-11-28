#!/bin/bash

NAMESPACE="elk"

kubectl create namespace $NAMESPACE

kubectl apply -f es-statefulSet.yaml

kubectl apply -f filebeat-configmap.yaml

kubectl apply -f filebeat-daemonset.yaml

kubectl apply -f logstash-configmap-conf.yaml

kubectl apply -f logstash.yaml

kubectl apply -f kibana.yaml

kubectl apply -f es-clean-cronjob.yaml

