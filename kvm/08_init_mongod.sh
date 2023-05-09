#!/usr/bin/env bash
#
chmod 644 /etc/resolv.conf
#

tee /etc/yum.repos.d/mongodb.repo <<-'EOF'
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOF

yum install -y mongodb-org

cp -r /var/lib/mongo /srv/data/
chown -R mongod.mongod /srv/data/mongo/
mv /var/lib/mongo{,.0}
ln -s /srv/data/mongo /var/lib/mongo


cp /etc/mongod.conf{,.0}
sed -i 's/  bindIp: 127.0.0.1/#  bindIp: 127.0.0.1/g' /etc/mongod.conf


vim /etc/selinux/config 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 

firewall-cmd --permanent --add-port=27017/tcp
firewall-cmd --reload


systemctl stop mongod
systemctl start mongod

$#mongo
> use admin
db.createUser(
  {
    user: "admin",
    pwd: "mongoadmin1415",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)

sed -i 's/#security:/security:\n    authorization: enabled/g' /etc/mongod.conf

systemctl restart mongod

#mongo
> use admin
db.auth("admin","mongoadmin1415")
1

use wift_mbrc_mgprod
db.createUser(
     {
       user: "wift_mbrc_mgprod",
       pwd: "Wift_mbrc_mgprod_165",
       roles: [
          { role: "readWrite", db: "wift_mbrc_mgprod" }
       ]
     }
 )

db.auth("wift_mbrc_mgprod","Wift_mbrc_mgprod_165")

> show users;

#use wift_mbrc_mgdev
#db.createUser(
#     {
#       user: "wift_mbrc_mgdev",
#       pwd: "Wift_mbrc_mgdev_21",
#       roles: [
#          { role: "readWrite", db: "wift_mbrc_mgdev" }		  
#       ]
#     }
# )
#
#use wift_mbrc_mgdev
#db.updateUser(
#   "wift_mbrc_mgdev",
#   {
#       roles: [
#          { role: "readWrite", db: "wift_mbrc_mgdev" }		  
#       ]
#    }
#)
# 
#db.auth("wift_mbrc_mgdev","Wift_mbrc_mgdev_21")
#
#> show users;



###########迁移#######################
mongodump -h 10.1.234.16 -d wift_mbrc_mgprod -o /tmp/mongotest

# mongorestore -h 127.0.0.1 -u wift_mbrc_mgdev -p Wift_mbrc_mgdev_21 -d wift_mbrc_mgdev --drop /tmp/mongotest/wift_mbrc_mgprod 
mongorestore -h 127.0.0.1 -u wift_mbrc_mgprod -p wift_mbrc_mgprod_16 -d wift_mbrc_mgprod --drop /tmp/mongotest/wift_mbrc_mgprod 

#mongo
show dbs;
use wift_mbrc_mgdev
use wift_mbrc_mgprod
db.auth("wift_mbrc_mgprod","wift_mbrc_mgprod_16")
show collections;
##################################################
use wift_mbrc_mgdev
db.auth("wift_mbrc_mgdev","Wift_mbrc_mgdev_21")



###################
#
# yum erase $(rpm -qa | grep mongodb-org)
# sudo rm -r /var/log/mongodb
# sudo rm -r /var/lib/mongo



###########备份(3.4)#######################
mongodump -h 10.1.22.11:27017 -u wift_mbrc_mgprod -p Wift_mbrc_mgprod_11 -d wift_mbrc_mgprod -o /tmp/mongoprod_$(date "+%F-%H%m")
scp -r /tmp/mongoprod_$(date "+%F-%H%m") docker@10.1.21.26:/tmp/
mkdir -p /srv/srv/data/mongodb
docker run -d --name prodbackup-mongo -v /srv/srv/data/mongodb:/srv/data/db -p 27017:27017 mongo --auth
docker exec -it prodbackup-mongo mongo admin
#use admin
#db.createUser(
#  {
#    user: "admin",
#    pwd: "mogoadmin1415",
#    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
#  }
#)
#use wift_mbrc_mgprod
#db.createUser(
#     {
#       user: "wift_mbrc_mgprod",
#       pwd: "Wift_mbrc_mgprod_11",
#       roles: [
#          { role: "readWrite", db: "wift_mbrc_mgprod" }
#       ]
#     }
#)

#use wift_mbrc_mgprodbkp
#db.createUser(
#     {
#       user: "wift_mbrc_mgprodbkp",
#       pwd: "Wift_mbrc_mgprodbkp_26",
#       roles: [
#          { role: "readWrite", db: "wift_mbrc_mgprodbkp" }
#       ]
#     }
#)
docker cp mongoprod_2017-02-17-1702/ prodbackup-mongo:/tmp/
docker exec -it prodbackup-mongo mongo -u admin -p mogoadmin1415 --authenticationDatabase admin
docker exec -it prodbackup-mongo /bin/bash
docker exec -it prodbackup-mongo mongo -u wift_mbrc_mgprod -p Wift_mbrc_mgprod_11 --authenticationDatabase wift_mbrc_mgprod
#mongorestore -h 127.0.0.1 -u wift_mbrc_mgprod -p Wift_mbrc_mgprod_11 --nsFrom="wift_mbrc_mgprod.*" --authenticationDatabase wift_mbrc_mgprod --nsTo="wift_mbrc_mgprod.*"  /tmp/mongoprod_2017-02-17-1702



db.updateUser(
   "wift_mbrc_mgpreprod",
   {
       pwd: "Wift_mbrc_mgpreprod_17",
       roles: [
          { role: "readWrite", db: "wift_mbrc_mgpreprod" }
       ]
    }
)
