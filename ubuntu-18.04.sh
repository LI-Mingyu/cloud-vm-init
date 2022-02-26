#!/bin/bash

# 安装docker # ref: https://blog.csdn.net/boonya/article/details/83011074
function docker_install() {
    echo "检查Docker......"
    docker -v
    if [ $? -eq 0 ]; then
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

USERNAME=$(ls /home | awk '{print $1}' | sed -n '1p') # 取 /home 目录第一个文件夹名称
if [ "$USERNAME" = "" ]; then
    USERNAME="root"
fi
echo "The default user when first login:" $USERNAME

# 开发者环境
apt update
apt install -y build-essential git cmake

echo "" >> /etc/ssh/sshd_config # 给sshd_config配置文件的末尾增加一个换行，以防发生格式错误
echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 6" >> /etc/ssh/sshd_config
systemctl restart sshd

# zsh & oh-my-zsh
apt install -y zsh
if [ "$USERNAME" = "root" ]; then
    chsh -s /bin/zsh
else
    sed -in "/$USERNAME/{s/bash/zsh/}" /etc/passwd
fi
su - $USERNAME -c 'curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh'

# use zsh theme https://github.com/LI-Mingyu/lmy.zsh-theme/blob/master/lmy.zsh-theme
su - $USERNAME -c 'curl -Lo $HOME/.oh-my-zsh/themes/lmy.zsh-theme https://raw.githubusercontent.com/LI-Mingyu/lmy.zsh-theme/master/lmy.zsh-theme'
su - $USERNAME -c 'sed -i "s/^ZSH_THEME.*/ZSH_THEME=\"lmy\"/g" $HOME/.zshrc'
# enable autocompletion for docker cmd
su - $USERNAME -c 'sed -in "/^plugins.*/{s/)/ docker)/}" $HOME/.zshrc'



# kubectl & minkube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
apt install -y conntrack # Kubernetes 1.22.3 requires conntrack to be installed in root's path
su -c 'minikube start --driver=none' # 这一行用 su -c 而不是直接执行，主要是因为要在/root/目录下，留下.minikube和.kube文件夹
su - $USERNAME -c 'sed -in "/^plugins.*/{s/)/ kubectl)/}" $HOME/.zshrc' # enable autocompletion for kubectl cmd

sleep 30 #等待k8s就绪

# 若默认用户为非root用户，让其有通过kubectl命令行操作本地k8s单节点集群的权限
if [ "$USERNAME" != "root" ]; then
    cp -r /root/.kube /home/$USERNAME/
    chown -hR $USERNAME /home/$USERNAME/.kube
    cp -r /root/.minikube /home/$USERNAME/
    chown -hR $USERNAME /home/$USERNAME/.minikube
    sed -i "s/root/home\/$USERNAME/g" /home/$USERNAME/.kube/config
fi

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
su - $USERNAME -c 'helm repo add bitnami https://charts.bitnami.com/bitnami'
su - $USERNAME -c 'helm repo update'
su - $USERNAME -c 'sed -in "/^plugins.*/{s/)/ helm)/}" $HOME/.zshrc' # enable autocompletion for helm cmd

# go-dev
wget https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz
su - $USERNAME -c 'echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.zshrc'
su - $USERNAME -c 'sed -in "/^plugins.*/{s/)/ golang)/}" $HOME/.zshrc' # enable autocompletion for the go cmd

# mpi-dev
# TODO
