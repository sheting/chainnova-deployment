#!/bin/bash
source sql_list.sh

echo -e "\n##### init mysql with sql file #####"

for (( i = 0; i < ${#sql_list[@]}; i++ )); do
    sql_file="${sql_list[$i]}"
    echo "*************** import sql file: $sql_file "
    ## add "set @@GLOBAL.max_allowed_packet=1073741824;" to sql file when cause max_allowed_packet error
    mysql -u root --max_allowed_packet=1G -pTestEnv.Chainnova.2019 -h 117.78.4.250-P 32021 <$sql_file
    if [[ $? != 0 ]]; then
        echo "!!!Error: Failed to import sql: " $sql_file
        exit 1
    else
    	echo "*************** import sql file: $sql_file success"
    fi
done

echo -e "\n####### SUCCESS ###########"
