#!/bin/bash

##### main process
echo
echo "****************************************************************************************************"
echo "**********    [PARA]"
echo "****************************************************************************************************"
if [[ "$VAR_CLUSTER_ENV_NAME" == "" || "$VAR_COMPONENT_NAME" == "" || "$GIT_TAG" == "" || "$PROJ" == "" ]]; then
    echo "Parameter not specified."
    exit 1
fi

if [[ ! $VAR_CLUSTER_ENV_NAME =~ "prod" ]]; then
	echo "test mode, add branch at the end of target image tag"
	TAG=$GIT_TAG'.'$BRANCH'.'$VAR_CLUSTER_ENV_NAME
else
	echo "prod mode"
	TAG=$GIT_TAG
fi

if [[ $GIT_TAG == 'testtag' && $VAR_CLUSTER_ENV_NAME =~ "prod" ]]; then
    echo "!!!Error: Untagged branch deploy to prod env. Component Name: $1"
    exit 1
fi

if [[ "$VAR_CLUSTER_ENV_NAME" == "docker" && DOCKER_NETWORK == "" ]]; then
    echo "!!!Error: Missing para. VAR_CLUSTER_ENV_NAME is docker and DOCKER_NETWORK is null. Component Name: $1"
    exit 1
fi

export __CLUSTER_ENV_NAME=$VAR_CLUSTER_ENV_NAME
export __COMPONENT=$VAR_COMPONENT_NAME
export __TAG=$TAG
export __PROJ=$PROJ
#export __MODE_TYPE=$VAR_MODE_TYPE
export __MODE_TYPE=$VAR_CLUSTER_ENV_NAME
export __DOCKER_NETWORK=$DOCKER_NETWORK

echo "SUCCESS"

echo
echo "****************************************************************************************************"
echo "**********    [GENERATE]"
echo "****************************************************************************************************"
cd ../config-template
#PROJ=$PROJ GIT_TAG=$GIT_TAG ./generate.sh $__CLUSTER_ENV_NAME
./generate.sh $__CLUSTER_ENV_NAME
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to generate config."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

echo
echo "****************************************************************************************************"
echo "**********    [BUILD]"
echo "****************************************************************************************************"
#COMPONENT_PATH=$(get_component_path)
cd ../script/build
PUSH_IMAGE=true ./build_image.sh ${__COMPONENT}
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to build."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

echo
echo "****************************************************************************************************"
echo "**********    [CLEAN]"
echo "****************************************************************************************************"
cd ../config-template
./clean.sh
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to generate config."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

exit 0
