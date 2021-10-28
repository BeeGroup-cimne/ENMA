#! /bin/bash
HIVE_ENV=/hadoop_stack/hive-3.1.2/conf/hive-env.sh

. $HIVE_ENV

ENV_TO_SET=(HIVE_HOME=$HIVE_HOME
            PATH=$PATH:$HIVE_HOME/bin)

while read p
do
  host=`echo $p|cut -d" " -f1`
  scp -r $HIVE_HOME $host:$HIVE_HOME
done < <(tail -n +2 $1)

while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "chown -R root:hadoop $HIVE_HOME"

  for env in ${ENV_TO_SET[@]}
    do
      ssh -n $host "echo export $env >> /etc/bash.bashrc"
    done
done < $1

LOG_DIR=${HIVE_LOG_DIR:-/tmp/hive/}
while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "mkdir -p $LOG_DIR"
  ssh -n $host "chown -R root:hadoop $LOG_DIR"
  ssh -n $host "chmod -R 775 $LOG_DIR"
done < $1

while read p
do
  host=`echo $p|cut -d" " -f2`
  ssh -n $host "useradd hive"
  ssh -n $host "usermod -a -G hadoop hive"
done < $1

while read p
do
  su hdfs -c "$HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hive/warehouse"
  su hdfs -c "$HADOOP_HOME/bin/hadoop fs -chmod -R g+w /user/hive/warehouse"
  su hdfs -c "$HADOOP_HOME/bin/hadoop fs -chmod -R g+rwx /tmp"
  ssh -n $p "su hive -c '$HIVE_HOME/bin/schematool -dbType mysql -initSchema'"
done < $HIVE_HOME/conf/master