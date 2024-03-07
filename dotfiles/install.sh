#!/bin/sh
set -xe

usage() {
	echo "Usage: $(basename "$0") <master | worker>"
	exit 1
}

[ "$#" -lt 1 ] && usage

dotfiles_dir="$(dirname "$0")"

all() {
	find "$dotfiles_dir/all" -type f \
		| while read -r file
		do
			echo "$file!"
		done
}

master() {
	all
}

worker() {
	all
}

case "$1" in
	master) master ;;
	worker) worker ;;
	*)      usage  ;;
esac
