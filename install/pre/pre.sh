#!/usr/bin/env bash

systemctl disable --now firewalld NetworkManager
setenforce 0
sed -ri '/^[^#]*SELINUX=/s#=.+$#=disabled#' /etc/selinux/config

swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab

yum install epel-release -y
yum install wget git  jq psmisc -y
yum update -y

module=(
  ip_vs
  ip_vs_lc
  ip_vs_wlc
  ip_vs_rr
  ip_vs_wrr
  ip_vs_lblc
  ip_vs_lblcr
  ip_vs_dh
  ip_vs_sh
  ip_vs_fo
  ip_vs_nq
  ip_vs_sed
  ip_vs_ftp
  )

for kernel_module in ${module[@]};do
    /sbin/modinfo -F filename $kernel_module |& grep -qv ERROR && echo $kernel_module >> /etc/modules-load.d/ipvs.conf || :
done

systemctl enable --now systemd-modules-load.service


declare -A MasterArray otherMaster NodeArray AllNode
MasterArray=(['m1']=192.168.2.128 ['m2']=192.168.2.130 ['m3']=192.168.2.129)
otherMaster=(['m2']=192.168.2.130 ['m3']=192.168.2.129)
NodeArray=(['n1']=192.168.2.131)
AllNode=(['m1']=192.168.2.128 ['m2']=192.168.2.130 ['m3']=192.168.2.129 ['n1']=192.168.2.131)

export         VIP=192.168.2.110
export INGRESS_VIP=192.168.2.109
[ "${#MasterArray[@]}" -eq 1 ]  && export VIP=${MasterArray[@]} || export API_PORT=8443
export KUBE_APISERVER=https://${VIP}:${API_PORT:-6443}

#声明需要安装的的k8s版本
export KUBE_VERSION=v1.11.3

# 网卡名
export interface=ens33

export K8S_DIR=/etc/kubernetes
export PKI_DIR=${K8S_DIR}/pki
export ETCD_SSL=/etc/etcd/ssl
export MANIFESTS_DIR=/etc/kubernetes/manifests/
# cni
export CNI_URL="https://github.com/containernetworking/plugins/releases/download"
export CNI_VERSION=v0.7.1
# cfssl
export CFSSL_URL="https://pkg.cfssl.org/R1.2"
# etcd
export ETCD_version=v3.3.9




#m1
git clone https://github.com/zhangguanzhang/k8s-manual-files.git ~/k8s-manual-files -b bin
cd ~/k8s-manual-files/
docker pull zhangguanzhang/k8s_bin:$KUBE_VERSION-full
docker run --rm -d --name temp zhangguanzhang/k8s_bin:$KUBE_VERSION-full sleep 10
docker cp temp:/kubernetes-server-linux-amd64.tar.gz .
tar -zxvf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

#分发master相关组件到其他master上(这边不想master跑pod的话就不复制kubelet和kube-proxy过去,以及后面master节点上的kubelet的相关操作)

for NODE in "${!otherMaster[@]}"; do
    echo "--- $NODE ${otherMaster[$NODE]} ---"
    scp /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} ${otherMaster[$NODE]}:/usr/local/bin/
done

for NODE in "${!NodeArray[@]}"; do
    echo "--- $NODE ${NodeArray[$NODE]} ---"
    scp /usr/local/bin/kube{let,-proxy} ${NodeArray[$NODE]}:/usr/local/bin/
done

mkdir -p /opt/cni/bin
wget  "${CNI_URL}/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz"
tar -zxf cni-plugins-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin

