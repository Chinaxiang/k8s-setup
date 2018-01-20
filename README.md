# k8s集群部署

二进制压缩包：

https://pan.baidu.com/s/1hsZViQw

请按分支选择。

将会部署如下组件：

- etcd: 分布式存储服务，供k8s存储配置，版本:3.2.9
- flannel: （可选）虚拟网络服务，支撑容器网络，版本:0.9.0
- calico: （可选,默认）虚拟网络服务，支撑容器网络，版本:3.0
- docker: 容器服务，版本:docker-ce 17.03
- k8s: kubernetes核心组件，版本：1.18.3
	- kube-apiserver
	- kube-controller-manager
	- kube-scheduler
	- kubelet
	- kubectl
	- kube-proxy
- k8s-plugins: kubernetes核心插件
	- coredns
	- heapster
	- kubernetes-dashboard
	- traefik-ingress

## 环境准备

- 为各节点设置独立的IP，相同的网卡名称(flannel安装需要指定默认网卡名称)。
- 为各节点设置不同的hostname（可选，建议设置好记的hostname）.

hostname | ip | network
--- | --- | ---
k8s-11 | 10.211.55.11 | enp0s5
k8s-12 | 10.211.55.12 | enp0s5
k8s-14 | 10.211.55.14 | enp0s5

- 为各节点配置hosts, 增加如下配置：

```
10.211.55.11 k8s-11
10.211.55.12 k8s-12
10.211.55.14 k8s-14
```

- 生成TLS证书的机器需要无密码访问其余机器。
- 安装用户需要具有sudo权限。
- k8s-cli节点上root用户需要无密码访问其余机器的ansible_user, k8s-cli节点需要生产TLS证书并scp到所有节点。
- 需要禁用swap分区，k8s 1.8之后如果不禁用swap分区会导致kubelet启动失败。

配置hostname, hosts可以通过ansible脚本完成。其余的需要手动完成。

### 免密码登录

安装机器需配置免密码登录到k8s机器的指定用户。

```
# 生产密钥对
ssh-keygen -t rsa -P ''
# 将生成的公钥拷贝到远程用户目录下
ssh-copy-id -i ~/.ssh/id_rsa.pub panda@10.211.55.11
ssh-copy-id -i ~/.ssh/id_rsa.pub panda@10.211.55.12
ssh-copy-id -i ~/.ssh/id_rsa.pub panda@10.211.55.14
```

登录到k8s-cli机器，切换到root用户，配置root免密码登录到其它机器的panda用户。

```
# 生产密钥对
ssh-keygen -t rsa -P ''
# 将生成的公钥拷贝到远程用户目录下
ssh-copy-id -i ~/.ssh/id_rsa.pub panda@10.211.55.11
ssh-copy-id -i ~/.ssh/id_rsa.pub panda@10.211.55.14
```

### 安装ansible

本安装脚本需在mac, linux下运行，需要安装ansible.

ansible是基于Python的，安装ansible最好的方式是使用pip.

> Ubuntu 16.04

```
apt-get -y install python-pip
pip install pip  --upgrade -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install --no-cache-dir ansible -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```

> CentOS 7

```
yum -y install python-pip
pip install pip  --upgrade -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install --no-cache-dir ansible -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```

后面考虑提供ansible容器给大伙用。

## 安装架构

roles | hostname | ip | service
--- | --- | --- | ---
node | k8s-11 | 10.211.55.11 | etcd, flannel/calico, kubelet, kube-proxy
master, node | k8s-12 | 10.211.55.12 | etcd, kube-apiserver, kube-controller-manager, kube-scheduler, flannel/calico, kubelet, kube-proxy
node | k8s-14 | 10.211.55.14 | etcd, flannel/calico, kubelet, kube-proxy

## 安装

> 配置如下文件

- `config/hosts`: 主机目录及变量配置
- `config/config.yml`: 安装用到的变量配置
- `script/template/hosts`: 集群hosts配置

> 验证主机目录

在根目录执行：

```
./install.sh check
```

如果目标机器默认是python3，则执行：

```
./install.sh check3
```

如果都是 ping -> pong 则表示配置正常。

```
10.211.55.11 | SUCCESS => {
    "changed": false,
    "failed": false,
    "ping": "pong"
}
```

### 一键安装

执行

```
./install.sh
```

一键安装。

### 分步安装

执行







