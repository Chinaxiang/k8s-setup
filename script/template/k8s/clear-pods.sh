#!/bin/bash

pods=`df -Th | grep '/var/lib/kubelet' | awk '{print $7}'`

for pod in $pods
do
  umount -f $pod
done