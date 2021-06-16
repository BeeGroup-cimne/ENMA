#! /bin/bash
# set and install server
cn=($@)
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
export AUTO_INSTALL=y
export CLIENT=${cn[0]}
bash openvpn-install.sh

#remove push-dns from configuration
sed '/^push/d' < /etc/openvpn/server.conf> /etc/openvpn/server.tmp
mv /etc/openvpn/server.tmp /etc/openvpn/server.conf

#add client-to-client communication
echo "client-to-client" >> /etc/openvpn/server.conf

#change server ip
sed 's/10.8.0.0/'"$VPN_IP"'/g' < /etc/openvpn/server.conf > /etc/openvpn/server.tmp
mv /etc/openvpn/server.tmp /etc/openvpn/server.conf
sed 's/255.255.255.0/'"$VPN_MASK"'/g' < /etc/openvpn/server.conf > /etc/openvpn/server.tmp
mv /etc/openvpn/server.tmp /etc/openvpn/server.conf

# change vpn interface
sed 's/dev tun/dev '"$VPN_INT"'/g' < /etc/openvpn/server.conf > /etc/openvpn/server.tmp
mv /etc/openvpn/server.tmp /etc/openvpn/server.conf

#restart openvpn to accept changes
systemctl restart openvpn

#set fixed ips (admin node is 1 (already set), first client is 2 and the rest +1
#content: ifconfig-push <IP> <Mask ex 255.255.255.0>
mkdir -p /etc/openvpn/ccd
echo "ifconfig-push ${VPN_IP/%.0/.2} $VPN_MASK" >/etc/openvpn/ccd/$CLIENT

#iterate over the rest of the clients and set the cert and fixed ip
ip=3 #(2+1)
for CLIENT in ${cn[@]:1}
do
  export CLIENT=$CLIENT
  export MENU_OPTION="1"
  export PASS="1"
  bash openvpn-install.sh
  sed 's/dev tun/dev '"$VPN_INT"'/g' < $USER_HOME/$CLIENT.conf > $USER_HOME/$CLIENT.tmp
  mv $USER_HOME/$CLIENT.tmp $USER_HOME/$CLIENT.conf
  echo "ifconfig-push ${VPN_IP/%.0/.$ip} $VPN_MASK" >/etc/openvpn/ccd/$CLIENT
  ip=$((ip +1))
done

