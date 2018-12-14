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

kubeadm init --pod-network-cidr=10.244.0.0/16

sysctl net.bridge.bridge-nf-call-iptables=1

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


export KUBECONFIG=/etc/kubernetes/admin.conf
 
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
