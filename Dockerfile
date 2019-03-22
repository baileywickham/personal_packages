FROM ubuntu
WORKDIR /home/y
COPY ./testing /testing
COPY . /home/y
RUN apt update
RUN apt install -y \
    build-essential \
    gcc
#COPY /etc/apt/sources.list /etc/apt/sources.list


