#! /bin/bash
CONF_DIRS=(/hadoop_stack/hadoop-3.3.1/etc/hadoop /hadoop_stack/hbase-2.4.4/conf /hadoop_stack/hive-3.1.2/conf)

while read p
do
  host=`echo $p|cut -d" " -f1`
  for conf in ${CONF_DIRS[@]}
  do
    ssh -n $host "rm -r $conf"
    scp -r conf $host:$conf
  done
done < <(tail -n +2 $1)