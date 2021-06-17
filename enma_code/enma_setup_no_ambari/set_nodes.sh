#! /bin/bash
# SET VPN_IP
echo "Input the vpn network ip"
read -r vpn_ip
export VPN_IP=$vpn_ip
# SET VPN_MASK
echo "Input the vpn network mask"
read -r vpn_mask
export VPN_MASK=$vpn_mask
# SET USER_HOME
echo "Input the main user home"
read -r home
export USER_HOME=$home
#prepare all nodes
#set private interface
echo "Input the fast private network interface"
read -r pint
export PRIVATE_INT=$pint
#set vpn interface
echo "Input the vpn interface"
read -r vpnint
export VPN_INT=$vpnint

while read p
do
  host=`echo $p|cut -d" " -f1`
	name=`echo $p|cut -d" " -f2`
	ssh-keyscan -H $host >> /root/.ssh/known_hosts
	scp -r enma_setup $host:./node_setup
	ssh -n $host ". node_setup/hosts_utils/backup_hosts.sh"
	ssh -n $host "hostname $name"
	ssh -n $host "echo $name > /etc/hostname"
	scp $1 $host:.
	ssh -n $host ". node_setup/hosts_utils/update_hosts.sh $1"
	ssh -n $host ". node_setup/install_scripts/install.sh" &
done < $1
wait

# create openvpn server in master
#create list of client_name
client_names=()
while read p
do
  name=`echo $p|cut -d" " -f2|cut -d"." -f1`
  client_names+=($name)
done < <(tail -n +2 $1)

. node_setup/install_scripts/set_vpn/install_vpn_server.sh ${client_names[0]}
. node_setup/install_scripts/set_vpn/vpn_configuration.sh ${client_names[@]}
. node_setup/install_scripts/set_vpn/create_vpn_clients.sh ${client_names[@]}

systemctl restart openvpn
#deploy all files in /etc/openvpn/client/file.conf and start openvpn
while read p
do
  host=`echo $p|cut -d" " -f1`
  name=`echo $p|cut -d" " -f2|cut -d"." -f1`
  scp $USER_HOME/$name.ovpn $host:/etc/openvpn/client/$name.conf
  ssh -n $host "systemctl enable openvpn-client@$name.service"
  ssh -n $host "systemctl start openvpn-client@$name.service"

done < <(tail -n +2 $1)

while read p
do
  host=`echo $p|cut -d" " -f1`
	ssh -n $host ". node_setup/install_scripts/set_firewall.sh $PRIVATE_INT $VPN_INT"
done < $1

echo "installation finished."
