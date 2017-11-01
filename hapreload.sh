#!/bin/bash

iptables -I INPUT -p tcp -m multiport --dports 80 --syn -j DROP && sleep 0.5 && \
/etc/init.d/haproxy reload;
iptables -F