# kafka

[![Build Status](https://travis-ci.org/katosys/kafka.svg?branch=master)](https://travis-ci.org/katosys/kafka)

Mesos Kafka framework

```
docker run -it --net host --rm \
-e STORAGE=zk:/kafka-mesos \
-e MASTER=zk://quorum-1:2181,quorum-2:2181,quorum-3:2181/mesos \
-e ZK=quorum-1:2181,quorum-2:2181,quorum-3:2181 \
-e API=http://master-1:7000 \
-e MESOS_NATIVE_JAVA_LIBRARY=/opt/lib/libmesos.so \
-v /opt/lib:/opt/lib \
quay.io/kato/kafka scheduler
```

```
./kafka-mesos.sh broker add 0 \
--container-type mesos \
--container-image quay.io/kato/kafka \
--container-mounts /opt/lib:/opt/lib:ro
```

```
./kafka-mesos.sh broker list
./kafka-mesos.sh broker start 0
```

Teardown the framework:
```
curl -H "Content-Type: application/json" -X POST \
-d 'frameworkId=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-ffff' \
-v -L http://master:5050/teardown
```

Purge ZK state:
```
sudo rkt enter $(rkt list | awk '/zookeeper/ {print $1}') \
/opt/zookeeper/bin/zkCli.sh -server 172.17.8.11:2181 rmr /kafka-mesos
```
