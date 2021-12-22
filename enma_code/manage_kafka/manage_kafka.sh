#! /bin/bash
export KAFKA_HOME=/kafka_2.13-3.0.0
case $1 in
start)
        $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /dev/null 2>&1 &
        $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /dev/null 2>&1 &
        ;;
stop)
        pkill -f org.apache.zookeeper.server.quorum.QuorumPeerMain
        pkill -f kafka.Kafka
        ;;
esac