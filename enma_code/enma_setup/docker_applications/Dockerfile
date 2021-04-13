FROM rocker/r-base:3.6.3

RUN mkdir -p /usr/jdk64
WORKDIR /usr/jdk64
RUN wget http://public-repo-1.hortonworks.com/ARTIFACTS/jdk-8u112-linux-x64.tar.gz
RUN gunzip jdk-8u112-linux-x64.tar.gz
RUN tar -xf jdk-8u112-linux-x64.tar

RUN update-alternatives --install /usr/bin/java java /usr/jdk64/jdk1.8.0_112/bin/java 1
RUN ln -s -f /usr/jdk64/jdk1.8.0_112/bin/java /usr/bin/java

ENV HADOOP_HOME /usr/hdp/current
ENV JAVA_HOME=/usr/jdk64/jdk1.8.0_112

RUN Rscript -e 'install.packages("dplyr", repos = "https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("readr", repos = "https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("lubridate", repos = "https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("data.table", repos = "https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("stringr", repos = "https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("remotes", repos = "https://cloud.r-project.org")'

RUN Rscript -e 'library(remotes); remotes::install_github("beedata-analytics/rbaseline", auth_token = "8dc1e5504a6f1af871cf1067a3272a882192085b")'

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
    apt-get -yqq install krb5-user libpam-krb5 && \
    apt-get -yqq clean

COPY . /app
WORKDIR /app
