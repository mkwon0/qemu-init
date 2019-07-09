#!/bin/bash

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
systemctl disable docker
systemctl stop docker
rm -rf /var/lib/docker*
rm -rf /var/run/docker*
