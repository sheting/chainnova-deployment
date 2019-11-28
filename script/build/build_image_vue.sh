#!/bin/bash

export PROJ_CONFIG_DIR=$RELATIVE_PATH/"/k8syaml/config-template"
export SCRIPT_DIR="../utils"

#$1         config item
#return     value
get_config_value() {
    FILE_NAME=${FILE_NAME:-${PROJ_CONFIG_DIR}'/'${PROJ}'-config.yaml'}
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $FILE_NAME
}

# build static
START=$(date +"%s")


echo '*** CHECK PARA ***'
if [[ $REPOSITORY == "" || __TAG == "" || __MODE_TYPE == "" || WDIR == ""  ]]; then
    echo "!!!Error: Missing para. REPOSITORY OR __TAG OR __MODE_TYPE OR WDIR. Component Name: $1"
    exit 1
fi

#REPOSITORY is input
IMAGE_LOCAL="$REPOSITORY:$__TAG"

source ${SRC_PATH}/.env

if [ -f "${SRC_PATH}/.env.${__MODE_TYPE}" ]; then 
  echo
  echo "########################################"
  echo "##### LOADING ENV: ${SRC_PATH}/.env.${__MODE_TYPE}"
  echo "########################################"
  source ${SRC_PATH}/.env.${__MODE_TYPE}
  BUILD_ENV="--env-file $(pwd)/$SRC_PATH/.env.${__MODE_TYPE}"
fi 

export BASE_TAG=${__BASE_TAG:-'3.5.5'}
export SERVICE_BASE_TAG=${__SERVICE_BASE_TAG:-'3.0.0'}
export BASE_DEV_REPOSITORY=${__BASE_DEV_REPOSITORY:-'fe-common/vue-cli-dev'}
export BASE_BUILD_REPOSITORY=${__BASE_BUILD_REPOSITORY:-'fe-common/vue-cli'}
export BASE_SERVICE_REPOSITORY=${__BASE_SERVICE_REPOSITORY:-'fe-common/static-service'}
export BASE_REGISTRYNAME=$(get_config_value "FE_base_registry")
export TARGET_REGISTRYNAME=$(get_config_value "Target_registry")


echo
echo "########################################"
echo "##### check && pull && build base image "
echo "########################################"
rm -rf .tmp_base_image
echo -e "$BASE_BUILD_REPOSITORY:$BASE_TAG\n$BASE_DEV_REPOSITORY:$BASE_TAG\n$BASE_SERVICE_REPOSITORY:$SERVICE_BASE_TAG\n">>.tmp_base_image
ALWAYS_PULL=$ALWAYS_PULL BASE_TAG=${BASE_TAG} REGISTRYNAME=$BASE_REGISTRYNAME PROJ=$PROJ ENV_NAME=$__MODE_TYPE ./check_image_base.sh
if [[ $? != 0 ]]; then
  echo '!!!ERR: check && pull && build base image failed!'
  exit 1
fi

CHECK_BASE=$(date +"%s")

echo
echo "########################################"
echo "##### BUILD STATIC FILES "
echo "########################################"
docker run --rm --env-file $(pwd)/$SRC_PATH/.env $BUILD_ENV -v $(pwd)/$SRC_PATH:/code -v $(pwd)/../../deploy_fe_vue:/code/deploy_fe_vue -w /code ${BASE_BUILD_REPOSITORY}:${BASE_TAG} ./deploy_fe_vue/src/${build_script}
#docker run --rm --env-file  -v $(pwd)/$SRC_PATH:/code $(pwd)/:/code ./images/src/build_ionic3.sh
#docker-compose run --rm build ./images/src/build_ionic3.sh
if [[ $? != 0 ]]; then
  echo '!!!ERR: Build static failed!'
  exit 1
fi
BUILD_STATIC=$(date +"%s")

# build image
## version info
#TAG=`cat ./package.json | awk 'BEGIN{FS="\""}/"version": "(.+)",/{print $4}'`

echo
echo "########################################"
echo "##### BUILD IMAGE "
echo "########################################"
docker build --no-cache --build-arg BASE_REPOSITORY=${BASE_SERVICE_REPOSITORY} --build-arg BASE_TAG=${SERVICE_BASE_TAG} --build-arg MODE_TYPE=$__MODE_TYPE -f ../../deploy_fe_vue/Dockerfile_service -t $IMAGE_LOCAL ./$SRC_PATH
if [ $? != 0 ]; then
    echo "!!!Error: Build image failed."
    exit 1
fi
if [[ $CONCURRENCY != "true" ]]; then
    docker rmi $(docker images -q -f dangling=true)
fi
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

if [[ $PUSH_IMAGE == "true" ]]; then
    cd $SCRIPT_DIR
    ENV_NAME=ENV_NAME registry=$TARGET_REGISTRYNAME ./push_image.env.sh $IMAGE_LOCAL
    if [ $? != 0 ]; then
        exit 1
    fi
    cd - &> /dev/null
fi

FINISH=$(date +"%s")

echo "### Time elapsed ($(($FINISH - $START)) = $(($FINISH - $BUILD_COMPLETE)) + $(($BUILD_COMPLETE - $BUILD_STATIC)) + $(($BUILD_STATIC - $CHECK_BASE)) + $(($CHECK_BASE - $START)))s"

exit 0

