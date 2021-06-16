#! /bin/bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
for x in $@
do
  ufw allow in on $x
done
ufw --force enable