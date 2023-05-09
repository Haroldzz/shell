#!/usr/bin/env bash
#
set -x
cat cloneKvm.list | awk '{if(NR%2==1) print $2,$3,$4}' | while read kname kip kport; do
    virt-clone -o centos7-dk-seed -n ${kname} -f /var/lib/libvirt/images/${kname}.img;
    sed -i "s#port='-1' autoport='yes'#port=\'${kport}\' autoport='no'#g" /etc/libvirt/qemu/${kname}.xml;
    virsh define /etc/libvirt/qemu/${kname}.xml;
    virsh start ${kname};
    
    echo "--sleep 25 seconds--";
    sleep 25;
    
    ssh root@10.10.10.10 "echo '+++++++++++++++++++++++++' \
&& sed -i 's#localhost.localdomain#${kname}.localdomain#g' /etc/hostname \
&& sed -i 's#10.1.6.220#${kip}#g' /etc/sysconfig/network-scripts/ifcfg-eth0 \
&& shutdown -r now" < /dev/null
    echo "----------------------------------------";
done
