# cassandra 配置

## 服务

创建一个本地服务（namespace=develop，ClusterIP=10.106.39.210，端口为9042）
[cassandra-service](/cassandra/cassandra-service.yaml)



## 存储

采用挂载本地目录的形式，挂载的本地目录为：`/home/data/cassandra/cassandra-data-0` ,可修改

	kubectl create -f local-volume.yaml

创建一个StatefulSet,负责创建pod。
镜像版本： cassandra:3   [Dockerfile](https://github.com/cugblack/dockerfile/tree/master/cassandra)

它提供有序部署、有序终止和唯一网络名称。

	kubectl create -f cassandra-StatefulSet.yaml

验证StatefulSet

    $ kubectl get statefulsets
    NAME        DESIRED   CURRENT   AGE
    cassandra   1         1         2h


    kubectl get pod --all-namespaces
    NAMESPACE     NAME                                 READY     STATUS    RESTARTS   AGE
    develop       cassandra-0                          1/1       Running   0          26m

扩展StatefulSet

    kubectl scale --replicas=3 statefulset/cassandra

访问cassandra容器

    kubectl exec -it cassandra-0 --namespace=develop cqlsh
    
    

>参考

>>[IBM-Scalable-Cassandra](https://github.com/IBM/Scalable-Cassandra-deployment-on-Kubernetes/)
