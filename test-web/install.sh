#!/bin/bash

WORK_DIR=/home/mkwon

install_pre() {
	yum install -y git
	cd $WORK_DIR && git clone https://github.com/nanoninja/docker-nginx-php-mysql.git
}

configure_ssl() {
	cd $WORK_DIR/docker-nginx-php-mysql && \
	source .env && \
	docker run --rm -v $(pwd)/etc/ssl:/certificates -e "SERVER=$NGINX_HOST" jacoelho/generate-certificate && \
	sed -i '24,48 s/^#//' etc/nginx/default.template.conf
		
}

install_docker_compose() {
	cd $WORK_DIR && \
	git clone git@github.com:mkwon0/docker-compose-swap.git && \
	cd docker-compose-swap && \
	./init.sh && \
	cp web/app/composer.json.dist web/app/composer.json	
}

run_application() {
	cd $WORK_DIR/docker-nginx-php-mysql && \
	docker-compose up -d && \
	docker-compose logs -f
}

main() {
#	install_pre
#	configure_ssl
#	install_docker_compose
	run_application
}

main
