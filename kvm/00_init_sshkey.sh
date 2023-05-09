#!/usr/bin/env bash
#
if [ $(id -u) != "0" ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

cat >> ~/.bashrc <<-'EOF'
#
alias sshc='ssh -l root'
EOF


cat host.list | while read host username password; do 
    sshpass -p ${password} ssh-copy-id -oStrictHostKeyChecking=no ${username}@${host}
    echo ${host} c$(echo ${host} | awk -F. '{print $NF}') >> /etc/hosts
done

# host,list.sample
# 10.1.234.39 root y6**_V*Y
# 10.1.234.38 root wZ**F3*D
# 10.1.234.37 root #e**x6*q
# 10.1.234.36 root vv**N3*@
# 10.1.234.35 root jH**wW*S
# 10.1.234.34 root Ea**Xw*8
# 10.1.234.33 root hP**PS*h
# 10.1.234.32 root jU**cu*E
# 10.1.234.31 root h!**UR*C
# 10.1.234.30 root k8**2Y*e
# 10.1.234.29 root nL**2v*T
# 10.1.234.28 root ya**3x*A
# 10.1.234.27 root ZR**X8*q
# 10.1.234.26 root Ak**!h*3
# 10.1.234.25 root 7s**u_*k
# 10.1.234.24 root @Z**pf*G
