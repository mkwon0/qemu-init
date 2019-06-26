#!/bin/bash

NUM_CPU=16

##### Install golang
#cur_path=`pwd`

#sudo yum install wget git -y
#wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
#sudo tar xf ${cur_path}/go1.12.6.linux-amd64.tar.gz -C /usr/local
#rm -rf ${cur_path}/go1.12.6.linux-amd64.tar.gz

#sudo mkdir -p /home/mygo
#sudo chown -R mkwon:mkwon /home/mygo

#sudo echo "export GOROOT=/usr/local/go" >> /etc/profile
#sudo echo "export GOPATH=/home/mygo" >> /etc/profile
#sudo echo "export PATH=\$PATH:\$GOROOT/bin" >> /etc/profile
#source /etc/profile

#sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#go get -u github.com/kardianos/govendor
#cp ${GOPATH}/bin/govendor /usr/local/go/bin/

##### Check installed golang
#go version
#ls /home/mygo/ /home/mygo/src/ /home/mygo/src/github.com/ /usr/local/go/bin/

##### Docker install
#sudo yum install -y gcc make cmake device-mapper-devel \
#    btrfs-progs-devel libarchive libseccomp-devel glibc-static

#### Install docker client & server
#cd $GOPATH/src/github.com/
#mkdir docker && cd docker
#
#git clone git@github.com:mkwon0/docker-swap.git
#cp -R docker-swap docker && rm -rf docker-swap
#
#cd $GOPATH/src/github.com/docker/docker/cmd/docker
#go build && sudo cp docker /usr/local/bin
#
#cd $GOPATH/src/github.com/docker/docker/cmd/dockerd
#go build && sudo cp dockerd /usr/local/bin

#### Install docker containerd
git clone git@github.com:mkwon0/docker-containerd-swap.git "${GOPATH}/src/github.com/docker/containerd"
cd "${GOPATH}/src/github.com/docker/containerd"

make static -j${NUM_CPU} -s
sudo cp bin/containerd /usr/local/bin/docker-containerd
sudo cp bin/containerd-shim /usr/local/bin/docker-containerd-shim
sudo cp bin/ctr /usr/local/bin/docker-containerd-ctr
