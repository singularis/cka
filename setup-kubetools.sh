#!/bin/bash
# kubeadm installation instructions as on
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# this script supports centos 7 and Ubuntu 20.04 only
# run this script with sudo

if ! [ $USER = root ]
then
	echo run this script with sudo
	exit 3
fi

# setting MYOS variable
MYOS=$(hostnamectl | awk '/Operating/ { print $3 }')
OSVERSION=$(hostnamectl | awk '/Operating/ { print $4 }')

##### CentOS 7 config
if [ $MYOS = "CentOS" ]
then
	echo RUNNING CENTOS CONFIG
	sudo sh /home/vagrant/cka/eof.sh
	# Set SELinux in permissive mode (effectively disabling it)
	sudo setenforce 0
	sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

	# disable swap (assuming that the name is /dev/centos/swap
	sed -i 's/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/' /etc/fstab
	swapoff /dev/mapper/centos-swap

	sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

	sudo systemctl enable --now kubelet
fi


# Set iptables bridging
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
