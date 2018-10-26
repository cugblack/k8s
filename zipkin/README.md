使用的镜像为：openzipkin/zipkin:latest，有需要可自行更换其他版本的镜像


zipkin支持的配置


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
