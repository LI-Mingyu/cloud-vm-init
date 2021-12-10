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
apt update
apt install -y build-essential git cmake 

echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 6" >> /etc/ssh/sshd_config
systemctl restart sshd
