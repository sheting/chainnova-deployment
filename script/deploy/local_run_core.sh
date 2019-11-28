#!/bin/bash

export RELATIVE_PATH="../../.."
export PROJ_CONFIG_DIR="$RELATIVE_PATH/k8syaml/config-template"
export SCRIPT_DIR="../utils"
export TAG='development'
export __TAG='development'
export __MODE_TYPE='development'

get_config_value() {
    FILE_NAME=${FILE_NAME:-${PROJ_CONFIG_DIR}'/'${PROJ}'-config.yaml'}
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $FILE_NAME
}

START=$(date +"%s")
export CONTAINER_NAME=$(echo $1 | tr "\/" "-")
export DOCKER_IMAGE=$PROJ/$1:$__TAG
export registry=$(get_config_value "FE_base_registry")
export NETWORK="local-$PROJ"

echo "Component: $1"
echo "****** load component para file ******"
cd ../utils/
source ./load_compoment_para.sh $1
if [ $? != 0 ]; then
    echo "!!!Error: Load Component Para file failed."
    exit 1
fi

if [ -f "${SRC_PATH}/.env.docker.${__MODE_TYPE}" ]; then 
  echo "external docker run env file: $(pwd)/${SRC_PATH}/.env.docker.${__MODE_TYPE}"
  source ${SRC_PATH}/.env.docker.${__MODE_TYPE}
  ENV_FILE="--env-file $(pwd)/${SRC_PATH}/.env.${__MODE_TYPE}"
fi 

export REPOSITORY=$PROJ/$_REPOSITORY
export SRC_PATH=$SRC_PATH
export PORT=$_PORT
#export MODE_TYPE=$MODE_TYPE
export WDIR=$_WDIR

if [[ ${_PROJECT_TYPE} =~ 'vue' ]]; then
	ENV_FILE="--env-file $(pwd)/${SRC_PATH}/.env "$ENV_FILE
	VOL="-v $(pwd)/${SRC_PATH}:/code -v $(pwd)/${SRC_PATH}/Docker/nginx/${__MODE_TYPE}.conf:/etc/nginx/conf.d/default.conf"
	export BASE_DEV_REPOSITORY=${__BASE_DEV_REPOSITORY:-'fe-common/vue-cli-dev'}:${__BASE_TAG:-'3.5.5'}
	cd $SCRIPT_DIR
    registry=$registry ./pull_image.env.sh $BASE_DEV_REPOSITORY
    res=$?
    cd - &> /dev/null
    if [ $res != 0 ]; then
        echo "!!!Error: Pull $BASE_DEV_REPOSITORY failed."
        exit 1
    fi
#	start_command=''
elif [[ ${_PROJECT_TYPE} == 'ionic' ]]; then
	ENV_FILE="--env-file $(pwd)/${SRC_PATH}/.env "$ENV_FILE
	VOL="-v $(pwd)/${SRC_PATH}:/code -v $(pwd)/${SRC_PATH}/Docker/nginx/${__MODE_TYPE}.conf:/etc/nginx/conf.d/default.conf"
	DPORT="-p $((8100+index)):8100 -p $((35729+index)):35729 -p $((53703+index)):53703"
	export BASE_DEV_REPOSITORY=${__BASE_DEV_REPOSITORY:-'fe-common/ionic-cli-dev'}:${__BASE_TAG:-'3.0.0'}
	cd $SCRIPT_DIR
    registry=$registry ./pull_image.env.sh $BASE_DEV_REPOSITORY
    res=$?
    cd - &> /dev/null
    if [ $res != 0 ]; then
        echo "!!!Error: Pull $BASE_DEV_REPOSITORY failed."
        exit 1
    fi
else
	export BASE_DEV_REPOSITORY=${REPOSITORY}:${TAG}
	if [[ $BUILD == 'true' ]]; then
		cd ../build
		__MODE_TYPE=${__MODE_TYPE} ./build_image_${_PROJECT_TYPE}.sh $REPOSITORY
		res=$?
	    cd - &> /dev/null
	    if [ $res != 0 ]; then
	        echo "!!!Error: build image failed."
	        exit 1
	    fi
	fi
fi

echo "docker_compose:$docker_compose"

if [[ "$docker_compose" == true ]]; then
	exit 0
fi

docker network ls | grep -q -E "${NETWORK}"
if [[ "$?" == "0" ]]; then
	echo "network exist. No need to create network"
else
	docker network create ${NETWORK}
	if [[ "$?" != "0" ]]; then
		echo "!!!Err: create network:$5 failed!"
		exit 1
	fi
fi

docker ps | grep -q -E "$BASE_DEV_REPOSITORY"
if [[ "$?" == "0" ]]; then
  echo "!!!Err: $BASE_DEV_REPOSITORY is running ***"
  exit 1
fi

#echo "docker run --rm ${ENV_FILE} ${VOL} --privileged -dit -p $_DOCKER_PORT:$_PORT --name $CONTAINER_NAME --network ${NETWORK} $BASE_DEV_REPOSITORY"
docker run --rm ${ENV_FILE} ${VOL} --privileged -dit -p $_DOCKER_PORT:$_PORT $DPORT --name $CONTAINER_NAME --network ${NETWORK} $BASE_DEV_REPOSITORY
#docker run --rm ${ENV_FILE} ${VOL} -p $_DOCKER_PORT:$_PORT --name $CONTAINER_NAME --network ${NETWORK} $BASE_DEV_REPOSITORY

docker ps | grep -q -E "$BASE_DEV_REPOSITORY"
if [[ "$?" != "0" ]]; then
  echo "!!!Err: docker run  $BASE_DEV_REPOSITORY failed! ***"
  exit 1
fi

exit 0