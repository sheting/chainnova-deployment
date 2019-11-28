#!/bin/bash

START=$(date +"%s")

REPOSITORY="chainnova/ci/notify-server"
TAG="0.0.1"
IMAGE_LOCAL="$REPOSITORY:$TAG"

./cleanup.sh

echo ""
echo "**********************************"
echo "***  build notify server image ***"
echo "**********************************"

docker images |grep -E "^$REPOSITORY\s+$TAG\s+"

echo "docker build -f ./Dockerfile -t $IMAGE_LOCAL ."
docker build -f ./Dockerfile -t $IMAGE_LOCAL .
if [ $? != 0 ]; then
	echo "[ERROR] Build image failed!!!"
	exit -1
fi

BUILD_COMPLETE=$(date +"%s")

if [[ $PUSH_IMAGE == "true" ]]; then
	cd ../script/utils
	./push_image.sh $IMAGE_LOCAL
	cd - &> /dev/null
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"
exit 0
