FROM ubuntu
WORKDIR /home/y
COPY ./testing /testing
COPY . /home/y
RUN apt-get update -qq
RUN apt-get  install -y -qq \
    build-essential \
    gcc \
    curl \
    git
#COPY /etc/apt/sources.list /etc/apt/sources.list


