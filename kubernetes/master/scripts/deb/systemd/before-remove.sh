#!/bin/bash
        # Package removal, not upgrade
        systemctl --no-reload disable kube-apiserver kube-scheduler kube-controller-manager kubelet kube-proxy > /dev/null 2>&1 || :
        systemctl stop kube-apiserver kube-scheduler kube-controller-manager kubelet kube-proxy > /dev/null 2>&1 || :
