#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <master machine>"
	echo
	echo "Example: $(basename "$0") aida@10.3.1.150"
	exit 1
}

[ "$#" -lt 1 ] && usage

user="$(whoami)"
if [ -z "$user" ]
then
	echo "user is empty: $user" >&2
	usage
fi

hostname="$(hostname)"
if [ -z "$hostname" ]
then
	echo "hostname is empty: $hostname" >&2
	usage
fi

type=ed25519
ssh_file=~/.ssh/id_rsa
password=
master_machine="$1"
if [ -z "$master_machine" ]
then
	echo "master_machine is empty: $master_machine" >&2
	usage
fi

set -xe

ssh-keygen -t "$type" -C "$user@$hostname" -f "$ssh_file" -N "$password"
sed -i '/'"$user"'@'"$hostname"'/d' ~/.ssh/authorized_keys
ssh-keygen -y -f "$ssh_file" | tee --append ~/.ssh/authorized_keys
scp "$ssh_file" "$user@$hostname:~/.ssh/$hostname"
