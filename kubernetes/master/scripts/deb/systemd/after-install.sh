#!/bin/bash

        chmod +x /usr/bin/kube-apiserver
        chmod +x /usr/bin/kube-scheduler
        chmod +x /usr/bin/kube-controller-manager
        chmod +x /usr/bin/kubelet

        chmod +x /usr/bin/kubectl
        chmod +x /usr/bin/hyperkube

        # Initial installation
        systemctl preset kube-apiserver kube-scheduler kube-controller-manager >/dev/null 2>&1 || :
