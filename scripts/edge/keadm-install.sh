#!/bin/sh
set -xe

arch=amd64
version=1.15
install_dir=/usr/local/bin

temp_dir="$(mktemp --directory)"

cd "$temp_dir"

binary_url="https://github.com/kubeedge/kubeedge/releases/download/v$version/keadm-v$version-linux-$arch.tar.gz"
checksum_url="https://github.com/kubeedge/kubeedge/releases/download/v$version/checksum_keadm-v$version-linux-$arch.tar.gz.txt"

curl --location --remote-name "$binary_url"
tar -zxvf "keadm-v$version-linux-$arch.tar.gz"

curl --location --remote-name "$checksum_url"

sudo install --owner=root --group=root "keadm-v$version-linux-$arch/keadm/keadm" "$install_dir/keadm"
