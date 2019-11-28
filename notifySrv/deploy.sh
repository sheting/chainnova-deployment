#!/bin/bash
REGISTRYSERVER="370307265965.dkr.ecr.cn-north-1.amazonaws.com.cn"
REPOSITORY="chainnova/ci/notify-server"
CONTAINERNAME="chainnova-ci-notify-server"
TAG="0.0.1"

echo ""
echo "********************************"
echo "***   docker pull image      ***"
echo "********************************"
echo "docker pull $REGISTRYSERVER/$REPOSITORY:$TAG"

$(aws ecr get-login --no-include-email --region cn-north-1)
if [ $? != 0 ]; then
	echo "[ERROR] docker login to Registry server failed!!!"
	exit -1
fi

docker pull $REGISTRYSERVER/$REPOSITORY:$TAG
if [ $? != 0 ]; then
	echo "[ERROR] docker pull image failed!!!"
	exit -1
fi

echo ""
echo "********************************"
echo "***   docker run             ***"
echo "********************************"
IMAGEID=`docker images |grep "$REPOSITORY" |awk '{print $3}'`
echo "IMAGEID : $IMAGEID"
if [ "$IMAGEID" == "" ]; then
	echo "[ERROR] image not exist!!!"
	exit -1
fi

echo "docker run -p 30222:30222 -v $(pwd)/gitlab-notify/config.json:/home/config/config.json --name=$CONTAINERNAME --restart=always $IMAGEID &> /dev/null &"
docker run -p 30222:30222 -v $(pwd)/gitlab-notify/config.json:/home/config/config.json -d --name=$CONTAINERNAME --restart=always $IMAGEID &> /dev/null &

if [ $? == 0 ]; then
	echo ""
	echo "********************************"
	echo "***   Deploy Success!!!      ***"
	echo "********************************"
fi



