# metrics-server

>注意：
>>1.13.1版本的cmd参数需要自行调整，仅需要保留
```
        command:
        - /metrics-server
        - --kubelet-insecure-tls
```

## 如果出现以下问题：

```
unable to fetch node metrics for node "k8s-master": no metrics known for node
unable to fully collect metrics: [unable to fully scrape metrics from source kubelet_summary:k8s-node1: unable to fetch metrics from Kubelet k8s-node1 (k8s-node1): Get https://k8s-node1:10250/stats/summary/: dial tcp: lookup k8s-node1 on 10.96.0.10:53: no such host, unable to fully scrape metrics from source kubelet_summary:k8s-master: unable to fetch metrics from Kubelet k8s-master (k8s-master): Get https://k8s-master:10250/stats/summary/: dial tcp: lookup k8s-master on 10.96.0.10:53: no such host]
```

需要修改`kubelet` 参数，`vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`，增加：

```
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --authentication-token-webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
```
