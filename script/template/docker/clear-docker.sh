#!/bin/bash

dockers=`df -Th | grep '/var/lib/docker' | awk '{print $7}'`

for docker in $dockers
do
  umount -f $docker
done

dockers=`cat /proc/mounts | grep 'docker' | awk '{print $2}'`

for docker in $dockers
do
  umount -f $docker
done