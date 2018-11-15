使用的镜像为：openzipkin/zipkin:2.7.5，有需要可自行更换其他版本的镜像


zipkin支持的部分配置，[详细配置请参考此文件](/zipkin/zipkin-server-shared.yml)




        - name: "STORAGE_PORT_9042_TCP_ADDR"
          value: "zipkin-cassandra:9411"
        - name: "CASSANDRA_CONTACT_POINTS"
          value: "10.106.39.210:9042"
        - name: "STORAGE_TYPE"
          value: "cassandra3"
        - name: "TRANSPORT_TYPE"
          value: "http"
        - name: "CASSANDRA_KEYSPACE"
          value: "zipkin3"
        - name: "KAFKA_ZOOKEEPER"
          value: "172.32.100.132:2181"
        - name: "KAFKA_TOPIC"
          value: "master"
       
       
访问集群出口IP:31001即可访问zipkin界面
>Tips
>>存储支持cassandra、mysql等数据库，参数可自行查询

---
 
## 以下为部分配置与YAML参数配置的对应关系

`完整文件`为 [zipkin-server-shared.yml](/zipkin/zipkin-server-shared.yml)
``` 
  collector:
    kafka:
      # Kafka bootstrap broker list, comma-separated host:port values. Setting this activates the
      # Kafka 0.10+ collector.
      bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:}
      # Name of topic to poll for spans
      topic: ${KAFKA_TOPIC:zipkin}
      # Consumer group this process is consuming on behalf of.
      group-id: ${KAFKA_GROUP_ID:zipkin}
      # Count of consumer threads consuming the topic
      streams: ${KAFKA_STREAMS:1}

  storage：
    cassandra3:
      # Comma separated list of host addresses part of Cassandra cluster. Ports default to 9042 but you can also specify a custom port with 'host:port'.
      contact-points: ${CASSANDRA_CONTACT_POINTS:localhost}
      # Name of the datacenter that will be considered "local" for latency load balancing. When unset, load-balancing is round-robin.
      local-dc: ${CASSANDRA_LOCAL_DC:}
      # Will throw an exception on startup if authentication fails.
      username: ${CASSANDRA_USERNAME:}
      password: ${CASSANDRA_PASSWORD:}
      keyspace: ${CASSANDRA_KEYSPACE:zipkin2}
      # Max pooled connections per datacenter-local host.
      max-connections: ${CASSANDRA_MAX_CONNECTIONS:8}
      # Ensuring that schema exists, if enabled tries to execute script /zipkin2-schema.cql
      ensure-schema: ${CASSANDRA_ENSURE_SCHEMA:true}
      # how many more index rows to fetch than the user-supplied query limit
      index-fetch-multiplier: ${CASSANDRA_INDEX_FETCH_MULTIPLIER:3}
      # Using ssl for connection, rely on Keystore
      use-ssl: ${CASSANDRA_USE_SSL:false}
```
