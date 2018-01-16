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

usage=$'Please read the README.md'
item=0

# check ansible
function check_ansible {
	if ! ansible-playbook --version &> /dev/null
	then
		error "Need to install ansible(2.4.x+) first and run this script again."
		exit 1
	fi
	
	# ansible has been installed and check its version
	if [[ $(ansible-playbook --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
	then
		ansible_version=${BASH_REMATCH[1]} # 2.4.1
		ansible_version_part1=${BASH_REMATCH[2]} # 2
		ansible_version_part2=${BASH_REMATCH[3]} # 4
		
        # the version of ansible_version does not meet the requirement
        if [ "$ansible_version_part1" -lt 2 ] || ([ "$ansible_version_part1" -eq 2 ] && [ "$ansible_version_part2" -lt 4 ])
        then
            error "Need to upgrade ansible_version package to 2.4.x+."
            exit 1
        else
            note "ansible version: $ansible_version"
        fi
	else
		error "Failed to parse ansible version."
		exit 1
	fi
}

# check
function check {
	h2 "Check Inventory Hosts";
	check_ansible
	ansible -i config/hosts all -m ping
}

# check python3
function check3 {
	h2 "Check Inventory Hosts Use python3";
	check_ansible
	ansible -i config/hosts all -m ping -e "ansible_python_interpreter=/usr/bin/python3"
}

while [ $# -gt 0 ]; do
    case $1 in
        --help)
        note "$usage"
        exit 0;;
        check)
        check
        exit 0;;
        check3)
        check3
        exit 0;; 					 	
        *)
        note "$usage"
        exit 1;;
    esac
    shift || true
done

note "This script will install components:
1.Install k8s cluster(eg. etcd, network(flannel or calico), kubernetes, docker)
2.Install CoreDNS or Kube-DNS plugin
3.Install Kubernetes Dashboard plugin
4.Install Heapster Monitor plugin
5.Install Traefik Ingress plugin"


h2 "[Step $item]: checking installation environment ..."; let item+=1
check_ansible
h2 "[Step $item]: prepare k8s cluster ..."; let item+=1
ansible-playbook -i config/hosts script/prepare-k8s.yml
h2 "[Step $item]: prepare tls files ..."; let item+=1
ansible-playbook -i config/hosts script/install-tls.yml
h2 "[Step $item]: install etcd cluster ..."; let item+=1
ansible-playbook -i config/hosts script/install-etcd.yml
h2 "[Step $item]: install flannel ..."; let item+=1
ansible-playbook -i config/hosts script/install-flanneld.yml
h2 "[Step $item]: install docker ..."; let item+=1
ansible-playbook -i config/hosts script/install-docker.yml
h2 "[Step $item]: install calico ..."; let item+=1
ansible-playbook -i config/hosts script/install-calico.yml
h2 "[Step $item]: install masters ..."; let item+=1
ansible-playbook -i config/hosts script/install-masters.yml
h2 "[Step $item]: install nodes ..."; let item+=1
ansible-playbook -i config/hosts script/install-nodes.yml

note "Begin install plugins."
h2 "[Step $item]: install calico controller ..."; let item+=1
ansible-playbook -i config/hosts plugins/calico/install-calico.yml
h2 "[Step $item]: install coredns ..."; let item+=1
ansible-playbook -i config/hosts plugins/coredns/install-coredns.yml
h2 "[Step $item]: install kube-dns ..."; let item+=1
ansible-playbook -i config/hosts plugins/kube-dns/install-kube-dns.yml
h2 "[Step $item]: install heapster monitor ..."; let item+=1
ansible-playbook -i config/hosts plugins/heapster/install-heapster.yml
h2 "[Step $item]: install kubernetes dashboard ..."; let item+=1
ansible-playbook -i config/hosts plugins/kubernetes-dashboard/install-kubernetes-dashboard.yml
h2 "[Step $item]: install traefik ingress ..."; let item+=1
ansible-playbook -i config/hosts plugins/traefik-ingress/install-traefik-ingress.yml

success "Install Finished."
