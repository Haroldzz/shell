#!/usr/bin/env bash
#
systemctl status docker.service
systemctl start docker.service
systemctl enable docker.service

docker pull reg.zbx.space/library/ubuntu
mkdir /opt/appdata
chown docker.docker /opt/appdata
docker run -d -v /opt/appdata:/opt/appdata --name appdata reg.zbx.space/library/ubuntu
