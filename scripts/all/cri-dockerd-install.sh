#!/bin/sh
set -xe

version=0.3.10
temp_dir="$(mktemp --directory)"
cd "$temp_dir"

set -x

curl --silent --location --remote-name "https://github.com/Mirantis/cri-dockerd/releases/download/v$version/cri-dockerd-$version.amd64.tgz"
tar -xvzf "cri-dockerd-$version.amd64.tgz"

cd cri-dockerd
sudo mkdir --parents /usr/local/bin
sudo install \
	--owner=root \
	--group=root \
	--mode=0755 \
	cri-dockerd /usr/local/bin/cri-dockerd
cd ..
rm -r cri-dockerd

git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
sudo install packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker.socket
