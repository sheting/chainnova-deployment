#!/bin/bash

START=$(date +"%s")

source ${PROJ}_component_list.sh

echo
echo "############################################################"
echo "##### build images"
echo "############################################################"

#launch the process concurrency
for (( i = 0; i < ${#Component[@]}; i++ )); do
    REPOSITORY="${Component[$i]}"
    SRC_PATH="${Path[$i]}"
    PORT="${Port[$i]}"
    PROJECT_TYPE="${Project_Type[$i]}"
    WDIR="${WDIR[$i]}"
    if [[ $REPOSITORY == "" || $SRC_PATH == "" || $PORT == "" || $PROJECT_TYPE == "" || $WDIR == "" ]]; then
        echo "!!!Error: Missing para. Component OR Path OR Port OR Project_Type OR WDIR. Component Name: $1"
        exit 1
    fi
    #CONCURRENCY=true ./build_image.sh &> build_image.log
    echo
    echo "*********** build compoment $REPOSITORY ***********"
    REPOSITORY=$REPOSITORY SRC_PATH=$SRC_PATH PORT=$PORT MODEL_TYPE=$MODEL_TYPE WDIR=$WDIR ./build_image_${PROJECT_TYPE}.sh $REPOSITORY

    cd - &> /dev/null
done

#concurrency build, remove dangling image when all build process done.
docker rmi $(docker images -q -f dangling=true) &> /dev/null

FINISH=$(date +"%s")
echo
echo "##### Total Time elapsed ($(($FINISH - $START)))"

exit $RET_VALUE
