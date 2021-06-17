#! /bin/bash
# install packages to node
apt update
apt install -y pdsh
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
apt install -y python-tk
apt install -y virtualenv
apt install -y zlib1g-dev
apt install -y ifupdown2
apt install -y docker.io
apt install -y chrony
apt install -y openjdk-8-jdk
apt install -y nmap
apt install -y ufw
apt install -y openvpn

# prepare for hadoop
ulimit -n 10000
printf "*\thard\tnofile\t10000\n*\tsoft\tnofile\t10000" >> /etc/security/limits.conf
systemctl enable chronyd

# configure docker
mkdir -p /etc/docker
printf "{\n\t\"live-restore\": false,\n\t\"debug\": true\n}" > /etc/docker/daemon.json
sudo groupadd docker

systemctl enable docker.service
systemctl enable containerd.service

