#!/bin/bash

REPOSITORY="chainnova/ci/notify-server"
CONTAINERNAME="chainnova-ci-notify-server"

echo ""
echo "********************************"
echo "****** clean container    ******"
echo "********************************"
IMAGEID=`docker ps -a |grep $CONTAINERNAME |awk '{print $2}'`
CONTAINERID=`docker ps -a |grep $CONTAINERNAME |awk '{print $1}'`

echo "Container name : $CONTAINERNAME"
echo "Container id : $CONTAINERID"
echo "Image id : $IMAGEID"

if [ "$CONTAINERID" != "" ]; then
	echo "docker stop $CONTAINERID"
	docker stop $CONTAINERID
	echo "docker rm $CONTAINERID"
	docker rm $CONTAINERID
fi

echo "********************************"
echo "****** clean none images  ******"
echo "********************************"

if [ "$IMAGEID" != "" ]; then
	docker rmi $IMAGEID
fi

docker images |grep none |awk '{print $3}' |xargs docker rmi

docker rmi $REPOSITORY:0.0.1

echo "********************************"
echo "****** cleanup finished   ******"
echo "********************************"



