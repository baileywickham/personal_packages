FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Create user to simulate non root
RUN useradd -ms /bin/bash user
RUN mkdir /etc/sudoers.d/
RUN echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

RUN apt-get update -qqq > /dev/null && apt-get install -y -qqq \
    build-essential \
    gcc \
    curl \
    git \
    sudo

FROM build AS final
COPY . /home/user
WORKDIR /home/user
RUN chown -R user /home/user

USER user

#ENTRYPOINT ./personal_packages.sh -a
