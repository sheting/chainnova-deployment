#!/bin/bash

source deploy_public_func.sh

create_configmap() {
    Yaml_DIR=$1
    CONFIGMAP_VERSION=$2
    parse_yaml $Yaml_DIR/namespace.yaml
    eval $(parse_yaml $Yaml_DIR/namespace.yaml )
    _NAME_SPACE_=${_NAME_SPACE_:-$metadata_name}

    echo "namespace: $_NAME_SPACE_"

    if [[ ! -f $Yaml_DIR/component_configmap.sh ]]; then
        echo "!!!Warning: No configmap need to be created "
        return 0
    fi
    source $Yaml_DIR/component_configmap.sh
    #configmap
    echo -e "\n##### configmap #####"
#    ./$Yaml_DIR/platform-server-cp-yaml.sh
    for (( i = 0; i < ${#Configmap[@]}; i++ )); do
        EachConf="${Configmap[$i]}"
        EachConfSrc="${ConfigmapSource[$i]}"
        kubectl create configmap $EachConf$CONFIGMAP_VERSION                --from-file=$Yaml_DIR/$EachConfSrc           --namespace $_NAME_SPACE_
        if [[ $? != 0 ]]; then
            echo "!!!Error: Failed to create configmap: " $EachConf
            exit 1
        fi
    done
}

### create all component in component
create_component() {
    Yaml_DIR=$1
    REGISTRY_TYPE=$(get_config_value "Registry_type")
    
    #components
    source $Yaml_DIR/component_$REGISTRY_TYPE.sh

    for EachComp in "${Component[@]}"
    do
        echo -e "\n##### $EachComp #####"
        ls $Yaml_DIR/$EachComp.yaml
        kubectl apply -f $Yaml_DIR/$EachComp.yaml --record=true
        if [[ $? != 0 ]]; then
            echo "!!!Error: Failed to create component $EachComp."
            exit 1
        fi
        sleep 0.5
    done  
}





