# plugins

k8s相关插件。

## calico

calico-kube-controllers.

负责监听Network Policy的变化，并将Policy应用到相应的网络接口。

## coredns

kubernetes dns插件之一，部署简单，性能稳定快速。

## heapster

kubernetes 监控指标搜集器。

## kube-dns

与coredns类似，比coredns早，需要多个镜像，稍繁琐。

## kubernetes-dashboard

k8s ui 管理。

## traefik-ingress

k8s 负载均衡插件。