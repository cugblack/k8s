***
## Monitoring on kubernetes


### k8s集群获取核心资源指标有两种方式：

    heapster
    metrics-server

当然也支持自定义资源指标来对集群进行监控：

    prometheus
---
    
    
在部署了这二者[`heapster/metrics-server`]之中的任意一个，可以通过 `kubectl top node/pod` 来查看集群内node节点或者pod的`资源使用情况`，同时也可以使用k8s支持的hpa[`自动弹性伸缩autoscale`],当监控到pod资源达到限制的值时，会对资源[deployment、statefulset、replicationController]进行自动伸缩。  
```
    kubectl top --help
    Available Commands:
    node        Display Resource (CPU/Memory/Storage) usage of nodes
    pod         Display Resource (CPU/Memory/Storage) usage of pods
```


>Tips:
>>kubernetes官方已经在`v1.10`开始陆续的废弃heapster，在 `v1.12` 已经彻底不支持heapster了。v1.11.0以及之前的版本，heapster可以正常使用。

