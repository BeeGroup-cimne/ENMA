FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk python3 python3-pip python-tk python-dev git-all



ADD passwd /etc/passwd
RUN mkdir /home/ubuntu
RUN chown -R ubuntu /home/ubuntu
WORkDIR /home/ubuntu
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY wordcount.py .
COPY task.sh .
RUN chmod +x task.sh
RUN chmod +x wordcount.py
USER ubuntu
ENTRYPOINT ["./task.sh"]
