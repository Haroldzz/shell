#!/usr/bin/env bash
#
echo '0 0 * * 1 /usr/sbin/ntpdate cn.pool.ntp.org' >> /var/spool/cron/root
