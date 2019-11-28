#!/bin/bash

LOG_FILE=/home/ubuntu/baas_server_script/cleanup_image.log
{

INCLUDED="^dev-.*-peer.*-.*\s+latest\s+|^.*\s+<none>\s+"
IMAGE_LIST=$(docker images | grep -E $INCLUDED)
if [[ "$IMAGE_LIST" != "" ]]; then
    #remove unused image
    echo
    date

    df -t ext4

    echo "$IMAGE_LIST"
    ID_LIST=$(echo "$IMAGE_LIST" | awk '{print $3}')
    docker rmi $ID_LIST

    docker rmi -f $(docker images | grep -E "^.*baas.*\s+<none>\s+" | awk '{print $3}' | uniq -d)

    df -t ext4
else
    echo -n "."
fi

} >> $LOG_FILE 2>&1
