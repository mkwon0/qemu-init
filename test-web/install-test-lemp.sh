#!/bin/bash

WORK_DIR=/home/mkwon/docker-lemp/devel
mkdir -p /home/mkwon/docker-lemp
mkdir -p $WORK_DIR

pre_install() {
    sudo yum install -y mysql-devel libcurl-devel json-c-devel
}

git_install() {
    cd $WORK_DIR \
    && git clone https://camel.kaist.ac.kr/kukdh1/tpcc-mysql.git \
    && git clone https://camel.kaist.ac.kr/docker-ce/bench-lemp-shared.git \
    && cd tpcc-mysql/src \
    && make
}

main() {
    pre_install
    git_install 
}

main
 
