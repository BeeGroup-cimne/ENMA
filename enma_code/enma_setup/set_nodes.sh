#! /bin/bash
while read p
	do
		host=`echo $p|cut -d" " -f1`
		name=`echo $p|cut -d" " -f2`
		echo "setting up $name"
		ssh-keyscan -H $host >> /root/.ssh/known_hosts
		scp -r enma_setup $host:./node_setup
		ssh -n $host ". node_setup/hosts_utils/set_up.sh"
		ssh -n $host "hostname $name"
		ssh -n $host "echo $name > /etc/hostname"
		scp $1 $host:.
		ssh -n $host ". node_setup/hosts_utils/update_hosts.sh $1"
		ssh -n $host ". node_setup/install.sh"
       	done < $1
