# helm安装使用

    helm：客户端，管理本地chart仓库，管理chart，与服务器交互，发送chart，实例安装、查询、卸载等操作
    
    tiller：服务端接收helm发来的charts与config合并生成release
    
   
## 安装

### 1、下载helm可执行文件

    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-linux-amd64.tar.gz

    tar -zxvf helm-v2.9.0-linux-amd64.tar.gz 
    cp helm/helm /use/bin/helm
    
### 2、RBAC

  [rbac配置文件](/k8s/helm/rbac-helm.yaml)

### 3、初始化init

    helm init --service-account tiller
    
此时会生成一个tiller的deployment，如果无法连接k8s.gcr.io，可使用此镜像：

    kubectl  set image deployment/tiller-deploy -n kube-system  tiller=cugblackcugblack/kubernetes-helm-tiller:v2.9.0
    
>其他版本请参考
>>[官方站点](https://github.com/helm/helm)