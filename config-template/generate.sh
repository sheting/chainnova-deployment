#!/bin/bash

#check image
./build_image.sh &> build_image.log
if [[ $? != 0 ]]; then
    echo "!!!Error: Build image failed."
    exit 1
fi

if [[ "$PROJ" == "common" && "$PROJ_CONFIG_DIR" != "" ]]; then
    echo "common generate. set the special config path $RELATIVE_PATH"
    RELATIVE_PATH="./"
else
    RELATIVE_PATH="../../"
fi

#run script in docker
docker run  --rm \
            -v $(pwd)/../../:/home \
            -e GIT_COMMIT_ID=${GIT_COMMIT_ID} \
            chainnova/config-template:0.0.1 \
            -c "cd deployment/config-template && PROJ_CONFIG_DIR=${PROJ_CONFIG_DIR:-'${RELATIVE_PATH}k8syaml/config-template'} PROJ=$PROJ TAG=${__TAG} ./generate_in_docker.sh $1"

exit $?
