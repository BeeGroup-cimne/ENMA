#!bin/bash

INPUT=/tmp/rbaseline/measures
OUTPUT=/tmp/rbaseline/baseline

HADOOP_HOME=/usr/hdp/current
HADOOP_STREAMING=$HADOOP_HOME/hadoop-mapreduce-client/hadoop-streaming.jar
MOUNTS="$HADOOP_HOME:$HADOOP_HOME:ro,/usr/jdk64:/usr/jdk64:ro,/etc/passwd:/etc/passwd:ro,/etc/group:/etc/group:ro,/etc:/etc:ro"
IMAGE_ID="local/rbaseline-docker"

export YARN_CONTAINER_RUNTIME_TYPE=docker
export YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$IMAGE_ID
export YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=$MOUNTS
export YARN_CONTAINER_RUNTIME_DOCKER_RUN_PRIVILEGED_CONTAINER=true
export YARN_CONTAINER_RUNTIME_DOCKER_RUN_OVERRIDE_DISABLE=true
export KRB5_CONFIG=/etc/krb5.conf

vars="YARN_CONTAINER_RUNTIME_TYPE=docker"
vars="$vars,YARN_CONTAINER_RUNTIME_DOCKER_IMAGE=$IMAGE_ID"
vars="$vars,YARN_CONTAINER_RUNTIME_DOCKER_MOUNTS=$MOUNTS"

hdfs dfs -rm -r $OUTPUT

mapred streaming \
	-Dyarn.app.mapreduce.am.env=$vars \
	-Dmapreduce.map.env=$vars \
	-Dmapred.map.max.attempts=1 \
	-Dmapreduce.reduce.env=$vars \
	-Djava.security.krb5.conf=$KRB5_CONFIG \
	-mapper "Rscript /app/R/mapper.R" \
	-input $INPUT \
	-output $OUTPUT
