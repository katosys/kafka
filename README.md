# kafka

[![Build Status](https://travis-ci.org/katosys/kafka.svg?branch=master)](https://travis-ci.org/katosys/kafka)

Mesos Kafka framework

```
docker run -it --rm \
  -e STORAGE=zk:/kafka-mesos \
  -e MASTER=zk://quorum-1:2181,quorum-2:2181,quorum-3:2181/mesos \
  -e ZK=quorum-1:2181,quorum-2:2181,quorum-3:2181 \
  -e API=http://master-1:7000 \
  quay.io/kato/kafka scheduler
```
