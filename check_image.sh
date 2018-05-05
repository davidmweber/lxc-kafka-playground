#!/bin/bash
red=$'\e[1;31m'
grn=$'\e[1;32m'
end=$'\e[0m'

ok="${grn}OK${end}"
failed="${red}Failed${end}"

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

host $address > /dev/null
if (( $? != 0 )); then
  echo "Unable to resolve the host name for the container ($1). Please fix the LXD DNS"
fi

# Check Zookeeper
echo -n "Zookeeper:          "
if (( $(echo dump | nc $address 2181 | grep broker | wc -l) == 1 )); then
  echo $ok
else
  echo $failed
fi

# Check if Cassandra is running
echo -n "Kafka broker:       "
nc -z $address 9092
if (( $? == 0 )); then
  echo $ok
else
  echo $failed
fi

# Check grafana
echo -n "Grafana:            "
if [[ $(curl -Is http://$address:3000/login | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo $ok
else
  echo $failed
fi

# Check elastic search
echo -n "ElasticSearch:      "
if [[ $(curl -Is http://$address:9200 | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo $ok
else
  echo $failed
fi

# Check the schema registry
echo -n "Schema registry:    "
if [[ $(curl -Is http://$address:8081/subjects | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo $ok
else
  echo $failed
fi

# Check the schema registry
echo -n "KSQL server:        "
if [[ $(curl -Is http://$address:8088/status | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo $ok
else
  echo $failed
fi

# Check the Kafka ReST interface
echo -n "Kafka ReST server:  "
if [[ $(curl -Is http://$address:8082 | head -1) = *'HTTP/1.1 200 OK'* ]]; then
  echo $ok
else
  echo $failed
fi

# Check if Cassandra is running
echo -n "Cassandra server:   "
nc -z $address 9042
if (( $? == 0 )); then
  echo $ok
else
  echo $failed
fi
