#!/usr/bin/env bash
#
#wget -O /tmp/epel-release-7-7.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm
#yum -y localinstall /tmp/epel-release-7-7.noarch.rpm
#yum -y update
yum -y install redis
systemctl start redis.service
systemctl enable redis.service

redis-cli ping
redis-benchmark -q -n 1000 -c 10 -P 5

cp /etc/redis.conf{,.0}
sed -i 's/# requirepass foobared/requirepass redis_prod_pass/g' /etc/redis.conf
sed -i 's/bind 127.0.0.1/# bind 127.0.0.1/g' /etc/redis.conf

firewall-cmd --permanent --add-port=6379/tcp
firewall-cmd --reload

# systemctl stop iptables.service
# systemctl disable iptables.service
# firewall-cmd --permanent --add-port=6379/tcp
# firewall-cmd --reload

sudo systemctl restart redis.service
redis-cli -a redis_prod_pass ping
