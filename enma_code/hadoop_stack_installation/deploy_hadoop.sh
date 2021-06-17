#! /bin/bash
HADOOP_STACK_DIR=/hadoop_stack
HADOOP_ENV=$HADOOP_STACK_DIR/hadoop-3.3.1/etc/hadoop/hadoop-env.sh
HADOOP_DATA_DIR=/hdd

. $HADOOP_ENV

ENV_TO_SET=(JAVA_HOME=$JAVA_HOME
            HADOOP_HOME=$HADOOP_HOME
            PATH=$PATH:$HADOOP_HOME/bin)

while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "mkdir -p $HADOOP_STACK_DIR"
  scp -r $HADOOP_HOME $host:$HADOOP_STACK_DIR
done < <(tail -n +2 $1)

while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "groupadd hadoop"
  ssh -n $host "chown -R root:hadoop $HADOOP_STACK_DIR"
  ssh -n $host "chown -R root:hadoop $HADOOP_DATA_DIR"
  ssh -n $host "chmod -R 775 $HADOOP_DATA_DIR"
  for env in ${ENV_TO_SET[@]}
    do
      ssh -n $host 'echo "export $env" >> /etc/bash.bashrc'
    done
done < $1

LOG_DIR=${HADOOP_LOG_DIR:-$HADOOP_HOME/logs}
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
  ssh-keyscan -H $host >> /root/.ssh/known_hosts

  ssh -n $host "useradd hdfs"
  ssh -n $host "useradd yarn"
  ssh -n $host "useradd mapred"
  ssh -n $host "usermod -a -G hadoop hdfs"
  ssh -n $host "usermod -a -G hadoop yarn"
  ssh -n $host "usermod -a -G hadoop mapred"
done < $1
