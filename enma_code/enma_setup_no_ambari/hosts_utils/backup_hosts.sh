#! /bin/bash

#copy /etc/hosts as backup

if ! test -f /opt/hosts_utils/original.hosts
	then
		mkdir /opt/hosts_utils
		cp /etc/hosts /opt/hosts_utils/original.hosts
fi
