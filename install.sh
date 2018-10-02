#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo 'deb https://artifacts.elastic.co/packages/6.x/apt stable main' | tee -a /etc/apt/sources.list.d/elastic-5.x.list
echo 'deb https://packagecloud.io/grafana/stable/debian/ stretch main' | tee -a /etc/apt/sources.list.d/grafana.list
echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
add-apt-repository 'deb [arch=amd64] https://packages.confluent.io/deb/4.1 stable main'
curl -s https://packages.confluent.io/deb/5.0/archive.key | apt-key add -
curl -s https://packagecloud.io/gpg.key | apt-key add -
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
curl -s https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
apt -y update
apt -y upgrade
apt -y install openjdk-8-jre-headless
apt -y install confluent-platform-oss-2.11
apt -y install elasticsearch
apt -y install grafana
apt -y install cassandra
apt -y autoremove
systemctl enable elasticsearch
systemctl start elasticsearch
systemctl enable grafana-server
systemctl start grafana-server
systemctl enable cassandra
systemctl start cassandra
