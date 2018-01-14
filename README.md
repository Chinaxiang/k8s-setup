# k8s集群部署

将会部署如下组件：

- etcd: 分布式存储服务，供k8s存储配置，版本:3.2.9
- flannel: （可选）虚拟网络服务，支撑容器网络，版本:0.9.0
- calico: （可选）虚拟网络服务，支撑容器网络，版本:3.0
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

- 为各节点设置独立的IP，相同的网卡名称。
- 为各节点设置不同的hostname.

hostname | ip | network
--- | --- | ---
k8s-11 | 10.211.55.11 | ens32
k8s-12 | 10.211.55.12 | ens32
k8s-14 | 10.211.55.14 | ens32

- 确保各节点可以通过apt-get安装相关的依赖包，如conntrack.
- 为各节点配置hosts, 增加如下配置：

```
10.211.55.11 k8s-11
10.211.55.12 k8s-12
10.211.55.14 k8s-14
```

- 生成TLS证书的机器需要无密码访问其余机器。
- 安装用户需要具有sudo权限。
- k8s-cli节点上root用户需要无密码访问其余机器的ansible_user, k8s-cli节点需要生产TLS证书并scp到所有节点。
- 需要禁用swap。

配置hostname, hosts, 安装conntrack可以通过ansible脚本完成。其余的需要手动完成。

## 安装架构

roles | hostname | ip | service
--- | --- | --- | ---
node | k8s-11 | 10.211.55.11 | etcd, flannel/calico, kubelet, kube-proxy
master, node | k8s-12 | 10.211.55.12 | etcd, kube-apiserver, kube-controller-manager, kube-scheduler, flannel/calico, kubelet, kube-proxy
node | k8s-14 | 10.211.55.14 | etcd, flannel/calico, kubelet, kube-proxy, nginx

nginx是用来提供dashboard访问使用。

## 安装

配置完无密码登录，确认各节点可以访问网络，下面就可以开始安装了。

> 配置如下文件

- `config/hosts`: 主机目录及变量配置
- `config/config.yml`: 安装用到的变量配置
- `script/template/hosts`: 集群hosts配置

> 验证主机目录

在根目录执行：

```
./install.sh check
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





