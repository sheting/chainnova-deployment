#!/bin/bash

kubectl apply -f namespace.yaml

kubectl apply -f nfs-provisioner.yaml

kubectl apply -f zk-statefulset.yaml

