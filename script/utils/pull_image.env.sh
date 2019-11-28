#!/bin/bash --login

#usage: ./pull_image.sh jenkins:2.60.3 jenkins:2.60.3
#                        \_IMAGE_LOCAL  \_IMAGE_REGISTRY
#       the registry's URL will be automatically added
#
#usage: TAG_SUFFIX=true ./pull_image.sh jenkins:2.60.3
#       the tag suffix will be automatically added

if [[ $1 == "" ]]; then
    echo "!!!Error: No image specified."
    exit 1
fi
IMAGE_LOCAL=$1

ENV_NAME=${ENV_NAME:-'dev'}

if [[ "$registry" == "" ]]; then
    echo "ERROR: Not specified registry name."
    exit 1
fi

REGISTRY_CONF_PATH=../../config-template/registry

source $REGISTRY_CONF_PATH/registry-$registry.env

if [[ $2 != "" ]]; then
    IMAGE_REGISTRY=$2
else
    IMAGE_REGISTRY=$IMAGE_LOCAL
fi

#url & suffix
if [[ $TAG_SUFFIX == "true" ]]; then
    IMAGE_URL=${REGISTRY_URL}/$IMAGE_REGISTRY-${ENV_NAME}
else
    IMAGE_URL=${REGISTRY_URL}/$IMAGE_REGISTRY
fi

echo
echo "##############################"
echo "##### pull image"
echo "##############################"
if [[ "ecr" == ${REGISTRY_TYPE} ]]; then
    #login
    $(aws ecr get-login --no-include-email --region cn-north-1)
    if [ $? != 0 ]; then
        echo "!!!Error: Login failed."
        exit 1
    fi
else
    docker login -u ${REGISTRY_USER} -p ${REGISTRY_PW} ${REGISTRY_URL} &> /dev/null
fi


#pull
docker pull $IMAGE_URL &&
docker tag $IMAGE_URL $IMAGE_LOCAL &&
docker rmi $IMAGE_URL
if [ $? != 0 ]; then
    echo "!!!Error: Pull image failed."
    exit 1
fi

exit 0
