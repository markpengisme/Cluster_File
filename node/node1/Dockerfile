FROM ubuntu:16.04
MAINTAINER Mark Peng

RUN set -x \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install vim git software-properties-common wget  -y 
ADD run.sh /run.sh
RUN ["/bin/bash","-c","./run.sh"] 
RUN git clone https://github.com/markpengisme/Cluster_File.git \
	&& cp -r Cluster_File/7nodes/node1 /home/node1 \
	&& rm -rf Cluster_File/ \
	&& rm ./run.sh
