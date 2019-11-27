# Install Hadoop Cluster

This tutorial will guide you to install the working hadoop cluster in a few easy steps

## Set up the cluster

1. set the root password for all nodes
```bash
sudo passwd
su -
```

2. create public key in master node for root and configure the passwordless ssh in all hosts.

*on master node*
```bash
ssh-keygen
cat /root/.ssh/id_rsa.pub
```

*on each host node (including master)*
```bash
echo/cat master_key >> /root/.ssh/authorized_keys
```

3. connect the node to the private network
```bash
ip link # list all ip interfaces
ip address # check connected interfaces
ifconfig <int> <private address> up # force connection to the ip address
```

4. mount the HDD of the nodes if required
```bash
lsblk # to list all hdd
fdisk /dev/sdb #create primary partition with 'n' and 'p' and save with 'w' 
mkfs.ext3 /dev/sdb1 # to format the partition
mkdir /hdd
mount /dev/sdb1 /hdd
e2label /dev/sdb1 hdd
```
update the /etc/fstab
```
LABEL=hdd       /hdd            ext3    defaults        1 2
```
5. create the file with all cluster hosts in the master node:
```
<ip> <hostname>
<ip> <hostname>
```
Include all nodes in the script (master and workers)

6. copy the enma_setup to the master node

7. run the set_nodes.sh utility
    ```bash
    . enma_setup/set_nodes.sh hosts_file 
    ```
    This script has the utility to set-up all the hosts through ssh
    1. backup the /etc/hosts file in /opt/hosts_utils.
    2. adds all the hosts of the file passed as parameter into /etc/hosts
    3. sets the hostname of the nodes
    4. install the required packages

8. on master node, install and start the ambari server and connect to <ip>:8080 to configure.
```bash
apt install -y ambari-server
ambari-server setup
ambari-server start
```
9. During installation take into account:
    1. download mysql-connector-java.jar (for hive).
    ```bash
    wget url
    dpkg -i path_to_deb_file
    ```
    2. set-up ambari to get it. path usually in /usr/share/java/mysql.connector.jar (pkg name)
    3. change the DNS port to 530 in yarn
    4. Add hive property to connect to hbase properly(matching values with hbase config)
        - In hive->config->advanced-> custom hive-site.xml
        hbase.zookeeper.quorum : value in hbase->config->advanced
        zookeeper.znode.parent : value in hbase->config->advanced

10. After installation, change configuration of cluster:
    1. configure yarn max memory to match the max memory of the node/ram
    2. configure tez to close session when query is finished:
        -tez.session.am.dag.submit.timeout.secs = 0
    
10. on the server running the hbase master, start the thrift hive server:
```bash
sudo /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift --bind <private_ip>
```
11. Install celery on the master node

```bash
sudo apt install -y libmysqlclient-dev
sudo apt install -y rabbitmq-server
sudo apt install -y supervisor
pip3 install celery
pip3 install django
pip3 install mysqlclient
sudo apt install -y python-celery-common
```
12. Install the enma_project directories in the folder to run the project and set the following files:
    - envconfig.json: Set the info for the rabbitmq
    - celeryconfig.py: Set the info of the local celery database
    - celery_supervisor.sh: Set the path of the enma_projects folder and hadoop streaming home
    set permissions to execute `celery_supervisor.sh`
    
    ```bash
    chmod 0755 celery_supervisor.sh
    ```
    
13. Create the rabbitmq config as in envconfig.json
```
sudo rabbitmqctl add_user <username> <password>
sudo rabbitmqctl  add_vhost <vhost>
sudo rabbitmqctl set_permissions -p <vhost> <username> ".*" ".*" ".*"
```

14. Create the supervisorctl script.
``` bash
[program:celery]
directory=<enma_project_folder>
command=<enma_project_folder>/celery_supervisor.sh
user = <user>
startsecs = 5
autostart = True
```

