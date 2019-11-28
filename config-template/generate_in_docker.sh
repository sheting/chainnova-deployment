#!/bin/bash

#$1         config item
#return     value
get_config_value() {
    FILE_NAME=${FILE_NAME:-'$PROJ-config.yaml'}
    PATTERN='$1=='"\"$1:\""'{print $2}'
    awk "$PATTERN" $FILE_NAME
}

#env
echo
echo "##############################"
echo "##### env"
echo "##############################"
if [[ "$1" == "" ]]; then
    echo "ERROR: Not specified env name."
    exit 1
fi

if [[ "$PROJ" == "" || "$TAG" == "" || "$GIT_COMMIT_ID" == "" ]]; then
    echo "ERROR: Missing para.PROJ($PROJ) OR TAG($TAG) OR GIT_COMMIT_ID($GIT_COMMIT_ID)"
    exit 1
fi

if [[ "$PROJ" == "common" && "$PROJ_CONFIG_DIR" != "" ]]; then
    echo "common generate. set the special config file rule to common-config-$1"
    CONFIG_ENV_FILE="$PROJ_CONFIG_DIR/$PROJ-config-$1.yaml"
    TMPL_LIST_FILE="${PROJ}_tmpl_list.sh"
else
    CONFIG_ENV_FILE="$PROJ_CONFIG_DIR/config-$1.yaml"
    TMPL_LIST_FILE="tmpl_list.sh"
fi

CONFIG_FILE="$PROJ-config.yaml"
IMAGE_TAG_SUFFIX="-$1"
if [[ ! -f "$CONFIG_ENV_FILE" ]]; then
    echo "ERROR: Can't find env config file \"$CONFIG_ENV_FILE\"."
    exit 1
fi

echo
echo "##############################"
echo "##### replace the release env"
echo "##############################"
REGISTRY_ENV=$(FILE_NAME=$CONFIG_ENV_FILE get_config_value "Target_registry")
source registry/registry-${REGISTRY_ENV}.env
#IMAGE_TAG_SUFFIX used to push different tag image for different env
sed "s/##IMAGE_TAG_SUFFIX##/$IMAGE_TAG_SUFFIX/g;s/##IMAGE_TAG##/$TAG/g;s/##Registry_url##/$REGISTRY_URL/g;s/##Registry_user##/$REGISTRY_USER/g;s/##Registry_password##/$REGISTRY_PW/g;s/##Registry_type##/$REGISTRY_TYPE/g" $CONFIG_ENV_FILE >$PROJ_CONFIG_DIR/$CONFIG_FILE
if [[ $? != 0 ]]; then
    exit 1
fi
echo "COMMIT_ID: ${GIT_COMMIT_ID}" >> $PROJ_CONFIG_DIR/$CONFIG_FILE
if [[ $? != 0 ]]; then
    exit 1
fi
echo "SUCCESS"

#get value
REGISTRY_TYPE=$(FILE_NAME=$PROJ_CONFIG_DIR/$CONFIG_FILE get_config_value "Registry_type")
echo $REGISTRY_TYPE
if [[ $REGISTRY_TYPE == "docker_registry" ]]; then
    #hub secret
    echo
    echo "##############################"
    echo "##### secret"
    echo "##############################"
    ./generate_secret.sh
    if [[ $? != 0 ]]; then
        exit 1
    fi
    echo "SUCCESS"

    #htpasswd
    echo
    echo "##############################"
    echo "##### htpasswd"
    echo "##############################"
    ./generate_htpasswd.sh
    if [[ $? != 0 ]]; then
        exit 1
    fi
    echo "SUCCESS"
fi

#replace push_image and pull_image
sed "s/##PROG##/$PROJ/g" ../script/utils/pull_image.sh.tmpl.tmp > ../script/utils/pull_image.sh.tmpl &&
sed "s/##PROG##/$PROJ/g" ../script/utils/push_image.sh.tmpl.tmp > ../script/utils/push_image.sh.tmpl
if [[ $? != 0 ]]; then
    echo "ERROR: Failed to replace para PROJ"
    exit 1
fi

#tmpl files
echo
echo "##############################"
echo "##### tmpl"
echo "##############################"
cd ${PROJ_CONFIG_DIR}
source $TMPL_LIST_FILE

for (( i = 0; i < ${#CONFIG_FILE_LIST[@]}; i++ )); do
    CONFIG_FILE_EACH="${CONFIG_FILE_LIST[$i]}"

    #copy
    cp "$CONFIG_FILE_EACH.tmpl" "$CONFIG_FILE_EACH"
    if [[ $? != 0 ]]; then
        echo "ERROR: Failed to copy $CONFIG_FILE_EACH.tmpl"
        exit 1
    fi

    #gomplate
    gomplate --file "$CONFIG_FILE_EACH.tmpl" --out "$CONFIG_FILE_EACH" --datasource $CONFIG_FILE 
    #--datasource $common-config.yaml
    if [[ $? != 0 ]]; then
        echo "ERROR: Failed to execute $CONFIG_FILE_EACH.tmpl"
        exit 1
    fi

    echo "SUCCESS $CONFIG_FILE_EACH"
done
cd - &> /dev/null

#give script execution permission
chmod +x ../script/utils/pull_image.sh &&
chmod +x ../script/utils/push_image.sh
#chmod +x ../build_image_ionic.sh &&
#chmod +x ../build_image_vue.sh
if [[ $? != 0 ]]; then
    echo "ERROR: Failed to give script execute Permission"
    exit 1
fi

exit 0
