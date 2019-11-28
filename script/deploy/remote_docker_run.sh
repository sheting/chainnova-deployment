#!/bin/bash

echo "DOCKER_PORT: $1"
echo "PORT:$2"
echo "Container_Name:$3"
echo "DOCKER_IMAGE: $4"
echo "DOCKER_NETWORK: $5"
echo "BUILD_ENV: $6"

echo "****** check para ******"
if [[ $1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" ]]; then
    echo "!!!Error: Missing para. DOCKER_PORT OR PORT OR Container_Name OR DOCKER_IMAGE OR DOCKER_NETWORK is null. Component Name: $1"
    exit 1
fi

docker network ls | grep -q -E "$5"
if [[ "$?" == "0" ]]; then
	echo "network exist. No need to create network"
else
	docker network create $5
	if [[ "$?" != "0" ]]; then
		echo "!!!Err: create network:$5 failed!"
		exit 1
	fi
fi

docker ps -a | grep -q -E "$3"
if [[ "$?" == "0" ]]; then
  echo "*** INFO: $3 is running ***"
  ### run containner
  docker rm -f $3
  if [[ "$?" != "0" ]]; then
    echo '!!!ERR: Old service shutdown failed!'
    exit 1
  fi
fi

docker run $6 --privileged -dit -p $1:$2 --name $3 --network $5 $4
if [ "$?" != "0" ]; then
  echo '!!!ERR: Start service failed!'
  exit 1
fi

echo "*** SUCCESS ***"