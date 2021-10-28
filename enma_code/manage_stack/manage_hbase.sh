#! /bin/bash

case $1 in
start)
  while read p
  do
    ssh -n $p "su hbase -c '$HBASE_HOME/bin/start-hbase.sh'"
    ssh -n $p "su hbase -c '$HBASE_HOME/bin/hbase-daemon.sh start thrift --bind 0.0.0.0"
  done < $HBASE_HOME/conf/hmaster
;;
stop)
  while read p
  do
    ssh -n $p "su hbase -c '$HBASE_HOME/bin/hbase-daemon.sh stop thrift'"
    ssh -n $p "su hbase -c '$HBASE_HOME/bin/stop-hbase.sh'"
  done < $HBASE_HOME/conf/hmaster
;;
restart)
  bash $0 stop
  bash $0 start
;;
*)
   echo "you should use start, stop or restart"
;;
esac
