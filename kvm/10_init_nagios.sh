##client
yum install epel-release
yum install nrpe nagios-plugins-all openssl

sed -i 's#allowed_hosts=127.0.0.1#allowed_hosts=127.0.0.1, localhost, 10.1.22.0/24#g' /etc/nagios/nrpe.cfg
sed -i '/check_total_procs/acommand[check_root_partiton]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /' /etc/nagios/nrpe.cfg
sed -i '/check_total_procs/acommand[check_boot_partiton]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /boot' /etc/nagios/nrpe.cfg;
sed -i '/check_total_procs/acommand[check_srv_partiton]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /srv' /etc/nagios/nrpe.cfg;


firewall-cmd --permanent --add-port=5666/tcp
firewall-cmd --reload

systemctl restart nrpe
systemctl enable nrpe


##server
docker run --name nagios4  \
  -v /srv/nagios/etc/:/opt/nagios/etc/ \
  -v /srv/nagios/var:/opt/nagios/var/ \
  -v /srv/nagios/Custom-Nagios-Plugins:/opt/Custom-Nagios-Plugins \
  -p 80:80 jasonrivers/nagios:latest

sed -i 's$#cfg_dir=/opt/nagios/etc/servers$cfg_dir=/opt/nagios/etc/servers$g' /srv/nagios/etc/nagios.cfg
mkdir /srv/nagios/etc/servers

cat >>/srv/nagios/etc/objects/commands.cfg<<-'EOF'



################################################################################
#
# custom define command
#
################################################################################

# 'custom_check_http' command definition
define command{
        command_name    custom_check_http
        command_line    $USER1$/check_http -I $HOSTADDRESS$ -p $ARG1$ -u $ARG2$ -e $ARG3$
        }


define command{
        command_name    check_nrpe
        command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
EOF

#############################add new server#############################
cat >/srv/nagios/etc/servers/10.1.22.2.cfg<<-'EOF'
define host{
        use                     linux-server            ; Name of host template to use
                                                        ; This host definition will inherit all variables that are defined
                                                        ; in (or inherited by) the linux-server host template definition.
        host_name               10.1.22.1
        alias                   prodApp01
        address                 10.1.22.1
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             Root Partition
        check_command                   check_nrpe!check_root_partiton
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             Current Users
        check_command                   check_nrpe!check_users
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             Total Processes
        check_command                   check_nrpe!check_total_procs
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             Current Load
        #check_command                  check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
        check_command                   check_nrpe!check_load
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             Current ZombieProcesses
        #check_command                  check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
        check_command                   check_nrpe!check_zombie_procs
        }

#define service{
#        use                             generic-service,graphed-service         ; Name of service template to use
#        host_name                       10.1.22.1
#        service_description             Swap Usage
#        check_command                   check_local_swap!20!10
#        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             admin-service
        check_command                   custom_check_http!8040!/admin-service/heartbeat/deploy.do!200
        notifications_enabled           1
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             product-base-commu
        check_command                   custom_check_http!8090!/product-base-commu/heartbeat/deploy.do!200
        notifications_enabled           1
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             pa-commu
        check_command                   custom_check_http!9015!/pa-commu/heartbeat/deploy.do!200
        notifications_enabled           1
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             clm-commu
        check_command                   custom_check_http!9016!/clm-commu/heartbeat/deploy.do!200
        notifications_enabled           1
        }


define service{
        use                             generic-service,graphed-service         ; Name of service template to use
        host_name                       10.1.22.1
        service_description             cs-query-commu
        check_command                   custom_check_http!9017!/cs-query-commu/heartbeat/deploy.do!200
        notifications_enabled           1
        }

EOF


