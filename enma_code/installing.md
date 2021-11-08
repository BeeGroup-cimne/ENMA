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
    tac hosts_file > hosts_file_rev
    bash enma_setup/run_on_nodes.sh hosts_file_rev reboot
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
  su hdfs -c "$HADOOP_HOME/bin/hdfs namenode -format"
  ```
- Start hadoop
  ```
  bash manage_stack/manage_hadoop.sh start
  ```
- Change permissions and owners:
  ```
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp"
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chown -R hdfs:hadoop /"
  su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chmod -R 0775 /" 
  ```
#### Test installation
check the web interfaces:
<namenode>:9870
<resourcemanager>:8088
copy the examples jar to the user home.

*Test installation*:
```
hadoop jar hadoop-mapreduce-examples-3.3.1.jar pi 10 1000
```
*Test docker*:
```
MOUNTS="$HADOOP_HOME:$HADOOP_HOME:ro,/etc/passwd:/etc/passwd:ro,/etc/group:/etc/group:ro"
IMAGE_ID="library/openjdk:8"
yarn jar hadoop-mapreduce-examples-3.3.1.jar pi \
    -Dmapreduce.map.env.YARN_CONTAINER_RUNTIME_TYPE=docker \
    -Dmapreduce.map.env.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=$MOUNTS \
    -Dmapreduce.map.env.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$IMAGE_ID \
    -Dmapreduce.reduce.env.YARN_CONTAINER_RUNTIME_TYPE=docker \
    -Dmapreduce.reduce.env.YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=$MOUNTS \
    -Dmapreduce.reduce.env.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$IMAGE_ID \
    1 40000
```

#### Install HBASE
- download stable hbase release binary from oficial [webpage](https://hbase.apache.org/):
- untar the file in the `hadoop_stack` folder
  ```
  tar -xzvf hbase-x.y-z.tar.gz -C /hadoop_stack
  ```
- set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
- set a `hmaster` file with the master node name
- set the variables in the setup script `hadoop_stack_installation -> deploy_hbase.sh`
  - HBASE_ENV
  
- run the script:
  ```
  bash hadoop_stack_installation/deploy_hbase.sh hosts_file
  ```
    - it copies the folder to all nodes
    - sets the permissions groups and environment variables
    - creates the hbase user to run hbase
    - sets passwordless ssh between nodes for hbase user
    
- Start hbase
```
    bash manage_stack/manage_hbase.sh start
```
#### Test installation
check the web interfaces
<hmaster>:16010

in any node, run

```
hbase shell
list
create "test","m"
list
put 'test',1,'m:test','10'
scan 'test'
```

### Install HIVE
- download stable hadoop release binary from oficial [webpage](https://hive.apache.org/):
- untar the file in the `hadoop_stack` folder
  ```
  tar -xzvf hive-x.y-z.tar.gz -C /hadoop_stack
  ```
- set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
 
- set mysql as the hive metadata database following the [tutorial](https://data-flair.training/blogs/configure-hive-metastore-to-mysql)
    - sudo apt-get install mysql-server on the manager_node
    - download, install and copy mysql-connector-java:
      ```bash
        wget url
        dpkg -i path_to_deb_file
        ```
      copy the jar file usually in /usr/share/java/ to $HIVE_HOME/lib

- Edit configuration in hive-site.xml
        - javax.jdo.option.ConnectionURL: jdbc:mysql://host/hcatalog?createDatabaseIfNotExist=true
        - javax.jdo.option.ConnectionUserName: <hive_mysql_username> 
        - javax.jdo.option.ConnectionPassword: <hive_mysql_password>
        - javax.jdo.option.ConnectionDriverName: com.mysql.cj.jdbc.Driver
- Create mysql table `hcatalog`, user with password in mysql 
    ```
      create database 'hcatalog';
      create 'user'@'%' identified by 'password';
      grant all privileges on hcatalog.* to hive;
    ```
- Edit mysql configuration to listen to all IP
    ```
       vim /etc/mysql/mysql.conf.d/mysqld.cnf 
       # set
       bind-address            = 0.0.0.0
       mysqlx-bind-address     = 0.0.0.0     
    ```
- Restart mysql
  ```
  systemctl restart mysql
  ```
- change guava jar on hive from the one in hadoop:
  - remove guava-x.y.z.jar on $HIVE_HOME/lib
  - copy $HADOOP_HOME/share/hadoop/hdfs/lib/guava-x.y.z.jar to $HIVE_HOME/lib
   
- set the variables in the setup script `hadoop_stack_installation -> deploy_hive.sh`
  - HIVE_ENV

- run the script:
  ```
  bash hadoop_stack_installation/deploy_hive.sh hosts_file
  ```
    - it copies the folder to all nodes
    - sets the permissions groups and environment variables
    - creates the hive user to run hiveserver2
    - creates the schema in mysql database

- Start hbase
```
    bash manage_stack/manage_hive.sh start
