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

if [[ $VAR_CLUSTER_ENV_NAME == 'docker' && $DOCKER_NETWORK == "" ]]; then
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
echo "**********    [BUILD]"
echo "****************************************************************************************************"
cd kubectl
./build_image.sh
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to build."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

echo
echo "****************************************************************************************************"
echo "**********    [GENERATE]"
echo "****************************************************************************************************"
cd ../config-template
./generate.sh $__CLUSTER_ENV_NAME
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to generate config."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

echo
echo "****************************************************************************************************"
echo "**********    [DEPLOY]"
echo "****************************************************************************************************"
CREATE_MODE=${__CREATE_MODE:-'apply_one'}
if [[ "$VAR_CLUSTER_ENV_NAME" == "previewdk" ]]; then
    CREATE_MODE="docker_run"
fi

if [[ "apply_one" != "$CREATE_MODE" && "docker_run" != "$CREATE_MODE" ]]; then
    echo "!!!Error: invalid CREATE_MODE: " $CREATE_MODE
    exit 1
fi

echo $__CLUSTER_ENV_NAME
KUBECTL_SCRIPT="./kubectl/kubectl_docker.sh $__CLUSTER_ENV_NAME"
if [[ "$VAR_CLUSTER_ENV_NAME" != "previewdk" ]]; then
    $KUBECTL_SCRIPT "kubectl get namespace"
fi
CREATE_SCRIPT="./"$CREATE_MODE".sh "$__COMPONENT
echo "CREATE_SCRIPT: " $CREATE_SCRIPT

cd ../..
docker run  --rm \
            -e "KUBECONFIG=/root/config_$__CLUSTER_ENV_NAME" \
            -e "DOCKER_NETWORK=$DOCKER_NETWORK" \
            -e "PROJ=$__PROJ" \
            -e "__TAG=$__TAG" \
            -e "__MODE_TYPE=$__MODE_TYPE" \
            -v $(pwd)/deployment/ci/kubectl/docker/config:/root \
            -v $(pwd):/home/ \
            -v /home/ubuntu/.ssh:/ssh \
            chainnova/ci/kubectl:0.0.4 \
            -c "cd /home/deployment/script/deploy/ && $CREATE_SCRIPT"
if [[ $? == 0 ]]; then
    echo "SUCCESS!"
else
    echo "!!!Error: Failed to Deploy Component( $__COMPONENT )."
    exit 1
fi
cd - &> /dev/null

if [[ "$VAR_CLUSTER_ENV_NAME" != "previewdk" ]]; then
    $KUBECTL_SCRIPT "kubectl get namespace"
fi

echo
echo "****************************************************************************************************"
echo "**********    [CLEAN]"
echo "****************************************************************************************************"
cd ../config-template
PROJ=__PROJ ./clean.sh
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to generate config."
    exit 1
fi
cd - &> /dev/null
echo "SUCCESS"

exit 0
