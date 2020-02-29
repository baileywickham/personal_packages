FROM ubuntu

# Create user to simulate non root
RUN useradd -ms /bin/bash user
RUN mkdir /etc/sudoers.d/
RUN echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user
COPY . /home/user
WORKDIR /home/user

# Install packages req
RUN apt-get update -qq > /dev/null
RUN apt-get install -qq \
    build-essential \
    gcc \
    curl \
    git \
    sudo > /dev/null

USER user
ENV DEBIAN_FRONTEND=noninteractive
#ENTRYPOINT ./personal_packages.sh -a

#COPY /etc/apt/sources.list /etc/apt/sources.list


