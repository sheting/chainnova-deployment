#!/bin/bash

LOG_FILE=/home/ubuntu/baas_server_script/cleanup_container.log
{

EXCLUDED="^CONTAINER\s+|\s+busybox\s+|\s+k8s_fabric-template1-artifacts_|\s+k8s_fabric-template2-artifacts_|\s+k8s_pre-pull-ccenv_|\s+k8s_pre-pull-baseos_"
CONTAINER_LIST=$(docker ps --filter "status=exited" | grep -v -E $EXCLUDED)
if [[ "$CONTAINER_LIST" != "" ]]; then
    #remove exit container
    echo
    date

    df -t ext4

    echo "$CONTAINER_LIST"
    ID_LIST=$(echo "$CONTAINER_LIST" | awk '{print $1}')
    docker rm -v $ID_LIST

    df -t ext4
else
    echo -n "."
fi

} >> $LOG_FILE 2>&1
