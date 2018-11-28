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
lxc launch ubuntu:18.04 $1

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

lxc file push --uid=0 --gid=0 --mode=644 configs/ksql-server.properties $1/etc/ksql/ksql-server.properties
lxc exec $1 systemctl restart confluent-ksql

lxc file push --uid=0 --gid=0 --mode=644 configs/schema-registry.properties $1/etc/schema-registry/schema-registry.properties
lxc exec $1 systemctl restart confluent-schema-registry


# Grab the landoop connectors for Cassandra and ElasticSearch
#lxc exec kafka-streams -- /bin/bash -c "cd /usr/share/java && curl -sL https://github.com/Landoop/stream-reactor/releases/download/1.0.0/kafka-connect-cassandra-1.0.0-1.0.0-all.tar.gz | tar xzf -"

