#!/bin/bash

START=$(date +"%s")

#KUBECTL_ENV_NAME
if [ "$1" == "" ]; then
    echo "!!!Error: Can't find KUBECTL_ENV_NAME para."
    exit 1
fi
KUBECTL_ENV_NAME="$1"

#KUBECTL_COMMAND
if [ "$2" == "" ]; then
    echo "!!!Error: Can't find KUBECTL_COMMAND para."
    exit 1
fi
KUBECTL_COMMAND=$2

#check image
#REPOSITORY & TAG
REPOSITORY="chainnova/ci/kubectl"
TAG="0.0.3"
docker images | grep -q -E "^$REPOSITORY\s+$TAG\s+"
if [[ $? != 0 ]]; then
    echo "!!!Error: Can't find image \"$REPOSITORY:$TAG\", please use \"ci/kubectl/build_image.sh\" build first."
    exit 1
fi

echo -e "\n##### Run kubectl command"
docker run -v $(pwd)/kubectl/docker/config:/root --rm -e "KUBECONFIG=/root/config_$KUBECTL_ENV_NAME" "$REPOSITORY:$TAG" -c "$KUBECTL_COMMAND"
if [ $? != 0 ]; then
    echo "!!!Error: Run command failed."
    exit 1
fi

FINISH=$(date +"%s")
echo -e "##### Time elapsed ($(($FINISH - $START)))\n"
exit 0
