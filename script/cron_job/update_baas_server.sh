#!/bin/bash

#shold copy ~/.ssh/id_rsa.pub to ~/.ssh/authorized_keys
#brew install pssh
#brew install pscp
#hosts should be add to known_hosts

source ./server_cmd.sh

##########  SERVER SCRIPT
SRC_DIR="cron_server_script"
update_cron_server_script(){
    echo "update_cron_server_script"
    server_cp $SRC_DIR
    if [[ $? == 0 ]]; then
        return 0
    else
        return 1
    fi
}

##########  CRON JOB
declare -a CRON_JOB_LIST=(
"30 4 * * * $WORK_DIR/cron_server_script/cleanup_container.sh"
"30 4 * * * $WORK_DIR/cron_server_script/cleanup_image.sh"
"30 4 * * * $WORK_DIR/cron_server_script/cleanup_log.sh"
);

CRON_JOB_COMMENT="#Cron Job"

#$1=cron job array var name
append_cron_job_string(){
    RETVAL="$CRON_JOB_COMMENT"
    ARRAY="$1[@]"
    for EACH in "${!ARRAY}"; do
        RETVAL=$(echo "$RETVAL"; echo "$EACH $CRON_JOB_COMMENT")
    done
    echo "$RETVAL"
}

CRON_JOB_TMP="$WORK_DIR/cron_server_script/cron_job_tmp"
update_cron_job(){
    echo "update_cron_job"
    CRON_JOB_STR=$(append_cron_job_string CRON_JOB_LIST)

    server_cmd_sudo "echo '' > $CRON_JOB_TMP &&
                     crontab -u root -l | grep -v \"$CRON_JOB_COMMENT\" > $CRON_JOB_TMP;
                     echo \"$CRON_JOB_STR\" >> $CRON_JOB_TMP &&
                     crontab -u root $CRON_JOB_TMP &&
                     rm $CRON_JOB_TMP"

    return 0
}

##########  MAIN
update_cron_server_script
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to update cron server script."
    exit 1
fi

update_cron_job
if [[ $? != 0 ]]; then
    echo "!!!Error: Failed to update cron job."
    exit 1
fi

exit 0
