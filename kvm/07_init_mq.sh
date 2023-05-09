#!/usr/bin/env bash
#
chmod 644 /etc/resolv.conf
#
#wget -O /tmp/epel-release-7-7.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm
#yum -y localinstall /tmp/epel-release-7-7.noarch.rpm
#yum -y update
yum -y install java-1.8.0-openjdk.x86_64

wget -O /tmp/apache-activemq-5.13.5-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/activemq/5.13.5/apache-activemq-5.13.5-bin.tar.gz
tar -zxf /tmp/apache-activemq-5.13.5-bin.tar.gz  -C /srv/data
ln -s /srv/data/apache-activemq-5.13.5 /srv/data/apache-activemq

cp /srv/data/apache-activemq/conf/credentials.properties{,.0}
cp /srv/data/apache-activemq/conf/groups.properties{,.0}
cp /srv/data/apache-activemq/conf/log4j.properties{,.0}

sed -i 's/log4j.rootLogger=INFO, console, logfile/log4j.rootLogger=DEBUG, console, logfile/g' /srv/data/apache-activemq/conf/log4j.properties

cat >> /srv/data/apache-activemq/conf/redentials.properties <<-'EOF'
user.username=mq_prod
user.password=mq_prod_161
EOF

cat >> /srv/data/apache-activemq/conf/groups.properties <<-'EOF'

users=mq_prod
EOF

useradd activemq -s /bin/false
chown -R activemq.activemq /srv/data/apache-activemq-5.13.5
chown -R activemq.activemq /srv/data/apache-activemq

cat >> /etc/rc.local <<-'EOF'
su -s /bin/bash -c "/srv/data/apache-activemq/bin/activemq start &>/tmp/activemq.log &" activemq
EOF

firewall-cmd --permanent --add-port=52852/tcp;
firewall-cmd --permanent --add-port=61616/tcp;
firewall-cmd --permanent --add-port=5672/tcp;
firewall-cmd --permanent --add-port=61613/tcp;
firewall-cmd --permanent --add-port=1883/tcp;
firewall-cmd --permanent --add-port=61614/tcp;
firewall-cmd --permanent --add-port=8161/tcp;
firewall-cmd --reload;

su -s /bin/bash -c "/srv/data/apache-activemq/bin/activemq start &>/tmp/activemq.log &" activemq 

# iptables -F