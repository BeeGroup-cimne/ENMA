# Install ENMA

This tutorial will guide you to install the working hadoop cluster in a few easy steps.

*The instructions are updated for ubuntu 20.04(LTS) if using other versions some of the scripts migth need to be modified*

## Set up the cluster
### Requirements before start
- ssh access to all nodes
- Basic knowledge of the hadoop infrastructure and concepts.
- Basic knowledge of ubuntu concepts.
### Naming convention
During this tutorial, some concepts will be used. In this section you can find a definition of the different concepts that may help understanding them.

- **root:** The user administrator of the linux system. It has permissions to perform all operations. His name is `root`
- **node:** Any machine conforming the cluster.
- **master node:** A node that will be used to install hadoop master components. This will manage the executions and the storage.
- **worker node:** A node that will be used to install hadoop worker components. This will execute the tasks and store the data
- **admin node:** The node that will be used to install and administrate the whole cluster. You can select any node. A recommendation is to use one of the masters.
- **interface(connection):** The interface is the given name to a physical of virtual connection interface in the OS.
- **fast private network:** A private network that internally connects the cluster machines. In OVH is the private network configuration.
- **drive name:** The name that OS gives to all drives. Usually for physical drives is sdX where X is a letter. ex: sda
- **drive partition name:** The name that OS gives to all partitions. Usually for physical drive partitions is sdXY where X is a letter and y a number. ex: sda1
- **private hostname:** Is a hostname we will choose for the node for internal use. 

### Prepare the nodes 
###### 1. set the root password for all nodes and log-in as the root user. Continue the tutorial as root on all nodes
```bash
sudo passwd
sudo su -
```

###### 2. create public key in the admin node for the root user and configure the passwordless ssh in all hosts.
*on admin node*

```bash
ssh-keygen -t rsa -m PEM
cat /root/.ssh/id_rsa.pub
```

*on each host node (including admin)*

```bash
echo "<master_key>" >> /root/.ssh/authorized_keys
```

###### 3. check if the nodes are connected on the fast private network if it exists in your cluster.
```bash
ip address
```
   *Check the interface on the fast private network interface to use latter*

   If the state of the is DOWN, verify how to connect to the fast private network according to your linux distribution.

   > Permanently connect to the fast private network (ditribution: Ubuntu20.04)
   > 
   > - *Edit the 50-cloud-init.yaml file*
   > 
   >```bash
   >   vim /etc/netplan/50-cloud-init.yaml 
   >   ```
   > -  *add the following text following yaml format*
   >   ```yaml
   >   network:
   >       ethernets:
   >           <network interface>:
   >               dhcp4: false
   >               addresses: [<private network>/<mask>] ex: 10.8.0.1/24
   >       version: 2
   >
   >   ```
   > -  *accempt the changes*
   >   ```bash
   >   netplan apply
   >   ```

###### 4. mount the HDD of the nodes if external drives are available
```bash
lsblk # to list all hdd
fdisk /dev/<drive name> #create primary partition with 'n' and 'p' and save with 'w' 
mkfs.ext3 /dev/<drive partition name> # to format the partition
mkdir /hdd
mount /dev/<drive partition name> /hdd
e2label /dev/<drive partition name> hdd
```
update the `vim /etc/fstab` file
```
LABEL=hdd       /hdd            ext3    defaults        1 2
```
    
###### 5. create a `hosts_file` file with all cluster hosts in the admin node:
```
<fast private ip> <private hostname>
<fast private ip> <private hostname>
```
*Include all nodes in the file (the admin node must be the first one)*
>TIP: the private hostname can be any name to identify the nodes internally. ex: `<node_name>.internal

###### 6. copy the [enma_setup directpry](enma_code/enma_setup) to the admin node. Choose a folder in the root home `/root`

   - run the setup utility that will prepare each node for hadoop with bash
   ```bash
   bash enma_setup/set_nodes.sh hosts_file
   ```

   - During execution, some information will be asked by the script to properly set the cluster
    
     - **VPN network:** The vpn network you are going to create. Choose any  reserved private IP.
     - **VPN network mask:** The mask for the VPN network. ex: 255.255.255.0 
     - **Main user home:** The home for the main user, where the vpn certs are stored. ex: /home/ubuntu
     - **Fast private network interface:** The interface of the fast private network.
     - **VPN interface:** The interface of the VPN network.
     
   - This script will:
   
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

###### 7. reboot system to prepare for installing hadoop:

You can use the `run_on_nodes.sh` script
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
###### download stable hadoop release binary from oficial [webpage](https://hadoop.apache.org/):
###### untar the file in the `hadoop_stack` folder
```bash
tar -xzvf hadoop-x.y-z.tar.gz -C /hadoop_stack
```
###### set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
    - check examples in `config_examples` folder.
###### set a `masters` file with the master information:
```
<user> <binary> <service> <node> ex: hdfs bin/hdfs namenode master1
```
  - **user:** the user that will run the service
  - **binary:** the binary to use to run the service [hdfs, yarn]
  - **service:** the master service to run [namenode, secondarynamenode, resourcemanager, proxyserver]
  - **node:** the private hostname of the node that will run the service
    
###### set the variables in the setup script `deploy_hadoop.sh` 
```bash
vim hadoop_stack_installation/deploy_hadoop.sh
```
  And set the environemnt variables:.
  - **HADOOP_STACK_DIR:** folder created for the hadoop_stack. ex: /hadoop_stack
  - **HADOOP_ENV:** path to the `hadoop-env.sh` configuration file. ex:/hadoop_stack/hadoop/etc/hadoop/hadoop-env.sh
  - **HADOOP_DATA_DIR:** Folder to store the hadoop data. ex: /hdd
###### run the script:
```bash
bash hadoop_stack_installation/deploy_hadoop.sh hosts_file
```
this script:
- copies the hadoop installation to all nodes
- sets the permissions groups and environment variables
- creates the users to run hadoop

###### On master node running namenode, format the hdfs
```bash
su hdfs -c "$HADOOP_HOME/bin/hdfs namenode -format"
```
###### Start hadoop
```bash
bash manage_stack/manage_hadoop.sh start
```
###### Change permissions and owners:
```bash
su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp"
su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chown -R hdfs:hadoop /"
su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chmod -R 0775 /" 
```
#### Test installation
check the web interfaces:
<namenode>:9870
<resourcemanager>:8088
copy the examples jar to the user home, the examples can be found in the hadoop_stack folder `/hadoop_stack/hadoop/share/hadoop/mapreduce/`

*Test installation*:
```bash
hadoop jar hadoop-mapreduce-examples-3.3.1.jar pi 10 1000
```
*Test docker*:
```bash
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
###### download stable hbase release binary from oficial [webpage](https://hbase.apache.org/):
###### untar the file in the `hadoop_stack` folder
```bash
tar -xzvf hbase-x.y-z.tar.gz -C /hadoop_stack
```
###### set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
- check examples in `config_examples` folder.
###### set a `hmaster` file with the master node name
###### set the variables in the setup script `deploy_hbase.sh` 
```bash
vim hadoop_stack_installation/deploy_hbase.sh
```
  And set the environemnt variables:.
  - **HBASE_ENV:** path to the `hbase-env.sh` configuration file. ex:/hadoop_stack/hbase/conf/hbase-env.sh
 
