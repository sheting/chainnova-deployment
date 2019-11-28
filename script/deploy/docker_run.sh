#!/bin/bash

export RELATIVE_PATH="../../.."
export PROJ_CONFIG_DIR="$RELATIVE_PATH/k8syaml/config-template"

get_config_value() {
    FILE_NAME=${FILE_NAME:-${PROJ_CONFIG_DIR}'/'${PROJ}'-config.yaml'}
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $FILE_NAME
}

START=$(date +"%s")
export CONTAINER_NAME=$(echo ${PROJ}-$1 | tr "\/" "-")
export DOCKER_IMAGE=$PROJ/$1:$__TAG
export registry=$(get_config_value "Target_registry")

echo "Component: $1"
echo "****** load component para file ******"
cd ../utils/
source ./load_compoment_para.sh $1
if [ $? != 0 ]; then
    echo "!!!Error: Load Component Para file failed."
    exit 1
fi

echo "****** check para ******"
if [[ $DOCKER_NETWORK == "" || $CONTAINER_NAME == "" || $__MODE_TYPE == "" ]]; then
    echo "!!!Error: Missing para. DOCKER_NETWORK OR CONTAINER_NAME OR __MODE_TYPE. Component Name: $1"
    exit 1
fi


echo "*** mkdir ***"
ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"mkdir -p /home/ubuntu/preview_script/script/utils"
ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"mkdir -p /home/ubuntu/preview_script/runenv"
ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"mkdir -p /home/ubuntu/preview_script/config-template"
if [ "$?" != "0" ]; then
  echo '!!!ERR: mkdir failed!'
  exit 1
fi

if [[ ${_PROJECT_TYPE} =~ 'vue' ]]; then
  scp -i /ssh/id_rsa_EBP-Dev-Env-AWS ${SRC_PATH}/.env ubuntu@52.83.220.111:/home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv.default
  BUILD_ENV=" --env-file /home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv.default"
fi

echo "*** scp ***"
if [ -f "${SRC_PATH}/.env.${__MODE_TYPE}" ]; then 
  echo "*** scp env file***"
  scp -i /ssh/id_rsa_EBP-Dev-Env-AWS ${SRC_PATH}/.env.${__MODE_TYPE} ubuntu@52.83.220.111:/home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv
  scp -i /ssh/id_rsa_EBP-Dev-Env-AWS ${SRC_PATH}/.env.${__MODE_TYPE} ubuntu@52.83.220.111:/home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv
  ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"sudo chmod +777 /home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv"
#  src_env=${SRC_PATH}/.env.${__MODE_TYPE}
  BUILD_ENV="\""$BUILD_ENV" --env-file /home/ubuntu/preview_script/runenv/${CONTAINER_NAME}.runenv\""
fi 
scp -i /ssh/id_rsa_EBP-Dev-Env-AWS /home/deployment/script/utils/pull_image.env.sh ubuntu@52.83.220.111:/home/ubuntu/preview_script/script/utils/pull_image.env.sh
scp -i /ssh/id_rsa_EBP-Dev-Env-AWS -r /home/deployment/config-template/registry ubuntu@52.83.220.111:/home/ubuntu/preview_script/config-template/registry
scp -i /ssh/id_rsa_EBP-Dev-Env-AWS /home/deployment/script/deploy/remote_docker_run.sh ubuntu@52.83.220.111:/home/ubuntu/preview_script/remote_docker_run.sh


echo "*** pull image ***"
ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"cd /home/ubuntu/preview_script/script/utils && registry=$registry ./pull_image.env.sh $DOCKER_IMAGE"
if [ "$?" != "0" ]; then
  echo '!!!ERR: pull image failed!'
  exit 1
fi

echo "*** docker run service ***"
ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"/home/ubuntu/preview_script/remote_docker_run.sh $_DOCKER_PORT $_PORT $CONTAINER_NAME $DOCKER_IMAGE $DOCKER_NETWORK $BUILD_ENV"
if [ "$?" != "0" ]; then
  echo '!!!ERR: Start service failed!'
  exit 1
fi

#ssh -i /ssh/id_rsa_EBP-Dev-Env-AWS ubuntu@117.78.4.250"rm -rf /home/ubuntu/preview_script/remote_docker_run.sh"

echo "*** SUCCESS ***"
exit 0
