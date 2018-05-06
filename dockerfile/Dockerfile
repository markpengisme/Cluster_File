
FROM ubuntu
MAINTAINER Mark Peng

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install vim git software-properties-common wget  -y
ADD run.sh /run.sh
RUN chmod 755 /run.sh
RUN ["/bin/bash","-c","./run.sh"]
