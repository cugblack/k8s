# Bookeinfo应用
---

>它由多个服务、多个语言构成，并且 reviews 服务具有多个版本。


部署一个样例应用，它由四个单独的微服务构成，用来演示多种 Istio 特性。这个应用模仿在线书店的一个分类，显示一本书的信息。页面上会显示一本书的描述，书籍的细节（ISBN、页数等），以及关于这本书的一些评论。

### Bookinfo 应用分为四个单独的微服务：

```
      productpage ：productpage 微服务会调用 details 和 reviews 两个微服务，用来生成页面。
      details ：这个微服务包含了书籍的信息。
      reviews ：这个微服务包含了书籍相关的评论。它还会调用 ratings 微服务。
      ratings ：ratings 微服务中包含了由书籍评价组成的评级信息。
```

### reviews 微服务有 3 个版本：

```
      v1 版本不会调用 ratings 服务。
      v2 版本会调用 ratings 服务，并使用 1 到 5 个黑色星形图标来显示评分信息。
      v3 版本会调用 ratings 服务，并使用 1 到 5 个红色星形图标来显示评分信息
```

## 部署
---

> 部署之前请确定正确安装了istio且服务已正常

### 启动应用容器

集群使用的是自动 Sidecar 注入，只需简单的 kubectl 就能完成服务的部署：

kubectl apply -f [samples/bookinfo/platform/kube/bookinfo.yaml](istio-1.0.4/samples/bookinfo/platform/kube/bookinfo.yaml)

> 此命令会启动全部的四个服务，其中也包括了 reviews 服务的三个版本（v1、v2 以及 v3）

给应用定义网关ingress gateway:

kubectl apply -f [samples/bookinfo/networking/bookinfo-gateway.yaml](istio-1.0.4/samples/bookinfo/networking/bookinfo-gateway.yaml)

### 确认所有的pod以及服务都正常，确定GATEWAY_URL

> 默认的istio的服务使用的是loadbalancer,如果对应的平台不支持，可换成nodeport访问。

```
      export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
      export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
      export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

```

## 测试

执行以下命令测试应用的运行情况：
`curl -o /dev/null -s -w "%{http_code}%\n" http://$GATEWAY_URL/productpage`

> 也可以直接网页访问： http://GATEWAY_URL/productpage


> Tips
>> 环境清除：bash samples/bookinfo/platform/kube/cleanup.sh

[官方文档](https://istio.io/zh/docs/examples/bookinfo)
