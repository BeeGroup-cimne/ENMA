#! /bin/bash
CONF_DIR=${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}
case $1 in
start)
  while read p
  do
    user=`echo $p|cut -d" " -f1`
    binary=`echo $p|cut -d" " -f2`
    service=`echo $p|cut -d" " -f3`
    node=`echo $p|cut -d" " -f4`
    ssh -n $node "su $user -c '$HADOOP_HOME/$binary --daemon $1 $service'"

  done < $CONF_DIR/masters

  while read p
  do
    ssh -n $p "su hdfs -c '$HADOOP_HOME/bin/hdfs --daemon $1 datanode'"
    ssh -n $p "su yarn -c '$HADOOP_HOME/bin/yarn --daemon $1 nodemanager'"
    ssh -n $p "su mapred -c '$HADOOP_HOME/bin/mapred --daemon $1 historyserver'"
  done < $CONF_DIR/workers
;;
stop)
  while read p
  do
    ssh -n $p "su hdfs -c '$HADOOP_HOME/bin/hdfs --daemon $1 datanode'"
    ssh -n $p "su yarn -c '$HADOOP_HOME/bin/yarn --daemon $1 nodemanager'"
    ssh -n $p "su mapred -c '$HADOOP_HOME/bin/mapred --daemon $1 historyserver'"
  done < $CONF_DIR/workers
  while read p
  do
    user=`echo $p|cut -d" " -f1`
    binary=`echo $p|cut -d" " -f2`
    service=`echo $p|cut -d" " -f3`
    node=`echo $p|cut -d" " -f4`
    ssh -n $node "su $user -c '$HADOOP_HOME/$binary --daemon $1 $service'"

  done < $CONF_DIR/masters
;;
restart)
  bash $0 stop
  bash $0 start
;;
*)
  echo "you should use start, stop or restart"
;;
esac