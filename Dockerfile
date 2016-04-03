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
RUN /root/rpi-docker-builder/build.sh
RUN /root/rpi-docker-builder/run-builder.sh
RUN dpkg -i /root/rpi-docker-builder/dist/docker-hypriot_1.10.3-1_armhf.deb

ENTRYPOINT ["bash"]
