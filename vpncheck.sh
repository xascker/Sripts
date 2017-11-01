#!/bin/bash

ip_NEIGHBOR0='10.10.10.10'
ip_NEIGHBOR1='20.20.20.20'
count=1
recursions=3
tunnels=($ip_NEIGHBOR0 $ip_NEIGHBOR1)

ping_tunnels () {
    /bin/ping -c 1 -W 1 $ip 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "`hostname`:-> $ip is unavailable $count time(s) for $tun_name at `date`"
        logger "`hostname`:-> $ip is unavailable $count time(s) for $tun_name at `date`"
        sleep $(($count*2))
    else
        return
    fi

    count=$(( $count + 1 ))

    if [ $count -gt $recursions ]; then
       echo "`hostname`:-> Reset $tun_name tunnel ip $ip_tun at `date`"
       logger "`hostname`:-> Reset $tun_name tunnel ip $ip_tun at `date`"
       /bin/vbash -ic "clear vpn ipsec-peer $ip_tun"
       count=1
    else
       ping_tunnels
    fi
}

for ip in "${tunnels[@]}"; do
    if [ $ip = $ip_NEIGHBOR0 ]; then
        tun_name='vti0'
        ip_tun='10.10.10.01'
    else
        tun_name='vti1'
        ip_tun='20.20.20.01'
    fi
    ping_tunnels
done
