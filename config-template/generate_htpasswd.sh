#!/bin/bash

#$1         config item
#return     value
get_config_value() {
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $PROJ_CONFIG_DIR/$PROJ-config.yaml
}

#main process

#get value
REGISTRY_USER=$(get_config_value "Registry_user")
REGISTRY_PWD=$(get_config_value "Registry_password")

#compue htpasswd
htpasswd -cbB ./htpasswd $REGISTRY_USER $REGISTRY_PWD &> /dev/null
exit $?
