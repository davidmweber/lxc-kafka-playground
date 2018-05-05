#!/bin/bash

if (( $# == 0 ))
then
  echo "Usage $0 <container-name>"
  exit -1
fi

if ((  $(lxc list | grep $1 | wc -l) == 1  ))
then
  echo "A container called $1 already exists. Exiting now."
  exit -1
fi
#
# This script assumes that there is no container called kafka-streams
lxc launch ubuntu:16.04 $1

echo "Waiting for the container network to come up"
sleep 15

# Copy and run the installation script over to the container
lxc file push --uid=0 --gid=0 --mode=744 install.sh $1/root/install.sh
lxc exec $1 /root/install.sh

# Configure elastic ElasticSearch
lxc file push --uid=0 --gid=0 --mode=644 configs/elasticsearch.yml $1/etc/elasticsearch/elasticsearch.yml
lxc exec $1 systemctl restart elasticsearch

# Configure cassandra so it will be accessible outside the container
lxc file push --uid=0 --gid=0 --mode=644 configs/cassandra.yaml $1/etc/cassandra/cassandra.yaml
lxc exec $1 systemctl restart cassandra

# Configure confluent tools
lxc file push --uid=0 --gid=0 --mode=644 configs/ksql-server.properties $1/etc/ksql/ksql-server.properties

# Copy the systemd control scripts over to the container and enable the confluent services
cd configs/systemd
find ./ -name "*.service" -exec lxc file push --uid=0 --gid=0 --mode=644 {} $1/lib/systemd/system/ \;
lxc exec $1 systemctl enable `ls -1 *.service`
lxc exec $1 systemctl start `ls -1 *.service`
cd -
