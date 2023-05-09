#!/usr/bin/env bash
#
# set -ex
# use admin
# db.createUser(
#      {
#        user: "dumpbackup",
#        pwd: "password",
#        roles: [
#           { role: "readAnyDatabase", db: "admin" }
#        ]
#      }
# )
# 1 2 * * * sh /data/backup/backup_db_mongodb.sh &> /data/backup/backup_db_mongodb_$(date +\%F_\%H\%M\%S).log
user="dumpbackup"
pass="password"
host="172.16.0.16"
port="27017"
schemas=(insurance order pay sms wxmp)

dateTimeNow=$(date +'%F-%H%M')

MONGO="/srv/backup/mongodb-4.0.28/bin/mongo"
MONGODUMP="/srv/backup/mongodb-4.0.28/bin/mongodump"
MONGOAUTH="-u ${user} -p ${pass} -h ${host}:${port}"
DUMPOPTION="--authenticationDatabase admin"

basePath="/srv/backup"

for schema in ${schemas[@]}; do
    logFile="${basePath}/${host}/logs/${schema}_${dateTimeNow}.log"
    dumpFile="${basePath}/${host}/databases/${schema}_db_${dateTimeNow}"

    [ -d ${basePath}/${host}/logs ] || mkdir -p ${basePath}/${host}/logs
    [ -d ${basePath}/${host}/databases/tmp ] || mkdir -p ${basePath}/${host}/databases/tmp

    exec >> ${logFile}
    exec 2>&1

    ${MONGODUMP} ${MONGOAUTH} ${DUMPOPTION} -d ${schema} -o ${dumpFile}
    tar -zcf ${dumpFile}.tgz ${dumpFile}
    mv ${dumpFile} ${basePath}/${host}/databases/tmp
done

# rm -rf ${basePath}/${host}/databases/tmp/*
rm -rf /srv/backup/172.16.0.16/databases/tmp/*_db_20*

# delete files older than 61 days
for file in $(find /srv/backup/172.16.0.16/databases/ -name "*_db_*.tgz" -type f -ctime +61); do
    echo "Deleted" > ${file};
done
