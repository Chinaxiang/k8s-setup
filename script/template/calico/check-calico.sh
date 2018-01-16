#!/bin/bash

calico_node=`docker ps | grep 'calico-node' | awk '{print $1}'`

echo "check-calico: $calico_node" > /tmp/check-calico.log
# calico_node为空
while [ -z "$calico_node" ]
do
  calico_node=`docker ps | grep 'calico-node' | awk '{print $1}'`
  echo "check-calico: $calico_node" >> /tmp/check-calico.log
  sleep 3s
done

echo $calico_node > /var/run/calico-node.pid