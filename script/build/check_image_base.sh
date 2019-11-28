#!/bin/bash

# build static
START=$(date +"%s")

export SCRIPT_DIR="../utils"

BASE_TAG=${BASE_TAG:-'3.0.0'}
SERVICE_BASE_TAG=${SERVICE_BASE_TAG:-'3.0.0'}

#echo '*** CHECK PARA ***'
#if [[ $REGISTRYNAME == "" || $BASE_BUILD_REPOSITORY == "" || $BASE_DEV_REPOSITORY == "" || $BASE_SERVICE_REPOSITORY == "" || $BASE_TAG == "" || $SERVICE_BASE_TAG == "" ]]; then
#    echo "!!!Error: Missing para. REGISTRYNAME OR BASE_BUILD_REPOSITORY OR BASE_DEV_REPOSITORY OR BASE_SERVICE_REPOSITORY OR BASE_TAG OR SERVICE_BASE_TAG. Component Name: $1"
#    echo "REGISTRY_NAME: $REGISTRYNAME"
#    exit 1
#fi

CHECK_BUILD=$(date +"%s")

for line in $(cat .tmp_base_image)
do
    IMAGE_LOCAL="${line}"
    echo
    echo "********************* check $IMAGE_LOCAL begin *********************"
    docker images | grep -q -E "^${IMAGE_LOCAL%:*}\s+${IMAGE_LOCAL#*:}\s+"
    if [[ $? != 0 || $ALWAYS_PULL == "true" ]]; then
        echo "Need to pull $IMAGE_LOCAL"
        cd $SCRIPT_DIR
        registry=$REGISTRYNAME ./pull_image.env.sh $IMAGE_LOCAL
        res=$?
        cd - &> /dev/null
        if [ $res != 0 ]; then
            echo "!!!Error: Pull $IMAGE_LOCAL failed."
            exit 1
        fi
    else
        echo "No need to pull $IMAGE_LOCAL"
    fi
done

FINISH=$(date +"%s")

rm -rf .tmp_base_image

echo "### Time elapsed ($(($FINISH - $START)) = $(($FINISH - $CHECK_BUILD)) + $(($CHECK_BUILD - $START)))s"

exit 0

