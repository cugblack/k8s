# kafka-zookeeper

## 1、配置命名空间及存储  

命名空间：kafka  

    namespace: kafka
    kubectl create -f 00-namespace.yaml
    

存储：

storageclass创建： 

    由系统自动完成PV的创建和绑定，实现动态资源绑定
    
    采用 docker.io/hostpath 创建临时目录，与pod共享生命周期
    03storageclass.yaml
    
PV：`PresistentVolume`,将底层存储共享给pod使用
    
    采用hostPath模式，挂载本地目录
    [01local-pv.yaml](/kafka-zookeeper/01-local-pv.yaml)
    02local-pvc.yaml

PVC：用户对于存储资源的“申请”  
---
## 2、zookeeper部署

配置采用configmap编写

    10zookeeper-config.yaml
    
部署服务

    20pzoo-service.yaml
    21zoo-service.yaml
    30zookeeper-service.yaml
    
部署zookeeper  statefulSet

    50pzoo-statefulset.yaml
    51zoo-statefulset.yaml
    
## 3、部署kafka

配置采用configmap

      [10broker-config.yaml](/kafka-zookeeper/kafka/10broker-config.yaml)
          
部署服务

    20dns.yaml     "broker"
    30bootstrap-service.yaml  "bootstrap"


部署kafka

    50kafka.yaml

