# The Little Big Data Playground

The scripts here buld an LXD container with a full Kafka/Confluent suite of
services  The idea is a one stop playground for experiment and development work
for Kafka and friends. It is supposed to emulate a deployed set of services
rather than some local deployment. It is helpful to have a local copy of tools
such as `csqlsh` available locally to interact with the playground. Some scripts
require that you have `jq` installed as a json pretty printer. Get it using
`apt-get install jq`.

We assume that you have a fully functional `lxd` setup
running on your local machine with a functional DNS that can [resolve container
IP addresses](https://discuss.linuxcontainers.org/t/dns-for-lxc-containers/235)
from the container name. You can check if the DNS is working for some container
called `container` by running `host container.lxd`. This should return the
IP address of the container. If you do not do this then services such as Kafka
will not start properly as it cannot resolve the host name properly.

The following packages are installed as part of the playground:

* [Kafka](https://kafka.apache.org/)
* [Kafka streams](https://kafka.apache.org/documentation/streams/) with the default connectors provided by the Confluent distribution
* [KSQL](https://github.com/confluentinc/ksql)
* Confluent's [schema registry](https://github.com/confluentinc/schema-registry)
* [Kafka connect](https://docs.confluent.io/current/connect/)
* [ElasticSearch](https://www.elastic.co/)
* [Grafana](https://grafana.com/).
* [Cassandra](http://cassandra.apache.org/)

To build the image and start the services, just run

```bash
./build-image.sh kafka-streams
```
This will create an image called `kafka-streams` and provision it. The script
will not overwrite an existing container so make sure the container name is
unique. The Confluent component life cycles are managed by `systemd` rather than
the confluent CLI as this better suits the nature of the service as a container.
You can check if the services are up by running

```bash
./check_image.sh <container-name>
```
If you have configured LXD's DNS properly, the container should be resolvable
from its name. For this example, we assume the container was called `kafka-streams`.
In our example, the DNS entry for the container will be `kafka-streams.lxd`.

Check out `kafka-rest_test.sh` for an example of how to use HTTP to produce
and consume messages in Kafka.

Accessing the container requires that you have its IP address. You can obtain
it using `lxc list` or `host <container-name>.lxd`.

The following services are available on the containers external address:

* Grafana: http://kafka-streams.lxd:3000. The username and the password are both "admin".
* Confluent schema registry: http://kafka-streams.lxd:8081. See The docs for all
the [available ReST](https://docs.confluent.io/current/schema-registry/docs/intro.html#quickstart) functions.
* Zookeeper is at port 2181. Check if Kafka is running using `echo dump | nc kafka-streams.lxd 2181` and look for "broker".
* A KSQL server will be running on the container. Connect to it using `bin/ksql-cli remote https://kafka-streams.lxd:8090`. The full suite of KSQL tools are available in `/root/ksql/bin/`.
* ElasticSearch is exposed on port 9200 on the container. Use `curl http://kafka-streams.lxd:9200` to retrieve basic information about this server.
* The schema registry is exposed at port 8081. Use `curl http://kafka-streams.lxd:8081/subjects` to see a list of schemas.
* The [Kakfa ReST](https://github.com/confluentinc/kafka-rest) server is available.
Check it using `curl http://kafka-streams.lxd:8082/topics`
* The [Kafka Connect](https://docs.confluent.io/current/connect) is started
in distributed mode and individual connectors must be started using the
[ReST API](https://docs.confluent.io/current/connect/restapi.html#connect-userguide-rest).

You can access a shell on the container using `lxc exec <container-name> bash`. The
KSQL tool set is available from `ksql/bin/`.

See [this video](https://www.youtube.com/embed/A45uRzJiv7I) for a taste as to
what this container can do.

Useful tools: [Kafka streams Scala](https://github.com/lightbend/kafka-streams-scala)
