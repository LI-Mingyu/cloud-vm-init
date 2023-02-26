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

# 使用阿里云的docker镜像加速服务
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://srlt0lw8.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

# 配置 sshd 保持链接不断开
echo "" >> /etc/ssh/sshd_config # 给sshd_config配置文件的末尾增加一个换行，以防发生格式错误
echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 6" >> /etc/ssh/sshd_config
systemctl restart sshd

USERNAME=$(ls /home | awk '{print $1}' | sed -n '1p') # 取 /home 目录第一个文件夹名称
if [ "$USERNAME" = "" ]; then
    USERNAME="root"
fi
echo "The default user when first login:" $USERNAME

# 在默认用户的home目录下放一个实验用的dockerfile
su - $USERNAME -c 'echo "
FROM nginx:1.20-alpine-perl
RUN echo $(date -R) >> /usr/share/nginx/html/index.html
" > $HOME/dockerfile'
