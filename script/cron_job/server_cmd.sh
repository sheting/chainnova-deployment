#!/bin/bash

declare -a SERVER_LIST=(
"server_list_hw root key ~/.ssh/chainnova-cluster.pem"
"server_list_test root key ~/.ssh/chainnova-cluster.pem"
#"server_list_ubuntu_aws ubuntu key ~/.ssh/id_rsa_EBP-Dev-Env-AWS"
#"server_list_ubuntu_aliyun root pwd Should'nStoredInCode"
);

##########  COMMAND FRAMEWORK
#$1 command
server_cmd(){
    for EACH_SERVER in "${SERVER_LIST[@]}"; do
        HOST=$(echo "$EACH_SERVER" | cut -d " " -f 1)
        USER=$(echo "$EACH_SERVER" | cut -d " " -f 2)
        TYPE=$(echo "$EACH_SERVER" | cut -d " " -f 3)
        PSWD=$(echo "$EACH_SERVER" | cut -d " " -f 4)

        if [[ $TYPE == "key" ]]; then
            pssh -h $HOST -l $USER -x "-i $PSWD" "$1"
        elif [[ $TYPE == "pwd" ]]; then
            pssh -h $HOST -l $USER "$1"
        fi
    done
}

#$1=command
server_cmd_sudo(){
    for EACH_SERVER in "${SERVER_LIST[@]}"; do
        HOST=$(echo "$EACH_SERVER" | cut -d " " -f 1)
        USER=$(echo "$EACH_SERVER" | cut -d " " -f 2)
        TYPE=$(echo "$EACH_SERVER" | cut -d " " -f 3)
        PSWD=$(echo "$EACH_SERVER" | cut -d " " -f 4)

       #echo "$PSWD" | pssh -h $HOST -l $USER -I "sudo -S $1"
       #echo "$PSWD" | pssh -h $HOST -l $USER -I "sudo -S -- sh -c '$1'"
        if [[ $TYPE == "key" ]]; then
            pssh -h $HOST -l $USER -x "-i $PSWD" "sudo -- sh -c '$1'"
        elif [[ $TYPE == "pwd" ]]; then
            pssh -h $HOST -l $USER "sudo -S -- sh -c '$1'"
            #echo "$PSWD" | pssh -h $HOST -l $USER -I "sudo -S -- sh -c '$1'"
        fi
    done
}

#$1=SRC
WORK_DIR="/home/ubuntu"
server_cp(){
    for EACH_SERVER in "${SERVER_LIST[@]}"; do
        HOST=$(echo "$EACH_SERVER" | cut -d " " -f 1)
        USER=$(echo "$EACH_SERVER" | cut -d " " -f 2)
        TYPE=$(echo "$EACH_SERVER" | cut -d " " -f 3)
        PSWD=$(echo "$EACH_SERVER" | cut -d " " -f 4)

        if [[ $TYPE == "key" ]]; then
            pssh -h $HOST -l $USER -x "-i $PSWD" "rm -rf $WORK_DIR/$1 && mkdir -p $WORK_DIR/$1"
            pscp -h $HOST -l $USER -x "-i $PSWD" -r "$1" "$WORK_DIR"
        elif [[ $TYPE == "pwd" ]]; then
            pssh -h $HOST -l $USER "rm -rf $WORK_DIR/$1 && mkdir -p $WORK_DIR/$1"
            pscp -h $HOST -l $USER -r "$1" "$WORK_DIR"
        fi
    done
}
