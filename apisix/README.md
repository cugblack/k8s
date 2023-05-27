# apisix部署与使用

[charts地址](https://github.com/cugblack/helm/tree/main/apisix)

**安装方式**：he l m



## 操作步骤

```
# 添加apisix官方helm charts仓库
helm repo add apisix https://charts.apiseven.com

# 执行仓库更新
helm repo update

# 拉取charts到本地，方便修改自定义配置
helm pull apisix/dashboard
helm pull apisix/apisix-dashboard

# 解压缩
tar -zxvf ..

# 查看charts的结构
├── Chart.lock
├── Chart.yaml
├── README.md
├── README.md.gotmpl
├── charts
│   ├── apisix-dashboard
│   ├── apisix-ingress-controller
│   └── etcd
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── _pod.tpl
│   ├── clusterrole.yaml
│   ├── clusterrolebinding.yaml
│   ├── configmap.yaml
│   ├── daemonset.yaml
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress-admin.yaml
│   ├── ingress.yaml
│   ├── pdb.yaml
│   ├── service-admin.yaml
│   ├── service-control-plane.yaml
│   ├── service-gateway.yaml
│   ├── service-monitor.yaml
│   └── serviceaccount.yaml
├── values.schema.json
└── values.yaml

# 执行安装: 不修改配置，直接使用远端charts

helm install apisix apisix/apisix --create-namespace  --namespace apisix
helm install apisix-dashboard apisix/apisix-dashboard --create-namespace --namespace apisix

# 查看创建好的资源
kubectl get po -n apisix
kubectl get svc -n apisix

```



## charts文件解析

我们只需要关注2个部分：

- templates文件夹：存放所有资源的模版文件
- values.yaml文件：存放所有可替换变量



## 如何访问dashboard？



如果按照默认的charts创建dashboard，则可以看到**svc中 apisix-dashboard的类型为ClusterIP，无法直接访问，仅支持在集群内访问**。

如果需要在集群外访问，则可以修改s v c类型为NodePort，即可通过**masterIP:nodePort** 在集群外进行访问。

修改方式：二选一即可

- 部署前：修改values.yaml中service.type，由ClusterIP 改为NodePort
- 部署后：修改s v c，kubectl edit 或者更改s v c的yaml文件即可

