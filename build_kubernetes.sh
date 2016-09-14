#!/bin/bash

K8S_VERSION=${K8S_VERSION:-1.3.7}
REV=${REV:-1}

rm -rf kubernetes/source/kubernetes/v$K8S_VERSION
rm -f kubernetes/builds/kubernetes-master_$K8S_VERSION_amd64.deb
rm -f kubernetes/builds/kubernetes-node_$K8S_VERSION_amd64.deb

mkdir -p kubernetes/source/kubernetes/v$K8S_VERSION
mkdir -p kubernetes/downloads/v$K8S_VERSION

cd kubernetes/downloads/v$K8S_VERSION
if [[ -f kubernetes.tar.gz ]]; then
  echo "already have the download ..."
else
  wget https://github.com/kubernetes/kubernetes/releases/download/v$K8S_VERSION/kubernetes.tar.gz
fi

cd ../../source/kubernetes/v$K8S_VERSION
tar zxf ../../../../kubernetes/downloads/v$K8S_VERSION/kubernetes.tar.gz

tar xfvz kubernetes/server/kubernetes-server-linux-amd64.tar.gz
cd ../../../../

# systemd version
fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds \
-C ./kubernetes/master \
-v "$K8S_VERSION"-${REV} \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/master/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/master/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/master/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/master/scripts/deb/systemd/before-remove.sh \
--license "Apache Software License 2.0" \
--maintainer "yoti <noc@yoti.com>" \
--vendor "yoti ltd" \
--description "Kubernetes master binaries and services" \
--url "https://www.yoti.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/federation-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/federation-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-dns=/usr/bin/kube-dns \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubemark=/usr/bin/kubemark \
services/systemd/kube-apiserver.service=/lib/systemd/system/kube-apiserver.service \
services/systemd/kube-controller-manager.service=/lib/systemd/system/kube-controller-manager.service \
services/systemd/kube-scheduler.service=/lib/systemd/system/kube-scheduler.service \
etc/kubernetes/master/kubelet.conf \
etc/kubernetes/master/apiserver.conf \
etc/kubernetes/master/config.conf \
etc/kubernetes/master/controller-manager.conf \
etc/kubernetes/master/scheduler.conf \
etc/kubernetes/manifests

# post launch script for addons
# skydns enable
# Kubernetes installs do not configure the nodes' resolv.conf files to use the cluster DNS by default, because that process is inherently environment-specific.
# This should probably be implemented eventually.

#build_deb_node

# services
# deps etcd, docker (etcd.service, docker.service)
# kube-proxy.service
# kube-kubelet.service
# cadvisor.service?

# systemd version
fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds \
-C ./kubernetes/node \
-v "$K8S_VERSION"-${REV} \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/node/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/node/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/node/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/node/scripts/deb/systemd/before-remove.sh \
--config-files etc/kubernetes/node \
--license "Apache Software License 2.0" \
--maintainer "yoti <noc@yoti.com>" \
--vendor "yoti ltd" \
--description "Kubernetes node binaries and services" \
--url "https://www.yoti.com" \
etc/kubernetes/node/config.conf \
etc/kubernetes/node/kubelet.conf \
etc/kubernetes/node/proxy.conf \
services/systemd/kubelet.service=/lib/systemd/system/kubelet.service \
services/systemd/kube-proxy.service=/lib/systemd/system/kube-proxy.service \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests

