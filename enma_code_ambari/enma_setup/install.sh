#! /bin/bash
apt update
apt install -y python
apt install -y python-dev
apt install -y openssh-client
apt install -y curl
apt install -y unzip
apt install -y tar
apt install -y wget
apt install -y build-essential
apt install -y manpages-dev
apt install -y python-pip
apt install -y python3-pip
apt install -y libsasl2-dev
apt install -y python-tk
apt install -y virtualenv
apt install -y libssl-dev
apt install -y libffi-dev
apt install -y libxml2-dev
apt install -y libxslt1-dev
apt install -y zlib1g-dev
apt install -y ifupdown2
apt install -y docker.io
apt install -y chrony

ulimit -n 10000
printf "*\thard\tnofile\t10000\n*\tsoft\tnofile\t10000" >> /etc/security/limits.conf
systemctl enable chronyd
# change for other linux versions
wget -O /etc/apt/sources.list.d/ambari.list http://public-repo-1.hortonworks.com/ambari/ubuntu18/2.x/updates/2.7.3.0/ambari.list
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
apt-get update

mkdir /etc/docker
printf "{\n\t\"live-restore\": false,\n\t\"debug\": true\n}" > /etc/docker/daemon.json
