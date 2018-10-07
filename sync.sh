#!/bin/bash
THISDIR="$(cd "$(dirname "$0")"; pwd)"
rsync --archive "$THISDIR/root/" /

dnf -y install dnf-plugins-core
dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
dnf -y install docker-ce

systemctl daemon-reload

for op in enable start; do
    systemctl $op docker
    systemctl $op nginx-proxy
    systemctl $op nginx-proxy-letsencrypt
done
