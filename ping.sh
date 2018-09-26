#!/bin/bash
echo `date`
for i in `seq 254`;do
    nohup ping -c 1 -W 1  "172.16.92.$i" &> /dev/null
    if [ $? -eq 0 ];then
        echo "host 172.16.92.$i is on-line"
    fi
done
echo `date`
