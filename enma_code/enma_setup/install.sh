#! /bin/bash
sudo apt update
sudo apt install -y python
sudo apt install -y python-dev
sudo apt install -y openssh-client
sudo apt install -y curl
sudo apt install -y unzip
sudo apt install -y tar
sudo apt install -y wget
sudo apt install -y build-essential
sudo apt install -y manpages-dev
sudo apt install -y python-pip
sudo apt install -y python3-pip
sudo apt install -y libsasl2-dev
sudo apt install -y python-tk
sudo apt install -y virtualenv
sudo apt install -y libssl-dev
sudo apt install -y libffi-dev
sudo apt install -y libxml2-dev
sudo apt install -y libxslt1-dev
sudo apt install -y zlib1g-dev
sudo apt install -y ifupdown2
sudo apt install -y docker.io
sudo apt install -y chrony

sudo ulimit -n 10000
printf "*\thard\tnofile\t10000\n*\tsoft\tnofile\t10000" >> /etc/security/limits.conf
sudo systemctl enable chronyd
# change for other linux versions
sudo wget -O /etc/apt/sources.list.d/ambari.list http://public-repo-1.hortonworks.com/ambari/ubuntu18/2.x/updates/2.7.3.0/ambari.list
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
sudo apt-get update

sudo mkdir /etc/docker
printf "{\n\t\"live-restore\": false,\n\t\"debug": true\n}" > /etc/docker/daemon.json
