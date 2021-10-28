#! /bin/bash

case $1 in
start)
  while read p
  do
    ssh -n $p "su hive -c '$HIVE_HOME/bin/hive --service hiveserver2 > /dev/null 2>&1'" &
  done < $HIVE_HOME/conf/master
;;
stop)
  while read p
  do
    hive2_pid=`ssh -n $p "pgrep -f org.apache.hive.service.server.HiveServer2"`
    if [[ -n "$hive2_pid" ]]
    then
      for pid in $hive2_pid
      do
        ssh -n $p "kill -9 $pid"
      done
    fi
  done < $HIVE_HOME/conf/master
;;
restart)
  bash $0 stop
  bash $0 start
;;
*)
  echo "you should use start, stop or restart"
;;
esac