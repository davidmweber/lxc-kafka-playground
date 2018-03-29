#!/bin/bash
if (( $# == 0 )); then
  echo "Usage $0 <container-name>"
  exit -1
fi

if ((  $(lxc list | grep $1 | wc -l) ==  0 )); then
  echo "The container $1 does not exist"
  exit -1
fi

address=$(lxc list | grep $1 | cut -d" " -f6)

# Check Zookeeper
if (( $(echo dump | nc $address 2181 | grep broker | wc -l) == 1 )); then
  echo "Zookeeper: OK"
else
  echo "Zookeeper: Failed "
fi

# Check grafana
if [[ $(curl -Is http://$address:3000/login | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo "Grafana: OK"
else
  echo "Grafana: Failed"
fi

# Check elastic search
if [[ $(curl -Is http://$address:9200 | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo "ElasticSearch: OK"
else
  echo "ElasticSearch: Failed"
fi

# Check the schema registry
if [[ $(curl -Is http://$address:8081/subjects | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo "Schema registry: OK"
else
  echo "Schema registry: Failed"
fi

# Check the schema registry
if [[ $(curl -Is http://$address:8090 | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo "KSQL server: OK"
else
  echo "KSQL: Failed"
fi

# Check the Kafka ReST interface
if [[ $(curl -Is http://$address:8082 | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo "Kafka and Kafka ReST: OK"
else
  echo "Kafka and Kafka ReST: Failed"
fi
