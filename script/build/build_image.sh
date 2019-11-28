#!/bin/bash

START=$(date +"%s")

export RELATIVE_PATH="../../.."
export SCRIPT_DIR="../utils/"

echo "****** load component para file ******"
cd ../utils/
source ./load_compoment_para.sh $1
if [ $? != 0 ]; then
    echo "!!!Error: Load Component Para file failed."
    exit 1
fi
cd - &> /dev/null

echo
echo "#########################################"
echo "##### build image with $_PROJECT_TYPE sh"
echo "#########################################"
#export TAG=${GIT_TAG:-'testtag.'$BRANCH}
export REPOSITORY=$PROJ/$_REPOSITORY
export SRC_PATH=$SRC_PATH
export PORT=$_PORT
#export MODE_TYPE=$MODE_TYPE
export WDIR=$_WDIR
export TAG=$__TAG
#only used to distingrush vue and vue_h5
export build_script=build_${_PROJECT_TYPE}.sh

if [[ ${_PROJECT_TYPE} =~ 'vue' ]]; then
	export _PROJECT_TYPE='vue'
fi

./build_image_${_PROJECT_TYPE}.sh $REPOSITORY
# &> /build_image.log
if [ $? != 0 ]; then
    echo "!!!Error: build image failed."
    exit 1
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) "
exit 0
