FROM hypriot/rpi-node:latest
MAINTAINER Ryan Barry <azaeres@gmail.com>

WORKDIR /root

RUN apt-get update && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

RUN git clone https://github.com/ryancbarry/composure.git
RUN git clone https://github.com/jpetazzo/dind.git

RUN git clone https://github.com/hypriot/rpi-docker-builder.git
RUN ./rpi-docker-builder/build.sh
RUN ./rpi-docker-builder/run-builder.sh

ENTRYPOINT ["bash"]
