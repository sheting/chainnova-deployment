#!/bin/bash

#$1         config item
#return     value
get_config_value() {
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" ../../config-template/$PROJ-config.yaml
}

delete_configmap_from_file() {
#    echo -e "\n##### configmap #####"
    configmap_delete=$1
    _NAME_SPACE_=$2
    if [[ "" == "$configmap_delete" || "" == "$_NAME_SPACE_" ]]; then
        echo "!!!Error: delete_configmap_from_file para error."
        exit 1
    fi
    for line in $(cat $configmap_delete)
    do
        EachConf="${line}"
        kubectl delete configmap $EachConf                --namespace $_NAME_SPACE_
        if [[ $? != 0 ]]; then
            echo "!!!Error: Failed to delete configmap: " $EachConf
        fi
    done
    
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}