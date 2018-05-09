#!/bin/bash

if (( $# == 0 )); then
  echo "Usage $0 <container-name>"
  exit -1
fi

if ((  $(lxc list | grep $1 | wc -l) ==  0 )); then
  echo "The container $1 does not exist"
  exit -1
fi

# You should be able to resolve the IP address from the container name
# If not, fix the LXD dns as per the README.
address=$1.lxd:8083

# Configure an ElasticSearch sink for our json_user topic
curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" \
 --data '{ "name": "user-es-sink",
           "config": {
               "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector", "tasks.max": "1",
               "topics": "json_user",
               "key.ignore": "true",
               "connection.url": "http://localhost:9200",
               "type.name": "kafka-connect"
             }
          }' http://$address/connectors
