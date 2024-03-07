#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <mount | unmount> <local directory>"
	echo
	echo 'Then it will (un)mount all machines inside the <local directory>'
	exit 1
}

user=aida
master='master 10.3.1.150'
worker01='worker01 10.3.1.102'
worker02='worker02 10.3.1.194'
worker03='worker03 10.3.3.137'

check_directory() {
	local_directory="$(realpath "$1")"

	if [ ! -d "$local_directory" ]
	then
		echo "$local_directory is not a valid directory" >&2
		usage
	fi

	echo "$local_directory"
}

mount() {
	local_directory="$(check_directory "$1")"

	set -x

	for host in "$master" "$worker01" "$worker02" "$worker03"
	do
		hostname="$(echo "$host" | cut --delimiter=' ' --fields=1)"
		ip="$(echo "$host" | cut --delimiter=' ' --fields=2)"
		mkdir --parents "$hostname"
		sshfs -o 'compression=yes,reconnect' "$user@$ip:/home/$user" "$local_directory/$hostname"
	done
}

unmount() {
	local_directory="$(check_directory "$1")"

	set -x

	for host in "$master" "$worker01" "$worker02" "$worker03"
	do
		hostname="$(echo "$host" | cut --delimiter=' ' --fields=1)"
		fusermount3 -u "$local_directory/$hostname"
	done
}

[ "$#" -lt 2 ] && usage

set -x
case "$1" in
	mount)   mount   "$2" ;;
	unmount) unmount "$2" ;;
	*)       usage   ;;
esac
