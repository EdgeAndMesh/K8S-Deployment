#!/bin/sh
set -xe

arch="${KEADM_ARCH:-amd64}"
version=${KEADM_VERSION:-1.12.1}
install_dir=/usr/local/bin

temp_dir="$(mktemp --directory)"

cd "$temp_dir"

archive_url="https://github.com/kubeedge/kubeedge/releases/download/v$version/keadm-v$version-linux-$arch.tar.gz"
checksum_url="https://github.com/kubeedge/kubeedge/releases/download/v$version/checksum_keadm-v$version-linux-$arch.tar.gz.txt"

curl --location --remote-name "$archive_url"
curl --location --remote-name "$checksum_url"

if ! awk '{print $0 " keadm-v'"$version"'-linux-'"$arch"'.tar.gz"}' "checksum_keadm-v$version-linux-$arch.tar.gz.txt" | sha512sum --check
then
	cd
	rm -rdf "$temp_dir"
	exit 1
fi

tar -zxvf "keadm-v$version-linux-$arch.tar.gz"

sudo install --owner=root --group=root "keadm-v$version-linux-$arch/keadm/keadm" "$install_dir/keadm"
