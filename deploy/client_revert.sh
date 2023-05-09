#!/usr/bin/env bash
#
# set -ex
# you should update the $APP_NAME and $PKG_HASH

APP_NAME='name'
APP_INSTANCE=('01')
APP_SERVER=('1.1.1.1')
APP_DIRECTORY='/srv/packages'
PKG_HASH='hash'

if [[ ${#PKG_HASH} -ne 32 ]]; then
    for host in ${APP_SERVER[*]}; do
        ssh docker@${host} "cat /home/docker/deploy/package.list"
    done
    echo "***"
    echo "you should update the #APP_NAME and #PKG_HASH via [Configure] and the newer hash on the right separated by :"
    echo "***"
    exit 1
else    
    for host in ${APP_SERVER[*]}; do
        ssh docker@${host} "/home/docker/deploy/remote-deploy.sh ${APP_NAME} ${PKG_HASH}"
    done
fi
