#! /bin/bash
adduser --disabled-password --shell /bin/bash --gecos "User" hbase
usermod -a -G hadoop hbase
mkdir -p /home/hbase/.ssh
chown hbase:hbase /home/hbase/.ssh
echo $@ >> /home/hbase/.ssh/authorized_keys
