#! /bin/bash

echo "write the user to create"
read -r CLIENT
sudo adduser $CLIENT
export CLIENT=$CLIENT
export MENU_OPTION="1"
bash openvpn-install.sh
while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "usermod -a -G hadoop $CLIENT"
  ssh -n $host "usermod -a -G docker $CLIENT"
done < $1

su hdfs -c "$HADOOP_HOME/bin/hdfs dfsadmin -refreshUserToGroupsMappings"
su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/$CLIENT"
su hdfs -c "$HADOOP_HOME/bin/hdfs dfs -chown $CLIENT:hadoop /user/$CLIENT"