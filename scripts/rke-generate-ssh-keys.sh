#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0")"
	exit 1
}

[ "$#" -ne 0 ] && usage

user="$(whoami)"
if [ -z "$user" ]
then
	echo "user is empty: $user" >&2
	exit 1
fi

hostname="$(hostname)"
if [ -z "$hostname" ]
then
	echo "hostname is empty: $hostname" >&2
	exit 1
fi

type=ed25519
file=~/.ssh/id_rsa
password=

set -xe

ssh-keygen -t "$type" -C "$user@$hostname" -f "$file" -N "$password"
sed -i '/'"$user"'@'"$hostname"'/d' ~/.ssh/authorized_keys
ssh-keygen -y -f "$file" | tee --append ~/.ssh/authorized_keys
