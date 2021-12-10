#!/bin/bash

# 安装docker 
function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
    	echo "安装docker环境..."
        curl -sSL https://get.daocloud.io/docker | sh
        echo "安装docker环境...安装完成!"
    fi
    # 创建公用网络==bridge模式
    #docker network create share_network
}
 
# 执行函数
docker_install

# 开发者环境
yum update -y && yum install -y build-essential git cmake 

echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 6" >> /etc/ssh/sshd_config
systemctl restart sshd

# zsh
yum update -y && yum install -y zsh
chsh -s /bin/zsh
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# kubectl & minkube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl 
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
su -c 'install minikube-linux-amd64 /usr/local/bin/minikube'
yum update -y && yum install -y conntrack # Kubernetes 1.22.3 requires conntrack to be installed in root's path
su -c 'minikube start --driver=none'

# helm & kubevela
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
su -c 'helm repo add kubevela https://charts.kubevela.net/core'
su -c 'helm repo update'
su -c 'helm install --create-namespace -n vela-system kubevela kubevela/vela-core --set multicluster.enabled=true --wait'
su -c 'helm test kubevela -n vela-system'

# mpi-dev

# TODO
