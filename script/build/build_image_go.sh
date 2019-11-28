#!/bin/bash

START=$(date +"%s")

#REPOSITORY & TAG & IMAGE
BASE_TAG="0.0.2"
IMAGE_LOCAL="$REPOSITORY:$__TAG"

echo '*** CHECK PARA ***'
if [[ $REPOSITORY == "" || __TAG == "" || __MODE_TYPE == "" || WDIR == ""  ]]; then
    echo "!!!Error: Missing para. REPOSITORY OR TAG. Component Name: $1"
    exit 1
fi

echo
echo "##############################"
echo "##### exec prepare script"
echo "##############################"
if [ -f "${SRC_PATH}/scripts/prepare-build.sh" ]; then 
    cd ${SRC_PATH}/scripts/
    MODE_TYPE=$__MODE_TYPE ./prepare-build.sh
    res=$?
    cd - &> /dev/null
    if [[ $res != 0 ]]; then
        exit 1
    fi
    echo "SUCCESS"
else
    echo "no prepare-build.sh need to exec "
fi

echo
echo "##############################"
echo "##### build dependent images"
echo "##############################"
BASE_REPOSITORY=$REPOSITORY"-base"
BASE_IMAGE_LOCAL="$BASE_REPOSITORY:$BASE_TAG"
docker images | grep -q -E "^$BASE_REPOSITORY\s+$BASE_TAG\s+"
if [ $? != 0 ]; then
    echo "Need to rebuild $BASE_IMAGE_LOCAL"
    docker build -f ../../deploy_go/Dockerfile_base -t $BASE_IMAGE_LOCAL ./$SRC_PATH
    if [ $? != 0 ]; then
        echo "!!!Error: Build $BASE_IMAGE_LOCAL failed."
        exit 1
    fi
else
    echo "No need to rebuild $BASE_IMAGE_LOCAL"
fi

echo
echo "##############################"
echo "##### build saas bbsp image"
echo "##############################"
#build image
docker build --no-cache --build-arg BASE_REPOSITORY=$BASE_REPOSITORY --build-arg WDIR=$WDIR --build-arg BASE_TAG=$BASE_TAG --build-arg MODE_TYPE=$__MODE_TYPE -f ../../deploy_go/Dockerfile -t $IMAGE_LOCAL ./$SRC_PATH
if [ $? != 0 ]; then
    echo "!!!Error: Build image failed."
    exit 1
fi
if [[ $CONCURRENCY != "true" ]]; then
    docker rmi $(docker images -q -f dangling=true)
fi
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

#push image
if [[ $PUSH_IMAGE == "true" ]]; then
    cd $SCRIPT_DIR
    ./push_image.sh $IMAGE_LOCAL
    if [ $? != 0 ]; then
        echo "!!!Error: Push image failed."
        exit 1
    fi
    cd - &> /dev/null
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"


exit 0
