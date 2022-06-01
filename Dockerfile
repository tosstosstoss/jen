FROM ubuntu:latest
RUN apk add bash

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt update
RUN apt install python3.9 -y
RUN python3.9 --version
RUN useradd -g 0 jenkins
RUN cat /etc/passwd | grep jenkins