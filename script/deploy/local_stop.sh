#!/bin/bash

export RELATIVE_PATH="../../.."
export __TAG='local'

echo
echo "************   [CHECK PARA]  *************"
if [[ "$PROJ" == "" ]]; then
    echo "Parameter not specified. PROJ "
    exit 1
fi

if [[ "$1" == "" && (! -f ${RELATIVE_PATH}/local_list.sh) ]]; then
    echo "Parameter not specified. component "
    exit 1
fi

if [[ -f ${RELATIVE_PATH}/local_list.sh ]]; then
	source ${RELATIVE_PATH}/local_list.sh
else
	declare -a local_comps=("$1");
fi

if [[ -f ${RELATIVE_PATH}/docker_compose.yaml ]]; then
    echo "run with docker_compose"
    docker_compose=true
    exit 1
fi

if [[ "$docker_compose"==false ]]; then
    for (( i = 0; i < ${#local_comps[@]}; i++ )); do
        local_comp="${local_comps[$i]}"
        echo "******** RM $local_comp **********"
        CONTAINER_NAME=$(echo $local_comp | tr "\/" "-")
        docker rm -f $CONTAINER_NAME
    done
else
    cd ${RELATIVE_PATH}
    docker-compose -f docker-compose.yaml down -d
fi



echo "clean config"

cd ../../config-template/
PROJ=$PROJ ./clean.sh
res=$?
cd - &> /dev/null
if [ $res != 0 ]; then
    echo "!!!Error: generate file failed."
    exit 1
fi

exit 0
