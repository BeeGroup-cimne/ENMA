#! /bin/bash
# set and install server
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
export AUTO_INSTALL=y
export CLIENT=$1
bash openvpn-install.sh
