#!/bin/sh
set -xe

version=0.3.10
temp_dir="$(mktemp --directory)"
cd "$temp_dir"
curl -LO "https://github.com/Mirantis/cri-dockerd/releases/download/v$version/cri-dockerd-$version.amd64.tgz"
tar -xvzf "cri-dockerd-$version.amd64.tgz"
