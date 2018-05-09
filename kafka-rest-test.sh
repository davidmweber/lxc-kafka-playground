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
address=$1.lxd:8082

# Produce a message using JSON with the value '{ "foo": "bar" }' to the topic jsontest
echo "Sending message to topic jsontest"
curl -s -X POST -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -H "Accept: application/vnd.kafka.v2+json" \
  --data '{"records":[{"value":{"foo":"bar"}}]}' "http://$address/topics/jsontest" > /dev/null

# Create a consumer for JSON data, starting at the beginning of the topic's
# log and subscribe to a topic. Then consume some data using the base URL in the first response.
# Finally, close the consumer with a DELETE to make it leave the group and clean up
# its resources.

echo -n "Comsumer setup response: "
curl -s -X POST -H "Content-Type: application/vnd.kafka.v2+json" \
    --data '{"name": "my_consumer_instance", "format": "json", "auto.offset.reset": "earliest"}' \
    http://$address/consumers/my_json_consumer
echo

curl -X POST -H "Content-Type: application/vnd.kafka.v2+json" --data '{"topics":["jsontest"]}' \
  http://$address/consumers/my_json_consumer/instances/my_consumer_instance/subscription

echo -n "Retrieved message: "
curl -X GET -H "Accept: application/vnd.kafka.json.v2+json" \
  http://$address/consumers/my_json_consumer/instances/my_consumer_instance/records
echo

curl -X DELETE -H "Content-Type: application/vnd.kafka.v2+json" \
  http://$address/consumers/my_json_consumer/instances/my_consumer_instance
