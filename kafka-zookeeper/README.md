# kafka-zookeeper

## 1、配置命名空间及存储  

### 命名空间：kafka  

    namespace: kafka
    kubectl create -f 00-namespace.yaml
    

### 存储：

#### storageclass创建： 

    由系统自动完成PV的创建和绑定，实现动态资源绑定
    
    采用 docker.io/hostpath 创建临时目录，与pod共享生命周期
    03storageclass.yaml
    
#### PV：`PresistentVolume`,将底层存储共享给pod使用
    
采用hostPath模式，挂载本地目录
    
   `完整文件` 为 [ PV以及PVC](/kafka-zookeeper/01-local-pv.yaml)


PVC：用户对于存储资源的“申请”  
---
## 2、zookeeper部署

配置均采用configmap编写

>[配置文件configmap](/kafka-zookeeper/zookeeper/10zookeeper-config.yaml) 
    
>>部署服务svc以及部署statefulSet [配置文件](/kafka-zookeeper/zookeeper/)

    
## 3、部署kafka

>配置采用configmap[配置文件configmap](/kafka-zookeeper/kafka/10broker-config.yaml)
          
>>部署服务svc以及statefulset[配置文件configmap](/kafka-zookeeper/kafka/)


kubectl apply -f  所有文件即可

