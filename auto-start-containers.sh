#!/bin/bash
while [ ! -f /var/run/docker.pid ]
do
  sleep 2
done
echo "docker started"
CONTAINERS=/root/containers_ids/*
for c in $CONTAINERS
do
 docker -H tcp://127.0.0.1:4243 start `cat $c`
done
