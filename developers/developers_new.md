# ENMA - Documentation for developers

[Return home](../README.md)

## General information

This `Documentation for developers` section is made exclusively for developers who needs to adapt or create a new modules in the platform.

### 1. Docker imgages
Docker is used as the main feature to keep the modules isolated one from the other.
This allows the developers to work with a specific language, library versions, and packeges, without the need to install the software into the platform itself.

There are two different ways how the docker are used, and the developers may need to create differen images depending on wich one they are currently using.

1. **Docker container for Hadoop process:**

> In this method, Docker is used as a container to run the specific hadoop process (map-reduce or spark).
This containers are managed by the hadoop aplication itself and controlled by the container-executor.
> 
> 
2. **Docker container for Job:**

> In this method, Docker is used as the whole analytics controller, the docker will be runned by passing the parameters 
> to the docker the module itself can make use or not of the hadoop cluster.
> 
> This module container will be launched as a job in kubernetes.
 
### Create a docker for Hadoop process
For this process, the docker 
### Create the docker for the job
For this process, the docker "enma" must be used as the base docker. Install your dependencies and set your scripts to be executed into the docker.
### Create the Kubernetes Job or CronJob

### Run the container in enma

### Configure your computer to access the ENMA architecture

###
build docker
docker build -t local/python .
export docker as tar-gz

docker save local/python | gzip > python.tar.gz

send the docker and load it in all worker nodes
docker load < python.tar.gz

build docker module

docker build -t wordcount .

run docker

docker run -v /hadoop_stack:/hadoop_stack -v /var:/var --network=host -e HADOOP_HOME=$HADOOP_HOME -e PATH=$PATH --add-host=master1.internal:10.0.88.76  --add-host=master2.internal:10.0.87.95 --add-host=worker1.internal:10.0.88.132 --add-host=worker2.internal:10.0.86.33 --add-host=worker3.internal:10.0.87.145 --add-host=worker4.internal:10.0.86.214 wordcount