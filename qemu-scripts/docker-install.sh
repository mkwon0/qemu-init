#!/bin/bash

NUM_CPU=16

#### Install golang
cur_path=`pwd`

modify_profile() {
    echo "export GOROOT=/usr/local/go" >> /etc/profile
    echo "export GOPATH=/home/mygo" >> /etc/profile
    echo "export PATH=\$PATH:\$GOROOT/bin" >> /etc/profile
}

install_golang() {
    sudo yum install wget -y
    wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz \
    && sudo tar xf ${cur_path}/go1.12.6.linux-amd64.tar.gz -C /usr/local \
    && rm -rf ${cur_path}/go1.12.6.linux-amd64.tar.gz

    sudo mkdir -p /home/mygo \
    && sudo chown -R mkwon:mkwon /home/mygo

    source /etc/profile
    sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    go get -u github.com/kardianos/govendor
    sudo cp ${GOPATH}/bin/govendor /usr/local/go/bin/

    #### Check installed golang
    go version
    ls /home/mygo/ /home/mygo/src/ /home/mygo/src/github.com/ /usr/local/go/bin/
}

#### NOTE
#### This is just for custom docker compile and build 
install_docker() {
    #### Docker install
    sudo yum install -y gcc make cmake device-mapper-devel \
        btrfs-progs-devel libarchive libseccomp-devel glibc-static
    
    ### Install centos7 docker-ce
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install docker-ce -y
    sudo systemctl start docker
    
    ## docker test
    sudo groupadd docker
    sudo usermod -aG docker $USER

    echo "$(tput setaf 4 bold)$(tput setab 7)WARNING!!!!!!!!!!!!!!!!!!$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)Plz restart shell$(tput sgr 0)"
}

#### NOTE
#### Compile and build the custom docker-ce which supports swapfile
install_docker_ce() {
    source /etc/profile
    cd $GOPATH/src/github.com/ \
    && mkdir -p docker && cd docker \
    && git clone https://github.com/mkwon0/docker-ce-swap.git \
    && cd docker-ce-swap \
    && make static DOCKER_BUILD_PKGS=static-linux -j$NUM_CPU -s \
    && sudo cp components/packaging/static/build/linux/docker/* /usr/local/bin/
}

file_gen() {
cat > docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/local/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

cat > docker.socket <<EOF
[Unit]
Description=Docker Socket for the API
PartOf=docker.service

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

cat > containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/usr/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
KillMode=process
Delegate=yes
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
}

restart_service() {
    file_gen
    sudo mv docker.service /etc/systemd/system/
    sudo mv docker.socket /etc/systemd/system/
    sudo mv containerd.service /etc/systemd/system/
    sudo systemctl stop docker
    sudo systemctl stop containerd
    sudo systemctl disable docker
    sudo systemctl disable containerd
    sudo systemctl daemon-reload
    sudo systemctl start docker
    sudo systemctl start containerd
    sudo systemctl enable docker
    sudo systemctl enable containerd
    sudo systemctl status docker
    sudo systemctl status containerd
}

disable_selinux() {
    sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
    sudo sestatus

    
    echo ""
    echo "$(tput setaf 4 bold)$(tput setab 7)Finished with script execution!$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)In the above output, you'll see that the value of 'SELinux status' is 'enabled'.$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)That is normal. Do the following two steps:$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)1. reboot your environment:$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)sudo shutdown -r now$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)2. When you server comes back online, run this command:$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)sudo sestatus$(tput sgr 0)"
    echo "$(tput setaf 4 bold)$(tput setab 7)You should then see 'SELinux status: disabled' to confirm that SELinux is in fact disabled$(tput sgr 0)"

    docker run --rm hello-world
}

install_docker_compose() {
    cd $GOPATH/src/github.com/docker \
    && git clone https://github.com/mkwon0/docker-compose-swap.git \
    && cd docker-compose-swap/ \
    && sudo ./init.sh
}

main() {
    ##### Execute as root
    modify_profile

    ##### Execute as normal user
#    install_golang
#    install_docker
#    install_docker_ce
#    disable_selinux
#    restart_service
#    install_docker_compose
}

main
