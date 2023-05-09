#!/usr/bin/env bash
#
set -ex
#* * * * * sh /root/opsallow.sh > /dev/null 2>&1

ALLOWED_DOMAIN=('opsallow.ops.dev' 'ops.e-tianrong.com' 'ops.baidu.com')
ALLOWED_FILE='/etc/hosts.allow'

for domain in "${ALLOWED_DOMAIN[@]}"; do
    allow_host="$(ping -c 3 -w 3 ${domain} | awk '/PING/ { print $3 }' | sed 's/(//g; s/)//g')"
    if [[ -n ${allow_host} ]]; then
        if [[ -z $(grep -ow "${allow_host}" "${ALLOWED_FILE}") ]]; then
            sed -i "\$asshd : ${allow_host}" "${ALLOWED_FILE}";
        fi
    fi
done
