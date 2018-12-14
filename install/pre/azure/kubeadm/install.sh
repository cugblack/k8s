---

# 安装docker:master node都需要
---


apt-get remove docker-ce docker-engine docker.io

apt-get update

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-cache madison docker-ce

apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu 
systemctl enable docker
systemctl start docker


# 安装kubeadm kubelet kubectl: master node都需要


      apt-get update && apt-get install -y apt-transport-https curl
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
      cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
      deb https://apt.kubernetes.io/ kubernetes-xenial main
      EOF 
      apt-get update
      apt-get install -y kubelet kubeadm kubectl
      apt-mark hold kubelet kubeadm kubectl


# 初始化master节点

kubeadm init --pod-network-cidr=10.244.0.0/16

sysctl net.bridge.bridge-nf-call-iptables=1

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


export KUBECONFIG=/etc/kubernetes/admin.conf
 
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml


# 添加node节点：

在node节点执行master节点初始化生成的join命令：

kubeadm join 10.0.0.5:6443 --token ivlmam.ocbyel0u6et7cigg --discovery-token-ca-cert-hash sha256:8ec14516bbc76578c5226cae32cf11987807713eaf6be45982a4fbb9f2ff10f9
