# Launching Hadoop Applications Using Docker Containers

## Docker post-installation steps

1. [Manage Docker as non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

2. [Configure Docker to start on boot](https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot)

## [Launching Applications Using Docker Containers](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/DockerContainers.html)

- Copy `conf/container-executor.cfg` to `/usr/hdp/current/hadoop-client/conf/container-executor.cfg` on all workers
- Copy `conf/yarn-site.xml` to `/usr/hdp/current/hadoop-client/conf/yarn-site.xml` on all workers

## Build docker image from source

```bash
cd rbaseline-docker
docker build -t local/rbaseline-docker:latest .
```

## Test Docker locally

```bash
cat data/30952 | docker run -i local/rbaseline-docker:latest Rscript R/mapper.R
```

## Save docker image and copy to hdfs

```bash
docker save -o rbaseline-docker.tar local/rbaseline-docker:latest
hdfs dfs -rm /tmp/rbaseline-docker.tar
hdfs dfs -copyFromLocal rbaseline-docker.tar /tmp/rbaseline-docker.tar
```

## Load image on all workers

```bash
ssh ubuntu@worker1.odin.tech.beegroup-cimne.com
hdfs dfs -copyToLocal /tmp/rbaseline-docker.tar rbaseline-docker.tar
docker load -i rbaseline-docker.tar
```

## Login to kerberos

```bash
kinit
```

## Launch docker on YARN

- `yarn.sh`
- `yarn_jar.sh`
- `yarn_mapred_streaming.sh`
