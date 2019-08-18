FROM ubuntu

RUN useradd -ms /bin/bash testing
COPY . /home/testing
WORKDIR /home/testing

RUN echo -e "testing\ntesting" | passwd testing

RUN apt-get update -qq > /dev/null
RUN apt-get install -qq \
    build-essential \
    gcc \
    curl \
    git \
    sudo > /dev/null

USER testing

#COPY /etc/apt/sources.list /etc/apt/sources.list


