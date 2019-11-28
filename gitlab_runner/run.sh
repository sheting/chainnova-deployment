#!/bin/bash

docker run -d --name gitlab-runner --restart always -v /home/ubuntu/gitlab-runner-conf:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest

docker run -p 30222:30222 -v $(pwd)/gitlab-notify/config.json:/home/config/config.json --name=gitlab-notify --restart=always -d 370307265965.dkr.ecr.cn-north-1.amazonaws.com.cn/chainnova/ci/notify-server:0.0.1
