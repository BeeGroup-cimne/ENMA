#! /bin/bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
for x in $@
do
  ufw allow in on $x
done
sudo ufw enable