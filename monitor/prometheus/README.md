# prometheus operator部署

 kubectl apply -f [bundle.yaml](prometheus-operator/bundle.yaml)
 
 kubectl apply -f [prometheus-operator/](prometheus-operator)


>Tips
>>配置kubelet使用一下认证方式：

   如果出现403 ,无法获取kubelet的数据，可在每个节点[包含master]的/etc/systemd/system/kubelet.service.d/10-kubeadm.conf中，KUBELET_AUTHZ_ARGS 新增 --authentication-token-webhook，[点击查看10-kube-adm.conf](10-kubeadm.conf)，之后重启服务即可：
    
    systemctl daemon-reload
    systemctl start kubelet