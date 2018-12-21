# 安装istio

---


## 方法一：
执行脚本下载安装文件并自动解压缩：

>   sh [downloadIstioCandidate.sh](downloadIstioCandidate.sh)

或者自行下载：

下载地址：[https://github.com/istio/istio/releases](https://github.com/istio/istio/releases)

目录结构：[tree istio-1.0.4](istio文件树.txt)

    install/ 目录中包含了 Kubernetes 安装所需的 .yaml 文件
    samples/ 目录中是示例应用
    istioctl 客户端文件保存在 bin/ 目录之中。istioctl 的功能是手工进行 Envoy Sidecar 的注入，以及对路由规则、策略的管理
    istio.VERSION 配置文件  
  
加入到环境变量：

    cd istio

    export PATH=$PWD/bin:$PATH

安装 Istio 的核心部分。从以下四种_非手动_部署方式中选择一种方式安装。然而，官方推荐在生产环境时使用 Helm Chart 来安装 Istio，这样可以按需定制配置选项。

安装 Istio 而不启用 sidecar 之间的双向 TLS 验证。对于现有应用程序的集群，使用 Istio sidecar 的服务需要能够与其他非 Istio Kubernetes 服务以及使用存活和就绪探针、headless 服务或 StatefulSets 的应用程序通信的应用程序选择此选项。

   $ kubectl apply -f [istio-demo.yaml](/istio/istio-1.0.4/install/kubernetes/istio-demo.yaml)

或者

默认情况下安装 Istio，并强制在 sidecar 之间进行双向 TLS 身份验证。仅在保证新部署的工作负载安装了 Istio sidecar 的新建的 Kubernetes 集群上使用此选项。

   $ kubectl apply -f [istio-demo-auth.yaml](/istio/istio-1.0.4/install/kubernetes/istio-demo-auth.yaml)
    

---

## 方法二
---
ansible安装

    ansibel 2.4
    
在[install/kubernetes/ansible](/istio/istio-1.0.4/install/kubernetes/ansible)路径下：

    ansibel-playbook main.yml

>Tips
>>[官方中文文档](https://istio.io/zh/docs/)
