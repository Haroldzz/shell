#!/usr/bin/env bash
#
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine

systemctl stop docker.service

useradd docker -g docker
echo 'docker' | passwd docker --stdin

mv /var/lib/docker{,.0}
mkdir /data/docker
chown docker.docker /data/docker
ln -s /data/docker /var/lib/docker
ls -al /var/lib/docker

#cat >> /etc/sudoers <<-'EOF'
#%docker    ALL=(ALL)       ALL
#EOF

cat >> /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
EOF


yum remove docker docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data   lvm2
ansible -m shell -a 'yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo' prod7;
ansible -m shell -a 'yum-config-manager --enable docker-ce-edge' prod7;
ansible -m shell -a 'yum-config-manager --enable docker-ce-test' prod7;
ansible -m shell -a 'yum install -y docker-ce' prod7;

# 2018.05.10 Centos 7.4
mkdir rpm
yum install --downloadonly --downloaddir=./rpm/ epel-release rsync ntp git nrpe nagios-plugins-all openssl nfs-utils yum-utils device-mapper-persistent-data lvm2 docker-ce
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum localinstall -y *.rpm
systemctl enable docker
systemctl start docker
