#!/bin/bash

#$1         config item
#return     value
get_config_value() {
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $PROJ_CONFIG_DIR/$PROJ-config.yaml
}

#main process

#get value
REGISTRY_URL=$(get_config_value "Registry_url")
REGISTRY_USER=$(get_config_value "Registry_user")
REGISTRY_PWD=$(get_config_value "Registry_password")

#compue base64 result
HUB_SECRET_PLAIN="{\"$REGISTRY_URL\":{\"username\":\"$REGISTRY_USER\",\"password\":\"$REGISTRY_PWD\"}}"
HUB_SECRET_BASE64=$(echo -n $HUB_SECRET_PLAIN | base64 -w 0)

#check
if [[ "$HUB_SECRET_PLAIN" != $(echo -n "$HUB_SECRET_BASE64" | base64 -d) ]]; then
    echo "ERROR: Failed to check base64 result."
    exit 1
fi

#replace
mv $PROJ-config.yaml $PROJ-config.yaml_bakcup &&
sed "s/##Hub_secret_value##/$HUB_SECRET_BASE64/g" $PROJ-config.yaml_bakcup > $PROJ-config.yaml &&
rm $PROJ-config.yaml_bakcup

exit $?
