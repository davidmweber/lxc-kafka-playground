# The Little Big Data Playground

The scripts here buld an LXD container with a full Kafka/Confluent suite of
services  The idea is a one stop playground for experiment and development work
for Kafka and friends. We assume that you have a fully functional `lxd` setup
running on your local machine with a functional DNS that can [resolve container
IP addresses](https://discuss.linuxcontainers.org/t/dns-for-lxc-containers/235)
from the container name. You can check if the DNS is working for some container
called `container` by running `host container.lxd`. This should return the
IP address of the container.

The following packages are installed as part of the playground:

* [Kafka](https://kafka.apache.org/)
* [Kafka streams](https://kafka.apache.org/documentation/streams/) with the default connectors provided by the Confluent distribution
* [KSQL](https://github.com/confluentinc/ksql)
* Confluent's [schema registry](https://github.com/confluentinc/schema-registry)
* [ElasticSearch](https://www.elastic.co/)
* [Grafana](https://grafana.com/).
* [Cassandra](http://cassandra.apache.org/)

To build the image and start the services, just run

```bash
./build-image.sh kafka-streams
```
This will create an image called `kafka-streams` and provision it. The script
will not overwrite an existing container so make sure the container name is
unique. You can check if the services are up by running

```bash
./check_image.sh <container-name>
```

Note that the Confluent Kafka suite and the KSQL server are started by the
installation script. You will need to manually restart them if you reboot the
image using the following commands:

```bash
lxc exec <container-name> confluent stop
lxc exec <container-name> confluent start
lxc exec <container-name> /root/ksql/bin/ksql-server-start -daemon /root/ksql.properties
```

Accessing the container requires that you have its IP address. You can obtain
it using `lxc list` or using the following command:

```bash
lxc list | grep <container-name> | cut -d" " -f6
```

The following services are available on the containers external address:

* Grafana: http://{10.x.x.x}:3000. The username and the password are both "admin".
* Confluent schema registry: http://{10.x.x.x}:8081. See The docs for all
the [available ReST](https://docs.confluent.io/current/schema-registry/docs/intro.html#quickstart) functions.
* Zookeeper is at port 2181. Check if Kafka is running using `echo dump | nc 10.x.x.x 2181` and look for "broker".
* A KSQL server will be running on the container. Connect to it using `bin/ksql-cli remote https://10.x.x.x:8090`. The full suite of KSQL tools are available in `/root/ksql/bin/`.
* ElasticSearch is exposed on port 9200 on the container. Use `curl http://10.x.x.x:9200` to retrieve basic information about this server.
* The schema registry is exposed at port 8081. Use `curl http://localhost:8081/subjects` to
 see a list of schemas.
* Access a shell on the container using `lxc exec <container-name> bash`. The
KSQL tool set is available from `ksql/bin/`.
* The [Kakfa ReST](https://github.com/confluentinc/kafka-rest) server is available.
Check it using `curl http://10.x.x.x:8082/topics`

See [this video](https://www.youtube.com/embed/A45uRzJiv7I) for a taste as to
what this container can do.

Useful tools: [Kafka streams Scala](https://github.com/lightbend/kafka-streams-scala)


You can start the services without having to use confluent's tool:

* Zookeeper: `/usr/bin/zookeeper-server-start -daemon /etc/kafka/zookeeper.properties`
* Kafka server: `/usr/bin/kafka-server-start -daemon /etc/kafka/server.properties`
