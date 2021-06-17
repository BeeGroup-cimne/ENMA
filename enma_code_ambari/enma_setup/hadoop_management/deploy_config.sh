while read p
  do
    host=`echo $p|cut -d" " -f1`
    name=`echo $p|cut -d" " -f2`
    while read app
      do
        conf=`echo $app|cut -d" " -f2`
        scp -r hadoop_stack/$conf/* $host:hadoop_stack/$conf/
      done < hdp_version
  done < $1
