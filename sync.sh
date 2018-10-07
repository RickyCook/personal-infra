#!/bin/bash
THISDIR="$(cd "$(dirname "$0")"; pwd)"
rsync --archive "$THISDIR/root/" /

systemctl daemon-reload

for op in enable start; do
    systemctl $op nginx-proxy
    systemctl $op nginx-proxy-letsencrypt
done
