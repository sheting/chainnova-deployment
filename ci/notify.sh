#!/bin/bash

#user
declare -a USER_LIST=(
'liuyongming'
'lixiaoling'
'lisa'
);
declare -a MOBILE_LIST=(
'18810759508'
'13261904513'
'13671257620'
);
get_user_mobile() {
    local ret_val=""

    for (( i = 0; i < ${#USER_LIST[@]}; i++ )); do
        if [[ "${USER_LIST[$i]}" = "$__USER" ]]; then
            ret_val="${MOBILE_LIST[$i]}"
            break
        fi
    done

    echo "$ret_val"
}

##### main process
echo
echo "****************************************************************************************************"
echo "**********    [PARA]"
echo "****************************************************************************************************"
if [ "$__DINGTALK_URL" == "" ] || [ "$__CLUSTER_ENV_NAME" == "" ]; then
    echo "Parameter not specified."
    exit 1
fi

#@some one
__ATMOBILE=$(get_user_mobile)
if [[ "$__PIPELINE_SRC" != "schedule" ]] || [[ "$__ATMOBILE" == "" ]]; then
    __ATALL="true"
else
    __ATALL="false"
fi
__DATA="
{
    \"msgtype\": \"text\",
    \"text\": {
        \"content\": {
            \"cluster\": \"$__CLUSTER_ENV_NAME\",
            \"pipelineid\": $__PIPELINE_ID
        }
    },
    \"at\": {
        \"atMobiles\": [
            \"$__ATMOBILE\"
        ],
        \"isAtAll\": $__ATALL
    }
}"

curl "$__DINGTALK_URL" \
    -H 'Content-Type: application/json' \
    -d "$__DATA"

#message
#__DATA="
#{
#    \"msgtype\": \"markdown\",
#    \"markdown\": {
#        \"title\":\"$__CLUSTER_ENV_NAME\",
#        \"text\": \"## **$__CLUSTER_ENV_NAME**\n > #$__PIPELINE_ID\n\n > branch: **$__BRANCH**\n\n > commit: **$__COMMITMSG**\n\n > ![screenshot](https://picsum.photos/300/150?image=$(($RANDOM % 1000)))\n\n > Triger by **$__PIPELINE_SRC**, [Link to GitLab]($__PIPELINE_URL)\n\n > ###### $__PROJECT\n\n \"
#    }
#}"
#curl "$__DINGTALK_URL" \
#   -H 'Content-Type: application/json' \
#   -d "$__DATA"

echo "SUCCESS"

