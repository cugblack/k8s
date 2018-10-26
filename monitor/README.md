k8s集群常用监控，主要有heapster和普罗米修斯，部署采用的镜像均为k8s.io官方镜像


heapster可获取节点以及pod资源占用，搭配官方自动伸缩 HPA，实现资源动态扩容。
