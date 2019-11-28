#!/bin/bash

#usage: ./push_image.sh jenkins:2.60.3 jenkins:2.60.3
#                        \_IMAGE_LOCAL  \_IMAGE_REGISTRY
#       the registry's URL will be automatically added
#
#usage: TAG_SUFFIX=true ./push_image.sh jenkins:2.60.3
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
echo "##### push image"
echo "##############################"
if [[ "ecr" == ${REGISTRY_TYPE} ]]; then
    #login
    $(aws ecr get-login --no-include-email --region cn-north-1)
    if [ $? != 0 ]; then
        echo "!!!Error: Login failed."
        exit 1
    fi

    #create registry
    aws ecr create-repository --repository-name ${IMAGE_REGISTRY%:*} --region cn-north-1 &> /dev/null
    #--tags Key=team,Value=salix &> /dev/null
    if [ $? != 0 ]; then
        echo "The repository with name ${IMAGE_REGISTRY%:*} already exists in the registry "
    else
        echo "Add lifecycle policy to new registry"
        aws ecr put-lifecycle-policy --repository-name ${IMAGE_REGISTRY%:*} --lifecycle-policy-text "file://../../aws/ecr-policy-deleteuntagged.json"
        if [ $? != 0 ]; then
            echo "!!!Error: Add lifecycle policy failed."
            exit 1
        fi
    fi
else
    docker login -u ${REGISTRY_USER} -p ${REGISTRY_PW} ${REGISTRY_URL} &> /dev/null
fi


#push
docker tag  $IMAGE_LOCAL $IMAGE_URL &&
docker push $IMAGE_URL &&
docker rmi  $IMAGE_URL
if [ $? != 0 ]; then
    echo "!!!Error: Push image failed."
    exit 1
fi

exit 0
