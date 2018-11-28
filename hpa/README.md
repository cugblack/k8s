# Kubernetes Horizontal Pod Autoscaler(HPA)

---

kubernetes集群内，基于获取到的metrics(CPU utilization、memory，custom metrics) value，对rc, deployment管理的pods进行自动伸缩。

核心指标的获取需要依赖额外的组件：
    
    heapster  [v1.11版本开始弃用]
    metrics server

## HPA的创建

### 支持使用`kubectl create hpa`
   
### 支持使用`kubectl autoscale deployment/replicationcontroller examplt_1 --min=1 --max=5 --cpu-percent=60 -n namespace`

此方式创建的hpa仅支持cpu为限制指标
   
### 支持编写yaml来创建
    autoscaling/v1：仅支持cpu为限制指标
    autoscaling/v2beta1：支持同时对cpu和内存进行限制

## autoscaling/v2beta1 
[YAML示例](hpa-autoscaling-v2beta.yaml)：
```angular2html
    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    metadata:
        name: filesystem-stage
        namespace: stage
    spec:
        scaleTargetRef:
            apiVersion: extensions/v1beta1
            kind: Deployment
            name: filesystem-stage
        minReplicas: 1
        maxReplicas: 3
        metrics:
        - type: Resource
          resource:
            name: cpu
            targetAverageUtilization: 80
        - type: Resource
          resource:
            name: memory
            targetAverageValue: 200Mi
```


    
