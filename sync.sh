#!/bin/bash
set -e

THISDIR="$(cd "$(dirname "$0")"; pwd)"

which jq >/dev/null || dnf -y install jq

mkdir -p "$THISDIR/files"
filescount=$(jq 'keys|length' "$THISDIR/files.json")
for n in $(seq 0 $(expr $filescount - 1)); do
    n_name="$(jq -r "keys[$n]" "$THISDIR/files.json")"
    n_url="$(jq -r ".[\"$n_name\"].url" "$THISDIR/files.json")"
    n_md5="$(jq -r ".[\"$n_name\"].md5" "$THISDIR/files.json")"
    n_path="$THISDIR/files/$n_name"

    if [[ ! -f "$n_path" ]] || ! (echo "$n_md5 $n_path" | md5sum --check); then
        curl --fail --output "$n_path" "$n_url"
        if ! echo "$n_md5 $n_path" | md5sum --check; then
            echo Failed to verify $n_name >&2
            exit 1
        fi
    fi
done

rsync --archive "$THISDIR/root/" /w

if ! which docker >/dev/null; then
    dnf -y install dnf-plugins-core
    dnf config-manager \
        --add-repo \
        https://download.docker.com/linux/fedora/docker-ce.repo
    dnf -y install docker-ce
fi

systemctl daemon-reload

for op in enable start; do
    systemctl $op docker
    systemctl $op nginx-proxy
    systemctl $op nginx-proxy-letsencrypt
    systemctl $op nextcloud-app
    systemctl $op nextcloud-web
done
