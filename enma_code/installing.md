# Install ENMA

This tutorial will guide you to install the working hadoop cluster in a few easy steps.

*The instructions are updated for ubuntu 20.04(LTS) if using other versions some of the scripts migth need to be modified*

## Set up the cluster
### Requirements before start
- ssh access to all nodes

### Prepare the nodes 
1. set the root password for all nodes and log as the root user
    ```bash
    sudo passwd
    sudo su -
    ```

2. create public key in the admin node for root and configure the passwordless ssh in all hosts.
    *on admin node*

    ```bash
    ssh-keygen -t rsa -m PEM
    cat /root/.ssh/id_rsa.pub
    ```

    *on each host node (including admin)*

    ```bash
    echo "<master_key>" >> /root/.ssh/authorized_keys
    ```

3. check if the nodes are connected on the fast private network.
   ```
   ip address
   ```
   If they are not, connect them depending on their linux distribution.
   
   *Check the name on the private network interface*

4. mount the HDD of the nodes
    ```bash
    lsblk # to list all hdd
    fdisk /dev/sdb #create primary partition with 'n' and 'p' and save with 'w' 
    mkfs.ext3 /dev/sdb1 # to format the partition
    mkdir /hdd
    mount /dev/sdb1 /hdd
    e2label /dev/sdb1 hdd
    ```
    update the `vim /etc/fstab` file
    ```
    LABEL=hdd       /hdd            ext3    defaults        1 2
    ```
    
5. create a `hosts_file` file with all cluster hosts in the admin node:
    ```
    <private fast ip> <private hostname>
    <private fast ip> <private hostname>
    ```
    *Include all nodes in the file (the administrator node must be the first one)*

6. copy the [enma_setup directpry](enma_code/enma_setup) to the admin node

7. run the setup utility that will prepare each node for hadoop with bash
    ```
    bash enma_setup/set_nodes.sh hosts_file
    ```
    this script will:
    - on all nodes:
        - install the necessari packages
        - set hostnames and hosts
        - set the limits in files and processes
        - configure docker to be executed as non root and start on startup.
    - on admin node:
        - set the VPN server
        - create all vpn clients for each node
        - send the certificate to each node
    - on all nodes:
        - connect to the vpn
        - configure the firewall to block all connections but port 22 in external ip

8. reboot system to prepare for installing hadoop:
    ```bash 
    tac hosts_file > rev
    bash enma_setup/run_on_nodes.sh rev reboot
   ```

### Install HADOOP STACK:
To safely install hadoop stack applications, create a new folder `hadoop_stack` that will contain all the hadoop_stack binary. 
This folder must be placed in the root directory "/".
```
mkdir -p /hadoop_stack
```

