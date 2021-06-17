#! /bin/bash
HADOOP_STACK_DIR=/hadoop_stack
APP_DEPLOY=$HADOOP_STACK_DIR/hadoop-3.3.1

ENV_TO_SET=(JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
            HADOOP_HOME=$APP_DEPLOY
            PATH=$PATH:$APP_DEPLOY/bin)

while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "mkdir -p $HADOOP_STACK_DIR"
  scp -r $APP_DEPLOY $host:$HADOOP_STACK_DIR
done < <(tail -n +2 $1)

while read p
do
  ssh -n $host "chown -R root:hadoop /hadoop_stack"
  for env in ${ENV_TO_SET[@]}
    do
      echo "export $env" >> /etc/bash.bashrc
    done
done < $1