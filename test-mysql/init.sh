#!/bin/bash

SYSBENCH_HOME=/home/mkwon/perf

#### Install mysql
yum install wget -y
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
rm -f *.rpm
yum install mysql-server -y
systemctl start mysqld

#### Install sysbench
yum install libtool mysql-devel automake lua -y
wget https://github.com/akopytov/sysbench/archive/master.zip
unzip master.zip && rm -f master.zip
my sysbench-master $SYSBENCH_HOME
cd $SYSBENCH_HOME/sysbench-master

./autogen.sh
./configure --prefix=$SYSBENCH_HOME/sysbench-master \
	--with-mysql-includes=/usr/include/mysql \
	--with-mysql-libs=/usr/lib64/mysql
make -j16 -s
make install -j16 -s
./bin/sysbench --version
