if [ $1 -eq 0 ] ; then
        # Package removal, not upgrade
        systemctl --no-reload disable kubelet kube-proxy > /dev/null 2>&1 || :
        systemctl stop kubelet kube-proxy > /dev/null 2>&1 || :
fi