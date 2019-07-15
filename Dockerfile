FROM ubuntu
WORKDIR /home/y
COPY ./testing /testing
COPY . /home/y
RUN apt-get update -qq
RUN apt-get install -qq \
    build-essential \
    gcc \
    curl \
    sudo \ 
    git
#COPY /etc/apt/sources.list /etc/apt/sources.list


