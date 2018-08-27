可以先生成service,以及配置文件，再生成statefulset
PV：采用的是挂载本地HostPath的方式，即POD调度到哪个node，就在对应的node的相应目录创建对应文件夹并存储数据。
注意：
    如果kafka集群的每个broker都需要连接，集群内网是可以访问的，但是当外网访问时，由于kafka集群的模式，即通过连接的broker找到集群内的所有broker然后去连接，此时，如果另外两个broker没有外网IP，则此时集群无法外网访问，只能内网（k8s集群内网网段）。
