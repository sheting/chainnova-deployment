#!/bin/bash

source database_list.sh
mkdir v1

for (( i = 0; i < ${#mysql_databases[@]}; i++ )); do
    sqlfile="${mysql_databases[$i]}"
    echo
    echo "************** mysqldump $sqlfile *************"
    mysqldump --max_allowed_packet=1G -uUSER -pPASSWORD -hDATABASE_HOST  -P 3306 --databases ${sqlfile} > v1/${sqlfile}.sql
done

tar zcvf bdh-v1.tar.gz v1
