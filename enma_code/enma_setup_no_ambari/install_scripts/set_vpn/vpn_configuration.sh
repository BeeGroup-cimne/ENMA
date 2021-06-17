#! /bin/bash
echo "openvpn installed, changing configuration"

while [ ! -f /etc/openvpn/server.conf ] ;
do
      sleep 2
done

echo "conf is ready"
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


#set fixed ips (admin node is 1 (already set), first client is 2 and the rest +1
#content: ifconfig-push <IP> <Mask ex 255.255.255.0>
cn=($@)

mkdir -p /etc/openvpn/ccd
echo "ifconfig-push ${VPN_IP/%.0/.2} $VPN_MASK" >/etc/openvpn/ccd/${cn[0]}

#iterate over the rest of the clients and set the cert and fixed ip
ip=3 #(2+1)
for CLIENT in ${cn[@]:1}
do
  sed 's/dev tun/dev '"$VPN_INT"'/g' < $USER_HOME/$CLIENT.ovpn > $USER_HOME/$CLIENT.tmp
  mv $USER_HOME/$CLIENT.tmp $USER_HOME/$CLIENT.ovpn
  echo "ifconfig-push ${VPN_IP/%.0/.$ip} $VPN_MASK" >/etc/openvpn/ccd/$CLIENT
  ip=$((ip +1))
done