15. Create the HDFS user's home and add the user to the hadoop and hdfs group
```bash
    # create the user folder in hdfs
    su - # access as root
    su hdfs # hdfs user has permission to create files
    hdfs dfs -mkdir /user/<user> # create the folder
    hdfs dfs -chown <user>:hdfs /user/<user> # change the owner
    # go back to the root
    exit
    # add the <user> to the hadoop and hdfs groups
    usermod -a -G hadoop <user>
    usermod -a -G hdfs <user>
    exit
```

16. Start supervisor and celery
``` bash
sudo service supervisor start
sudo supervisorctl reload
```

17. Configure a project to be run in `celery_backend.py`
    add the module's task in the `include` list


## Add new nodes to cluster

1. set the root password for the new nodes
```bash
sudo passwd
su -
```

2. add public key and configure the passwordless ssh in the new hosts.

*on master node*
```bash
cat /root/.ssh/id_rsa.pub
```

*on each new host node*
```bash
echo/cat master_key >>/root/.ssh/authorized_keys
```

3. connect the node to the private network
```bash
ip link # list all ip interfaces
ip address # check connected interfaces
ifconfig <int> <private address> up # force connection to the ip address
```

4. update the file with the new cluster hosts in the master node:
```
<ip> <hostname>
<ip> <hostname>
```
Include all nodes in the script (master and workers)

5. run the set_nodes.sh utility
```bash
. enma_setup/set_nodes.sh hosts_file 
```
This script has the utility to set-up all the hosts through ssh
1. backup the /etc/hosts file in /opt/hosts_utils.
2. adds all the hosts of the file passed as parameter into /etc/hosts
3. sets the hostname of the nodes
4. install the required packages

6. connect to master:8080 to configure the new node


# Description of enma_setup
This package contains scripts to manage the cluster nodes from the master. 

Following is a brief description on the scripts

1. hosts_utils:
    package containing the required scripts to manage the /etc/hosts
    1. enma_setup/hosts_utilities/set_up.sh: Run on the setup of the node, it copies the /etc/hosts as a backup to add more hosts later.

    2. enma_setup/hosts_utilities/update_hosts.sh: Updates the original hosts with the new hosts files passed as parameter.

2. install.sh 
    install all required packages for setting up the ambari server and 

3. set_nodes.sh
    main installation script that:
    1. updates the /etc/hosts to all nodes
    2. sets the hostname of all nodes
    3. installs the packages in "install.sh"

4. run_on_nodes.sh
    utility to run commands on all nodes

#### enma_setup code
hosts_utils/set_up.sh
```bash
#! /bin/bash

#copy /etc/hosts as backup

if ! test -f /opt/hosts_utils/original.hosts
    then
        mkdir /opt/hosts_utils
        cp /etc/hosts /opt/hosts_utils/original.hosts
fi
```
hosts_utils/update_hosts.sh
```bash
#! /bin/bash
cat /opt/hosts_utils/original.hosts $1 > /etc/hosts
```
install.sh
```bash
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

sudo ulimit -n 10000
sudo apt install -y ntp
sudo update-rc.d ntp defaults
# change for other linux versions
sudo wget -O /etc/apt/sources.list.d/ambari.list http://public-repo-1.hortonworks.com/ambari/ubuntu18/2.x/updates/2.7.3.0/ambari.list
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
sudo apt-get update
```
set_nodes.sh
```bash
#! /bin/bash
while read p
    do 
        host=`echo $p|cut -d" " -f1`
        name=`echo $p|cut -d" " -f2`
        echo "setting up $name"
        ssh-keyscan -H $host >> /root/.ssh/known_hosts
        scp -r enma_setup $host:./node_setup
        ssh -n $host ". node_setup/hosts_utils/set_up.sh"
        ssh -n $host "hostname $name" 
        scp $1 $host:.
        ssh -n $host ". node_setup/hosts_utils/update_hosts.sh $1"
        ssh -n $host ". node_setup/install.sh"
           done < $1
```
run_on_nodes.sh
```bash
#! /bin/bash
while read p
    do 
        host=`echo $p|cut -d" " -f1`
        name=`echo $p|cut -d" " -f2`
        echo "running on $name"
        ssh -n $host "$2"
           done < $1
```
