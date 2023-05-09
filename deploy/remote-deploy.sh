#!/usr/bin/env bash
#
set -ex

SERVER_LIST='/home/docker/deploy/service.list'
APP_DIRECTORY='/srv/packages'
APP_NAME=$1
APP_SERVER=($(grep -v ^# ${SERVER_LIST} | grep -w ${APP_NAME} | awk -F: '{ print $1 }'))
APP_PORT=$(grep -v ^# ${SERVER_LIST} | grep -w ${APP_NAME} | awk -F: '{ print $2 }')

if [[ -z ${APP_SERVER[@]} ]]; then
    echo "Please type the right app name." && exit 1
fi


case "${APP_NAME}" in
    configuration)
        LOCAL_DIRECTORY='/srv/apps/spring-cloud-configuration/configuration'
        for host in ${APP_SERVER[@]}; do
            ssh docker@${host} "rm -rf ${LOCAL_DIRECTORY}/*"
            scp ${APP_DIRECTORY}/${APP_NAME}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}.tgz -C ${LOCAL_DIRECTORY}/"
        done
	;;
    gmweb)
        LOCAL_DIRECTORY='/srv/packages/web01/nginx/html/gmnew/web'
        for host in ${APP_SERVER[@]}; do
            scp ${APP_DIRECTORY}/${APP_NAME}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}.tgz -C ${LOCAL_DIRECTORY}/"
            sleep 3
            ssh docker@${host} "docker restart web01"
        done
        ;;
    yunfuweb)
        LOCAL_DIRECTORY='/srv/packages/web01/nginx/html/yunfu2/web'
        for host in ${APP_SERVER[@]}; do
            scp ${APP_DIRECTORY}/${APP_NAME}.tgz docker@${host}:${LOCAL_DIRECTORY}/
            sleep 3
            ssh docker@${host} "tar -zxf ${LOCAL_DIRECTORY}/${APP_NAME}.tgz -C ${LOCAL_DIRECTORY}/"
            sleep 3
            ssh docker@${host} "docker restart web01"
        done
        ;;
    *)
        LOCAL_DIRECTORY='/srv/packages'
	if [[ ${#APP_SERVER[@]} -eq 1 ]]; then
	    host=${APP_SERVER[0]}
            APP_NAME_LIST=$(ssh docker@${host} "docker ps -a -q -f name=${APP_NAME}")
            scp ${APP_DIRECTORY}/${APP_NAME}-0.0.1-SNAPSHOT.jar docker@${host}:${LOCAL_DIRECTORY}/
            ssh docker@${host} "docker restart ${APP_NAME_LIST}"
	else
	    for host in ${APP_SERVER[@]}; do
		APP_NAME_LIST=$(ssh docker@${host} "docker ps -a -q -f name=${APP_NAME}")
		ACTUATOR_URL="http://${host}:${APP_PORT}/actuator"
		curl -H "Content-Type:application/json" -X POST "${ACTUATOR_URL}/service-registry?status=DOWN"
		sleep 60
		scp ${APP_DIRECTORY}/${APP_NAME}-0.0.1-SNAPSHOT.jar docker@${host}:${LOCAL_DIRECTORY}/
		sleep 10
		ssh docker@${host} "docker restart ${APP_NAME_LIST}"
		sleep 60
		curl -H "Content-Type:application/json" -X POST "${ACTUATOR_URL}/service-registry?status=UP"
		sleep 60
            done
	fi
esac
