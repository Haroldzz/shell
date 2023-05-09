#!/usr/bin/env bash
#
# set -ex
#
# CREATE USER 'dumpbackup'@'172.%' IDENTIFIED BY 'password';
# GRANT RELOAD, PROCESS, REPLICATION CLIENT, SHOW VIEW, SHOW DATABASES, LOCK TABLES, TRIGGER, SELECT ON *.* TO 'dumpbackup'@'172.%';
# FLUSH PRIVILEGES;
#
user="dumpbackup"
pass="password"
host="172.16.0.11"

dateTime=$(date +'%F')
dateTimeNow=$(date +'%F-%H%M')

MYSQL="/bin/mysql"
MYSQLDUMP="/bin/mysqldump"
MYSQLAUTH="-u${user} -p${pass} -h${host}"
#DUMPOPTION="--skip-lock-tables --add-locks=false --set-gtid-purged=OFF --databases --add-drop-database"
DUMPOPTION="--skip-lock-tables --add-locks=false --databases --add-drop-database"

schemas=($(${MYSQL} ${MYSQLAUTH} -e "SHOW DATABASES;" | awk '/^db/ {print $1}'))
basePath="/srv/backup"


for schema in ${schemas[@]}; do
    logFile="${basePath}/${host}/logs/${schema}_${dateTimeNow}.log"
    sqlFile="${basePath}/${host}/databases/${schema}_db_${dateTimeNow}.sql"

    [ -d ${basePath}/${host}/logs ] || mkdir -p ${basePath}/${host}/logs
    [ -d ${basePath}/${host}/databases/tmp ] || mkdir -p ${basePath}/${host}/databases/tmp

    exec >> ${logFile}
    exec 2>&1

    ${MYSQLDUMP} ${DUMPOPTION} ${MYSQLAUTH} ${schema} > ${sqlFile}
    tar -zcf ${sqlFile}.tgz ${sqlFile}
    mv ${sqlFile} ${basePath}/${host}/databases/tmp
done

# rm -rf ${basePath}/${host}/databases/tmp/db_*.sql
rm -rf /srv/backup/172.16.0.11/databases/tmp/db_*.sql

# delete files older than 180 days
for file in $(find /srv/backup/172.16.0.11/databases/ -name "*_db_*.tgz" -type f -ctime +180); do
    echo "Deleted" > ${file};
done
