#!/bin/bash

START=$(date +"%s")

source ${PROJ}_component_list.sh

declare -a Pid
declare -a Status

#return 0:true
#       1:false
is_all_process_finish() {
    local i
    for (( i = 0; i < ${#Component[@]}; i++ )); do
        if [ "${Status[$i]}" == "RUNNING" ]; then
            return 1
        fi
    done
    return 0
}

#return 0:true
#       1:false
is_all_process_success() {
    local i
    for (( i = 0; i < ${#Component[@]}; i++ )); do
        if [ "${Status[$i]}" != "SUCCESS" ]; then
            return 1
        fi
    done
    return 0
}

print_clear_line() {
    local i
    local SPACE
    for (( i = 0; i < 160; i++ )); do
        SPACE="$SPACE "
    done
    echo -ne "\r$SPACE\r"
}

declare -a Spin=(
'-'
'\'
'|'
'/'
);

#$1=time, $2=index
print_finish_process() {
    local i

    #progress bar
    local PROGRESS_NUM
    local PROGRESS_BAR
    PROGRESS_NUM=$(($1 / 10 + 1))
    for (( i = 1; i <= $PROGRESS_NUM; i++ )); do
        PROGRESS_BAR="$PROGRESS_BAR#"
    done
    for (( i = 1; i <= 60-$PROGRESS_NUM; i++ )); do
        PROGRESS_BAR="$PROGRESS_BAR "
    done

    if [ "$SHOW_PROGRESS_BAR" == "true" ]; then
        print_clear_line
    fi
    echo -e "[$PROGRESS_BAR][$1s]\t[${Status[$2]}]\t${Component[$2]}\t$(cat ${Path[$2]}/build_image.log | grep "##### Time elapsed")"
}

#$1=time
print_running_process() {
    if [ "$SHOW_PROGRESS_BAR" != "true" ]; then
        return
    fi

    local i

    #progress bar
    local PROGRESS_NUM
    local PROGRESS_BAR
    PROGRESS_NUM=$(($1 / 10))
    for (( i = 1; i <= $PROGRESS_NUM; i++ )); do
        PROGRESS_BAR="$PROGRESS_BAR#"
    done
    PROGRESS_BAR="$PROGRESS_BAR${Spin[$(($1 % 4))]}"
    for (( i = 1; i <= 60 - $(($PROGRESS_NUM+1)); i++ )); do
        PROGRESS_BAR="$PROGRESS_BAR "
    done

    #component
    local COMPONENT
    for (( i = 0; i < ${#Component[@]}; i++ )); do
        if [ "${Status[$i]}" == "RUNNING" ]; then
            COMPONENT="$COMPONENT${Component[$i]}|"
        fi
    done

    print_clear_line
    echo -ne "[$PROGRESS_BAR][$1s]\t[RUNNING]\t$COMPONENT"
}

kill_all_running_process() {
    local i

    for (( i = 0; i < ${#Component[@]}; i++ )); do
        if [ "${Status[$i]}" == "RUNNING" ]; then
            #Avoid repeated kill operation
            #For example, when the first process fails, other running processes has been killed
            #In response to the subsequent kill to exit, do not need to Kill again
            ps | grep -E -q "^\s*${Pid[$i]}\s+"
            if [ $? == 0 ]; then
                echo -e "Kill\t${Pid[$i]}\t${Component[$i]}"
                kill ${Pid[$i]}
            fi
        fi
    done

    docker rm -f $(docker ps -a | awk '{print $1}')
}

FIRST_FAILED_PROCESS_INDEX=-1
show_first_failed_process_log() {
    if [[ $FIRST_FAILED_PROCESS_INDEX == -1 ]]; then
        echo "Can't find the first failed process."
        return
    fi

    echo -e "\n##### show first failed process log [${Component[$FIRST_FAILED_PROCESS_INDEX]}] #####\n"
    cat ${Path[$FIRST_FAILED_PROCESS_INDEX]}/build_image.log
    echo -e "\n##### show first failed process log [${Component[$FIRST_FAILED_PROCESS_INDEX]}] #####\n"
}

echo
echo "############################################################"
echo "##### build images"
echo "############################################################"

#launch the process concurrency
for (( i = 0; i < ${#Component[@]}; i++ )); do
    REPOSITORY="${Component[$i]}"
    SRC_PATH="${Path[$i]}"
    PORT="${Port[$i]}"
    Project_Type="${Project_Type[$i]}"
    WDIR="${WDIR[$i]}"
    if [[ $REPOSITORY == "" || $SRC_PATH == "" || $PORT == "" || $Project_Type == "" || $WDIR == "" ]]; then
        echo "!!!Error: Missing para. Component OR Path OR Port OR Project_Type OR WDIR. Component Name: $1"
        kill_all_running_process
        exit 1
    fi
    echo
    echo "*********** build compoment $REPOSITORY ***********"
    REPOSITORY=$REPOSITORY SRC_PATH=$SRC_PATH PORT=$PORT MODEL_TYPE=$MODEL_TYPE WDIR=$WDIR ./build_image_${Project_Type}.sh $REPOSITORY &> $SRC_PATH/build_image.log &

    Pid[$i]=$!
    Status[$i]="RUNNING"

    cd - &> /dev/null
done

#wait for all process finish
for (( i = 0; i < 36000; i++ )); do
    CURRENT=$(date +"%s")

    for (( j = 0; j < ${#Component[@]}; j++ )); do
        if [ "${Status[$j]}" != "RUNNING" ]; then
            continue
        fi

        ps | grep -E -q "^\s*${Pid[$j]}\s+"
        if [ $? != 0 ]; then
            wait ${Pid[$j]}
            if [ $? == 0 ]; then
                Status[$j]="SUCCESS"
            else
                Status[$j]="FAILED"
                if [[ $FIRST_FAILED_PROCESS_INDEX == -1 ]]; then
                    FIRST_FAILED_PROCESS_INDEX=$j
                fi
            fi

            print_finish_process $(($CURRENT - $START)) $j

            #a process failed, other processes should be killed
            if [ ${Status[$j]} == "FAILED" ]; then
                kill_all_running_process
            fi
        fi
    done

    is_all_process_finish
    if [ $? == 0 ]; then
        break
    fi

    print_running_process $(($CURRENT - $START))

    sleep 0.1
done

is_all_process_finish
if [ $? != 0 ]; then
    CURRENT=$(date +"%s")
    echo "!!!Error: All processes failed to finish within $(($CURRENT - $START)) second."
fi

is_all_process_success
RET_VALUE=$?
if [ $RET_VALUE == 0 ]; then
    echo "All processes are successful."
else
    echo "!!!Error: Some processes failed."
    show_first_failed_process_log
fi

#concurrency build, remove dangling image when all build process done.
docker rmi $(docker images -q -f dangling=true) &> /dev/null

FINISH=$(date +"%s")
echo
echo "##### Total Time elapsed ($(($FINISH - $START)))"

exit $RET_VALUE
