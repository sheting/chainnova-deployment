#!/bin/bash

export RELATIVE_PATH="../../.."
export __TAG='development'
export __MODE_TYPE='development'
export index=${index:-0}

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

if [[ -f ${RELATIVE_PATH}/docker_compose.yaml ]]; then
    echo "run with docker_compose"
    docker_compose=true
    exit 1
fi

echo "generate config"

cd ../../config-template/
PROJ=$PROJ __TAG='development' ./generate.sh ${__MODE_TYPE} 
res=$?
cd - &> /dev/null
if [ $res != 0 ]; then
    echo "!!!Error: generate file failed."
    exit 1
fi

if [[ -f ${RELATIVE_PATH}/local_list.sh ]]; then
	source ${RELATIVE_PATH}/local_list.sh
else
	declare -a local_comps=("$1");
fi

for (( i = 0; i < ${#local_comps[@]}; i++ )); do
    local_comp="${local_comps[$i]}"
    echo "******** Run $local_comp **********"
    ./local_run_core.sh $local_comp
    if [ $? != 0 ]; then
        echo "!!!Error: Run component Filed.$local_comp"
        exit 1
    fi
done

cd ${RELATIVE_PATH}

exit 0
