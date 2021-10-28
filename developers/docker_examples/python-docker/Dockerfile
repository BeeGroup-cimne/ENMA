FROM python:3.7

RUN mkdir -p /usr/jdk64
RUN wget http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-8u112-linux-x64.tar.gz -P /usr/jdk64/
RUN tar -zxvf /usr/jdk64/jdk-8u112-linux-x64.tar.gz -C /usr/jdk64

RUN update-alternatives --install /usr/bin/java java /usr/jdk64/jdk1.8.0_112/bin/java 1
RUN ln -s -f /usr/jdk64/jdk1.8.0_112/bin/java /usr/bin/java

ENV HADOOP_HOME=/hadoop_stack/hadoop-3.3.0
ENV JAVA_HOME=/usr/jdk64/jdk1.8.0_112
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV HADOOP_INSTALL=$HADOOP_HOME

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update 
RUN apt-get -y install python-tk python3-dev python-dev

ADD passwd /etc/passwd
RUN mkdir -p /home/ubuntu
RUN chown -R ubuntu /home/ubuntu
WORkDIR /home/ubuntu
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
USER ubuntu
CMD [ "python"]