###### run the script:
```bash
bash hadoop_stack_installation/deploy_hbase.sh hosts_file
```
this script:
- copies the folder to all nodes
- sets the permissions groups and environment variables
- creates the hbase user to run hbase
- sets passwordless ssh between nodes for hbase user
    
###### Start hbase
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
###### download stable hadoop release binary from oficial [webpage](https://hive.apache.org/):
###### untar the file in the `hadoop_stack` folder
```
tar -xzvf hive-x.y-z.tar.gz -C /hadoop_stack
```
###### set the configuration of the service. Configurations are very personal. It is better to follow the oficial instructions.
- check examples in `config_examples` folder. 
###### set mysql as the hive metadata database following the [tutorial](https://data-flair.training/blogs/configure-hive-metastore-to-mysql)
- sudo apt-get install mysql-server on the manager_node
- download, install and copy mysql-connector-java:
```bash
    wget url
    dpkg -i path_to_deb_file
```
- copy the jar file usually in /usr/share/java/ to $HIVE_HOME/lib

###### Edit configuration in hive-site.xml in the config folder
- javax.jdo.option.ConnectionURL: jdbc:mysql://host/hcatalog?createDatabaseIfNotExist=true
- javax.jdo.option.ConnectionUserName: <hive_mysql_username> 
- javax.jdo.option.ConnectionPassword: <hive_mysql_password>
- javax.jdo.option.ConnectionDriverName: com.mysql.cj.jdbc.Driver

###### Create mysql table `hcatalog`, user with password in mysql 
```sql
create database 'hcatalog';
create 'user'@'%' identified by 'password';
grant all privileges on hcatalog.* to hive;
```

###### Edit mysql configuration to listen to all IP
- open mysql config file
```bash
vim /etc/mysql/mysql.conf.d/mysqld.cnf 
```
- Edit the important configuration fields
```
bind-address            = 0.0.0.0
mysqlx-bind-address     = 0.0.0.0     
```
- Restart mysql
```
systemctl restart mysql
```
###### change guava jar on hive from the one in hadoop:
- remove guava-x.y.z.jar on $HIVE_HOME/lib
- copy $HADOOP_HOME/share/hadoop/hdfs/lib/guava-x.y.z.jar to $HIVE_HOME/lib
- set the variables in the setup script `deploy_hive.sh` 
```bash
  vim hadoop_stack_installation/deploy_hive.sh
```
- And set the environemnt variables:.
  - **HBASE_ENV:** path to the `hive-env.sh` configuration file. ex:/hadoop_stack/hive/conf/hive-env.sh
  
###### run the script:
```bash
bash hadoop_stack_installation/deploy_hive.sh hosts_file
```
- This script
  - copies the folder to all nodes
  - sets the permissions groups and environment variables
  - creates the hive user to run hiveserver2
  - creates the schema in mysql database

###### Start hive
```bash
    bash manage_stack/manage_hive.sh start
```
#### Test installation

in any node, run

```hiveql
beeline -u jdbc:hive2://<master private hostname>:10000 -n ubuntu
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
If you need to create a user to work with the stack, this script will do it in all the nodes
```
bash manage_stack/create_user.sh hosts_file
```
### INSTALL KAFKA
By now, we are going to set the kafka in a single server, thus the instructions are just related for a single node
https://kafka.apache.org/quickstart
###### 1. set up the node installing required packages `kafka_installation/set_node.sh`
###### 2. mount the external HDD if available: [documentation](#4-mount-the-hdd-of-the-nodes-if-external-drives-are-available)
###### 3. download and untar kafka
###### 4. configure kafka
   1. edit `server.properties` and `zookeeper.properties` set servers to listen on the private fast interface
###### 5. configure ufw
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow in on <private fast interface>
ufw --force enable
```
###### 6. start kafka
```bash
bash manage_stack/manage_stack.sh start
```
