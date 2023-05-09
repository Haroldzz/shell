#!/usr/bin/env bash
#
set -ex

APP_NAME='name'
APP_INSTANCE=('01')
APP_SERVER=('1.1.1.1')
APP_DIRECTORY='/srv/packages'
PKG_HASH=$(md5sum ${WORKSPACE}/build/libs/*.jar | awk '{ print $1 }')

for host in ${APP_SERVER[*]}; do
    scp ${WORKSPACE}/build/libs/*.jar docker@${host}:/srv/packages/${APP_NAME}-${PKG_HASH}.jar;
    sleep 3;
    ssh docker@${host} "/home/docker/deploy/remote-deploy.sh ${APP_NAME} ${PKG_HASH}"
done
