# k8s集群部署

二进制压缩包：

https://pan.baidu.com/s/1hsZViQw

请按分支选择，将压缩包解压到`sbin`目录下。

需要使用到的谷歌镜像也可以到使用这位好心人提供的谷歌镜像：

https://hub.docker.com/r/mirrorgooglecontainers/kubernetes-dashboard-amd64/tags/

将会部署如下组件：

- etcd
- calico
- docker
- k8s: kubernetes核心组件，版本：1.9.4
	- kube-apiserver
	- kube-controller-manager
	- kube-scheduler
	- kubelet
	- kubectl
	- kube-proxy
- k8s-plugins: kubernetes核心插件
  - calico
  - coredns
  - heapster
  - kubernetes-dashboard
  - traefik-ingress

## 环境准备

- 为各节点设置独立的IP，相同的网卡名称(flannel安装需要指定默认网卡名称)。
- 为各节点设置不同的hostname（可选，建议设置好记的hostname）.
- 安装用户需要具有sudo权限。
- k8s-cli节点上root用户需要无密码访问其余机器的ansible_user, k8s-cli节点需要生成TLS证书并scp到所有节点。
- 需要禁用swap分区，k8s 1.8之后如果不禁用swap分区会导致kubelet启动失败（安装时会自动执行`swapoff -a`）。
### 免密码登录

安装机器需配置免密码登录到k8s机器的指定用户。

```
# 生产密钥对
ssh-keygen -t rsa -P ''
# 将生成的公钥拷贝到远程用户目录下
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible_user@remote_ip
```

登录到k8s-cli机器，切换到root用户，配置root免密码登录到其它机器的ansible_user用户。

```
# 生产密钥对
ssh-keygen -t rsa -P ''
# 将生成的公钥拷贝到远程用户目录下
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible_user@other_host_ip
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

## 安装

> 配置如下文件

- `config/hosts`: 主机目录及变量配置
- `config/config.yml`: 安装用到的变量配置

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

一键安装。如果遇到问题，请尝试分步安装。

### 分步安装

提取`install.sh`中的安装步骤即可。

```
ansible-playbook -i config/hosts script/prepare-k8s.yml
ansible-playbook -i config/hosts script/install-tls.yml
ansible-playbook -i config/hosts script/install-etcd.yml
ansible-playbook -i config/hosts script/install-flanneld.yml
ansible-playbook -i config/hosts script/install-docker.yml
ansible-playbook -i config/hosts script/install-calico.yml
ansible-playbook -i config/hosts script/install-masters.yml
ansible-playbook -i config/hosts script/install-nodes.yml
ansible-playbook -i config/hosts plugins/calico/install-calico.yml
ansible-playbook -i config/hosts plugins/coredns/install-coredns.yml
ansible-playbook -i config/hosts plugins/kube-dns/install-kube-dns.yml
ansible-playbook -i config/hosts plugins/heapster/install-heapster.yml
ansible-playbook -i config/hosts plugins/kubernetes-dashboard/install-kubernetes-dashboard.yml
ansible-playbook -i config/hosts plugins/traefik-ingress/install-traefik-ingress.yml
```







