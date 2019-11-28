#!/bin/bash

DOCKER_PATH=$(docker info | grep "Docker Root Dir:" | awk '{print $4}')

#logrotate configfile
echo "$DOCKER_PATH/containers/*/*.log {
  rotate 5
  daily
  compress
  size=10M
  missingok
  delaycompress
  copytruncate
}" > /etc/logrotate.d/baas-docker-container

LOG_FILE="/home/ubuntu/baas_server_script/cleanup_log.log"
{
    #remove old log and rotate current
    echo
    date
    docker ps

    df -t ext4
    du -d 1 -h $DOCKER_PATH/containers | sort -h

    #remove old log
    find $DOCKER_PATH/containers -name *.log.* -type f -delete

    #rotate current
    for (( i = 1; i <= 5; i++ )); do
        echo $i
        /usr/sbin/logrotate -f /etc/logrotate.d/baas-docker-container
        sleep 0.5
    done

    df -t ext4
    du -d 1 -h $DOCKER_PATH/containers | sort -h
} >> $LOG_FILE 2>&1
