#!/bin/bash

## Init packages
#sudo yum install screen -y
#sudo yum groupinstall "Development Tools" -y
#sudo yum install ncurses-devel bison bc flex eltutils-libelf-devel openssl-devel -y
#sudo yum install git -y 

## Install docker-ce
#sudo yum install yum-utils device-mapper-persistent-data lvm2 -y
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install docker-ce -y
#sudo yum-config-manager --enable docker-ce-edge
#sudo yum-config-manager --enable docker-ce-test

#sudo usermod -aG docker mkwon
#sudo systemctl enable docker
#sudo systemctl start docker

## Clone linux-5.0.7-swap
#git clone git@github.com:mkwon0/linux-5.0.7-swap.git

## Clone util-linux-swap
git clone git@github.com:mkwon0/util-linux-swap.git
cd util-linux-swap
./autogen.sh
./configure --disable-libuuid --prefix=/usr/bin
sudo make -j16 -s
sudo cp swapon swapoff /sbin/