```
#### Test installation

in any node, run

```
beeline -u jdbc:hive2://master1.internal:10000 -n ubuntu
show databases;
create database test;
use test;
create table test (id bigint, value string);
show tables;
insert into test values (1, "hola");
select * from test;
create external table htest(id int, test string) STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' WITH SERDEPROPERTIES ("hbase.columns.mapping"=":key,m:test") TBLPROPERTIES ("hbase.table.name"="test");
select * from htest;
```

#### Create user to work with the stack
bash manage_stack/create_user.sh hosts_file




[comment]: <> (***)

[comment]: <> (## Add new nodes to cluster)

[comment]: <> (1. set the root password for the new nodes)

[comment]: <> (```bash)

[comment]: <> (sudo passwd)

[comment]: <> (su -)

[comment]: <> (```)

[comment]: <> (2. add public key and configure the passwordless ssh in the new hosts.)

[comment]: <> (*on admin node*)

[comment]: <> (```bash)

[comment]: <> (cat /root/.ssh/id_rsa.pub)

[comment]: <> (```)

[comment]: <> (*on each new host node*)

[comment]: <> (```bash)

[comment]: <> (echo/cat master_key >>/root/.ssh/authorized_keys)

[comment]: <> (```)

[comment]: <> (3. connect the node to the private network)

[comment]: <> (```bash)

[comment]: <> (ip link # list all ip interfaces)

[comment]: <> (ip address # check connected interfaces)

[comment]: <> (ifconfig <int> <private address> up # force connection to the ip address)

[comment]: <> (```)

[comment]: <> (4. update the file with the new cluster hosts in the admin node:)

[comment]: <> (```)

[comment]: <> (<ip> <hostname>)

[comment]: <> (<ip> <hostname>)

[comment]: <> (```)

[comment]: <> (Include all nodes in the script &#40;admin, master and workers&#41;)

[comment]: <> (5. run the set_nodes.sh utility)

[comment]: <> (```bash)

[comment]: <> (. enma_setup/set_nodes.sh hosts_file )

[comment]: <> (```)

[comment]: <> (This script has the utility to set-up all the hosts through ssh)

[comment]: <> (1. backup the /etc/hosts file in /opt/hosts_utils.)

[comment]: <> (2. adds all the hosts of the file passed as parameter into /etc/hosts)

[comment]: <> (3. sets the hostname of the nodes)

[comment]: <> (4. install the required packages)

[comment]: <> (6. connect to <ip>:8080 to configure the new node)


[comment]: <> (# Description of enma_setup)

[comment]: <> (This package contains scripts to manage the cluster nodes from the master. )

[comment]: <> (Following is a brief description on the scripts)

[comment]: <> (1. hosts_utils:)

[comment]: <> (    package containing the required scripts to manage the /etc/hosts)

[comment]: <> (    1. enma_setup/hosts_utilities/set_up.sh: Run on the setup of the node, it copies the /etc/hosts as a backup to add more hosts later.)

[comment]: <> (    2. enma_setup/hosts_utilities/update_hosts.sh: Updates the original hosts with the new hosts files passed as parameter.)

[comment]: <> (2. install.sh )

[comment]: <> (    install all required packages for setting up the ambari server )

[comment]: <> (3. set_nodes.sh)

[comment]: <> (    main installation script that:)

[comment]: <> (    1. updates the /etc/hosts to all nodes)

[comment]: <> (    2. sets the hostname of all nodes)

[comment]: <> (    3. installs the packages in "install.sh")

[comment]: <> (4. run_on_nodes.sh)

[comment]: <> (    utility to run commands on all nodes)


[comment]: <> (## install hadoop stack)

[comment]: <> (#mkdir hadoop_stack)

[comment]: <> (#while read app)

[comment]: <> (#do)

[comment]: <> (#  url_app=`echo $app|cut -d" " -f1`)

[comment]: <> (#	filename=`basename $url_app`)

[comment]: <> (#  wget -P hadoop_stack $url_app;)

[comment]: <> (#  tar -xzvf hadoop_stack/$filename -C hadoop_stack)

[comment]: <> (#done < hdp_version)