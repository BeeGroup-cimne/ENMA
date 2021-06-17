#! /bin/bash
echo "creating all clients for nodes"
cn=($@)

for CLIENT in ${cn[@]:1}
do
  export CLIENT=$CLIENT
  export MENU_OPTION="1"
  export PASS="1"
  bash openvpn-install.sh
  sleep 1
done
