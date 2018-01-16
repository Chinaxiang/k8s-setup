#!/bin/bash

set +e
set -o noglob

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#
# Headers and Logging
#
underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() { printf "${white}%s${reset}\n" "$@"
}
info() { printf "${white}➜ %s${reset}\n" "$@"
}
success() { printf "${green}✔ %s${reset}\n" "$@"
}
error() { printf "${red}✖ %s${reset}\n" "$@"
}
warn() { printf "${tan}➜ %s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
note() { printf "${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}
set -e
set +o noglob
item=0

note "Begin Uninstall."

h2 "[Step $item]: uninstall coredns ..."; let item+=1
ansible-playbook -i config/hosts plugins/coredns/delete-coredns.yml
h2 "[Step $item]: uninstall kube-dns ..."; let item+=1
ansible-playbook -i config/hosts plugins/kube-dns/delete-kube-dns.yml
h2 "[Step $item]: uninstall heapster monitor ..."; let item+=1
ansible-playbook -i config/hosts plugins/heapster/delete-heapster.yml
h2 "[Step $item]: uninstall kubernetes dashboard ..."; let item+=1
ansible-playbook -i config/hosts plugins/kubernetes-dashboard/delete-kubernetes-dashboard.yml
h2 "[Step $item]: uninstall traefik ingress ..."; let item+=1
ansible-playbook -i config/hosts plugins/traefik-ingress/delete-traefik-ingress.yml
h2 "[Step $item]: uninstall calico ..."; let item+=1
ansible-playbook -i config/hosts plugins/calico/delete-calico.yml

sleep 10s
h2 "[Step $item]: delete other pods ..."; let item+=1
ansible-playbook -i config/hosts script/delete.yml

note "waiting for clear pods."
sleep 60s

h2 "[Step $item]: uninstall nodes ..."; let item+=1
ansible-playbook -i config/hosts script/uninstall-nodes.yml
h2 "[Step $item]: uninstall masters ..."; let item+=1
ansible-playbook -i config/hosts script/uninstall-masters.yml
h2 "[Step $item]: uninstall etcd cluster ..."; let item+=1
ansible-playbook -i config/hosts script/uninstall-etcd.yml
h2 "[Step $item]: uninstall calico ..."; let item+=1
ansible-playbook -i config/hosts script/uninstall-calico.yml
h2 "[Step $item]: uninstall flannel ..."; let item+=1
ansible-playbook -i config/hosts script/uninstall-flanneld.yml
h2 "[Step $item]: uninstall docker ..."; let item+=1

tmp=0
if read -t 30 -p "Do you want to delete docker engine? 0 or 1: " tmp
then
  if [ "$tmp" == "1" ]; then
    h2 "Will delete docker engine."
    ansible-playbook -i config/hosts script/uninstall-docker.yml
  fi
else
  h2 "You don't select whether delete docker, we ignore it."
fi

success "Uninstall Finished."






