#!/usr/bin/env bash
#
chmod 644 /etc/resolv.conf
#
wget -O /tmp/epel-release-7-7.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm 
yum -y localinstall /tmp/epel-release-7-10.noarch.rpm
yum -y update
yum -y install java-1.8.0-openjdk.x86_64

wget -O /tmp/elasticsearch-2.3.3.tar.gz https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.3/elasticsearch-2.3.3.tar.gz
tar -zxf /tmp/elasticsearch-2.3.3.tar.gz -C /srv/data
ln -s /srv/data/elasticsearch-2.3.3 /srv/data/elasticsearch
cp /srv/data/elasticsearch/config/elasticsearch.yml{,.0}
sed -i 's/# network.host: 192.168.0.1/network.host: 0.0.0.0/g' /srv/data/elasticsearch/config/elasticsearch.yml 

useradd elasticsearch -s /bin/false
chown -R elasticsearch.elasticsearch /srv/data/elasticsearch-2.3.3

wget -O /tmp/kibana-4.5.1-linux-x64.tar.gz https://download.elastic.co/kibana/kibana/kibana-4.5.1-linux-x64.tar.gz
tar -zxf /tmp/kibana-4.5.1-linux-x64.tar.gz -C /srv/data
ln -s /srv/data/kibana-4.5.1-linux-x64 /srv/data/kibana
chown -R elasticsearch.elasticsearch /srv/data/kibana-4.5.1-linux-x64

cat >> /etc/rc.local <<-'EOF'
su -s /bin/bash -c "/srv/data/elasticsearch/bin/elasticsearch &>/tmp/elasticsearch.log &" elasticsearch
su -s /bin/bash -c "/srv/data/kibana/bin/kibana &>/tmp/kibana.log &" elasticsearch
EOF

firewall-cmd --permanent --add-port=9200/tcp;
firewall-cmd --permanent --add-port=9300/tcp;
firewall-cmd --permanent --add-port=5601/tcp;
firewall-cmd --reload;

su -s /bin/bash -c "/srv/data/elasticsearch/bin/plugin install license" elasticsearch
su -s /bin/bash -c "/srv/data/elasticsearch/bin/plugin install graph" elasticsearch
su -s /bin/bash -c "/srv/data/kibana/bin/kibana plugin --install elasticsearch/graph/latest" elasticsearch

su -s /bin/bash -c "/srv/data/elasticsearch/bin/elasticsearch &>/tmp/elasticsearch.log &" elasticsearch 
su -s /bin/bash -c "/srv/data/kibana/bin/kibana &>/tmp/kibana.log &" elasticsearch

# iptables -F
