#!/bin/bash

export RELATIVE_PATH="../../.."

echo
echo "#######################################"
echo "############    [CHECK PARA]"
echo "#######################################"
echo "__TAG: $__TAG"
echo "PROJ: $PROJ"
if [[ "$__TAG" == "" || "$PROJ" == "" ]]; then
    echo "Parameter not specified."
    exit 1
fi

source $RELATIVE_PATH/component_list.sh
echo
echo "##############################"
echo "##### select matched component"
echo "##############################"
for (( i = 0; i < ${#Component[@]}; i++ )); do
    if [[ "${Component[$i]}" == $1 ]]; then
        export _REPOSITORY="${Component[$i]}"
        export _SRC_PATH="${Path[$i]}"
        export _PORT=${Port[$i]:-'8088'}
        export _PROJECT_TYPE="${Project_Type[$i]}"
        export _WDIR=${WDIR[$i]:-$_SRC_PATH}
        export _YAML_PATH="${Yaml_Path[$i]}"
        export _YAML_NAME="${Yaml_Name[$i]}"
        export _DOCKER_PORT="${Docker_Port[$i]}"
        echo "SUCCESS find component: $_REPOSITORY"
        break
    fi
done

export SRC_PATH="${RELATIVE_PATH}/${_SRC_PATH}"

if [[ $_REPOSITORY == "" || $SRC_PATH == "" || $_PORT == "" || $_PROJECT_TYPE == "" || $_WDIR == "" ]]; then
	echo "_REPOSITORY:$_REPOSITORY; SRC_PATH:$SRC_PATH; _PORT:$_PORT; _PROJECT_TYPE:$_PROJECT_TYPE; _WDIR:$_WDIR "
    echo "!!!Error: Missing para. Component OR Path OR Port OR Project_Type OR WDIR. Component Name: $1"
    exit 1
fi

if [[ ($_YAML_PATH == "" || $_YAML_NAME == "") && __MODE_TYPE != "docker" ]]; then
    echo "!!!Error: Missing para. __MODE_TYPE is docker and YAML_INFO is null. Component Name: $1"
    exit 1
fi

if [[ $_DOCKER_PORT == "" && __MODE_TYPE == "docker" ]]; then
    echo "!!!Error: Missing para. __MODE_TYPE is docker and _DOCKER_PORT is null. Component Name: $1"
    exit 1
fi
