#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
CONFLUENT_V=5.0

echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
echo "deb https://packagecloud.io/grafana/stable/debian/ stretch main" | tee -a /etc/apt/sources.list.d/grafana.list
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/${CONFLUENT_V} stable main"
curl -s https://packages.confluent.io/deb/${CONFLUENT_V}/archive.key | apt-key add -
curl -s https://packagecloud.io/gpg.key | apt-key add -
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
curl -s https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
apt -y update
apt -y upgrade
apt -y install openjdk-8-jre-headless confluent-platform-oss-2.11 elasticsearch grafana cassandra
apt -y autoremove
systemctl enable elasticsearch
systemctl start elasticsearch
systemctl enable grafana-server
systemctl start grafana-server
systemctl enable cassandra
systemctl start cassandra
systemctl enable confluent-zookeeper
systemctl start confluent-zookeeper
systemctl enable confluent-kafka
systemctl start confluent-kafka
systemctl enable confluent-kafka-connect
systemctl start confluent-kafka-connect
systemctl enable confluent-schema-registry
systemctl start confluent-schema-registry
systemctl enable confluent-kafka-rest
systemctl start confluent-kafka-rest
systemctl enable confluent-ksql
systemctl start confluent-ksql
