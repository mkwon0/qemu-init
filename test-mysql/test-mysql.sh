#!/bin/bash

NUM_THREAD=4

#### MySQL Parameters
IO_TYPE=oltp_read_only
OPTIONS="--threads=1 --events=100000 --time=0 \
		--table-size=1000000 --db-driver=mysql \
		--mysql-host=0.0.0.0 \
		--mysql-user=root --mysql-password=root \
		--mysql-ignore-errors="all" \
		--histogram"

#### SYSBENCH Parameters
SYSBENCH=/home/mkwon/perf/sysbench-master/bin/sysbench

pid_waits() {
	PIDS=("${!1}")
	for pid in "${PIDS[*]}"; do
		wait $pid
	done
}

docker_remove() {
	echo "$(tput setaf 4 bold)$(tput setab 7)Start removing existing docker$(tput sgr 0)"
	docker ps -aq | xargs --no-run-if-empty docker stop
	docker ps -aq | xargs --no-run-if-empty docker rm
}

docker_healthy() {
	while [ "$(docker ps -a | grep -c starting)" = 1 ]; do
		sleep 0.1;
	done
}

docker_mysql_gen() {
	echo "$(tput setaf 4 bold)$(tput setab 7)Generate mysql containers$(tput sgr 0)"
	for CONT_ID in $(seq 1 ${NUM_THREAD}); do
		HOST_PORT=$((3306+${CONT_ID}))
		docker run --name=mysql${CONT_ID} \
			--oom-kill-disable=true \
			--memory="100m" --memory-swap="150m" \
			-e MYSQL_ROOT_PASSWORD=root -e MYSQL_ROOT_HOST=% \
			-p $HOST_PORT:3306 -d mysql/mysql-server:8.0
		DID=$(docker inspect mysql${CONT_ID} --format {{.Id}})
		echo /root/swapfile${CONT_ID} > /sys/fs/cgroup/memory/docker/$DID/memory.swapfile
		cat /sys/fs/cgroup/memory/docker/$DID/memory.swapfile
	done
	sleep 5
	docker_healthy
	sleep 5
}

docker_db_gen() {	
	echo "$(tput setaf 4 bold)$(tput setab 7)Create database$(tput sgr 0)"
	for CONT_ID in $(seq 1 ${NUM_THREAD}); do
		HOST_PORT=$((3306+${CONT_ID}))
		docker exec mysql${CONT_ID} mysql -uroot -p'root' \
		-e "ALTER USER root IDENTIFIED WITH mysql_native_password BY 'root';create database sbtest${CONT_ID};"
	done
}

mysql_prepare() {
	PREPARE_PIDS=()
	for CONT_ID in $(seq 1 ${NUM_THREAD}); do
		HOST_PORT=$((3305+${CONT_ID}))
		$SYSBENCH $IO_TYPE $OPTIONS \
			--mysql-port=$HOST_PORT \
			--mysql-db=sbtest${CONT_ID} \
			prepare & PREPARE_PIDS+=("$!")		
	done
	pid_waits PREPARE_PIDS[@]
}

main() {
	docker_remove
	docker_mysql_gen
	#docker_db_gen

	#### MySQL Prepare
	#mysql_prepare
}

main
