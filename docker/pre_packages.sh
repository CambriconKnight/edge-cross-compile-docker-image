#!/bin/bash
#
echo -e 'nameserver 114.114.114.114' > /etc/resolv.conf
cp sources_16.04.list /etc/apt/sources.list
#add-apt-repository ppa:jonathonf/python-3.7
DEBIAN_FRONTEND=noninteractive
rm -rf /var/lib/apt/lists/* \
    && mkdir /var/lib/apt/lists/partial \
    && apt-get clean \
    && apt-get update --fix-missing \
    && apt-get upgrade -y \
    && apt-get install --assume-yes \
    && apt-get install -y --no-install-recommends \
            curl git wget vim build-essential cmake make apt-utils \
            libopencv-dev libcurl4-openssl-dev \
            libgoogle-glog-dev \
            openssh-server \
            libsdl2-dev  \
            lcov dos2unix file \
            ca-certificates \
            device-tree-compiler \
            python3.5 libssl-dev libncurses5-dev bc tree \
            minicom tftpd-hpa nfs-kernel-server nfs-common \
            net-tools \
    && apt-get clean \
    && apt-get update --fix-missing \
    && rm -rf /var/lib/apt/lists/* \
    && echo -e "\033[0;32m[apt install... Done] \033[0m"
echo '# /etc/default/tftpd-hpa' > /etc/default/tftpd-hpa \
    && echo 'TFTP_USERNAME="tftp"' >> /etc/default/tftpd-hpa \
    && echo 'TFTP_DIRECTORY="/data/tftp"' >> /etc/default/tftpd-hpa \
    && echo 'TFTP_ADDRESS="0.0.0.0:69"' >> /etc/default/tftpd-hpa \
    && echo 'TFTP_OPTIONS="-l -c -s"' >> /etc/default/tftpd-hpa \
    && echo '/data/nfs *(rw,sync,no_root_squash)' >> /etc/exports \
    && echo -e "\033[0;32m[tftp configure... Done] \033[0m"
