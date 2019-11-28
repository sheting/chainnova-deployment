#!/bin/bash

declare -a CONFIG_FILE_LIST=(
#script
"../script/utils/push_image.sh"
"../script/utils/pull_image.sh"

#monitor
"../monitor/alertmanager-deployment.yaml"
"../monitor/alertmanager-dingtalk-test.sh"
"../monitor/grafana-deployment.yaml"
"../monitor/hub-secret.yaml"
"../monitor/node-exporter-daemonset.yaml"
"../monitor/prometheus-deployment.yaml"

#mysql
"../mysql/mysql-deployment.yaml"

#fastDFS
"../fastDFS/fastDFS.yaml"

#StorageClass
"../kafka/nfs-provisioner.yaml"

#elk
"../elk/es-clean-cronjob.yaml"

#redis
"../redis/redis-master.yaml"
"../redis/redis-slave.yaml"

#chainnova domain
"../chainnova/mariadb.yaml"
"../chainnova/wordpress.yaml"
"../chainnova/chainnova-website.yaml"

);
