# Kafka Streams Playground

The scripts here buld an LXC container with a full Kafka/Confluent suite of
services  The idea is a one stop playground for experiment and development work
for Kafka and friends.

The following packages are installed:

* [Kafka](https://kafka.apache.org/)
* [Kafka streams](https://kafka.apache.org/documentation/streams/) with the default connectors provided by the Confluent distribution
* [KSQL](https://github.com/confluentinc/ksql)
* [ElasticSearch](https://www.elastic.co/)
* [Grafana](https://grafana.com/).

To build the image and start the services, just run

```bash
build-image.sh kafka-streams
```
This will create an image called `kafka-streams` and provision it. The script
will not overwrite an existing container so make sure the container name is
unique.

Note that the Confluent Kafka suite and the KSQL server are started by the
installation script. You will need to manually restart them if you reboot the
image using the following commands:

```bash
confluent start
/root/ksql/bin/ksql-server-start -daemon /root/ksql.properties
```

The following services are available on the containers external address:

* Grafana: http://{10.x.x.x}:3000. The username and the password are both "admin".
* Confluent schema registry: http://{10.x.x.x}:8081. See The docs for all
the [available ReST](https://docs.confluent.io/current/schema-registry/docs/intro.html#quickstart) functions.
* Zookeeper is at port 2181. Check if Kafka is running using `echo dump | nc 10.x.x.x 2128` and look for "broker".
* A KSQL server will be running on the container. Connect to it using `bin/ksql-cli remote 10.x.x.x`.
The full suite of KSQL tools are available in `/root/ksql/bin`/.
* ElasticSearch is currently only available on localhost.


Useful tools: [Kafka streams Scala](https://github.com/lightbend/kafka-streams-scala)
