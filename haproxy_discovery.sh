#!/bin/bash

servers="mule-ingr-"
cmd=$(echo "show stat" | socat /var/run/haproxy.sock stdio | grep "$servers" | cut -d, -f2)
array=($cmd)
comma=","

echo "{\"data\":["

for i in "${array[@]}"; do

   if [ $i =  ${array[@]:(-1)} ]; then
     comma=""
   fi

   echo "{\"{#SERV}\":\"$i\"}$comma"

done

echo "]}" 