# 分发cni文件
for NODE in "${!otherMaster[@]}"; do
    echo "--- $NODE ${otherMaster[$NODE]} ---"
    ssh ${otherMaster[$NODE]} 'mkdir -p /opt/cni/bin'
    scp /opt/cni/bin/* ${otherMaster[$NODE]}:/opt/cni/bin/
done

for NODE in "${!NodeArray[@]}"; do
    echo "--- $NODE ${NodeArray[$NODE]} ---"
    ssh ${NodeArray[$NODE]} 'mkdir -p /opt/cni/bin'
    scp /opt/cni/bin/* ${NodeArray[$NODE]}:/opt/cni/bin/
done

#在k8s-m1需要安裝CFSSL工具,这将会用來建立 TLS Certificates
wget "${CFSSL_URL}/cfssl_linux-amd64" -O /usr/local/bin/cfssl
wget "${CFSSL_URL}/cfssljson_linux-amd64" -O /usr/local/bin/cfssljson
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

#etcd
cd ~/k8s-manual-files/pki
mkdir -p ${ETCD_SSL}

#从CSR json文件ca-config.json与etcd-ca-csr.json生成etcd的CA keys与Certificate：
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare ${ETCD_SSL}/etcd-ca

#生成Etcd证书：
cfssl gencert \
  -ca=${ETCD_SSL}/etcd-ca.pem \
  -ca-key=${ETCD_SSL}/etcd-ca-key.pem \
  -config=ca-config.json \
  -hostname=127.0.0.1,$(xargs -n1<<<${MasterArray[@]} | sort  | paste -d, -s -) \
  -profile=kubernetes \
  etcd-csr.json | cfssljson -bare ${ETCD_SSL}/etcd

rm -rf ${ETCD_SSL}/*.csr
ls $ETCD_SSL
#etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pem


wget https://github.com/etcd-io/etcd/releases/download/${ETCD_version}/etcd-${ETCD_version}-linux-amd64.tar.gz

tar -zxvf etcd-${ETCD_version}-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin etcd-${ETCD_version}-linux-amd64/etcd{,ctl}

for NODE in "${!otherMaster[@]}"; do
    echo "--- $NODE ${otherMaster[$NODE]} ---"
    scp /usr/local/bin/etcd* ${otherMaster[$NODE]}:/usr/local/bin/
done


#在k8s-m1上配置etcd配置文件并分发相关文件
#配置文件存放在/etc/etcd/etcd.config.yml里
#注入基础变量
cd ~/k8s-manual-files/master/
etcd_servers=$( xargs -n1<<<${MasterArray[@]} | sort | sed 's#^#https://#;s#$#:2379#;$s#\n##' | paste -d, -s - )
etcd_initial_cluster=$( for i in ${!MasterArray[@]};do  echo $i=https://${MasterArray[$i]}:2380; done | sort | paste -d, -s - )
sed -ri "/initial-cluster:/s#'.+'#'${etcd_initial_cluster}'#" etc/etcd/config.yml

#分发systemd和配置文件
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} "mkdir -p $MANIFESTS_DIR /etc/etcd /var/lib/etcd"
    scp systemd/etcd.service ${MasterArray[$NODE]}:/usr/lib/systemd/system/etcd.service
    scp etc/etcd/config.yml ${MasterArray[$NODE]}:/etc/etcd/etcd.config.yml
    ssh ${MasterArray[$NODE]} "sed -i "s/{HOSTNAME}/$NODE/g" /etc/etcd/etcd.config.yml"
    ssh ${MasterArray[$NODE]} "sed -i "s/{PUBLIC_IP}/${MasterArray[$NODE]}/g" /etc/etcd/etcd.config.yml"
    ssh ${MasterArray[$NODE]} 'systemctl daemon-reload'
done

#启动etcd
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} 'systemctl enable --now etcd' &
done
wait

#etcd健康检查
etcdctl \
   --cert-file /etc/etcd/ssl/etcd.pem \
   --key-file /etc/etcd/ssl/etcd-key.pem  \
   --ca-file /etc/etcd/ssl/etcd-ca.pem \
   --endpoints $etcd_servers cluster-health

#Kubernetes CA
#为确保安全，kubernetes 系统各组件需要使用 x509 证书对通信进行加密和认证。
#在k8s-m1建立pki文件夹,并生成根CA凭证用于签署其它的k8s证书。
mkdir -p ${PKI_DIR}
cd ~/k8s-manual-files/pki
cfssl gencert -initca ca-csr.json | cfssljson -bare ${PKI_DIR}/ca

#此凭证将被用于API Server和Kubelet Client通信使用,使用下面命令生成kube-apiserver凭证
cfssl gencert \
  -ca=${PKI_DIR}/ca.pem \
  -ca-key=${PKI_DIR}/ca-key.pem \
  -config=ca-config.json \
  -hostname=10.96.0.1,${VIP},127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,$(xargs -n1<<<${MasterArray[@]} | sort  | paste -d, -s -) \
  -profile=kubernetes \
  apiserver-csr.json | cfssljson -bare ${PKI_DIR}/apiserver


#此凭证将被用于Authenticating Proxy的功能上,而该功能主要是提供API Aggregation的认证。使用下面命令生成CA:
cfssl gencert \
  -initca front-proxy-ca-csr.json | cfssljson -bare ${PKI_DIR}/front-proxy-ca

#接着生成front-proxy-client凭证(hosts的warning忽略即可)：
cfssl gencert \
  -ca=${PKI_DIR}/front-proxy-ca.pem \
  -ca-key=${PKI_DIR}/front-proxy-ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  front-proxy-client-csr.json | cfssljson -bare ${PKI_DIR}/front-proxy-client

#通过以下命令生成 Controller Manager 凭证(hosts的warning忽略即可)：
cfssl gencert \
  -ca=${PKI_DIR}/ca.pem \
  -ca-key=${PKI_DIR}/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  manager-csr.json | cfssljson -bare ${PKI_DIR}/controller-manager

#用kubectl生成Controller Manager的kubeconfig文件
# controller-manager set cluster

kubectl config set-cluster kubernetes \
    --certificate-authority=${PKI_DIR}/ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=${K8S_DIR}/controller-manager.kubeconfig

# controller-manager set credentials

kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=${PKI_DIR}/controller-manager.pem \
    --client-key=${PKI_DIR}/controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=${K8S_DIR}/controller-manager.kubeconfig

# controller-manager set context

kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=${K8S_DIR}/controller-manager.kubeconfig

# controller-manager set default context

kubectl config use-context system:kube-controller-manager@kubernetes \
    --kubeconfig=${K8S_DIR}/controller-manager.kubeconfig

#通过以下命令生成 Scheduler 凭证(hosts的warning忽略即可)：
cfssl gencert \
  -ca=${PKI_DIR}/ca.pem \
  -ca-key=${PKI_DIR}/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  scheduler-csr.json | cfssljson -bare ${PKI_DIR}/scheduler

#利用kubectl生成Scheduler的kubeconfig文件：
kubectl config set-cluster kubernetes \
    --certificate-authority=${PKI_DIR}/ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=${K8S_DIR}/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
    --client-certificate=${PKI_DIR}/scheduler.pem \
    --client-key=${PKI_DIR}/scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=${K8S_DIR}/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-scheduler \
    --kubeconfig=${K8S_DIR}/scheduler.kubeconfig

#通过以下命令生成 Kubernetes Admin 凭证(hosts的warning忽略即可)：
cfssl gencert \
  -ca=${PKI_DIR}/ca.pem \
  -ca-key=${PKI_DIR}/ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare ${PKI_DIR}/admin

#利用kubectl生成 Admin 的kubeconfig文件
# admin set cluster
kubectl config set-cluster kubernetes \
    --certificate-authority=${PKI_DIR}/ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=${K8S_DIR}/admin.kubeconfig

# admin set credentials
kubectl config set-credentials kubernetes-admin \
    --client-certificate=${PKI_DIR}/admin.pem \
    --client-key=${PKI_DIR}/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=${K8S_DIR}/admin.kubeconfig

# admin set context
kubectl config set-context kubernetes-admin@kubernetes \
    --cluster=kubernetes \
    --user=kubernetes-admin \
    --kubeconfig=${K8S_DIR}/admin.kubeconfig

# admin set default context
kubectl config use-context kubernetes-admin@kubernetes \
    --kubeconfig=${K8S_DIR}/admin.kubeconfig

#首先在k8s-m1节点生成所有 master 节点的 kubelet 凭证,通过下面命令來生成：
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ---"
    \cp kubelet-csr.json kubelet-$NODE-csr.json;
    sed -i "s/\$NODE/$NODE/g" kubelet-$NODE-csr.json;
    cfssl gencert \
      -ca=${PKI_DIR}/ca.pem \
      -ca-key=${PKI_DIR}/ca-key.pem \
      -config=ca-config.json \
      -hostname=$NODE \
      -profile=kubernetes \
      kubelet-$NODE-csr.json | cfssljson -bare ${PKI_DIR}/kubelet-$NODE;
    rm -f kubelet-$NODE-csr.json
  done

for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} "mkdir -p ${PKI_DIR}"
    scp ${PKI_DIR}/ca.pem ${MasterArray[$NODE]}:${PKI_DIR}/ca.pem
    scp ${PKI_DIR}/kubelet-$NODE-key.pem ${MasterArray[$NODE]}:${PKI_DIR}/kubelet-key.pem
    scp ${PKI_DIR}/kubelet-$NODE.pem ${MasterArray[$NODE]}:${PKI_DIR}/kubelet.pem
    rm -f ${PKI_DIR}/kubelet-$NODE-key.pem ${PKI_DIR}/kubelet-$NODE.pem
done

#m1执行以下命令给所有master产生kubelet的kubeconfig文件：
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ---"
    ssh ${MasterArray[$NODE]} "cd ${PKI_DIR} && \
      kubectl config set-cluster kubernetes \
        --certificate-authority=${PKI_DIR}/ca.pem \
        --embed-certs=true \
        --server=${KUBE_APISERVER} \
        --kubeconfig=${K8S_DIR}/kubelet.kubeconfig && \
      kubectl config set-credentials system:node:${NODE} \
        --client-certificate=${PKI_DIR}/kubelet.pem \
        --client-key=${PKI_DIR}/kubelet-key.pem \
        --embed-certs=true \
        --kubeconfig=${K8S_DIR}/kubelet.kubeconfig && \
      kubectl config set-context system:node:${NODE}@kubernetes \
        --cluster=kubernetes \
        --user=system:node:${NODE} \
        --kubeconfig=${K8S_DIR}/kubelet.kubeconfig && \
      kubectl config use-context system:node:${NODE}@kubernetes \
        --kubeconfig=${K8S_DIR}/kubelet.kubeconfig"
done

#Kubernetes Controller Manager 利用 Key pair 生成与签署 Service Account 的 tokens,而这边不能通过 CA 做认证,而是建立一组公私钥来让 API Server 与 Controller Manager 使用
openssl genrsa -out ${PKI_DIR}/sa.key 2048
openssl rsa -in ${PKI_DIR}/sa.key -pubout -out ${PKI_DIR}/sa.pub
ls ${PKI_DIR}/sa.*
/etc/kubernetes/pki/sa.key  /etc/kubernetes/pki/sa.pub


#删除不必要的文件
rm -f ${PKI_DIR}/*.csr \
    ${PKI_DIR}/scheduler*.pem \
    ${PKI_DIR}/controller-manager*.pem \
    ${PKI_DIR}/admin*.pem \
    ${PKI_DIR}/kubelet*.pem


#复制文件
for NODE in "${!otherMaster[@]}"; do
    echo "--- $NODE ${otherMaster[$NODE]}---"
    for FILE in $(ls ${PKI_DIR}); do
      scp ${PKI_DIR}/${FILE} ${otherMaster[$NODE]}:${PKI_DIR}/${FILE}
    done
  done

for NODE in "${!otherMaster[@]}"; do
    echo "--- $NODE ${otherMaster[$NODE]}---"
    for FILE in admin.kubeconfig controller-manager.kubeconfig scheduler.kubeconfig; do
      scp ${K8S_DIR}/${FILE} ${otherMaster[$NODE]}:${K8S_DIR}/${FILE}
    done
  done


#安装haproxy[所有master]

for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} 'yum install haproxy keepalived -y' &
done
wait
#修改配置文件
cd ~/k8s-manual-files/master/etc

sed -i '$r '<(paste <( seq -f'  server k8s-api-%g'  ${#MasterArray[@]} ) <( xargs -n1<<<${MasterArray[@]} | sort | sed 's#$#:6443  check#')) haproxy/haproxy.cfg
sed -ri "s#\{\{ VIP \}\}#${VIP}#" keepalived/*
sed -ri "s#\{\{ interface \}\}#${interface}#" keepalived/keepalived.conf
sed -i '/unicast_peer/r '<(xargs -n1<<<${MasterArray[@]} | sort | sed 's#^#\t#') keepalived/keepalived.conf

for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    scp -r haproxy/ ${MasterArray[$NODE]}:/etc
    scp -r keepalived/ ${MasterArray[$NODE]}:/etc
    ssh ${MasterArray[$NODE]} 'systemctl enable --now haproxy keepalived'
done

#ping下vip看看能通否,先等待大概四五秒等keepalived和haproxy起来

ping $VIP


cd ~/k8s-manual-files/master/
etcd_servers=$( xargs -n1<<<${MasterArray[@]} | sort | sed 's#^#https://#;s#$#:2379#;$s#\n##' | paste -d, -s - )
sed -ri '/--advertise-address/s#=.+#='"$VIP"' \\#' systemd/kube-apiserver.service
sed -ri '/--etcd-servers/s#=.+#='"$etcd_servers"' \\#' systemd/kube-apiserver.service

ENCRYPT_SECRET=$( head -c 32 /dev/urandom | base64 )
sed -ri "/secret:/s#(: ).+#\1${ENCRYPT_SECRET}#" encryption/config.yml

# 分发文件(不想master跑pod的话就不复制kubelet的配置文件)
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} "mkdir -p $MANIFESTS_DIR /etc/systemd/system/kubelet.service.d /var/lib/kubelet /var/log/kubernetes"
    scp systemd/kube-*.service ${MasterArray[$NODE]}:/usr/lib/systemd/system/

    scp encryption/config.yml ${MasterArray[$NODE]}:/etc/kubernetes/encryption.yml
    scp audit/policy.yml ${MasterArray[$NODE]}:/etc/kubernetes/audit-policy.yml

    scp systemd/kubelet.service ${MasterArray[$NODE]}:/lib/systemd/system/kubelet.service
    scp systemd/10-kubelet.conf ${MasterArray[$NODE]}:/etc/systemd/system/kubelet.service.d/10-kubelet.conf
    scp etc/kubelet/kubelet-conf.yml ${MasterArray[$NODE]}:/etc/kubernetes/kubelet-conf.yml
done

#在k8s-m1上给所有master机器启动kubelet 服务并设置kubectl补全脚本:
for NODE in "${!MasterArray[@]}"; do
    echo "--- $NODE ${MasterArray[$NODE]} ---"
    ssh ${MasterArray[$NODE]} 'systemctl enable --now kubelet kube-apiserver kube-controller-manager kube-scheduler;
    cp /etc/kubernetes/admin.kubeconfig ~/.kube/config;
    kubectl completion bash > /etc/bash_completion.d/kubectl'
done



