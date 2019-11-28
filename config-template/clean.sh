#!/bin/bash

if [[ "$PROJ" == "common" && "$PROJ_CONFIG_DIR" != "" ]]; then
    RELATIVE_PATH="./"
else
    RELATIVE_PATH="../../"
fi

PROJ_CONFIG_DIR=${PROJ_CONFIG_DIR:-${RELATIVE_PATH}"k8syaml/config-template"}

if [[ "$PROJ" == "common" && "$PROJ_CONFIG_DIR" != "" ]]; then
    TMPL_LIST_FILE="${PROJ}_tmpl_list.sh"
else
    TMPL_LIST_FILE="tmpl_list.sh"
fi

source ${PROJ_CONFIG_DIR}/${TMPL_LIST_FILE}

cd ${PROJ_CONFIG_DIR}
for (( i = 0; i < ${#CONFIG_FILE_LIST[@]}; i++ )); do
    CONFIG_FILE_EACH="${CONFIG_FILE_LIST[$i]}"

    rm -f "$CONFIG_FILE_EACH" &> /dev/null
done
cd - &> /dev/null

rm -f "htpasswd" &> /dev/null
rm -f "${PROJ_CONFIG_DIR}/${PROJ}-config.yaml" &> /dev/null
rm -f "../script/utils/pull_image.sh.tmpl" &> /dev/null
rm -f "../script/utils/push_image.sh.tmpl" &> /dev/null
rm -f "../build_image_ionic.sh.tmpl" &> /dev/null
rm -f "../build_image_vue.sh.tmpl" &> /dev/null
rm -f "../ci/kubectl/docker/config/.kube" &> /dev/null

exit 0
