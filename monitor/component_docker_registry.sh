#!/bin/bash

declare -a Component=(
'hub-secret'
'node-exporter-daemonset'
'node-exporter-service'
'prometheus-configmap'
'prometheus-deployment-replace'
'prometheus-service'
'grafana-deployment'
'grafana-service'
'alertmanager-configmap'
'alertmanager-deployment-replace'
'alertmanager-service'
);