#### Install HADOOP Core
- download stable hadoop release binary from oficial [webpage](https://hadoop.apache.org/):
- untar the file in the `hadoop_stack` folder
  ```
  tar -xzvf hadoop-x.y-z.tar.gz -C /hadoop_stack
  ```
- set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
- set a `masters` file with the master information:
  ```
  <user> <binary> <service> <node>
  ...
  hdfs bin/hdfs namenode master1
  ```
- set the variables in the setup script `hadoop_stack_installation -> deploy_hadoop.sh`
  - HADOOP_STACK_DIR
  - HADOOP_ENV
  - HADOOP_DATA_DIR
- run the script:
  ```
  bash hadoop_stack_installation/deploy_hadoop.sh hosts_file
  ```
    - it copies the folder to all nodes
    - sets the permissions groups and environment variables
    - creates the users to run hadoop
- On master node running namenode, format the hdfs
  ```
  su hdfs -c "$HADOOP_HOME/bin/hdfs namenode -format
  ```
- Start hadoop
  ```
  bash manage_hadoop/start_hadoop.sh start
  ```
- Change permissions and owners:
  ```
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp"
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chown -R hdfs:hadoop /"
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chmod 0775 /" 
  ```
        
#### Install HBASE
- download stable hbase release binary from oficial [webpage](https://hbase.apache.org/):
- untar the file in the `hadoop_stack` folder
  ```
  tar -xzvf apache-x.y-z.tar.gz -C /hadoop_stack
  ```
9- install hbase
    - download tar.gz and unpack
    - configure service
    - send it to all nodes
    - set up easy start

### Install HIVE
- download stable hadoop release binary from oficial [webpage](https://hive.apache.org/):
- untar the file in the `hadoop_stack` folder
  ```
  tar -xzvf hive-x.y-z.tar.gz -C /hadoop_stack
  ```
10- install hive
    - download tar.gz and unpack
    - configure service
    - send it to all nodes
    - set up easy start

    - download mysql-connector-java.jar.
        ```bash
        wget url
        dpkg -i path_to_deb_file
        ```
   
10. Last steps:
    - [Set up the correct name for the hadoop public hostname](https://community.cloudera.com/t5/Community-Articles/Why-ambari-host-might-have-different-public-host-name-and/ta-p/246662)(only on openstack)
    - change hdfs the *.http-address ip to 0.0.0.0
    - [uninstall smartsense](https://docs.cloudera.com/HDPDocuments/SS1/SmartSense-1.2.0/bk_smartsense_admin/content/ambari_uninstall.html) (if not paying the subscription)
    - install [tomcat](https://linuxize.com/post/how-to-install-tomcat-9-on-ubuntu-18-04/)
    - install [tez view](https://tez.apache.org/tez-ui.html)

*If you face errors while starting the ambari-metrics application, remove previous data and restart the service*.
```bash
rm -rf /var/lib/ambari-metrics-collector
```

### Connect HBASE with HIVE
    
1. Add hive property to connect to hbase properly(matching values with hbase config)

    *In hive->config->advanced-> custom hive-site.xml*
    
        hbase.zookeeper.quorum : value in hbase->config->advanced
        
        zookeeper.znode.parent : value in hbase->config->advanced
     
2. On the server running the hbase master, start the thrift hive server:
    ```bash
    /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift --bind <private_ip>
    ```
   For kerberized cluster set also the credentials for the thrift server:
    
   
In custom hbase-site.xml:
    
```bash
hbase.thrift.security.qop=auth
hbase.thrift.support.proxyuser=true
hbase.regionserver.thrift.http=true
hbase.thrift.keytab.file=/etc/security/keytabs/hbase.service.keytab 
hbase.thrift.kerberos.principal=hbase/_HOST@HWX.COM 
hbase.security.authentication.spnego.kerberos.keytab=/etc/security/keytabs/spnego.service.keytab 
hbase.security.authentication.spnego.kerberos.principal=HTTP/_HOST@HDP.COM
```
In custom core-site.xml:

```bash
hadoop.proxyuser.hbase.groups=*
hadoop.proxyuser.hbase.hosts=*
```

*font: https://community.cloudera.com/t5/Community-Articles/Start-and-test-HBASE-thrift-server-in-a-kerberised/tac-p/244673*
***
## Create users 
1. Create the HDFS user's home and add the user to the hadoop and hdfs group
    ```bash
    # create the user folder in hdfs
    su hdfs # hdfs user has permission to create files
    hdfs dfs -mkdir /user/<user> # create the folder
    hdfs dfs -chown <user>:hdfs /user/<user> # change the owner
    # go back to the root
    exit
    # add the <user> to the hadoop and hdfs groups
    usermod -a -G hadoop <user>
    usermod -a -G hdfs <user>
    ```
2. Configure pip in `.bashrc` to avoid installing python packages globally for the user who will execute jobs. Do it as user, not root.       
   ```bash
    # pip config
    export PIP_REQUIRE_VIRTUALENV=true
    gpip() {
        PIP_REQUIRE_VIRTUALENV="" pip "$@"
    }
    gpip3(){
        PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
    }
    ```

## Security

1. install [kerberos](https://docs.cloudera.com/HDPDocuments/HDP2/HDP-2.6.1/bk_security/content/configuring_amb_hdp_for_kerberos.html)

2. Create the principals for the users in hadoop.
    - Create the hdfs user principal

        ```kadmin:  addprinc hdfs@REALM.COM```
    - Repeat [step 1 in Create users](#create-users) (logging in as hdfs principal).
    - Create a principal in kerberos with the same name: 
    
        ```kadmin:  addprinc username@REALM.COM```
    
3. Generate the certificate for all nodes using certbot.
    *On admin node*
    ```bash
    . enma_setup/run_on_nodes.sh hosts_file "sudo snap install core; sudo snap refresh core"
    . enma_setup/run_on_nodes.sh hosts_file "sudo snap install --classic certbot"
    . enma_setup/run_on_nodes.sh hosts_file "sudo ln -s /snap/bin/certbot /usr/bin/certbot"
    ```
    *On all nodes*
    ```bash
    sudo certbot certonly --standalone
    ````
    
4. [Set the ambari server under https](https://docs.cloudera.com/HDPDocuments/Ambari-2.1.2.1/bk_Ambari_Security_Guide/content/_optional_set_up_ssl_for_ambari.html)
        
    To set the ambari-server to renew the certificates automatically using certbot we have to create a script in the deploy hook folder:
    ```bash
    cd /etc/letsencrypt/renewal-hooks/deploy
    CERT=<path to fullchain cert>
    KEY=<path to private key>
    PASSWD=<private key password>
    printf "#! /bin/bash\nambari-server stop\nambari-server setup-security --security-option=setup-https --api-ssl=true --api-ssl-port=8443 --import-cert-path=$CERT --import-key-path=$KEY --pem-password=\"$PASSWD\"\nambari-server start\n" > restart_ambari.sh
    chmod 0775 restart_ambari.sh
    ```
    *st the variables depending on your system*
    #########################################################################

    **Currently not working (Is for the complete HTTPS connection with the nodes)**
    *create the .p12 file with the obtained certs*
    ```bash
    #import the files in a jks keystore.
    apt install -y openjdk-11-jre-headless
    HOSTNAME=<host>
    PASSWORD=<password>
    #create p12 for the cert
    openssl pkcs12 -export -out cert.p12 -in fullchain.pem -inkey privkey.pem -passout pass:$PASSWORD
    #import it to the keystore
    keytool -importkeystore -srckeystore cert.p12 -srcstoretype pkcs12 -srcalias 1 -srcstorepass $PASSWORD -destkeystore odin-hadoop.jks -deststoretype JKS  -destalias $HOSTNAME -deststorepass $PASSWORD    
    ```
    send jks file to each host and repeat
    keytool -list -keystore odin-hadoop.jks -storepass $PASSWORD

    #########################################################################

## Optimization


1. After installation, change configuration of cluster:
    - configure yarn max memory to match the max memory of the node/ram
    - configure tez to close session when query is finished:
        -tez.session.am.dag.submit.timeout.secs = 0
    

## Set up docker for launching applications

1. [Manage Docker as non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

run the following commands on all nodes. You can use the "run on nodes utility"
```bash
USER=<non root user to add to the docker group>
source enma_setup/run_on_nodes.sh hosts_file "groupadd docker&usermod -aG docker $USER&newgrp docker"
```
2. [Configure Docker to start on boot](https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot)
```bash
source enma_setup/run_on_nodes.sh hosts_file "systemctl enable docker.service"
```
3. [Launching Applications Using Docker Containers](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/DockerContainers.html)
## Set up the project environment
1. Install celery on the admin node

```bash
apt install -y libmysqlclient-dev
apt install -y rabbitmq-server
apt install -y supervisor
apt install -y python-celery-common
pip3 install celery
pip3 install django
pip3 install mysqlclient
pip3 install django-celery
```

2. Install the enma_project directories in the folder to run the project and set the following files:
    - envconfig.json: Set the info for the rabbitmq
    - celeryconfig.py: Set the info of the local celery database
    - celery_supervisor.sh: Set the path of the enma_projects folder and hadoop streaming home
    set permissions to execute `celery_supervisor.sh`
    
    ```bash
    chmod 0755 celery_supervisor.sh
    ```
    
3. Create the rabbitmq config as in envconfig.json
``` bash
rabbitmqctl add_user <username> <password>
rabbitmqctl  add_vhost <vhost>
rabbitmqctl set_permissions -p <vhost> <username> ".*" ".*" ".*"
```

4. Create the supervisorctl script (celery.conf).
``` bash
[program:celery]
directory=<enma_project_folder>
command=<enma_project_folder>/celery_supervisor.sh
user = <user>
startsecs = 5
autostart = True
```


5. Start supervisor and celery
``` bash
service supervisor start
supervisorctl reload
```



6. Configure a project to be run in `celery_backend.py`
    - add the module's task in the `include` list
    - restart the celery server


## Add new nodes to cluster

1. set the root password for the new nodes
```bash
sudo passwd
su -
```

2. add public key and configure the passwordless ssh in the new hosts.

*on admin node*
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

4. update the file with the new cluster hosts in the admin node:
```
<ip> <hostname>
<ip> <hostname>
```
Include all nodes in the script (admin, master and workers)

5. run the set_nodes.sh utility
```bash
. enma_setup/set_nodes.sh hosts_file 
```
This script has the utility to set-up all the hosts through ssh
1. backup the /etc/hosts file in /opt/hosts_utils.
2. adds all the hosts of the file passed as parameter into /etc/hosts
3. sets the hostname of the nodes
4. install the required packages

6. connect to <ip>:8080 to configure the new node


# Description of enma_setup
This package contains scripts to manage the cluster nodes from the master. 

Following is a brief description on the scripts

1. hosts_utils:
    package containing the required scripts to manage the /etc/hosts
    1. enma_setup/hosts_utilities/set_up.sh: Run on the setup of the node, it copies the /etc/hosts as a backup to add more hosts later.

    2. enma_setup/hosts_utilities/update_hosts.sh: Updates the original hosts with the new hosts files passed as parameter.

2. install.sh 
    install all required packages for setting up the ambari server 

3. set_nodes.sh
    main installation script that:
    1. updates the /etc/hosts to all nodes
    2. sets the hostname of all nodes
    3. installs the packages in "install.sh"

4. run_on_nodes.sh
    utility to run commands on all nodes


## install hadoop stack
#mkdir hadoop_stack
#while read app
#do
#  url_app=`echo $app|cut -d" " -f1`
#	filename=`basename $url_app`
#  wget -P hadoop_stack $url_app;
#  tar -xzvf hadoop_stack/$filename -C hadoop_stack
#done < hdp_version