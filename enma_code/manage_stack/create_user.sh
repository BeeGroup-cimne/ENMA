! /bin/bash

read -r CLIENT

export CLIENT=$CLIENT
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