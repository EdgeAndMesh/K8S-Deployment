#!/bin/sh
set -e

arch=rke_linux-amd64
version=1.4.15
url_binary="https://github.com/rancher/rke/releases/download/v$version/$arch"
url_sha256="https://github.com/rancher/rke/releases/download/v$version/sha256sum.txt"
file=/usr/local/bin/rke

set -xe
sudo curl --location --silent --output "$file" "$url_binary"
curl --location --silent "$url_sha256" \
	| awk '/'"$arch"'/ { print $1 "  '"$file"'" }' \
	| sha256sum --check \
	|| sudo rm "$file"
