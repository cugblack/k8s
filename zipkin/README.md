# k8s集群部署zipkin

>用来跟踪微服务间的链路调用与日志，数据存储在[cassandra](../cassandra/)中。

>>使用的镜像为：`openzipkin/zipkin:2.7.5`，[Dockerfile](/zipkin/Dockerfile)， 有需要可自行更换其他版本的镜像


>>>zipkin支持的部分配置，[详细配置请参考此文件](/zipkin/zipkin-server-shared.yml)


### 本次使用的配置：

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
       
       
访问集群出口IP:31001即可访问zipkin的ui界面

>Tips
>>存储支持cassandra、mysql、Elasticsearch等，可参考[官方文档](https://github.com/openzipkin/docker-zipkin)。

---
 