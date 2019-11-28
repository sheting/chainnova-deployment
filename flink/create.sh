#!/bin/bash

NAMESPACE="flink"

kubectl create namespace flink;

kubectl apply -f flink-externalsvc.yaml

kubectl apply -f flink-JobManagers-configmap.yaml

kubectl apply -f flink-JobManagers.yaml

kubectl apply -f flink-TaskManagers.yaml

