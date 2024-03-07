#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <user> <hostname>"
	exit 1
}

[ "$#" -lt 2 ] && usage

user="$1"
hostname="$2"
type=ed25519
file=~/.ssh/id_rsa
password=

set -xe

ssh-keygen -t "$type" -C "$user@$hostname" -f "$file" -N "$password"
sed -i '/'"$user"'@'"$hostname"'/d' ~/.ssh/authorized_keys
ssh-keygen -y -f "$file" | tee --append ~/.ssh/authorized_keys
