#! /bin/bash
HBASE_ENV=/hadoop_stack/hbase-2.4.4/conf/hbase-env.sh

. $HBASE_ENV

ENV_TO_SET=(HBASE_HOME=$HBASE_HOME
            PATH=$PATH:$HBASE_HOME/bin)

while read p
do
  host=`echo $p|cut -d" " -f1`
  scp -r $HBASE_HOME $host:$HBASE_HOME
done < <(tail -n +2 $1)

while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "chown -R root:hadoop $HBASE_HOME"

  for env in ${ENV_TO_SET[@]}
    do
      ssh -n $host "echo export $env >> /etc/bash.bashrc"
    done
done < $1

LOG_DIR=${HBASE_LOG_DIR:-$HBASE_HOME/logs}
while read p
do
  host=`echo $p|cut -d" " -f1`
  ssh -n $host "mkdir -p $LOG_DIR"
  ssh -n $host "chown -R root:hadoop $LOG_DIR"
  ssh -n $host "chmod -R 775 $LOG_DIR"
done < $1

while read p
do
  scp -r hadoop_stack_installation/hbase_deploy_scripts $p:hbase_install_scripts
  ssh -n $p "bash hbase_install_scripts/create_master_huser.sh"
  SSH_KEY=`ssh -n $p "cat /home/hbase/.ssh/id_rsa.pub"`
done < $HBASE_HOME/conf/hmaster

while read p
do
  host=`echo $p|cut -d" " -f2`
  scp -r hadoop_stack_installation/hbase_deploy_scripts $host:hbase_install_scripts
  ssh -n $host "bash hbase_install_scripts/create_slave_huser.sh $SSH_KEY"

done < $1

while read p
do
  ssh -n $p "bash hbase_install_scripts/master_accept_connections.sh"
done < $HBASE_HOME/conf/hmaster