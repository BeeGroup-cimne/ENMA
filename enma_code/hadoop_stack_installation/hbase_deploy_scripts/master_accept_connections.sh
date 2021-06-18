#! /bin/bash

while read p
do
  host=`echo $p|cut -d" " -f2`
  su hbase -c "ssh-keyscan -H $host >> /home/hbase/.ssh/known_hosts"
done < hosts_file