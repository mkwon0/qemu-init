#!/bin/bash

NUM_CPU=16

##### Install golang
#cur_path=`pwd`
#
#sudo yum install wget git -y
#wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
#sudo tar xf ${cur_path}/go1.12.6.linux-amd64.tar.gz -C /usr/local
#rm -rf ${cur_path}/go1.12.6.linux-amd64.tar.gz
#
#sudo mkdir -p /home/mygo
#sudo chown -R mkwon:mkwon /home/mygo
#
#echo "export GOROOT=/usr/local/go" >> /etc/profile
#echo "export GOPATH=/home/mygo" >> /etc/profile
#echo "export PATH=\$PATH:\$GOROOT/bin" >> /etc/profile
#source /etc/profile
#
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
#git clone git@github.com:mkwon0/docker-containerd-swap.git "${GOPATH}/src/github.com/docker/containerd"
#cd "${GOPATH}/src/github.com/docker/containerd"
#
#make static -j${NUM_CPU} -s
#sudo cp bin/containerd /usr/local/bin/docker-containerd
#sudo cp bin/containerd-shim /usr/local/bin/docker-containerd-shim
#sudo cp bin/ctr /usr/local/bin/docker-containerd-ctr


#### Install docker-runc
#cd $GOPATH/src/github.com/
#mkdir opencontainers && cd opencontainers
#git clone git@github.com:mkwon0/docker-runc-swap.git "${GOPATH}/src/github.com/opencontainers/runc"
#cd  ${GOPATH}/src/github.com/opencontainers/runc
#make BUILDTAGS="${RUNC_BUILDTAGS:-"selinux"}" static -j${NUM_CPU} -s
#sudo cp runc /usr/local/bin/docker-runc


#### Install docker-init
#cd $GOPATH/src/github.com/
#mkdir krallin && cd krallin
#git clone https://github.com/krallin/tini.git "$GOPATH/tini"
#cd "$GOPATH/tini"
#git checkout -q 949e6facb77383876aeff8a6944dde66b3089574
#cmake .
#make tini-static -j${NUM_CPU} -s
#sudo cp tini-static /usr/local/bin/docker-init


#### Install docker-proxy
#cd $GOPATH/src/github.com/docker
#git clone git@github.com:mkwon0/docker-proxy-swap.git "$GOPATH/src/github.com/docker/libnetwork"
#cd "$GOPATH/src/github.com/docker/libnetwork"
#go build -ldflags="$PROXY_LDFLAGS" -o /usr/local/bin/docker-proxy github.com/docker/libnetwork/cmd/proxy

#### docker test
#sudo groupadd docker
#sudo usermod -aG docker $USER

#cd /usr/local/bin && sudo dockerd &
#ps aux | grep docker
#docker version
#docker pull busybox
#docker run -idt --memory-swapfile "none" busybox
#docker ps -a


#### Docker service
cat > docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/flannel/docker
ExecStart=/usr/local/bin/dockerd --log-level=error $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

sudo cp docker.service /etc/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker


