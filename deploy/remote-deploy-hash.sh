#!/usr/bin/env bash
#
set -ex

SERVER_LIST='/home/docker/deploy/service.list'
PACKAGE_LIST='/home/docker/deploy/package.list'
APP_DIRECTORY='/srv/packages'
APP_NAME=$1
PKG_HASH=$2
APP_SERVER=($(grep -v ^# ${SERVER_LIST} | grep -w ${APP_NAME} | awk -F: '{ print $1 }'))
APP_PORT=$(grep -v ^# ${SERVER_LIST} | grep -w ${APP_NAME} | awk -F: '{ print $2 }')

if [[ -z ${APP_SERVER[@]} ]]; then
    echo "Please type the right app name." && exit 1
fi

if [[ ${#PKG_HASH} -ne 32 ]]; then
    echo "Please type the right package hash." && exit 1
fi

if [[ -f "${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz" || -f "${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.jar" ]]; then
    if [[ -z $(grep -v ^# ${PACKAGE_LIST} | grep -w ${APP_NAME} | grep -wo ${PKG_HASH}) ]]; then
        sed -i "/${APP_NAME}/ s/$/:${PKG_HASH}/" ${PACKAGE_LIST}
    elif [[ "$(grep -v ^# ${PACKAGE_LIST} | grep -w ${APP_NAME} | awk -F: '{ print $NF }')" == "${PKG_HASH}" ]]; then
        echo "${APP_NAME}-${PKG_HASH} is the latest package, nothing to do." && exit 0
    fi
else
    echo "There is no ${APP_NAME}-${PKG_HASH} package." && exit 1
fi

case "${APP_NAME}" in
    configuration)
        LOCAL_DIRECTORY='/srv/apps/spring-cloud-configuration/configuration'
        for host in ${APP_SERVER[@]}; do
            ssh docker@${host} "rm -rf ${LOCAL_DIRECTORY}/*"
            scp ${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz -C ${LOCAL_DIRECTORY}/"
        done
	;;
    gmweb)
        LOCAL_DIRECTORY='/srv/packages/web01/nginx/html/gmnew/web'
        for host in ${APP_SERVER[@]}; do
            scp ${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz -C ${LOCAL_DIRECTORY}/"
            sleep 3
            ssh docker@${host} "docker restart web01"
        done
        ;;
    yunfuweb)
        LOCAL_DIRECTORY='/srv/packages/web01/nginx/html/yunfu2/web'
        for host in ${APP_SERVER[@]}; do
            scp ${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}-${PKG_HASH}.tgz -C ${LOCAL_DIRECTORY}/"
            sleep 3
            ssh docker@${host} "docker restart web01"
        done
        ;;
    *)
        LOCAL_DIRECTORY='/srv/packages'
	if [[ ${#APP_SERVER[@]} -eq 1 ]]; then
	    host=${APP_SERVER[0]}
            APP_NAME_LIST=$(ssh docker@${host} "docker ps -a -q -f name=${APP_NAME}")
            scp ${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.jar docker@${host}:${LOCAL_DIRECTORY}/${APP_NAME}-0.0.1-SNAPSHOT.jar
            ssh docker@${host} "docker restart ${APP_NAME_LIST}"
	else
	    for host in ${APP_SERVER[@]}; do
		APP_NAME_LIST=$(ssh docker@${host} "docker ps -a -q -f name=${APP_NAME}")
		ACTUATOR_URL="http://${host}:${APP_PORT}/actuator"
		curl -H "Content-Type:application/json" -X POST "${ACTUATOR_URL}/service-registry?status=DOWN"
		sleep 90
                scp ${APP_DIRECTORY}/${APP_NAME}-${PKG_HASH}.jar docker@${host}:${LOCAL_DIRECTORY}/${APP_NAME}-0.0.1-SNAPSHOT.jar
		sleep 10
		ssh docker@${host} "docker restart ${APP_NAME_LIST}"
		sleep 60
		curl -H "Content-Type:application/json" -X POST "${ACTUATOR_URL}/service-registry?status=UP"
            done
	fi
esac
