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
address=$1.lxd
connect_addr=$address:8083
kafka_addr=$address:8082
es_addr=$address:9200
connector=user-es-sink
topic=es-sink-test

# Delete existing connectors with this name
if (( $(curl -s http://$connect_addr/connectors | grep $connector | wc -l) == 1 )); then
  curl -s -X DELETE http://$connect_addr/connectors/$connector
fi

echo "Connector configuration returns:"
# Configure an ElasticSearch sink for our json_user topic
# The topic is the ES index, type.name is the ES type. The ID is generated
# by the connector.
curl -s -X POST -H "Content-Type: application/json" -H "Accept: application/json" \
 --data ' {
           "name": "'$connector'",
           "config": {
               "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
               "tasks.max": "1",
               "topics": "'$topic'",
               "key.ignore": "true",
               "connection.url": "http://localhost:9200",
               "type.name": "kafka-connect",
               "schema.ignore": "true"
             }
          }' http://$connect_addr/connectors | jq

sleep 10 # Wait for setup of the connector to complete
# Wite something silly to this topic. Note the JSON we write needs the
# "records" and the "value" array as this is Elastic Search's API
for i in {1..5}; do
  curl -s -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" -H "Accept: application/vnd.kafka.v2+json" \
    --data '{"records":[{"value": {"name":"a","email":"b","city":"city-'$i'"}}]}'\
    http://$kafka_addr/topics/$topic > /dev/null
done

echo
echo "Search result from ElasticSearch"
# Check if we have written anything to ElasticsearchSinkConnector
curl -s http://$es_addr/$topic/_search?pretty | jq
