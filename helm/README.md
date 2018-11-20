# helm安装使用
---

helm组成：

    helm：  客户端，管理本地chart仓库，管理chart，与服务器交互，发送chart，实例安装、查询、卸载等操作
    
    tiller：服务端，接收helm发来的charts与config合并生成release
    
   
## 一、安装

### 1、下载helm可执行文件

    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-linux-amd64.tar.gz

    tar -zxvf helm-v2.9.0-linux-amd64.tar.gz 
    cp linux-amd64/helm /use/bin/helm
    
### 2、RBAC

  [rbac配置文件](/helm/rbac-heml.yaml)

### 3、初始化init

    helm init --service-account tiller
    
此时会生成一个tiller的deployment，如果无法连接k8s.gcr.io，可使用此镜像：

    kubectl  set image deployment/tiller-deploy -n kube-system  tiller=cugblackcugblack/kubernetes-helm-tiller:v2.9.0
    
```
 /home/ubuntu/.helm 
 /home/ubuntu/.helm/repository 
 /home/ubuntu/.helm/repository/cache 
 /home/ubuntu/.helm/repository/local 
 /home/ubuntu/.helm/plugins 
 /home/ubuntu/.helm/starters 
 /home/ubuntu/.helm/cache/archive 
 /home/ubuntu/.helm/repository/repositories.yaml
```
    
---
# 二、使用

    helm version   #查看版本
    
    helm repo update #更新仓库
    
    helm repo list  #显示可用仓库
        ubuntu@i:/helm$ helm repo list

        NAME  	URL                                             
        stable	https://kubernetes-charts.storage.googleapis.com
        local 	http://127.0.0.1:8879/charts

    helm fetch stable/mysql
```
ubuntu@6:~$cd /home/ubuntu/.helm/cache/archive 
ubuntu@6:~/.helm/cache/archive$ tree mysql
mysql
├── Chart.yaml
├── README.md
├── templates
│   ├── configurationFiles-configmap.yaml
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── initializationFiles-configmap.yaml
│   ├── NOTES.txt
│   ├── pvc.yaml
│   ├── secrets.yaml
│   ├── svc.yaml
│   └── tests
│       ├── test-configmap.yaml
│       └── test.yaml
└── values.yaml

```    


>其他版本请参考
>>[官方站点](https://github.com/helm/helm)

>>[官方仓库](https://hub.kubeapps.com/)

>>[charts-github](https://github.com/helm/charts)