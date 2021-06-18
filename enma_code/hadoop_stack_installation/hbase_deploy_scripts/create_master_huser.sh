#! /bin/bash
adduser --disabled-password --shell /bin/bash --gecos "User" hbase
usermod -a -G hadoop hbase
su hbase -c "cat /dev/zero |ssh-keygen -t rsa -f /home/hbase/.ssh/id_rsa -m PEM -q -N ''"