#/bin/bash
declare -a Configmap=(
#'mysql-configmap'
'mysql-utf8-configmap'
'mysql-mycnf-configmap'
);

declare -a ConfigmapSource=(
#'../../platformSrv/platformSrv.sql'
'./mysqlutf8.cnf'
'./my.cnf'
);
